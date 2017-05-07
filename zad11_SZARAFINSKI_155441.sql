SET SERVEROUTPUT ON;

/*
1. a) Utwórz typ obiektowy o nazwie przedmiot zawieraj¹cy atrybuty: id,nazwa,cena,
data_produkcji.
b) Utwórz tabelê obiektow¹ o nazwie przedmioty typu obiektowego przedmiot.
c) Dodaj 7 przyk³adowych obiektów do tabeli przedmioty (w tym dwa obiekty o wspólnej
najwy¿szej cenie).
d) Z tabeli obiektowej przedmioty wyszukaj przedmiot (jeden lub kilka) o najwy¿szej cenie.
e) Do typu obiektowego przedmiot dodaj atrybut gwarancja,który bêdzie przechowywa³
informacjê o d³ugoœci gwarancji przedmiotu wyra¿onej w miesi¹cach. Typ obiektowy przedmiot
nale¿y zmodyfikowaæ w taki sposób,aby wszystkie sk³adowane obiekty tego typu równie¿ zosta³y
zmodyfikowane.
f) W tabeli przedmioty okreœl dla wszystkich wprowadzonych rekordów wartoœæ gwarancji – dla
rekordów o identyfikatorach nieparzystych ustaw na 24 miesi¹ce,a dla rekordów o
identyfikatorach parzystych ustaw na 36 miesiêcy.
g) Do typu obiektowego dodaj metodê funkcjê o nazwie wiek obliczaj¹c¹ ile lat ma przedmiot. Typ
obiektowy zmodyfikuj w taki sposób,aby wszystkie sk³adowane obiekty tego typu równie¿ zosta³y
zmodyfikowane.
h) Z tabeli przedmioty wyœwietl wszystkie nazwy przedmiotów i ich wiek (u¿yj metody funkcji
wiek). Wynik posortuj wzglêdem wieku malej¹co. 
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
a) Utwórz typ obiektowy o nazwie upominek zawieraj¹cy atrybuty: id, imiê, nazwisko, prezent,
data_wrêczenia, gdzie atrybut prezent przechowuje referencjê do obiektu typu przedmiot.
Utwórz przyk³adowy obiekt i wypisz na ekranie wartoœci jego atrybutów.
b) Do typu obiektowego upominek dodaj metodê funkcjê o nazwie ile_dni obliczaj¹c¹ ile dni temu
zosta³ wrêczony upominek (nazwa upominku).
Utwórz przyk³adowy obiekt i zademonstruj dzia³anie metody funkcji ile_dni.
c) Do typu obiektowego upominek dodaj metodê procedurê o nazwie kogo_obdarowano, która
wyœwietli na ekranie informacjê ile dni temu (u¿yj metody funkcji ile_dni) i jaka osoba (imiê i
nazwisko) otrzyma³a upominek.
Utwórz przyk³adowy obiekt i zademonstruj dzia³anie metody procedury kogo_obdarowano.
d) Utwórz tabelê obiektow¹ o nazwie upominki typu obiektowego upominek.
e) Do tabeli upominki dodaj 8 przyk³adowych obiektów. (W tabeli przedmioty powinieneœ mieæ
tylko 7 obiektów, wiêc jeden z dodawanych upominków powinien wskazywaæ na przedmiot
NULL).
f) Dla ka¿dego upominku wyœwietl informacjê o osobie (imiê i nazwisko), która go otrzyma³a i jaki
przedmiot otrzyma³a (nazwa przedmiotu).
g) Z tabeli przedmioty usuñ dowolne dwa przedmioty. W tabeli upominki znajdŸ obiekty, które
wskazuj¹ na nieistniej¹ce przedmioty. Utwórz zapytanie zwracaj¹ce obiekty.
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
g) Z tabeli przedmioty usuñ dowolne dwa przedmioty. W tabeli upominki znajdŸ obiekty, które
wskazuj¹ na nieistniej¹ce przedmioty. Utwórz zapytanie zwracaj¹ce obiekty.*/
delete from przedmioty where id = 2;
delete from przedmioty where id = 3;
select * from upominki u where prezent is dangling;