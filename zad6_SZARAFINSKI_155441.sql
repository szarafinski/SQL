SET SERVEROUTPUT ON

/*
1. Zaimplementuj funkcj� o nazwie odleglosc(x1,y1,x2,y2) obliczaj�c� odleg�o�� na p�aszczy�nie
pomi�dzy punktami (x1,y1) oraz (x2,y2). Przetestuj dzia�anie zaimplementowanej funkcji. 
*/
CREATE OR REPLACE FUNCTION 
    odleglosc(x1 NUMBER, y1 NUMBER, x2 NUMBER, y2 NUMBER) RETURN NUMBER IS
    liczba NUMBER:=0;
BEGIN
    liczba := sqrt(power(x2-x1,2)+power(y2-y1,2));
    RETURN liczba;
END;
/

BEGIN
DBMS_OUTPUT.PUT_LINE('liczba ' || round(odleglosc(1,2,3,4),2));
END;
/

/*
2. Utw�rz tabel� produkt(id,nazwa,cena) i dodaj przyk�adowe rekordy.
Napisz procedur� o nazwie aktualizacja_ceny(p_id_produkt,p_procent), kt�ra ma zaktualizowa�
cen� zadanego produktu o podany przez parametr procent. Przetestuj dzia�anie procedury
*/

CREATE TABLE produkt(id NUMBER(11), nazwa VARCHAR2(20), cena NUMBER(11,2));
/
INSERT INTO produkt VALUES (1, 'mleko', 12.4);
INSERT INTO produkt VALUES (2, 'chleb', 1.94);
INSERT INTO produkt VALUES (3, 'cukier', 2.4);
INSERT INTO produkt VALUES (4, 'woda', 1.24);

CREATE OR REPLACE PROCEDURE aktualizacja_ceny(
  p_id_produkt produkt.id%TYPE,p_procent NUMBER) IS
BEGIN
  UPDATE produkt SET cena = cena * (1+p_procent/100) WHERE id = p_id_produkt;
END;
/

EXECUTE aktualizacja_ceny(3,20);
/

/*
3. Napisz funkcj� o nazwie wiek(p_data_ur), kt�ra dla podanej przez parametr warto�ci daty
urodzenia obliczy wiek osoby. Przetestuj dzia�anie napisanej funkcji. 
*/
CREATE OR REPLACE FUNCTION wiek(p_data_ur DATE) RETURN number IS
data_dzis DATE := SYSDATE;
BEGIN
  
  return Floor(Trunc(months_between(data_dzis,p_data_ur))/12);
END;
/
DECLARE
data DATE := '1986-09-30';
BEGIN 
  dbms_output.put_line('wiek to ' || wiek(data));
END;
/

/*
4. Dana jest tabela: CREATE TABLE l_pierwsze(liczba INT);
Napisa� procedur� o nazwie wpisz_liczby_pierwsze(p_od,p_do), kt�ra wpisze do tabeli
l_pierwsze wszystkie liczby pierwsze z przedzia�u <p_od,p_do>.
Napisa� instrukcj� testuj�c� dzia�anie utworzonej procedury. 
*/

CREATE TABLE l_pierwsze(liczba INT);
/

CREATE OR REPLACE FUNCTION czy_pierwsza(liczba NUMBER) RETURN BOOLEAN IS
pierwiastek NUMBER := sqrt(liczba);
BEGIN
  FOR i IN 2..pierwiastek LOOP
    IF (MOD(liczba,i)=0) THEN
      return FALSE;
    END IF;
  END LOOP;
return TRUE;
END;
/

CREATE OR REPLACE PROCEDURE wpisz_liczby_pierwsze(od NUMBER,do NUMBER) IS
BEGIN
FOR i IN od..do LOOP
 IF (czy_pierwsza(i)) THEN
  INSERT INTO l_pierwsze VALUES (i);
 END IF;
END LOOP;
END;
/

BEGIN
 wpisz_liczby_pierwsze(100,400);
END;
/
/*
5. a) Napisa� funkcj� o nazwie czy_piatek_trzynastego(p_data) zwracaj�c� prawd�, gdy zadana
przez parametr p_data jest pi�tkiem trzynastego lub fa�sz, gdy nie jest to pi�tek trzynastego.
*/
CREATE OR REPLACE FUNCTION czy_piatek_trzynastego(p_data DATE) RETURN boolean IS
BEGIN
IF (extract(day from p_data) = 13) and (to_char(p_data,'D') = 5) THEN
  RETURN TRUE;
ELSE
  RETURN FALSE;
END IF;
END;
/

/* b) Utworzy� tabel� urodziny(id_osoba,imie,nazwisko,data_ur) i doda� do niej kilka rekord�w. */
CREATE TABLE urodziny(
  id_osoba NUMBER, 
  imie VARCHAR2(20),
  nazwisko VARCHAR2(40),
  data_ur DATE);
/
INSERT INTO urodziny values (1, 'Jan', 'Kowalski', to_date('13-09-1985','dd-mm-yyyy'));
INSERT INTO urodziny values (2, 'Krystyna', 'Pestka', to_date('24-07-1975','dd-mm-yyyy'));
INSERT INTO urodziny values (3, 'Kamil', 'Zonka', to_Date('04-01-1990','dd-mm-yyyy'));
INSERT INTO urodziny values (4, 'Maciej', 'Roka', to_date( '13-05-1966','dd-mm-yyyy'));
/

/*
c) U�yj funkcji czy_piatek_trzynastego i z tabeli urodziny wypisz wszystkie osoby, kt�re urodzi�y
si� w pi�tek trzynastego.
*/
BEGIN
dbms_output.put_line('lista os�b urodzonych w piatek trzynastego: ');
dbms_output.put_line('----------------------------------');
FOR rekord IN (select * from urodziny) LOOP
  IF (czy_piatek_trzynastego(rekord.data_ur)) then
    dbms_output.put_line(rekord.imie || ' ' || rekord.nazwisko);
  end if;
END LOOP;
END;
/

/*
d) Napisa� procedur� o nazwie wypisz_piatki_trzynastego(p_data_od,p_data_do), kt�ra wpisze
na ekranie wszystkie pi�tki trzynastego z zakresu dat <data_od,data_do>. U�yj funkcji
czy_piatek_trzynastego. Przetestuj dzia�anie utworzonej procedury. 
*/

CREATE OR REPLACE PROCEDURE wypisz_piateki_trzynastego(p_data_od DATE, p_data_do DATE) IS
poczatek number := to_number(to_char(p_data_od,'j'));
koniec NUMBER := to_number(to_char(p_data_do,'j'));
BEGIN
  FOR data in poczatek..koniec LOOP
    IF (czy_piatek_trzynastego(to_date(data,'j'))) THEN
      dbms_output.put_line('znaleziono piatek trzynastego: ' || to_char(to_date(data,'j'),'dd-mon-yyyy'));
    END IF;
  END LOOP;
END;
/
DECLARE
od date := '2017-01-01';
do date := '2018-01-01';
BEGIN
wypisz_piateki_trzynastego('2016-01-01', do);
END;
/