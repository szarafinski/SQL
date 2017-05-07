SET SERVEROUTPUT ON;
/

/*
1. Napisa� program, kt�ry dla i=0,1,2,�,100 wypisze 2^i (2 do pot�gi i). U�yj p�tli LOOP.
Oczekiwany wynik:
2^0=1
2^1=2
2^2=4
2^3=8
2^4=16
� 
*/

/* p�tla FOR */
DECLARE
v_wynik INTEGER;
BEGIN
  FOR v_licznik IN 0..100 LOOP
    v_wynik := 2**v_licznik;
    DBMS_OUTPUT.PUT_LINE('2^' || v_licznik || ' = ' || v_wynik);
  END LOOP;
END;
/
/* zwykla petla LOOP */
DECLARE
v_wynik INTEGER;
v_licznik PLS_INTEGER := 0;
BEGIN
  LOOP
    v_wynik := 2**v_licznik;
    DBMS_OUTPUT.PUT_LINE('2^' || v_licznik || ' = ' || v_wynik);
    v_licznik := v_licznik + 1;
    EXIT WHEN v_licznik = 101;
  END LOOP;
END;
/
/*
2. Napisa� program, kt�ry dla podanego przez u�ytkownika n obliczy warto�� wyra�enia
n!=1*2*3*�*n (liczymy silni� z liczby n). U�yj p�tli for.
Oczekiwany wynik dla n=7 to: 7!=5040. 
*/
DECLARE
 v_liczba INTEGER := &podaj_liczbe;
 v_wynik INTEGER :=1;
BEGIN
  FOR v_licznik IN 2..v_liczba LOOP
   v_wynik := v_wynik*v_licznik;
  END LOOP;
  DBMS_OUTPUT.PUT_LINE(v_liczba || '!= ' || v_wynik);
END;
/
/*
3. Napisa� program wypisuj�cy na ekranie pi�� losowych ocen w skali 2-5. U�yj p�tli while.
Wskaz�wka: a) ustawienie zarodka:
DBMS_RANDOM.SEED(TO_CHAR(SYSDATE,'MM-DD-YYYY HH24:MI:SS'));
b) wylosowanie liczby:
ROUND(DBMS_RANDOM.VALUE(2, 5)); 
*/
DECLARE
v_licznik PLS_INTEGER :=1;
BEGIN
  DBMS_RANDOM.SEED(TO_CHAR(SYSDATE,'MM-DD-YYYY HH24:MI:SS')); 
  WHILE v_licznik < 6 LOOP
        DBMS_OUTPUT.PUT_LINE('Wylosowana liczba nr ' || v_licznik || ' to: ' ||
        ROUND(DBMS_RANDOM.VALUE(2, 5))); 
        v_licznik := v_licznik + 1;
  END LOOP;
END;
/
/*
4. Stw�rz tabel� o nazwie nowa z jedn� kolumn� o nazwie liczba b�d�c� typu VARCHAR2(10), a
nast�pnie wpisz do niej za pomoc� dowolnej p�tli kolejne liczby ca�kowite od 1 do 113 z
pomini�ciem liczb: 5, 7, 55, 77. 
*/

/* utworzona tablica
CREATE TABLE nowa (liczba VARCHAR2(10));
*/

DECLARE
 rekord nowa%ROWTYPE;
 v_licznik PLS_INTEGER :=1;
BEGIN
  WHILE v_licznik < 114 LOOP
    IF v_licznik = 5 OR v_licznik = 7 OR v_licznik = 55 OR v_licznik = 77 THEN
      GOTO pomin;
    END IF;
    rekord.liczba := v_licznik;
    INSERT INTO nowa VALUES rekord;
    <<pomin>>
    v_licznik := v_licznik +1;
  END LOOP;
END;
/
/* alternatywnie */
BEGIN
  FOR v_licznik IN 1..113 LOOP
    CONTINUE WHEN v_licznik = 5 OR v_licznik = 7 OR v_licznik = 55 OR v_licznik = 77; 
    INSERT INTO nowa (liczba) VALUES (v_licznik);
  END LOOP;
END;
/
/*
5. Stw�rz tabel� nagroda(id_nagroda, nazwa, kwota). Dodaj 1000 rekord�w do tabeli nagroda
takich, �e: id_nagroda to liczby ca�kowite od 1 do 1000, nazwa to �a�cuchy znak�w odpowiednio
nazwa0001, nazwa0002, ..., nazwa0999, nazwa1000, kwota to wynik wyra�enia (id_nagroda*123
modulo 10000)/3 zaokr�glony do dw�ch miejsc po przecinku.
*/

/* stworzono tabele 
CREATE TABLE nagroda (id_nagroda INT, nazwa VARCHAR2(20), kwota INT);
*/
DECLARE
rekord nagroda%ROWTYPE;
BEGIN
  FOR v_i IN 1..1000 LOOP
    rekord.id_nagroda := v_i;
    rekord.nazwa := 'nazwa' || lpad('' || v_i, 4, '0');
    rekord.kwota := round(mod(v_i * 123, 10000)/3,2);
    INSERT INTO nagroda VALUES rekord;
  END LOOP;
END;
/
/*
6. Dana jest tabela:
CREATE TABLE wyplata(id_wyplata NUMBER(11) PRIMARY KEY, imie VARCHAR2(15),
nazwisko VARCHAR2(20), ile_dni INT, kwota NUMBER(22,2) );
i informacja ile dni przepracowa� dany pracownik:
INSERT INTO wyplata(id_wyplata,imie,nazwisko,ile_dni) VALUES(1,'Jan','Kowalski',1);
INSERT INTO wyplata(id_wyplata,imie,nazwisko,ile_dni) VALUES(2,'Jerzy','Nowak',5); 
INSERT INTO wyplata(id_wyplata,imie,nazwisko,ile_dni) VALUES(3,'Anna','Mak',7);
INSERT INTO wyplata(id_wyplata,imie,nazwisko,ile_dni) VALUES(4,'Ewa','Hak',11);
INSERT INTO wyplata(id_wyplata,imie,nazwisko,ile_dni) VALUES(5,'Joanna','Blondi',14);
INSERT INTO wyplata(id_wyplata,imie,nazwisko,ile_dni) VALUES(6,'Adam','Mocny',15);
INSERT INTO wyplata(id_wyplata,imie,nazwisko,ile_dni) VALUES(7,'Krzysztof','Gacek',18);
INSERT INTO wyplata(id_wyplata,imie,nazwisko,ile_dni) VALUES(8,'Jolanta','Fajna',21);
INSERT INTO wyplata(id_wyplata,imie,nazwisko,ile_dni) VALUES(9,'Anzelm','Agryf',26);
INSERT INTO wyplata(id_wyplata,imie,nazwisko,ile_dni) VALUES(10,'Wioletta','Markowska',30);
Nale�y wyliczy� kwot� wynagrodzenia i zapisa� jej warto�� do kolumny kwota w tabeli wyplata.
Zak�adamy, �e dni�wka pracownika za pierwszy dzie� pracy wynosi 1 grosz, a ka�da nast�pna
dni�wka jest dwa razy wi�ksza ni� dni�wka z dnia poprzedniego. Przyk�adowo po czterech
dniach pracy taki pracownik zarobi 1 gr + 2 gr + 4 gr + 8 gr = 15 gr. Dodatkowo przyjmijmy, �e
identyfikatory wyp�aty nie posiadaj� �dziur�. 

*/

/* wstawiona tablea juz
CREATE TABLE wyplata(id_wyplata NUMBER(11) PRIMARY KEY, imie VARCHAR2(15),
nazwisko VARCHAR2(20), ile_dni INT, kwota NUMBER(22,2) );
INSERT INTO wyplata(id_wyplata,imie,nazwisko,ile_dni) VALUES(1,'Jan','Kowalski',1);
INSERT INTO wyplata(id_wyplata,imie,nazwisko,ile_dni) VALUES(2,'Jerzy','Nowak',5); 
INSERT INTO wyplata(id_wyplata,imie,nazwisko,ile_dni) VALUES(3,'Anna','Mak',7);
INSERT INTO wyplata(id_wyplata,imie,nazwisko,ile_dni) VALUES(4,'Ewa','Hak',11);
INSERT INTO wyplata(id_wyplata,imie,nazwisko,ile_dni) VALUES(5,'Joanna','Blondi',14);
INSERT INTO wyplata(id_wyplata,imie,nazwisko,ile_dni) VALUES(6,'Adam','Mocny',15);
INSERT INTO wyplata(id_wyplata,imie,nazwisko,ile_dni) VALUES(7,'Krzysztof','Gacek',18);
INSERT INTO wyplata(id_wyplata,imie,nazwisko,ile_dni) VALUES(8,'Jolanta','Fajna',21);
INSERT INTO wyplata(id_wyplata,imie,nazwisko,ile_dni) VALUES(9,'Anzelm','Agryf',26);
INSERT INTO wyplata(id_wyplata,imie,nazwisko,ile_dni) VALUES(10,'Wioletta','Markowska',30);
*/

DECLARE
dni INT;
liczba_pracownikow INT;
wynagrodzenie INT;
BEGIN
SELECT COUNT(*) INTO liczba_pracownikow FROM wyplata;
  FOR licznik IN 1..liczba_pracownikow LOOP
    SELECT ile_dni INTO dni FROM wyplata WHERE id_wyplata = licznik;
    wynagrodzenie := 2**dni -1;
    UPDATE wyplata SET kwota = wynagrodzenie WHERE id_wyplata = licznik;
  END LOOP;
END;
/
/* alternatywne rozwiazanie */
DECLARE
dni INT;
liczba_pracownikow INT;
wynagrodzenie INT := 0;
stawka INT;
BEGIN
SELECT COUNT(*) INTO liczba_pracownikow FROM wyplata;
  FOR licznik IN 1..liczba_pracownikow LOOP
    SELECT ile_dni INTO dni FROM wyplata WHERE id_wyplata = licznik;
        stawka := 1;
        wynagrodzenie :=0;
        FOR j IN 1..dni LOOP
          wynagrodzenie := wynagrodzenie + stawka;
          stawka := stawka*2; 
        END LOOP;
    UPDATE wyplata SET kwota = wynagrodzenie WHERE id_wyplata = licznik;
  END LOOP;
END;
/