
-- Autor: Krzysztof Szarafiñski
-- nr albumu: 155441
-- Data: 12.01.2017

set serveroutput on
/* Wyzwalacz 1:
zapewnia by dodana nowa klasa wyposazenia podstawowego byla pisana z wielkiej litery
*/
create or replace trigger klasa_wielka_litera before insert or update on klasa_wyposazenia for each row
begin
if inserting then
:new.nazwa := upper(:new.nazwa);
elsif updating then
:new.nazwa := upper(:new.nazwa);
end if;
end;
/
-- sprawdzenie
select * from klasa_wyposazenia;
insert into klasa_wyposazenia(nazwa,opis) values ('Buisness', 'buisness, floty samochodwe');
select * from klasa_wyposazenia;

/* Wyzwalacz 2:
uniemozliwia usuniecie samochodu z bazy danych jezeli jest on zamowiony 
*/
create or replace trigger zamowiony_samochod before delete on samochod for each row
begin
  if (:old.zamowienie_id is not null) then
      RAISE_APPLICATION_ERROR(-20001, 'Samochod jest zamowiony. Nie mozna dokonac jego usuniecia.');
  end if;
end;
/

-- sprawdzenie
delete from samochod where id = 14;

/* Wyzwalacz 3:
sprawdza czy dana osoba jest juz w bazie: imie oraz naziwsko i adres zameiszkania. jezeli jest to uniemozlwia jej dodanie
*/
create or replace trigger duplikat_osoby before insert on klient for each row
declare
licznik int;
begin
select count(*) into licznik from klient where lower(imie) = lower(:new.imie) and lower(plec) = lower(:new.plec) 
  and lower(nazwisko)=lower(:new.nazwisko) and adres_id = :new.adres_id;
if inserting then
  if (licznik >0) then
    RAISE_APPLICATION_ERROR(-20002, 'Osoba znajduje siê juz w bazie.');
  end if;
end if;
end;
/

-- sprawdzenie
  insert into klient (plec, imie, nazwisko, adres_id) values ('k',	'Janina'	,'Zlota',	9);
  
/* wyzwalacz 4:
uniemozliwia wstawienie platnosci dla umow ktore nie zostay zawarte
*/
create or replace trigger wstaw_platnosc before insert on platnosc for each row
declare
zawarcie zamowienie.data_zawarcia%type;
begin
  begin
    select z.data_zawarcia into zawarcie from zamowienie z where z.ID=:new.zamowienie_id;
  exception
    WHEN no_data_found THEN
        zawarcie := sysdate;
  end;
  if (:new.data_dokonania < zawarcie) then
    RAISE_APPLICATION_ERROR(-20003, 'Wplata nie dotyczy zawartej umowy. Brak mozliwosci rejestracji.');
  end if;
end;
/

-- sprawdzenie
insert into platnosc (data_dokonania, kwota, klient_id,zamowienie_id) values (to_date('2016-10-30','yyyy-mm-dd'),1000,2,1);

/* wyzwalacz 5:
przy zmianie statusu zamowienia na odebrane zwalnia dane modele z zamowienia
*/
create or replace trigger odebranie_zamowienia after update on zamowienie for each row when (new.status_zamowienia_id = 5) 
declare
  cursor samochody is select zamowienie_id from samochod where ZAMOWIENIE_ID=:old.id;
  zamowienie_nr samochod.id%type;
begin
open samochody;
loop
  fetch  samochody into zamowienie_nr;
  update samochod set ZAMOWIENIE_ID = null where zamowienie_id = zamowienie_nr;
  exit when samochody%notfound;
end loop;
close samochody;
end;
/
-- sprawdzenie
update zamowienie set status_zamowienia_id = 5 where id = 15;


