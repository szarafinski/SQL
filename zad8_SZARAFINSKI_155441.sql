SET SERVEROUTPUT ON;

/*
1. Zdefiniuj pakiet bez cia³a zawieraj¹cy wartoœci dwóch sta³ych fizycznych: prêdkoœæ œwiat³a w
pró¿ni i standardowe przyœpieszenie ziemskie. Przetestuj dzia³anie utworzonego pakietu.
Wskazówka: prêdkoœæ œwiat³a w pró¿ni to c = 299 792 458 m/s, standardowe przyœpieszenie
ziemskie to g = 9,80665 m/s2.
*/
CREATE OR REPLACE PACKAGE zadanie1 IS
  przyspiesze      CONSTANT NUMBER := 9.80665;
  predkosc_swiatla CONSTANT NUMBER := 299792458;
END zadanie1;
/
BEGIN
  dbms_output.put_line('Predkosc swiatla to: ' || zadanie1.predkosc_swiatla );
  dbms_output.put_line('przyspieszenie to: ' || zadanie1.przyspiesze );
END;
/
/*
2. a) Utwórz tabelê osoba(id,imie,nazwisko) i dodaj do niej kilka przyk³adowych rekordów.
b) Utwórz pakiet o nazwie statystyki i zaimplementuj w nim trzy funkcje:
b1) LiczbaOsob – funkcja zwraca liczbê wszystkich osób wystêpuj¹cych w tabeli osoba,
b2) LiczbaUnikatowychImion – funkcja zwraca liczbê unikatowych imion wystêpuj¹cych w tabeli
osoba,
b3) LiczbaUnikatowychNazwisk – funkcja zwraca liczbê unikatowych nazwisk wystêpuj¹cych w
tabeli osoba,
c) Przetestuj dzia³anie funkcji z implementowanego pakietu.
*/
CREATE TABLE osoba1 (
    id       NUMBER(11),
    imie     VARCHAR2(30),
    nazwisko VARCHAR2(40)
  );
/

INSERT INTO osoba1 VALUES  (1, 'Jan', 'Kowalski');
INSERT INTO osoba1 VALUES  (2, 'Janina', 'Kowalska');
INSERT INTO osoba1 VALUES  (3, 'Karol', 'Bogusz');
INSERT INTO osoba1 VALUES  (4, 'Anna', 'Gil' );
/
CREATE OR REPLACE PACKAGE statystyki IS
  FUNCTION liczbaOsob RETURN NUMBER;
  FUNCTION liczbaUnikatowychImion  RETURN NUMBER;
  FUNCTION liczbaUnikatowychNazwisk RETURN NUMBER;
END statystyki;
/
CREATE OR REPLACE PACKAGE BODY statystyki IS
  FUNCTION liczbaOsob RETURN NUMBER IS
    licznik NUMBER := 0;
  BEGIN
    SELECT COUNT(*) INTO licznik FROM osoba1;
    RETURN licznik;
  END liczbaOsob;
  
  FUNCTION liczbaUnikatowychImion
    RETURN NUMBER IS
    licznik NUMBER :=0;
  BEGIN
    SELECT COUNT(*) INTO licznik FROM
      (SELECT DISTINCT imie FROM osoba1);
    RETURN licznik;
  END liczbaUnikatowychImion;
  FUNCTION liczbaUnikatowychNazwisk RETURN NUMBER IS
    licznik NUMBER :=0;
  BEGIN
    SELECT COUNT(DISTINCT nazwisko) INTO licznik FROM osoba1;
    RETURN licznik;
  END liczbaUnikatowychNazwisk;
END statystyki;
/
BEGIN
  dbms_output.put_line('Liczba osob w tabeli to: ' || statystyki.liczbaOsob);
  dbms_output.put_line('Liczba imion w tabeli to: ' || statystyki.liczbaUnikatowychImion);
  dbms_output.put_line('Liczba nazwisk w tabeli to: ' || statystyki.liczbaUnikatowychNazwisk);
END;
/
/*
3. a) Utwórz tabelê produkt(id_produkt,nazwa,cena) i dodaj do niej kilka przyk³adowych rekordów.
b) Utwórz pakiet o nazwie ceny posiadaj¹cy dwie przeci¹¿one procedury:
b1) podwyzka(p_procent INTEGER) – procedura powinna podwy¿szyæ cenê wszystkich
produktów w tabeli produkt o zadany procent,
b2) podwyzka(p_procent INTEGER, p_id_produkt INTEGER) – procedura powinna zwiêkszyæ
cenê zadanego produktu w tabeli produkt o zadany procent.
c) Przetestuj dzia³anie utworzonego pakietu.
*/
CREATE TABLE produkt (
    id    NUMBER(11),
    nazwa VARCHAR2(30),
    cena  NUMBER(6,2)
  );
/
INSERT INTO produkt VALUES (1, 'mleko', 2.39 );
INSERT INTO produkt VALUES (2, 'chleb', 1.89 );
INSERT INTO produkt VALUES (3, 'maslo', 3.49 );
/
CREATE OR REPLACE PACKAGE ceny IS
  PROCEDURE podwyzka (procent INTEGER );
  PROCEDURE podwyzka (procent INTEGER,p_id INTEGER);
END ceny;
/
CREATE OR REPLACE PACKAGE BODY ceny IS
  PROCEDURE podwyzka(procent INTEGER)IS
  BEGIN
    UPDATE produkt SET cena = cena*(1+procent/100);
  END podwyzka;
  
  PROCEDURE podwyzka( procent INTEGER, p_id INTEGER)IS
  BEGIN
    UPDATE produkt SET cena = cena*(1+procent/100) WHERE id = p_id;
  END podwyzka;
END ceny;
/
SELECT * FROM produkt;
/
BEGIN
  ceny.podwyzka(10);
  ceny.podwyzka(50,2);
END;
/
SELECT * FROM produkt;
/

/*
4.
Dana jest specyfikacja pakietu operuj¹cego na liczbach zespolonych: 
CREATE OR REPLACE PACKAGE lzesp IS 
    TYPE tzesp IS RECORD (re NUMBER, im NUMBER); 
    zero tzesp;   
    jeden tzesp;  
    PROCEDURE wypisz(z tzesp); 
    FUNCTION suma(z1 tzesp, z2 tzesp) RETURN tzesp; 
    FUNCTION roznica(z1 tzesp, z2 tzesp) RETURN tzesp; 
END lzesp; 
Utwórz cia³o pakietu dla zadanej specyfikacji:  
a) Zmienna zespolona zero powinna byæ zainicjowana wartoœciami re=0 i im=0, a zmienna zespolona jeden wartoœciami re=1 i im=1
b) Procedura wypisz powinna wypisywaæ liczbê zespolon¹ w formacie: (re,im). 
c) Funkcje suma i roznica powinny obliczaæ i zwracaæ odpowiednio sumê i ró¿nicê dwóch liczb zespolonych. 
d) Dla kodu testowego: 
DECLARE 
  a lzesp.tzesp; 
  b lzesp.tzesp; 
BEGIN 
  a.re:=5; a.im:=6; 
  b:=lzesp.suma(lzesp.roznica(lzesp.zero,lzesp.jeden),a); 
  lzesp.wypisz(b); 
END; 
powinien zostaæ zwrócony wynik: (4,5). 
*/
CREATE OR REPLACE PACKAGE lzesp IS
    TYPE tzesp IS RECORD (re NUMBER,im NUMBER);
    zero tzesp;
    jeden tzesp;
    PROCEDURE wypisz (z   tzesp);
    FUNCTION suma (z1   tzesp,z2   tzesp) RETURN tzesp;
    FUNCTION roznica (z1   tzesp,z2   tzesp) RETURN tzesp;
END lzesp;
/
CREATE OR REPLACE PACKAGE BODY lzesp IS
    PROCEDURE wypisz(z tzesp) is
    begin
      dbms_output.put_line('('||z.re || ','|| z.im || ')');
    end wypisz; 
    
    FUNCTION suma(z1 tzesp, z2 tzesp) RETURN tzesp is
    wynik tzesp;
    begin
    wynik.re := z1.re + z2.re;
    wynik.im := z1.im + z2.im;
    return wynik;
    end suma; 
    
    FUNCTION roznica(z1 tzesp, z2 tzesp) RETURN tzesp is
    wynik tzesp;
    begin
    wynik.re := z1.re - z2.re;
    wynik.im := z1.im - z2.im;
    return wynik;
    end roznica; 
bEGIN
  zero.re := 0;
  zero.im := 0;
  jeden.re := 1;
  jeden.im := 1;
END lzesp;
/

DECLARE 
  a lzesp.tzesp; 
  b lzesp.tzesp; 
BEGIN 
  a.re:=5; a.im:=6; 
  b:=lzesp.suma(lzesp.roznica(lzesp.zero,lzesp.jeden),a); 
  lzesp.wypisz(b); 
END;
/

