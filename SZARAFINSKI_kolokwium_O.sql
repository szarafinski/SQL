--SKOPIUJ, UZUPE£NIJ ROZWI¥ZANIA I ODEŒLIJ PLIK *.SQL.

--GR. O

--ZADANIA NA KOLOKWIUM

--Data: 07.01.2017
--Imiê: Krzysztof
--Nazwisko: Szarafiñski
--Semestr: 3
--Specjalnoœæ: Informatyka


--O1. Utwórz typ obiektowy o nazwie t_osoba zawieraj¹cy atrybuty: id, imie, 
--nazwisko, data_urodzenia, pensja oraz metodê funkcjê ile_lat zwracaj¹c¹ 
--informacjê ile lat ma dana osoba.
--Utwórz tabelê osoba typu obiektowego t_osoba i dodaj do niej co najmniej 3 rekordy.
--Napisaæ instrukcjê testuj¹c¹ dzia³anie utworzonej metody funkcji ile_lat.

--Rozwi¹zanie:
CREATE OR REPLACE TYPE t_osoba AS OBJECT (id INT, imie VARCHAR(30), 
nazwisko VARCHAR(40), data_urodzenia DATE, pensja NUMBER,
MEMBER function ile_lat return number);
/
create or replace type body t_osoba as
member function ile_lat return number is
  begin
    return floor(months_between(sysdate,self.data_urodzenia)/12);
  end ile_lat;
end;
/
create table osoby of t_osoba;
/
insert into osoby values (new t_osoba(1,'Jan', 'Pierwszy', to_date('1989-03-08','yyyy-mm-dd'),2000));
insert into osoby values (new t_osoba(2,'Karol', 'Drugi', to_date('1979-03-08','yyyy-mm-dd'),210));
insert into osoby values (new t_osoba(3,'Maciej', 'Trzeci', to_date('1969-03-08','yyyy-mm-dd'),1200));
insert into osoby values (new t_osoba(4,'Zuza', 'Czwarty', to_date('1999-03-08','yyyy-mm-dd'),20000));

--Test poprawnoœci rozwi¹zania:
select p.imie, p.nazwisko, p.ile_lat() as wiek from osoby p;

--Instrukcja usuwaj¹ca utworzon¹ tabelê i utworzony typ obiektowy:
drop table osoby;
drop type t_osoba;

--O2. Napisz procedurê o nazwie podwyzka3, która w tabeli osoba (z zadania O1) 
--trzem osobom najmniej zarabiaj¹cym podwy¿szy pensjê o 10%.
--Uwzglêdnij miejsca ex aequo.
--Do tabeli osoba dodaj kolejne rekordy, tak aby by³y dwie osoby zarabiaj¹ce najni¿sz¹ pensjê.
--Zademonstruj dzia³anie utworzonej procedury.

--Rozwi¹zanie:
create or replace procedure podwyzka is
cursor kursor is select p.imie,p.nazwisko,p.pensja, dense_rank() over (order by p.pensja) as ranga from osoby p for update;
begin
for rekord in kursor loop
  if rekord.ranga <4 then
    update osoby p set p.pensja=p.pensja*1.1 where current of kursor;
  end if;
end loop;
end;
/
insert into osoby values (new t_osoba(5,'Karina', 'Piaty', to_date('1986-03-08','yyyy-mm-dd'),2000));
insert into osoby values (new t_osoba(6,'Magda', 'Szosty', to_date('1975-03-08','yyyy-mm-dd'),210));
insert into osoby values (new t_osoba(7,'Iwona', 'Siodmy', to_date('1960-03-08','yyyy-mm-dd'),1200));
insert into osoby values (new t_osoba(8,'Dagmara', 'Osmy', to_date('2005-03-08','yyyy-mm-dd'),20000));
--Test poprawnoœci rozwi¹zania:
exec podwyzka;
select * from osoby;

--Instrukcja usuwaj¹ca utworzon¹ procedurê:
drop procedure podwyzka;


--O3. Napisaæ funkcjê posiadaj¹c¹ jeden parametr p_data i zwracaj¹c¹ 
--informacjê ile osób urodzi³o siê (wykorzystaj tabele osoba z zadania O1)
--po wskazanym dniu przez parametr p_data.
--Zademonstruj dzia³anie zaimplementowanej funkcji.

--Rozwi¹zanie:
create or replace function urodzenia(p_data date)return number is
temp number;
begin
  select count(*) into temp from osoby p where p.data_urodzenia > p_data;
  return temp;
end;
/

--Test poprawnoœci rozwi¹zania:
begin
dbms_output.put_line('po dacie urodzilo sie osob tyle: ' || urodzenia(to_date('1980-01-01','yyyy-mm-dd')));
end;
/
--Instrukcja usuwaj¹ca utworzon¹ funkcjê:
drop function urodzenia;


--O4. Rozwi¹zania zadañ O2-O3 umieœæ w pakiecie o nazwie rozwiazanie i zademonstruj, ¿e 
--dzia³aj¹ funkcje i procedury w utworzonym pakiecie.
--Dodatkowo przeci¹¿ dowolnie wybran¹ funkcjê lub procedurê
--(napisz co realizuje zaimplementowane przeci¹¿enie).

--Rozwi¹zanie:
create or replace package pakiecik is
  function urodzenia(p_data date) return number;
  procedure podwyzka;
    -- funkcja z dodatkowym parametrem zarobki, robi to samo co funkcja z jednym parametrem, ale dla osbób których pensja jest wiêksza ni¿ parametr zarobki
  function urodzenia(p_data date, zarobki number) return number;
end pakiecik;
/
create or replace package body pakiecik is
  function urodzenia(p_data date) return number is
  temp number;
begin
  select count(*) into temp from osoby p where p.data_urodzenia > p_data;
  return temp;
end;
  procedure podwyzka is 
  cursor kursor is select p.imie,p.nazwisko,p.pensja, dense_rank() over (order by p.pensja) as ranga from osoby p for update;
begin
for rekord in kursor loop
  if rekord.ranga <4 then
    update osoby p set p.pensja=p.pensja*1.1 where current of kursor;
  end if;
end loop;
end;
  function urodzenia(p_data date, zarobki number) return number is 
    temp number;
begin
  select count(*) into temp from osoby p where p.data_urodzenia > p_data and p.pensja > zarobki;
  return temp;
end;

end;
/
--Test poprawnoœci rozwi¹zania (uruchom wszystkie funkcje i procedury z pakietu):
begin
dbms_output.put_line('po dacie 1980-01-01 urodzilo sie tyle osob : ' || pakiecik.urodzenia(to_date('1980-01-01','yyyy-mm-dd')));
pakiecik.podwyzka;
dbms_output.put_line('po dacie 1980-01-01 urodzilo sie osob tyle z pensja wieksza niz 2000: ' || pakiecik.urodzenia(to_date('1980-01-01','yyyy-mm-dd'),2000));
end;
/

--Usuwamy utworzony pakiet (ca³kowicie)
drop package pakiecik;

--O5. Uniemo¿liwiæ w istniej¹cej tabeli osoba (patrz zadanie O1) przypisanie 
--wielkoœci pensji mniejszej ni¿ 2134 z³ i wiêkszej ni¿ 9999 z³.

--Rozwi¹zanie
create or replace trigger wyzwalacz before update on osoby for each row
declare
begin
if :new.pensja between 2134 and 9999 then
null;
else
raise_application_error(-20007,'pensja o nieodpowiednich wartosciach');
end if;
end;
/

--Testujemy poprawnoœæ rozwi¹zania:
update osoby p set p.pensja=1000;

--Instrukcja usuwaj¹ca utworzone obiekty:
drop trigger wyzwalacz;
