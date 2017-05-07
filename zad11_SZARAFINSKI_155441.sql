SET SERVEROUTPUT ON;

/*
1. a) Utw�rz typ obiektowy o nazwie przedmiot zawieraj�cy atrybuty: id,nazwa,cena,
data_produkcji.
b) Utw�rz tabel� obiektow� o nazwie przedmioty typu obiektowego przedmiot.
c) Dodaj 7 przyk�adowych obiekt�w do tabeli przedmioty (w tym dwa obiekty o wsp�lnej
najwy�szej cenie).
d) Z tabeli obiektowej przedmioty wyszukaj przedmiot (jeden lub kilka) o najwy�szej cenie.
e) Do typu obiektowego przedmiot dodaj atrybut gwarancja,kt�ry b�dzie przechowywa�
informacj� o d�ugo�ci gwarancji przedmiotu wyra�onej w miesi�cach. Typ obiektowy przedmiot
nale�y zmodyfikowa� w taki spos�b,aby wszystkie sk�adowane obiekty tego typu r�wnie� zosta�y
zmodyfikowane.
f) W tabeli przedmioty okre�l dla wszystkich wprowadzonych rekord�w warto�� gwarancji � dla
rekord�w o identyfikatorach nieparzystych ustaw na 24 miesi�ce,a dla rekord�w o
identyfikatorach parzystych ustaw na 36 miesi�cy.
g) Do typu obiektowego dodaj metod� funkcj� o nazwie wiek obliczaj�c� ile lat ma przedmiot. Typ
obiektowy zmodyfikuj w taki spos�b,aby wszystkie sk�adowane obiekty tego typu r�wnie� zosta�y
zmodyfikowane.
h) Z tabeli przedmioty wy�wietl wszystkie nazwy przedmiot�w i ich wiek (u�yj metody funkcji
wiek). Wynik posortuj wzgl�dem wieku malej�co. 
*/

CREATE OR REPLACE TYPE przedmiot AS OBJECT (
    id               NUMBER,
    nazwa            VARCHAR2(40),
    cena             NUMBER(10,2),
    data_produkcji   DATE
);
/

CREATE TABLE przedmioty OF przedmiot;
/

INSERT INTO przedmioty VALUES (
    NEW przedmiot (
        1,
        'zeszyt',
        2.20,
        TO_DATE('2016-03-12','YYYY-MM-DD')
    )
);

INSERT INTO przedmioty VALUES (
    NEW przedmiot (
        2,
        'notes',
        3.10,
        TO_DATE('2016-06-12','YYYY-MM-DD')
    )
);

INSERT INTO przedmioty VALUES (
    NEW przedmiot (
        3,
        'gumka',
        0.10,
        TO_DATE('2016-09-12','YYYY-MM-DD')
    )
);

INSERT INTO przedmioty VALUES (
    NEW przedmiot (
        4,
        'olowek',
        1.15,
        TO_DATE('2015-03-12','YYYY-MM-DD')
    )
);

INSERT INTO przedmioty VALUES (
    NEW przedmiot (
        5,
        'dlugopis',
        1.99,
        TO_DATE('2012-03-12','YYYY-MM-DD')
    )
);

INSERT INTO przedmioty VALUES (
    NEW przedmiot (
        6,
        'mazak',
        3.10,
        TO_DATE('2010-12-12','YYYY-MM-DD')
    )
);

INSERT INTO przedmioty VALUES (
    NEW przedmiot (
        7,
        'tasma klejaca',
        0.70,
        TO_DATE('2014-03-10','YYYY-MM-DD')
    )
);
/

SELECT
    p.nazwa,
    p.cena
FROM
    przedmioty p,
    (SELECT  MAX(p.cena) AS maksimum FROM  przedmioty p ) zapytanie
WHERE
    p.cena = zapytanie.maksimum;
/

ALTER TYPE przedmiot ADD ATTRIBUTE gwarancja NUMBER
    CASCADE INCLUDING TABLE DATA;
/

UPDATE przedmioty p SET p.gwarancja = 24 WHERE mod(p.id,2) = 1;
/

UPDATE przedmioty p
    SET
        p.gwarancja = 36
WHERE
    mod(p.id,2) = 0;
/

ALTER TYPE przedmiot
    ADD
        MEMBER FUNCTION wiek_przedmiotu RETURN NUMBER
    CASCADE INCLUDING TABLE DATA;
/

ALTER TYPE przedmiot
    DROP
        MEMBER PROCEDURE pole
    CASCADE INCLUDING TABLE DATA;
/

CREATE OR REPLACE TYPE BODY przedmiot AS
    MEMBER FUNCTION wiek_przedmiotu RETURN NUMBER
        AS
    BEGIN
        RETURN floor(
            months_between(SYSDATE,self.data_produkcji) / 12
        );
    END;

END;
/

SELECT p.nazwa, p.wiek_przedmiotu() as wiek FROM przedmioty p order by wiek;


/*
a) Utw�rz typ obiektowy o nazwie upominek zawieraj�cy atrybuty: id, imi�, nazwisko, prezent,
data_wr�czenia, gdzie atrybut prezent przechowuje referencj� do obiektu typu przedmiot.
Utw�rz przyk�adowy obiekt i wypisz na ekranie warto�ci jego atrybut�w.
b) Do typu obiektowego upominek dodaj metod� funkcj� o nazwie ile_dni obliczaj�c� ile dni temu
zosta� wr�czony upominek (nazwa upominku).
Utw�rz przyk�adowy obiekt i zademonstruj dzia�anie metody funkcji ile_dni.
c) Do typu obiektowego upominek dodaj metod� procedur� o nazwie kogo_obdarowano, kt�ra
wy�wietli na ekranie informacj� ile dni temu (u�yj metody funkcji ile_dni) i jaka osoba (imi� i
nazwisko) otrzyma�a upominek.
Utw�rz przyk�adowy obiekt i zademonstruj dzia�anie metody procedury kogo_obdarowano.
d) Utw�rz tabel� obiektow� o nazwie upominki typu obiektowego upominek.
e) Do tabeli upominki dodaj 8 przyk�adowych obiekt�w. (W tabeli przedmioty powiniene� mie�
tylko 7 obiekt�w, wi�c jeden z dodawanych upomink�w powinien wskazywa� na przedmiot
NULL).
f) Dla ka�dego upominku wy�wietl informacj� o osobie (imi� i nazwisko), kt�ra go otrzyma�a i jaki
przedmiot otrzyma�a (nazwa przedmiotu).
g) Z tabeli przedmioty usu� dowolne dwa przedmioty. W tabeli upominki znajd� obiekty, kt�re
wskazuj� na nieistniej�ce przedmioty. Utw�rz zapytanie zwracaj�ce obiekty.
*/

CREATE OR REPLACE TYPE upominek AS OBJECT (id number(11), imie varchar2(30), nazwisko varchar2(40), prezent ref przedmiot,
data_wreczenia date);
/

Declare
o_upominek upominek;
temp ref przedmiot;
prezent przedmiot;
begin
select ref(p) into temp from przedmioty p where p.nazwa = 'notes';
o_upominek := upominek('1','Jan','Kowalski', temp, to_date('2013-03-09','YYYY-MM-DD'));
select deref(temp) into prezent from dual;
  dbms_output.put_line('Prezent dla ' || o_upominek.imie || ' ' || o_upominek.nazwisko || ' to: ' || prezent.nazwa || ' o cenie: ' || prezent.cena );
end;
/

ALTER TYPE upominek ADD MEMBER FUNCTION ile_dni return number cascade including table data;
/

create or replace type body upominek as
member function ile_dni return number as
begin
return floor(sysdate - data_wreczenia);
end ile_dni;
end;
/

Declare
o_upominek upominek;
temp ref przedmiot;
prezent przedmiot;
begin
select ref(p) into temp from przedmioty p where p.nazwa = 'notes';
o_upominek := upominek('1','Jan','Kowalski', temp, to_date('2016-12-01','YYYY-MM-DD'));
select deref(temp) into prezent from dual;
  dbms_output.put_line('Prezent dla ' || o_upominek.imie || ' ' || o_upominek.nazwisko || ' to: ' || prezent.nazwa || ' o cenie: ' || prezent.cena || 
  ' upominek wreczono: ' || o_upominek.ile_dni() || ' temu.');
end;
/

alter type upominek add member procedure kogo_obdarowano cascade including table data;
/
create or replace type body upominek as
member function ile_dni return number as
begin
return floor(sysdate - data_wreczenia);
end ile_dni;
member procedure kogo_obdarowano is
begin
dbms_output.put_line('Osoba ' || self.imie || ' ' || self.nazwisko || ' otrzymala upominek ' || self.ile_dni || ' dni temu.');
end kogo_obdarowano;
end;
/
Declare
o_upominek upominek;
temp ref przedmiot;
begin
select ref(p) into temp from przedmioty p where p.nazwa = 'notes';
o_upominek := upominek('1','Jan','Kowalski', temp, to_date('2016-12-01','YYYY-MM-DD'));
o_upominek.kogo_obdarowano();
end;
/

create table upominki of upominek;
/

insert into upominki values (new upominek(1,'Jan','Kowalski', (select ref(p) from przedmioty p where p.nazwa = 'notes'), to_date('2016-12-01','YYYY-MM-DD')));
insert into upominki values (new upominek(2,'Karol','Kosko', (select ref(p) from przedmioty p where p.nazwa = 'zeszyt'), to_date('2011-10-01','YYYY-MM-DD')));
insert into upominki values (new upominek(3,'Kamila','Kawasa', (select ref(p) from przedmioty p where p.nazwa = 'gumka'), to_date('2015-12-21','YYYY-MM-DD')));
insert into upominki values (new upominek(4, 'Wojtek','Malinski', (select ref(p) from przedmioty p where p.nazwa = 'olowek'), to_date('2014-01-01','YYYY-MM-DD')));
insert into upominki values (new upominek(5,'Maciek','Kiwki', (select ref(p) from przedmioty p where p.nazwa = 'dlugopis'), to_date('2012-08-02','YYYY-MM-DD')));
insert into upominki values (new upominek(6,'Zofia','Malno', (select ref(p) from przedmioty p where p.nazwa = 'mazak'), to_date('2000-05-19','YYYY-MM-DD')));
insert into upominki values (new upominek(7,'Jadwiga','Buski', (select ref(p) from przedmioty p where p.nazwa = 'tasma klejaca'), to_date('2006-11-22','YYYY-MM-DD')));
insert into upominki values (new upominek(8,'Patryk','Kowalski', NULL, to_date('2009-10-11','YYYY-MM-DD')));
/

begin
for licznik in (select imie, nazwisko, u.prezent.nazwa as nazwa_upominku from upominki u) loop
dbms_output.put_line(licznik.imie || ' ' || licznik.nazwisko || ' ' || licznik.nazwa_upominku);
end loop;
end;
/

/*
g) Z tabeli przedmioty usu� dowolne dwa przedmioty. W tabeli upominki znajd� obiekty, kt�re
wskazuj� na nieistniej�ce przedmioty. Utw�rz zapytanie zwracaj�ce obiekty.*/
delete from przedmioty where id = 2;
delete from przedmioty where id = 3;
select * from upominki u where prezent is dangling;