set serveroutput on
--GR. P

--ZADANIA NA KOLOKWIUM

--Data: 07.01.2017
--Imiê: Krzysztof
--Nazwisko: Szarafiñski
--Semestr: 3
--Specjalnoœæ: Informatyka


--P1. Utwórz typ obiektowy o nazwie t_pracownik zawieraj¹cy atrybuty: id, imie, 
--nazwisko, data_zatrudnienia, pensja, dodatek (dodatek mo¿e wynosiæ NULL) 
--oraz metodê funkcjê o nazwie staz zwracaj¹c¹ informacjê ile lat jest zatrudniony dany pracownik.
--Utwórz tabelê pracownik typu obiektowego t_pracownik i dodaj do niej co najmniej 4 rekordy, 
--w tym dodaj co najmniej 1 pracownika posiadaj¹cego dodatek równy NULL.
--Napisaæ instrukcjê testuj¹c¹ dzia³anie utworzonej metody funkcji staz.

--Rozwi¹zanie:
CREATE OR REPLACE TYPE t_pracownik AS OBJECT (id INTEGER, imie VARCHAR2(30), nazwisko VARCHAR2(40), 
data_zatrudnienia DATE, pensja INTEGER, dodatek integer,
member function staz return number);
/
create or replace type  body t_pracownik as 
member function staz return number as
  begin
    return floor(months_between(SYSDATE,self.data_zatrudnienia) / 12);
  end;
end;
/
create table pracownicy of t_pracownik;
/
INSERT INTO pracownicy values (new t_pracownik (1,'Ania', 'Jeden', to_date('2012-03-12','yyyy-mm-dd'), 1000,10));
INSERT INTO pracownicy values (new t_pracownik (2,'Jan', 'Dwa', to_date('2014-03-12','yyyy-mm-dd'), 2000,20));
INSERT INTO pracownicy values (new t_pracownik (3,'Karol', 'Trzy', to_date('2002-09-12','yyyy-mm-dd'),2200,100));
INSERT INTO pracownicy values (new t_pracownik (4,'Zenon', 'Cztery', to_date('1982-03-08','yyyy-mm-dd'),3800,NULL));

--Test poprawnoœci rozwi¹zania:

select p.imie, p.nazwisko, p.staz() as staz_w_miesiacach from pracownicy p;

--Instrukcja usuwaj¹ca utworzon¹ tabelê i utworzony typ obiektowy:
drop table pracownicy;
drop type t_pracownik;

--P2. Napisz procedurê o nazwie oszczednosci, która w tabeli pracownik (patrz zadanie P1) 
--dwóm osobom najwiêcej zarabiaj¹cym (pensja+dodatek) obni¿y pensjê o 5%. Uwzglêdnij miejsca ex aequo.
--Do tabeli pracownik dodaj kolejne rekordy, tak aby by³o trzech pracowników zarabiaj¹cych 
--najwy¿sz¹ co do wartoœci pensjê+dodatek.
--Zademonstruj dzia³anie utworzonej procedury.

--Rozwi¹zanie:

create or replace procedure oszczednosci is
cursor kursor is select p.imie, p.nazwisko, dense_rank() over (order by  p.dodatek, p.pensja) as miejsce from pracownicy p for update;
begin
for rekord in kursor loop
  if rekord.miejsce < 4 then
    update pracownicy p set p.pensja=p.pensja*1.05, p.dodatek=p.dodatek*1.05 where current of kursor;
    end if;
end loop;
end;
/ 

INSERT INTO pracownicy values (new t_pracownik (5,'Kazik', 'Piec', to_date('2010-07-02','yyyy-mm-dd'), 1000,10));
INSERT INTO pracownicy values (new t_pracownik (6,'Magda', 'Szesc', to_date('2011-03-17','yyyy-mm-dd'), 2000,20));
INSERT INTO pracownicy values (new t_pracownik (7,'Sylwia', 'Siedem', to_date('2006-10-30','yyyy-mm-dd'),2200,100));
--Test poprawnoœci rozwi¹zania:
exec oszczednosci;

--Instrukcja usuwaj¹ca utworzon¹ procedurê:
drop procedure oszczednosci;

--P3. Napisaæ funkcjê o nazwie sprawdz posiadaj¹c¹ jeden parametr p_dodatek i zwracaj¹c¹ 
--informacjê ilu pracowników (wykorzystaj tabele pracownik z zadania P1)
--posiada dodatek ni¿szy ni¿ dodatek zadany parametrem p_dodatek.
--Zademonstruj dzia³anie zaimplementowanej funkcji.

--Rozwi¹zanie:
create or replace function sprawdz(p_dodatek number) return number is
temp number;
begin
select count(*) into temp from pracownicy p where p.dodatek < p_dodatek;
return temp;
end;
/

--Test poprawnoœci rozwi¹zania:
BEGIN
DBMS_OUTPUT.PUT_line('pracownicy ktorzy maja dodatek mniejszy niz 20: ' || sprawdz(20));
end;
/
--Instrukcja usuwaj¹ca utworzon¹ funkcjê:
drop function sprawdz;


--P4. Rozwi¹zania zadañ P2-P3 umieœæ w pakiecie o nazwie pakiecik i zademonstruj, ¿e one dzia³aj¹.
--Dodatkowo przeci¹¿ dowolnie wybran¹ funkcjê lub procedurê (napisz co realizuje zaimplementowane przeci¹¿enie).

--Rozwi¹zanie:
CREATE OR REPLACE PACKAGE pakiecik IS
    FUNCTION sprawdz (
        p_dodatek   NUMBER
    ) RETURN NUMBER;
    PROCEDURE oszczednosci;
    -- procedura z parametrem zarobki, robi to samo co procedura bez parametru, ale dla osbób których pensja jest wiêksza ni¿ parametr zarobki
    PROCEDURE oszczednosci (
        zarobki   NUMBER
    );
END pakiecik;
/

CREATE OR REPLACE PACKAGE BODY pakiecik IS
    FUNCTION sprawdz (
        p_dodatek   NUMBER
    ) RETURN NUMBER IS
        temp   NUMBER;
    BEGIN
        SELECT
            COUNT(*)
        INTO
            temp
        FROM
            pracownicy p
        WHERE
            p.dodatek < p_dodatek;

        RETURN temp;
    END;

    PROCEDURE oszczednosci IS
 cursor kursor is select p.imie, p.nazwisko, dense_rank() over (order by  p.dodatek, p.pensja) as miejsce from pracownicy p for update;
begin
for rekord in kursor loop
  if rekord.miejsce < 4 then
    update pracownicy p set p.pensja=p.pensja*1.05, p.dodatek=p.dodatek*1.05 where current of kursor;
    end if;
end loop;
end;

    PROCEDURE oszczednosci (
        zarobki   NUMBER
    ) IS
cursor kursor is select p.imie, p.nazwisko, dense_rank() over (order by  p.dodatek, p.pensja) as miejsce from pracownicy p where p.pensja > zarobki for update;
begin
for rekord in kursor loop
  if rekord.miejsce < 4 then
    update pracownicy p set p.pensja=p.pensja*1.05, p.dodatek=p.dodatek*1.05 where current of kursor;
    end if;
end loop;
end;

END pakiecik;
/
--Test poprawnoœci rozwi¹zania (uruchom wszystkie funkcje i procedury z pakietu):
begin
DBMS_OUTPUT.PUT_LINE('funkcja dla parametru 20: ' || pakiecik.sprawdz(200));
pakiecik.oszczednosci;
pakiecik.oszczednosci(2000);
end;
/

--Usuwamy utworzony pakiet (ca³kowicie):
drop package pakiecik;

--P5. Uniemo¿liwiæ w istniej¹cej tabeli pracownik (patrz zadanie P1) przypisanie 
--wartoœci data_zatrudnienia wczeœniejszej ni¿ 50 lat temu i póŸniejszej ni¿ bie¿¹ca data.

--Rozwi¹zanie
create or replace trigger wyzwalacz before insert or update on pracownicy for each row 
declare
data_nowa number;
begin
if inserting or updating then
data_nowa := extract(year from :new.data_zatrudnienia);
  if (:new.data_zatrudnienia > sysdate) or (:new.data_zatrudnienia < add_months(sysdate,-50*12)) then
  raise_application_error(-20000,'nieprawidlowa data, rok: ' || data_nowa);
  end if;
end if;
end;
/

--Testujemy poprawnoœæ rozwi¹zania:
INSERT INTO pracownicy values (new t_pracownik (17,'Kuba', 'Siedemnascie', to_date('2026-10-30','yyyy-mm-dd'),2200,100));

--Instrukcja usuwaj¹ca utworzone obiekty:
drop trigger wyzwalacz;
drop table pracownicy;