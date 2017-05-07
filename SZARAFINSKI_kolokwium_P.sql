set serveroutput on
--GR. P

--ZADANIA NA KOLOKWIUM

--Data: 07.01.2017
--Imi�: Krzysztof
--Nazwisko: Szarafi�ski
--Semestr: 3
--Specjalno��: Informatyka


--P1. Utw�rz typ obiektowy o nazwie t_pracownik zawieraj�cy atrybuty: id, imie, 
--nazwisko, data_zatrudnienia, pensja, dodatek (dodatek mo�e wynosi� NULL) 
--oraz metod� funkcj� o nazwie staz zwracaj�c� informacj� ile lat jest zatrudniony dany pracownik.
--Utw�rz tabel� pracownik typu obiektowego t_pracownik i dodaj do niej co najmniej 4 rekordy, 
--w tym dodaj co najmniej 1 pracownika posiadaj�cego dodatek r�wny NULL.
--Napisa� instrukcj� testuj�c� dzia�anie utworzonej metody funkcji staz.

--Rozwi�zanie:
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

--Test poprawno�ci rozwi�zania:

select p.imie, p.nazwisko, p.staz() as staz_w_miesiacach from pracownicy p;

--Instrukcja usuwaj�ca utworzon� tabel� i utworzony typ obiektowy:
drop table pracownicy;
drop type t_pracownik;

--P2. Napisz procedur� o nazwie oszczednosci, kt�ra w tabeli pracownik (patrz zadanie P1) 
--dw�m osobom najwi�cej zarabiaj�cym (pensja+dodatek) obni�y pensj� o 5%. Uwzgl�dnij miejsca ex aequo.
--Do tabeli pracownik dodaj kolejne rekordy, tak aby by�o trzech pracownik�w zarabiaj�cych 
--najwy�sz� co do warto�ci pensj�+dodatek.
--Zademonstruj dzia�anie utworzonej procedury.

--Rozwi�zanie:

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
--Test poprawno�ci rozwi�zania:
exec oszczednosci;

--Instrukcja usuwaj�ca utworzon� procedur�:
drop procedure oszczednosci;

--P3. Napisa� funkcj� o nazwie sprawdz posiadaj�c� jeden parametr p_dodatek i zwracaj�c� 
--informacj� ilu pracownik�w (wykorzystaj tabele pracownik z zadania P1)
--posiada dodatek ni�szy ni� dodatek zadany parametrem p_dodatek.
--Zademonstruj dzia�anie zaimplementowanej funkcji.

--Rozwi�zanie:
create or replace function sprawdz(p_dodatek number) return number is
temp number;
begin
select count(*) into temp from pracownicy p where p.dodatek < p_dodatek;
return temp;
end;
/

--Test poprawno�ci rozwi�zania:
BEGIN
DBMS_OUTPUT.PUT_line('pracownicy ktorzy maja dodatek mniejszy niz 20: ' || sprawdz(20));
end;
/
--Instrukcja usuwaj�ca utworzon� funkcj�:
drop function sprawdz;


--P4. Rozwi�zania zada� P2-P3 umie�� w pakiecie o nazwie pakiecik i zademonstruj, �e one dzia�aj�.
--Dodatkowo przeci�� dowolnie wybran� funkcj� lub procedur� (napisz co realizuje zaimplementowane przeci��enie).

--Rozwi�zanie:
CREATE OR REPLACE PACKAGE pakiecik IS
    FUNCTION sprawdz (
        p_dodatek   NUMBER
    ) RETURN NUMBER;
    PROCEDURE oszczednosci;
    -- procedura z parametrem zarobki, robi to samo co procedura bez parametru, ale dla osb�b kt�rych pensja jest wi�ksza ni� parametr zarobki
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
--Test poprawno�ci rozwi�zania (uruchom wszystkie funkcje i procedury z pakietu):
begin
DBMS_OUTPUT.PUT_LINE('funkcja dla parametru 20: ' || pakiecik.sprawdz(200));
pakiecik.oszczednosci;
pakiecik.oszczednosci(2000);
end;
/

--Usuwamy utworzony pakiet (ca�kowicie):
drop package pakiecik;

--P5. Uniemo�liwi� w istniej�cej tabeli pracownik (patrz zadanie P1) przypisanie 
--warto�ci data_zatrudnienia wcze�niejszej ni� 50 lat temu i p�niejszej ni� bie��ca data.

--Rozwi�zanie
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

--Testujemy poprawno�� rozwi�zania:
INSERT INTO pracownicy values (new t_pracownik (17,'Kuba', 'Siedemnascie', to_date('2026-10-30','yyyy-mm-dd'),2200,100));

--Instrukcja usuwaj�ca utworzone obiekty:
drop trigger wyzwalacz;
drop table pracownicy;