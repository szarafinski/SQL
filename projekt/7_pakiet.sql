
-- Autor: Krzysztof Szarafiñski
-- nr albumu: 155441
-- Data: 12.01.2017

set serveroutput on

create or replace package pakiecik is
-- funkcje
function cena_samochodu(numer int) return number;
function upust_zamowienia(numer int) return number;
FUNCTION cena_zamowienia (  numer   INT ) RETURN NUMBER;
function czy_oplacone_zamowienie (numer int) return boolean ;
function efektywnosc_pracownika(numer int) return number ;

-- procedury
procedure zmien_statusy_zamowienia;
procedure zmien_statusy_platnosci;
procedure zmien_wynagrodzenie(numer number);
procedure wyslij_mail;
procedure aneks(nr_zamowienia number, nr_auta number);

-- przeciazona funkcja i procedura
function efektywnosc_pracownika(numer int, od_dnia date, do_dnia date) return number;
procedure zmien_wynagrodzenie(numer number, nr_stanowiska number);

end pakiecik;
/
create or replace package body pakiecik is
--funkcje
function cena_samochodu(numer int) return number is
cursor ceny is 
select jeden.model, jeden.kolor, jeden.silnik, nvl(dwa.cena,0) as pakiet from
  (select s.id as numer, model.cena as model, kolor.cena as kolor, silnik.cena as silnik
  from model, kolor, silnik, samochod s 
  where s.model_id=model.id and s.silnik_id=silnik.id and s.kolor_id=kolor.id and s.id = numer) jeden 
left join
  (select s.id as numer, p.cena as cena 
    from samochod s, wybrane_pakiety w, pakiet_dodatkowy p 
    where s.id = w.SAMOCHOD_ID and p.id = w.PAKIET_DODATKOWY_ID and s.id = numer) dwa 
on dwa.numer=jeden.numer;
cena MODEL.CENA%type := 0;
begin
for rekord in ceny loop
  cena := cena + rekord.silnik + rekord.kolor + rekord.model+ rekord.pakiet;
end loop;
return cena;
exception
  when no_data_found then
    return 0;
end;

-- druga
function upust_zamowienia(numer int) return number is
wynik UPUST.WYSOKOSC%type :=0;
begin
SELECT sum(upust.wysokosc) into wynik
FROM  upust  INNER JOIN upust_oddzialu
    ON upust.id = upust_oddzialu.upust_id
    INNER JOIN oddzial
    ON oddzial.id = upust_oddzialu.oddzial_id
    INNER JOIN sprzedawca
    ON oddzial.id = sprzedawca.oddzial_id
    INNER JOIN zamowienie 
    ON sprzedawca.id = zamowienie.sprzedawca_id
WHERE zamowienie.data_zawarcia between upust.data_start and UPUST.DATA_KONIEC and zamowienie.id = numer
GROUP BY zamowienie.id;

if wynik >=20 then
    return 20;
ELSE
    return wynik;
end if;
exception
  when no_data_found then
    return 0;
end;


FUNCTION cena_zamowienia (
    numer   INT
) RETURN NUMBER IS
    wynik MODEL.CENA%type := 0;
    cena_ubezpieczenia   UBEZPIECZENIE.CENA%type := 0;
    dodatek PAKIET_DODATKOWY.CENA%type :=0;
-- begin dla ceny samochodu z rabatem
BEGIN
  -- begin dla ubezpieczenia
  BEGIN
      -- begin dla uslug dodatkowych
      BEGIN
          SELECT SUM(uslugi_dodatkowe.cena) into dodatek
          FROM zamowienie INNER JOIN  wybrane_uslugi
              ON zamowienie.id = wybrane_uslugi.zamowienie_id
              INNER JOIN uslugi_dodatkowe 
              ON uslugi_dodatkowe.id = wybrane_uslugi.uslugi_dodatkowe_id
          WHERE zamowienie.id = numer
          GROUP BY  zamowienie.id;
  
     --     dbms_output.put_line('cena dodatku to: ' ||  dodatek ||  ' PLN.');
      EXCEPTION
          WHEN no_data_found THEN
              dodatek := 0;
      END;
      SELECT ubezpieczenie.cena into  cena_ubezpieczenia
      FROM (SELECT  u.cena AS cena
              FROM zamowienie z, ubezpieczenie u
              WHERE z.ubezpieczenie_id = u.id AND z.id = numer ) ubezpieczenie;
  --    dbms_output.put_line('cena ubezpieczenia to: ' ||  cena_ubezpieczenia ||  ' PLN.');
  EXCEPTION
      WHEN no_data_found THEN
          cena_ubezpieczenia :=0;
  END;
wynik := dodatek + cena_ubezpieczenia + ( 1 - upust_zamowienia(numer) / 100 ) * cena_samochodu(numer);
wynik := round(wynik/100,0)*100;
RETURN wynik;
EXCEPTION
      WHEN no_data_found THEN
          return 0;
end;



-- funkcja 4
function czy_oplacone_zamowienie (numer int) return boolean is
wynik boolean := false;
cena platnosc.kwota%type :=0;
begin
SELECT
    SUM(platnosc.kwota) into cena
FROM  platnosc INNER JOIN zamowienie
    ON  zamowienie.id = platnosc.zamowienie_id
WHERE   zamowienie.id = numer  
GROUP BY zamowienie.id;

--dbms_output.put_line('wplaty dokonano na: ' ||  platnosc ||  ' PLN.');
if (cena >= cena_zamowienia(numer)) then
  wynik := true;
end if;

return wynik;
exception 
  when no_data_found then return false;
end;

-- funckaj 5
function efektywnosc_pracownika(numer int) return number is
licznik number(4,2):=0;
mianownik number(4,2):=0;
begin
select count(*) into licznik from zamowienie z, samochod s where z.id = s.zamowienie_id
and z.sprzedawca_id = numer
group by z.SPRZEDAWCA_ID;
--dbms_output.put_line('licznik ' || licznik);
select count(*) into mianownik from zamowienie z 
where z.sprzedawca_id = numer
group by z.SPRZEDAWCA_ID;
--dbms_output.put_line('licznik ' || mianownik);
return round(licznik/mianownik,2);
EXCEPTION
  when no_data_found then
    RETURN 0;
end;



-- PROCEDURY -----------

-- procedura 1
procedure zmien_statusy_zamowienia is
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

-- procedura 2
procedure zmien_statusy_platnosci as
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
        if suma > cena_z then
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
        elsif suma = cena_z then
          update platnosc set uwagi_dodatkowe = ('Ta wplata jest ostatnia wymagana. Dziekujemy') where current of oplaty_zamowienia;
        end if;
      end loop;
    end;  
  end if;
end loop;
end;

-- procedura 3

procedure zmien_wynagrodzenie(numer number) is
pensja SPRZEDAWCA.PENSJA%type := 0;
cursor pracownicy is select sprzedawca.id as id, sprzedawca.pensja as pensja from sprzedawca for update;
begin
for rekord in pracownicy loop
  if (efektywnosc_pracownika(rekord.id) > numer) then 
    update sprzedawca set pensja = round((rekord.pensja * 1.05),2) where current of pracownicy;
  end if;
end loop;
end;


-- procedura 4

procedure wyslij_mail is
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
        dbms_output.put_line('Zwracam siê z proœba by odebraæ swoje zamowienie zawarte w oparciu o umowe nr ' || rekord.nr_umowy || ' z dnia ' || 
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
        dbms_output.put_line('Zwracam siê z proœba by odebraæ swoje zamowienie zawarte w oparciu o umowe nr ' || rekord.nr_umowy || ' z dnia ' || 
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
        dbms_output.put_line('Zwracam siê z proœba by odebraæ swoje zamowienie zawarte w oparciu o umowe nr ' || rekord.nr_umowy || ' z dnia ' || 
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
        dbms_output.put_line('Zwracam siê z proœba by odebraæ swoje zamowienie zawarte w oparciu o umowe nr ' || rekord.nr_umowy || ' z dnia ' || 
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


-- procedura 5
procedure aneks(nr_zamowienia number, nr_auta number) is
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



----------------- przeciazona funkcja i procedura
-- funkcja
-- jako przeciazenie podaje sie parametr OD i DO jako definujace w jakim okresie czasu ma liczona byc efektywnosc dla danego pracownika
function efektywnosc_pracownika(numer int, od_dnia date, do_dnia date) return number is
licznik number(4,2):=0;
mianownik number(4,2):=0;
begin
select count(*) into licznik from zamowienie z, samochod s where z.id = s.zamowienie_id and z.DATA_ZAWARCIA between od_dnia and do_dnia
and z.sprzedawca_id = numer
group by z.SPRZEDAWCA_ID;
--dbms_output.put_line('licznik ' || licznik);
select count(*) into mianownik from zamowienie z 
where z.sprzedawca_id = numer
group by z.SPRZEDAWCA_ID;
--dbms_output.put_line('licznik ' || mianownik);
return round(licznik/mianownik,2);
EXCEPTION
  when no_data_found then
    RETURN 0;
end;


-- procedura
-- przeciazenie polega na tym, ze wyliczana jest efektywnosc dla pracownika ktorego stanowisko definiuje sie w dodatkwoym prametrze
-- jako parametr podaje sie id stanowiska
procedure zmien_wynagrodzenie(numer number, nr_stanowiska number) is
pensja SPRZEDAWCA.PENSJA%type := 0;
cursor pracownicy is select sprzedawca.id as id, sprzedawca.pensja as pensja from sprzedawca where sprzedawca.stanowisko_id = nr_stanowiska for update;
begin
for rekord in pracownicy loop
  if (efektywnosc_pracownika(rekord.id) > numer) then 
    update sprzedawca set pensja = round((rekord.pensja * 1.05),2) where current of pracownicy;
  end if;
end loop;
end;




end pakiecik;
/




-- sprawdzenie
declare
numer_zamowienia int :=12;
begin
--funkcja 1
dbms_output.put_line('cena samochodu 15 to: ' || pakiecik.cena_samochodu(15) || ' PLN.');
-- funkcja 2
dbms_output.put_line('Wartosc upustu dla sprzedazy numer 5: ' || pakiecik.upust_zamowienia(5)|| '%.');
-- funkcja 3
dbms_output.put_line('cena samochodu '|| numer_zamowienia || ' to: ' || pakiecik.cena_samochodu(numer_zamowienia) || ' PLN.');
dbms_output.put_line('Wartosc upustu dla sprzedazy numer ' || numer_zamowienia || ' to: ' || pakiecik.upust_zamowienia(numer_zamowienia)|| '%.');
dbms_output.put_line('Wartosc sprzeda¿y dla zamowienia ' || numer_zamowienia || ' to: ' || pakiecik.cena_zamowienia(numer_zamowienia)|| ' PLN.');
-- funkcja 4
numer_zamowienia := 3;
dbms_output.put_line('Wartosc sprzeda¿y dla zamowienia ' || numer_zamowienia || ' to: ' || pakiecik.cena_zamowienia(numer_zamowienia)|| ' PLN.');
if (pakiecik.czy_oplacone_zamowienie(numer_zamowienia)) then
dbms_output.put_line('Dokonano oplaty w calosci.');
else
dbms_output.put_line('Nie dokonano oplaty w calosci.');
end if;
-- funkcja 5
dbms_output.put_line('Efektywnoœæ pracownika 9 to: ' || pakiecik.efektywnosc_pracownika(9));
end;
/

-- sprawdzenie dla procdury 1
select * from zamowienia_i_platnosci;
begin
pakiecik.zmien_statusy_zamowienia;
end;
/
select * from zamowienia_i_platnosci;


-- sprawdzenie dla procedury 2
begin 
pakiecik.zmien_statusy_platnosci;
end;
/
select * from oplaty_za_zamowienie;

-- sprawdzenie dla procedury 3
BEGIN
pakiecik.zmien_wynagrodzenie(1);
end;
/
select * from pracownicy;


-- sprawdzenie proceudry 4
begin
pakiecik.wyslij_mail;
end;
/


-- sprawdzenie dla procdudry 5
begin
pakiecik.aneks(15,30);
end;
/


-- sprawdzenie dla przeciazonej funkcji 5
begin
dbms_output.put_line('Efektywnoœæ pracownika 1 to: ' || pakiecik.efektywnosc_pracownika(1, to_date('2014','yyyy'), to_date('2015','yyyy') ) );
end;
/

-- sprawdzenie dla przeciazonej procedury 3
BEGIN
pakiecik.zmien_wynagrodzenie(1, 4);
end;
/
select * from pracownicy;