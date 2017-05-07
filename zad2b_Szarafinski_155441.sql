SET SERVEROUTPUT ON;
/

/*
1.
Zadeklaruj zmienn� powi�zan� o nazwie v_wynik. Utw�rz etykiet� dla bloku zewn�trznego o nazwie etykieta_zewnetrzna
 oraz zadeklaruj zmienn� o nazwie v_liczba. Nast�pnie dla bloku wewn�trznego zadeklaruj zmienn� o identycznej nazwie 
v_liczba. (Mamy dwie zmienne o nazwie v_liczba � w bloku zewn�trznym i wewn�trznym.) 
Wykonaj mno�enie obu zmiennych v_liczba w bloku wewn�trznym z przypisaniem wyniku dozmiennej powi�zanej 
v_wynik. Zako�cz dzia�anie bloku anonimowego. Wy�wietl na ekranie warto�� zmiennej v_wynik. Warto�ci obu zmiennych 
v_liczba pobierz od u�ytkownika. 
 */
 
 VARIABLE v_wynik NUMBER;
 /
 
 <<l_zewnetrzna>>
DECLARE
 v_liczba NUMBER(11,2) := &podaj_liczbe1;
 BEGIN
  DECLARE
    v_liczba NUMBER(11,2) := &podaj_liczbe2;
  BEGIN
  :v_wynik := v_liczba * l_zewnetrzna.v_liczba;
  END;
  DBMS_OUTPUT.PUT_LINE('Wynik to: ' || :v_wynik);
END;

/*
2.
Dana jest tabela z przyk�adowymi rekordami: 
CREATE TABLE buty(id_buty INT,  
typ VARCHAR2(20),marka VARCHAR2(20),rozmiar NUMBER(8,2)); 
INSERT INTO buty VALUES(1,'sportowe','nike',44); 
INSERT INTO buty VALUES(2,'sportowe','reebok',45); 
INSERT INTO buty VALUES(3,'pantofle','fly-high',46)
; 
Wczytaj od u�ytkownika rozmiar buta, sprawd� czy taki rozmiar buta jest dost�pny i wypisz na 
ekranie odpowiedni� informacj� "Posiadamy buty w twoim rozmiarze, zapraszamy." lub "Nie 
posiadamy but�w w twoim rozmiarze, przykro nam.". 
*/
-- ju� wprowadzone dane
/*
CREATE TABLE buty(
id_buty INT,  
typ VARCHAR2(20),
marka VARCHAR2(20),
rozmiar NUMBER(8,2)
); 
INSERT INTO buty VALUES(1,'sportowe','nike',44); 
INSERT INTO buty VALUES(2,'sportowe','reebok',45); 
INSERT INTO buty VALUES(3,'pantofle','fly-high',46)
 /
 */
 
 DECLARE
 v_rozmiarUzytkownika buty.rozmiar%TYPE := &podaj_rozmiar_buta;
 v_dopasowania buty.rozmiar%TYPE;
 BEGIN
 SELECT COUNT(*) INTO v_dopasowania FROM buty WHERE rozmiar = v_rozmiarUzytkownika;
 IF v_dopasowania > 0 THEN 
  dbms_output.put_line('Posiadamy buty w twoim rozmiarze, zapraszamy.');
  ELSE 
  dbms_output.put_line('Nie posiadamy but�w w twoim rozmiarze, przykro nam.'); 
 END IF;
 END;
 /
 
 /*
 3.
Pobierz od u�ytkownika numer miesi�ca i wypisz na ekranie jego nazw� lub komunikat "nie ma 
takiego miesi�ca". U�yj instrukcji CASE z wyra�eniem. 
*/
DECLARE
 v_miesiac NUMBER(2) := &podaj_miesiac;
 v_miesiac_slownie VARCHAR2(30);
BEGIN
 CASE v_miesiac
  WHEN 1 THEN v_miesiac_slownie := 'Styczen';
  WHEN 2 THEN v_miesiac_slownie := 'Luty';
  WHEN 3 THEN v_miesiac_slownie := 'Marzec';
  WHEN 4 THEN v_miesiac_slownie := 'Kwiecien';
  WHEN 5 THEN v_miesiac_slownie := 'Maj';
  WHEN 6 THEN v_miesiac_slownie := 'Czerwiec';
  WHEN 7 THEN v_miesiac_slownie := 'Lipiec';
  WHEN 8 THEN v_miesiac_slownie := 'Sierpien';
  WHEN 9 THEN v_miesiac_slownie := 'Wrzesien';
  WHEN 10 THEN v_miesiac_slownie := 'Pazdziernik';
  WHEN 11 THEN v_miesiac_slownie := 'Listopad';
  WHEN 12 THEN v_miesiac_slownie := 'Grudzien';
  ELSE v_miesiac_slownie := 'Nie ma takiego miesiaca.';
END CASE;

DBMS_OUTPUT.PUT_LINE('Podany miesiac slownie to: ' || v_miesiac_slownie);
END;
/

/*
4.
Dana jest tabela i przyk�adowe rekordy: 
CREATE TABLE student (
id_student NUMBER(11), 
imie VARCHAR2(15),  
nazwisko VARCHAR2(20), 
srednia NUMBER(4,2), 
stypendium NUMBER(8,2)
); 
INSERT INTO student VALUES (1,'Jan','Kowalski',5,2000); 
INSERT INTO student VALUES (2,'Anna','Zdolna',4, 1000); 
INSERT INTO student VALUES (3,'Agata','Muza',3.5, 100); 
INSERT INTO student VALUES (4,'Anna','Kula',3, 1); 
INSERT INTO student VALUES (5,'Kacper','Adamek',2, 0); 

Wczytaj identyfikator studenta. (Zak�adamy, ze zawsze b�dzie istnia� wczytany identyfikator.) 
Odczytaj wysoko�� stypendium wskazanego studenta i wypisz na ekranie komunikat:  
a) je�li stypendium jest najwy�sze: "Najwy�sze stypendium", 
b) je�li stypendium jest najni�sze: "Najni�sze stypendium", 
c) je�li nie jest to ani najwy�sze ani najni�sze stypendium to wypisz jeden z pasuj�cych
poni�szych komunikat�w:  
c1) "Stypendium powy�ej �redniej",  
c2) "Stypendium poni�ej �redniej", 
c3) "Stypendium r�wne �redniej". 
U�yj instrukcji IF. 
*/

-- stworzono juz tabele
/*
CREATE TABLE student (
id_student NUMBER(11), 
imie VARCHAR2(15),  
nazwisko VARCHAR2(20), 
srednia NUMBER(4,2), 
stypendium NUMBER(8,2)
); 
/

INSERT INTO student VALUES (1,'Jan','Kowalski',5,2000); 
INSERT INTO student VALUES (2,'Anna','Zdolna',4, 1000); 
INSERT INTO student VALUES (3,'Agata','Muza',3.5, 100); 
INSERT INTO student VALUES (4,'Anna','Kula',3, 1); 
INSERT INTO student VALUES (5,'Kacper','Adamek',2, 0); 
*/

DECLARE
v_id student.id_student%TYPE := &podaj_identyfikator;
v_max student.stypendium%TYPE;
v_min student.stypendium%TYPE;
v_srednia student.stypendium%TYPE;
v_st_stypendium student.stypendium%TYPE;
BEGIN
 SELECT MAX(stypendium) INTO v_max FROM student;
 SELECT MIN(stypendium) INTO v_min FROM student;
 SELECT AVG(stypendium) INTO v_srednia FROM student;
 SELECT stypendium INTO v_st_stypendium FROM student WHERE id_student = v_id;
 IF v_st_stypendium = v_max THEN
  DBMS_OUTPUT.PUT_LINE('Najwy�sze stypendium.');
 ELSIF v_st_stypendium = v_min THEN
  DBMS_OUTPUT.PUT_LINE('Najni�sze stypendium.');
 ELSE
    IF v_st_stypendium > v_srednia THEN
      DBMS_OUTPUT.PUT_LINE('Stypendium powy�ej �redniej.');  
    ELSIF v_st_stypendium < v_srednia THEN
      DBMS_OUTPUT.PUT_LINE('Stypendium poni�ej �redniej.');
    ELSE 
      DBMS_OUTPUT.PUT_LINE('Stypendium r�wne �redniej.');
    END IF;
 END IF;
END;
/
/*
5.
Wykonaj ponownie powy�sze zadanie u�ywaj�c instrukcji CASE z wyszukiwaniem, nie u�ywaj instrukcji IF. 
*/

DECLARE
v_id student.id_student%TYPE := &podaj_identyfikator;
v_max student.stypendium%TYPE;
v_min student.stypendium%TYPE;
v_srednia student.stypendium%TYPE;
v_st_stypendium student.stypendium%TYPE;
BEGIN
 SELECT MAX(stypendium) INTO v_max FROM student;
 SELECT MIN(stypendium) INTO v_min FROM student;
 SELECT AVG(stypendium) INTO v_srednia FROM student;
 SELECT stypendium INTO v_st_stypendium FROM student WHERE id_student = v_id;
 CASE
  WHEN v_st_stypendium = v_max THEN DBMS_OUTPUT.PUT_LINE('Najwy�sze stypendium.');
  WHEN v_st_stypendium = v_min THEN DBMS_OUTPUT.PUT_LINE('Najni�sze stypendium.');
  WHEN v_st_stypendium > v_srednia THEN DBMS_OUTPUT.PUT_LINE('Stypendium powy�ej �redniej.');  
  WHEN v_st_stypendium < v_srednia THEN DBMS_OUTPUT.PUT_LINE('Stypendium poni�ej �redniej.');
  ELSE 
      DBMS_OUTPUT.PUT_LINE('Stypendium r�wne �redniej.');
END CASE;
END;
/

/*
6.
Utw�rz tabel� osoba(id_osoba,imie,nazwisko,pensja)
zawieraj�c� rekordy 
1 Jan Kowalski 1900, 
2 Anna Makurat 2100, 
3 Jerzy �o� 2300, 
4 Ewa1 Kot1 2601,  
4 Ewa2 Kot2 2602. 
Wczytaj od u�ytkownika identyfikator osoby. Je�li osoba o wczytanym identyfikatorze nie istnieje 
to wy�wietl na ekranie komunikat "Osoba o id_osoba = <id_osoba> nie istnieje!", je�li istnieje 
wi�cej ni� jedna taka osoba, to wtedy wy�wietl komunikat "Identyfikator id_osoba = <id_osoba> 
nie jest unikatowy!", je�li istnieje dok�adnie jedna taka osoba to wy�wietl na ekranie wielko�� 
pensji tej osoby oraz  
a) w przypadku gdy ona posiada pensj� mniejsz� ni� 2000 z�, to podwy�sz jej pensj� o 10%, 
odczytaj pensj� po podwy�ce i wy�wietl komunikat "Pensja po podwy�szeniu wynosi <pensja> z�", 
b) w przypadku gdy ona posiada pensj� wy�sz� ni� 3000 z�, to obni� jej pensj� o 2%, odczytaj 
pensj� po obni�ce i wy�wietl komunikat "Pensja po obni�ce wynosi <pensja> z�", 
c) w przeciwnym przypadku wy�wietl komunikat "Pensja pomi�dzy 2000 z� a 3000 z�". 
*/

-- stworzono juz tabele
/*
CREATE TABLE osoba(
  id_osoba NUMBER(11) NOT NULL, 
  imie VARCHAR2(20),
  nazwisko VARCHAR2(50),
  pensja NUMBER(10,2)
  );
/
INSERT INTO osoba VALUES (1, 'Jan', 'Kowalski', 1900);
INSERT INTO osoba VALUES (2, 'Anna', 'Makurat', 2100);
INSERT INTO osoba VALUES (3, 'Jerzy', '�o�', 2300);
INSERT INTO osoba VALUES (4, 'Ewa1', 'Kot1', 2601);
INSERT INTO osoba VALUES (4, 'Ewa2', 'Kot2', 2602);
*/

DECLARE
v_id osoba.id_osoba%TYPE := &podaj_id;
v_licznik NUMBER;
v_pensja osoba.pensja%TYPE;

BEGIN
SELECT COUNT(*) INTO v_licznik FROM osoba WHERE id_osoba = v_id;
IF v_licznik = 0 THEN
  dbms_output.put_line('Osoba o id_osoba = ' || v_id || ' nie istnieje!');
ELSE
  CASE
   WHEN v_licznik > 1 THEN dbms_output.put_line('Identyfikator id_osoba ' || v_id || ' nie jest unikatowy!');
   ELSE
      SELECT pensja INTO v_pensja FROM osoba WHERE id_osoba = v_id;
      dbms_output.put_line('Pensja u�ytkownika to: ' || v_pensja);
      
      IF v_pensja < 2000 THEN
        UPDATE osoba SET pensja = (pensja*1.10) WHERE id_osoba = v_id;
        SELECT pensja INTO v_pensja FROM osoba WHERE id_osoba = v_id;
        dbms_output.put_line('Pensja po podwy�szeniu wynosi: ' || v_pensja || 'zl');
      ELSIF v_pensja > 3000 THEN
        UPDATE osoba SET pensja = (pensja*0.98) WHERE id_osoba = v_id;
        SELECT pensja INTO v_pensja FROM osoba WHERE id_osoba = v_id;
        dbms_output.put_line('Pensja po obni�ce wynosi: ' || v_pensja || 'zl');
      ELSE
       dbms_output.put_line('Pensja pomi�dzy 2000 z� a 3000 z�');
      END IF;
  END CASE;
END IF;
END;
/

/*
7. Napisz program, kt�ry b�dzie wy�wietla�, w zale�no�ci od wyboru u�ytkownika, bie��c� dat� 
systemow� (wyb�r 'D') lub bie��cy czas systemowy (wyb�r 'C'). 
*/

DECLARE
v_wybor VARCHAR2(1) := '&podaj_litere';
BEGIN
  IF UPPER(v_wybor) = 'D' THEN
  dbms_output.put_line('Data systemowa to: ' || TO_CHAR (SYSDATE, 'Day, DD Month YYYY'));
  ELSIF UPPER(v_wybor) = 'C' THEN
  dbms_output.put_line('Czas systemowy to: ' || TO_CHAR (SYSDATE, 'HH24:MI:SS'));
  ELSE
  dbms_output.put_line('Podano niewlasciwa litere.');
  END IF;
END;
/