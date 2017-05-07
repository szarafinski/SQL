
-- Autor: Krzysztof Szarafiński
-- nr albumu: 155441
-- Data: 12.01.2017

set serveroutput on
/* Procedua 1:
nadaje odpowiednie statusy dla kazdego zamowienia w zaleznosci od dokonanej platnosci oraz dnia odbioru:
1 - automatycznie jest nadawane dla zarejestrowanych zamowien
2 - jest nadawane dla zamowien ktore zostaly oplacone
3 - jest nadawane dla zamoien ktore zostaly oplacone oraz data odbioru juz przypadla (status do odbioru)
4 - jezeli zamowienie jest do odbioru, ale nei zostalo odebrane i minely 2 miesiace od daty odbioru to uznaje sie je jako nie odebrane
*/
create or replace procedure zmien_statusy_zamowienia is
cursor zamowienia is select z.id as numer, z.data_odbioru as odbior, z.status_zamowienia_id as status from zamowienie z 
    where z.status_zamowienia_id not in (5) for update;
begin
    for rekord in zamowienia loop
      if (czy_oplacone_zamowienie(rekord.numer)) then
        -- nadanie zamowieniu statusu "oplacone" jezeli data odbioru jeszcze nie minela
        update zamowienie set status_zamowienia_id = 2 where current of zamowienia;
          -- nadanie zamowieniu statusu "gotowe do odbioru" jezeli jest oplacone oraz data odbioru juz minela
        if rekord.odbior <= sysdate then
          update zamowienie set status_zamowienia_id = 3 where current of zamowienia;
        end if;
      end if;
    end loop;
    
    for rekord in zamowienia loop
      -- nadanie zamowienia statusu "nieodebrane" jezeli jest gotowe to odbioru i minely juz 2 miesiace od daty odbioru
      if (rekord.status = 3) and (add_months(rekord.odbior,2) <= sysdate) then
         update zamowienie set status_zamowienia_id = 4 where current of zamowienia;
      end if;
    end loop;
end;
/

create or replace view zamowienia_i_platnosci as 
select jeden.id as nr_zamowienia, 
cena_zamowienia(jeden.id) as cena, 
dwa.platnosc as platnosc, 
(cena_zamowienia(jeden.id)-dwa.platnosc) as do_zaplaty,
s.NAZWA as status
from  
  (select z.id as id, z.data_zawarcia as zawarcie, z.data_odbioru as odbior, z.status_zamowienia_id as status 
    from zamowienie z where z.status_zamowienia_id not in (5)) jeden 
full outer join 
  (SELECT SUM(platnosc.kwota) as platnosc, zamowienie.id as id
  FROM  platnosc INNER JOIN zamowienie ON  zamowienie.id = platnosc.zamowienie_id 
  GROUP BY zamowienie.id) dwa
on jeden.id = dwa.id, status_zamowienia s where s.ID=jeden.status order by nr_zamowienia, do_zaplaty ;
/
-- sprawdzenie
select * from zamowienia_i_platnosci;
exec zmien_statusy_zamowienia;
select * from zamowienia_i_platnosci;

/* Funkcja 2
nadaje odpowiednie statusy dla wniesionych platnosci:
1 - kazda zarejesrowana platnosc ma naday status "zaksiegowane"
jezeli jest nadplata to osatnia wplata ktora spowoowala nadplate otrzymuje status nr 2 "nadplata". w opisie sie pojawia kwota o nadplacie
doawany jest rekord z kwota jemna i przypisanem statusem nr 3 do zwrotu. w uwagach dodatkwoych jest informacja o kwocie nadplaty
*/

create or replace procedure zmien_statusy_platnosci as
cursor oplacone_zamowienia is select DISTINCT platnosc.zamowienie_id as zamowienie  from platnosc order by zamowienie;
begin
for rekord in oplacone_zamowienia loop
  if czy_oplacone_zamowienie(rekord.zamowienie) then
    declare
      cursor oplaty_zamowienia is 
        select platnosc.kwota as kwota, platnosc.klient_id as klient, platnosc.id as id, platnosc.RODZAJ_PLATNOSCI_ID as rodzaj
        from platnosc where platnosc.zamowienie_id = rekord.zamowienie for update;
      suma PLATNOSC.KWOTA%type :=0;
      cena_z PLATNOSC.KWOTA%type :=0;
      temp platnosc.kwota%type:=0;
    begin 
      select cena_zamowienia(rekord.zamowienie) into cena_z from dual;
      for oplata in oplaty_zamowienia loop
        temp := suma;
        suma := suma + oplata.kwota;
        if suma = cena_z then
          update platnosc set uwagi_dodatkowe = ('Ta wplata jest ostatnia wymagana. Dziekujemy') where current of oplaty_zamowienia;
        elsif suma > cena_z then
         --update platnosc set status_platnosci_id = 2 where current of oplaty_zamowienia;
          update platnosc set uwagi_dodatkowe = ('Ta wplata jest za wysoka o kwote: ' || (suma - cena_z) ) where current of oplaty_zamowienia;
          update platnosc set kwota = (cena_z-temp) where current of oplaty_zamowienia;
          insert into platnosc (DATA_DOKONANIA, KWOTA, UWAGI_DODATKOWE, STATUS_PLATNOSCI_ID, RODZAJ_PLATNOSCI_ID, KLIENT_ID, ZAMOWIENIE_ID) 
            values (sysdate,(suma-cena_z),('Kwota nadplacona: ' ||(suma-cena_z)|| ' dotyczy platnosci nr: ' || oplata.id), 
                    2,oplata.rodzaj,oplata.klient, rekord.zamowienie);
          insert into platnosc (DATA_DOKONANIA, KWOTA, UWAGI_DODATKOWE, STATUS_PLATNOSCI_ID, RODZAJ_PLATNOSCI_ID, KLIENT_ID, ZAMOWIENIE_ID) 
            values (sysdate,(cena_z-suma),('Kwota nadplacona, do zwrotu: ' ||(suma-cena_z)|| ' dotyczy platnosci nr: ' || oplata.id), 
                    3,4,oplata.klient, rekord.zamowienie);
          suma := cena_z;
        end if;
      end loop;
    end;  
  end if;
end loop;
end;
/

create or replace view wyciag_z_konta as
select  p.zamowienie_id as nr_zamowienia, p.id as nr_platnosci, s.nazwa as status_oplaty, p.uwagi_dodatkowe as opis,
cena_zamowienia(p.zamowienie_id) as cena_zamowieni, p.kwota as kwota
from 
platnosc p, STATUS_PLATNOSCI s where s.id = p.STATUS_PLATNOSCI_ID order by nr_zamowienia, nr_platnosci;
/

-- sprawdzenie
select * from wyciag_z_konta;
exec zmien_statusy_platnosci;
select * from wyciag_z_konta;

/* Procedura 3
w zaleznosci od podanego parametru zmienia pensje pracownika w zaleznosci od jego efektywnosci.
parametr wskazuje jak duza powinna byc efektywnosc pracownika by zwiekszyc jego wynagrodzenie o 5%
*/

create or replace procedure zmien_wynagrodzenie(numer number) is
pensja SPRZEDAWCA.PENSJA%type := 0;
cursor pracownicy is select sprzedawca.id as id, sprzedawca.pensja as pensja from sprzedawca for update;
begin
for rekord in pracownicy loop
  if (efektywnosc_pracownika(rekord.id) > numer) then 
    update sprzedawca set pensja = round((rekord.pensja * 1.05),2) where current of pracownicy;
  end if;
end loop;
end;
/

-- sprawdzenie
create or replace view pracownicy as select p.imie,p.nazwisko, s.nazwa, p.PENSJA, efektywnosc_pracownika(p.id) as efektywnosc 
from SPRZEDAWCA p, stanowisko s where p.stanowisko_id = s.id;
/
select * from pracownicy;
exec zmien_wynagrodzenie(1);
select * from pracownicy;


/*Procedura 4
generuje format maila ktory powinien wyslac pracownik do kupujacego by odebral swoje zamowienie
*/
create or replace procedure wyslij_mail is
mail klient.email%type;
czy_poczta boolean := true;
dane_klienta klient%rowtype;
adres_klienta adres%rowtype;
pracownik sprzedawca%rowtype;
cursor nieodebrane is select z.ID ,z.NR_UMOWY ,z.DATA_ZAWARCIA ,z.DATA_ODBIORU ,z.KLIENT_ID ,z.SPRZEDAWCA_ID ,z.STATUS_ZAMOWIENIA_ID ,z.UBEZPIECZENIE_ID
from zamowienie z where z.status_zamowienia_id = 4;
begin
  for rekord in nieodebrane loop
select k.id, k.plec, k.imie, k.nazwisko, k.email, k.adres_id into dane_klienta  from klient k, zamowienie where k.id = zamowienie.klient_id and zamowienie.id = rekord.id;
select ID ,ULICA ,MIASTO ,NR_DOMU ,NR_MIESZKANIA  into adres_klienta from adres where adres.id = dane_klienta.id;
select s.ID ,s.IMIE ,s.NAZWISKO ,s.EMAIL ,s.ODDZIAL_ID ,s.STANOWISKO_ID ,s.PENSJA  into pracownik from sprzedawca s where s.id = rekord.sprzedawca_id;
    begin
      mail := dane_klienta.email;
      czy_poczta := false;
    EXCEPTION
          WHEN no_data_found THEN
            czy_poczta := true;
    end;
      -- kiedy klient nie ma maila to zostanie wyslany mu list polecony na adres zamieszkania 
    if (czy_poczta) then
      if (lower(dane_klienta.plec)='k') then
        dbms_output.put_line('*************************');
        dbms_output.put_line('Pani ' || dane_klienta.imie || ' ' || dane_klienta.nazwisko || ',' );
        dbms_output.put_line('ul. ' || adres_klienta.ulica || ' ' || adres_klienta.nr_domu || ' ' || nvl(adres_klienta.nr_mieszkania,''));
        dbms_output.put_line( adres_klienta.miasto);
        dbms_output.put_line(' ');
        dbms_output.put_line('Zwracam sie z prosba by odebrac swoje zamowienie zawarte w oparciu o umowe nr ' || rekord.nr_umowy || ' z dnia ' || 
        to_char(rekord.data_zawarcia, 'DD-MM-YYYY') || '.');
        dbms_output.put_line(' ');
        dbms_output.put_line('z wyrazami szacunku,');
        dbms_output.put_line(pracownik.imie || ' ' || pracownik.nazwisko);
        dbms_output.put_line('*************************');
        dbms_output.put_line('');
      else 
        dbms_output.put_line('*************************');
        dbms_output.put_line('Pan ' || dane_klienta.imie || ' ' || dane_klienta.nazwisko || ',' );
        dbms_output.put_line('ul. ' || adres_klienta.ulica || ' ' || adres_klienta.nr_domu || ' ' || nvl(adres_klienta.nr_mieszkania,''));
        dbms_output.put_line( adres_klienta.miasto);
        dbms_output.put_line('Zwracam sie z prosba by odebrac swoje zamowienie zawarte w oparciu o umowe nr ' || rekord.nr_umowy || ' z dnia ' || 
        to_char(rekord.data_zawarcia, 'DD-MM-YYYY') || '.');
        dbms_output.put_line(' ');
        dbms_output.put_line('z wyrazami szacunku,');
        dbms_output.put_line(pracownik.imie || ' ' || pracownik.nazwisko);
        dbms_output.put_line('*************************');
        dbms_output.put_line('');
      end if;
    else
      if (lower(dane_klienta.plec)='k') then
        dbms_output.put_line('*************************');
        dbms_output.put_line('OD: ' || pracownik.email);
        dbms_output.put_line('DO: ' || dane_klienta.email);
        dbms_output.put_line('Pani ' || dane_klienta.imie || ' ' || dane_klienta.nazwisko || ',' );
        dbms_output.put_line('Zwracam sie z prosba by odebrac swoje zamowienie zawarte w oparciu o umowe nr ' || rekord.nr_umowy || ' z dnia ' || 
        to_char(rekord.data_zawarcia, 'DD-MM-YYYY') || '.');
        dbms_output.put_line(' ');
        dbms_output.put_line('z wyrazami szacunku,');
        dbms_output.put_line(pracownik.imie || ' ' || pracownik.nazwisko);
        dbms_output.put_line('*************************');
        dbms_output.put_line('');
      else 
        dbms_output.put_line('*************************');
        dbms_output.put_line('OD: ' || pracownik.email);
        dbms_output.put_line('DO: ' || dane_klienta.email);
        dbms_output.put_line('Pan ' || dane_klienta.imie || ' ' || dane_klienta.nazwisko || ',' );
        dbms_output.put_line('Zwracam sie z prosba by odebrac swoje zamowienie zawarte w oparciu o umowe nr ' || rekord.nr_umowy || ' z dnia ' || 
        to_char(rekord.data_zawarcia, 'DD-MM-YYYY') || '.');
        dbms_output.put_line(' ');
        dbms_output.put_line('z wyrazami szacunku,');
        dbms_output.put_line(pracownik.imie || ' ' || pracownik.nazwisko);
        dbms_output.put_line('*************************');
        dbms_output.put_line('');
      end if;
    end if;
  end loop;
end;
/

-- sprawdzenie
exec wyslij_mail;

/* Procedura 5:
w przypadku podpisania aneksu do umowy zmieniajacego samochod jaki ma byc objety umowa, procedura dokonuje zmiany przypisania numeru zamowienia
do odpowiedniego samochodu. jako argument podaje sie numer zamowienia oraz nr katalogowy samochodu (ID samochodu) jaki ma byc uwzgledniony w zamowieniu
*/
create or replace procedure aneks(nr_zamowienia number, nr_auta number) is
pojazd number;
cursor zamowione_auta is select s.zamowienie_id from samochod s where s.ZAMOWIENIE_ID = nr_zamowienia for update;
umowa zamowienie.nr_umowy%type;
begin
select z.nr_umowy into umowa from zamowienie z where z.id = nr_zamowienia;
select nvl(s.ZAMOWIENIE_ID,0)  into pojazd from samochod s where s.id = nr_auta;
-- sprawdzamy czy wyrane auto jest dostepne
  if (pojazd = 0) then
    -- jezeli jest dostepne to zerujemy wszystkie zamowione samochody w danym zamowieniu
    for zamowienie in zamowione_auta loop
      update samochod set zamowienie_id = null where current of zamowione_auta;
    end loop;
    -- dodajemy wybrany samochod do zamowienia
    update samochod set zamowienie_id = nr_zamowienia where id = nr_auta;
    update zamowienie set nr_umowy = (umowa || '/a') where id = nr_zamowienia;
  else
    RAISE_APPLICATION_ERROR(-20000, 'Wybrany samochod: ' || nr_auta || ' jest juz przypisany do zamowienia: ' || pojazd || '.');
  end if;
end;
/
-- sprawdzenie
exec aneks(15,30);
