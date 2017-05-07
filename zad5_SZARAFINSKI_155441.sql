SET SERVEROUTPUT ON
/*
1. Utw�rz tabel� pracownicy(id_pracownik, imie, nazwisko, plec, data_urodzenia, data_zatrudnienia,
stanowisko, pensja, dodatek) i dodaj do niej co najmniej 10 rekord�w, np:
INSERT INTO pracownicy VALUES (1,'Anna','Kowalska','K','1975-05-25','2001-12-01',
'kierownik',2300,500);
Usu� z tabeli pracownicy co drugi rekord wzgl�dem nazwisk i imion u�o�onych w porz�dku
alfabetycznym (czyli usuwamy 2, 4, 6, itd. rekord w narzuconym porz�dku). U�yj kursora jawnego
i p�tli LOOP. Pos�u� si� poleceniem FETCH. 
*/

/* tabela ju� stworzona*/
CREATE TABLE pracownicy (
id_pracownik NUMBER(11), 
imie VARCHAR2(20), 
nazwisko VARCHAR2(40), 
plec CHAR, 
data_urodzenia DATE, 
data_zatrudnienia DATE,
stanowisko VARCHAR2(20), 
pensja NUMBER(11,2), 
dodatek NUMBER(11,2)
);
/
/* testowa baza*/
DECLARE
rekord pracownicy%ROWTYPE;
BEGIN
FOR v_i IN 1..12 LOOP
 rekord.id_pracownik := v_i;
 rekord.imie := 'Anna' || v_i;
 rekord.nazwisko := 'Kowalska' || v_i;
 rekord.plec := 'K';
 rekord.data_urodzenia := '1975-05-25';
 rekord.data_zatrudnienia := '2001-12-01';
 rekord.stanowisko := 'kierownik';
 rekord.pensja := 2300;
 rekord.dodatek := 500;
 INSERT INTO pracownicy VALUES rekord;
END LOOP;
END;
/

/* wypelnienie */
INSERT INTO pracownicy VALUES (1,'Jan', 'Kowalski', 'M', '1958-07-06', '2000-12-03', 'kierownik', 2300, 100);
INSERT INTO pracownicy VALUES (2,'Janina', 'Plocka', 'K', '1978-04-14', '2003-10-07', 'dyrektor', 3500, 500);
INSERT INTO pracownicy VALUES (3,'Karolina', 'Wirkowicz', 'K', '1984-07-26', '1999-02-18', 'kierownik', 2900, 120);
INSERT INTO pracownicy VALUES (4,'Karol', 'Ma�la�ski', 'M', '1983-09-16', '2009-10-30', 'brygadzista', 3200, 300);
INSERT INTO pracownicy VALUES (5,'Andrzej', 'Zonka', 'M', '1988-04-13', '2007-01-03', 'brygadzista', 2690, 700);
INSERT INTO pracownicy VALUES (6,'Antonina', 'Majkowska', 'K', '1973-03-30', '2012-11-30', 'pracownik', 3800, 5900);
INSERT INTO pracownicy VALUES (7,'Kamil', 'Bunka', 'M', '1981-02-17', '2004-12-03', 'pracownik', 4700, 300);
INSERT INTO pracownicy VALUES (8,'Maciej', 'Forki', 'M', '1974-11-06', '2003-01-31', 'pracownik', 2600, 450);
INSERT INTO pracownicy VALUES (9,'Zosia', 'Macka', 'K', '1988-01-08', '2005-03-23', 'pracownik', 3670, 7000);
INSERT INTO pracownicy VALUES (10,'Kasia', 'Lusko', 'K', '1956-08-30', '2013-05-13', 'brygadzista', 12000, 321);

DECLARE
licznik NUMBER(11):= 0;
rekord pracownicy%ROWTYPE;
CURSOR usun_parzyste IS SELECT * FROM pracownicy ORDER BY nazwisko, imie FOR UPDATE;
BEGIN

OPEN usun_parzyste;
LOOP
  licznik := licznik + 1;
  FETCH usun_parzyste INTO rekord;
  IF licznik MOD 2 = 0 THEN
    DELETE FROM pracownicy WHERE ID_PRACOWNIK = rekord.id_pracownik;
  END IF;
  
  EXIT WHEN usun_parzyste%NOTFOUND;
END LOOP;
CLOSE usun_parzyste;

END;
/


/*
2. Wykorzystaj tabel� pracownicy z zadania 1. Zdefiniuj kursor jawny zawieraj�cy imiona, nazwiska i
daty zatrudnienia wszystkich kierownik�w. Pos�u� si� kursorem do wy�wietlenia rekord�w w
formie zda�: "Pracownik <imie> <nazwisko> pracuje na stanowisku kierownika od
<data_zatrudnienia>.". U�yj p�tli WHILE i pos�u� si� poleceniem FETCH. 
*/
DECLARE
rekord pracownicy%ROWTYPE;
CURSOR kursor IS SELECT * FROM pracownicy WHERE STANOWISKO = 'kierownik';
BEGIN
OPEN kursor;
FETCH kursor INTO rekord;
WHILE kursor%FOUND LOOP
  DBMS_OUTPUT.PUT_LINE('Pracownik ' || rekord.imie || ' ' || rekord.nazwisko || ' pracuje na stanowisku kierownika od ' || rekord.data_zatrudnienia);
  FETCH kursor INTO rekord;
END LOOP;
CLOSE kursor;
END;

/*
3. Wykorzystaj tabel� pracownicy z zadania 1. Zdefiniuj kursor jawny, dzi�ki kt�remu b�dzie mo�na
wy�wietli� na ekranie trzech najlepiej zarabiaj�cych pracownik�w patrz�c na wysoko�� zarobk�w
(bez dodatku). Uwzgl�dnij miejsca ex aequo. U�yj p�tli FOR. 
*/
DECLARE
rekord pracownicy%ROWTYPE;
CURSOR kursor IS select * from (
select imie, nazwisko, pensja, dense_rank() over (ORDER BY pensja DESC) as miejsce from pracownicy) where miejsce <4;
BEGIN
FOR rekord IN kursor
LOOP 
DBMS_OUTPUT.PUT_LINE('Miejsce: ' || rekord.miejsce || ', to ' || rekord.imie || ' ' || rekord.nazwisko);
END LOOP;
END;
/
/*4. Wykorzystaj tabel� pracownicy z zadania 1. Napisz program, kt�ry zapyta si� u�ytkownika o
nazw� stanowiska, a nast�pnie wypisze na ekranie w porz�dku alfabetycznym wszystkich
pracownik�w pracuj�cych na zadanym stanowisku. Zastosuj p�tl� FOR z kursorem
sparametryzowanym. 
*/

DECLARE
stanowisko pracownicy.stanowisko%TYPE := '&podaj_nazwe';
CURSOR kursor(nazwa pracownicy.stanowisko%TYPE) IS 
  SELECT *  FROM pracownicy WHERE stanowisko = nazwa ORDER BY nazwisko ;
BEGIN
 FOR rekord IN kursor(stanowisko) LOOP
  DBMS_OUTPUT.PUT_LINE(rekord.imie || ' ' || rekord.nazwisko);
 END LOOP;
END;
/

/*
Wykorzystaj tabel� pracownicy z zadania 1. 
W pewnej firmie powsta�a inicjatywa przyznania dodatku motywacyjnego dla jej pracownik�w. 
Dodatek jest przyznawany procentowo w stosunku do pensji podstawowej ka�dego pracownika. 
*) Ka�demu pracownikowi zarabiaj�cemu poni�ej 3000 z� przyznano tyle % dodatku, aby jego pensja plus ten dodatek by�a r�wna 3000 z�. 
*) Za ka�dy pe�ny rok pracy w firmie przyznano dodatkowo 1% dodatku. 
*) Osoby zajmuj�ce wy�sze stanowiska otrzyma�y dodatkowo: dyrektor � 20%, kierownik � 10%, brygadzista � 5% dodatku. 
*) Kobiety otrzyma�y dodatkowo dodatek 5%. 
Wszystkie dodatki si� sumuj� i s� przyznawane w podanej kolejno�ci, jednak w sumie nie mog� by� wy�sze ni� 60% pensji podstawowej  pracownika
Wyliczone kwoty dodatk�w dla pracownik�w nale�y zapisa� w kolumnie dodatek w tabeli pracownicy. 
(Warto�� poprzedniego dodatku w tabeli pracownicy nie ma znaczenia.) U�yj p�tli FOR z podzapytaniem. 
*/
DECLARE
wartosc NUMBER;
BEGIN
  FOR rekord IN (SELECT * FROM pracownicy) LOOP
    wartosc := 0;
    /* nadanie wartosci dodatku dla pensji poni�ej 3000 by pensja+dodatek bylo = 3000*/
    IF rekord.pensja < 3000 THEN
      wartosc := (3000 / rekord.pensja * 100) - 100;
    END IF;
    /* obliczenie ilosci lat przepracowanych i nadanie dodatku za przepracowane lata*/
    wartosc := wartosc + round((SYSDATE- rekord.data_zatrudnienia)/365-1);
    /* Osoby zajmuj�ce wy�sze stanowiska otrzyma�y dodatkowo: dyrektor � 20%, kierownik � 10%, brygadzista � 5% dodatku. */
    CASE rekord.stanowisko
      WHEN 'kierownik' THEN wartosc := wartosc + 10;
      WHEN 'dyrektor' THEN wartosc := wartosc + 20;
      WHEN 'brygadzista' THEN wartosc := wartosc + 5;
      ELSE wartosc := wartosc;
    END CASE;
    /* Kobiety otrzyma�y dodatkowo dodatek 5%. */
    CASE rekord.plec
     WHEN 'K' THEN wartosc := wartosc + 5;
     ELSE wartosc := wartosc;
    END CASE;
    wartosc := round(wartosc,2);
    IF wartosc < 60 THEN
      UPDATE pracownicy SET dodatek = (wartosc/100 * rekord.pensja) WHERE ID_PRACOWNIK = rekord.id_pracownik;
    END IF;
  END LOOP;
END;
/

/*
Dana jest tabela  
CREATE TABLE punkt(x INT, y INT); 
i przyk�adowe rekordy: 
BEGIN 
  FOR v_i IN 1..1000 LOOP 
    INSERT INTO punkt(x,y) VALUES (MOD(123*v_i,MOD(1
27*v_i,27)),MOD(147*v_i,37)); 
  END LOOP; 
END; 
Po wykonaniu zapytania  
SELECT x, y, count(*) AS ile FROM punkt GROUP BY x,
 y ORDER BY ile DESC;  
zauwa�ono, �e niekt�re warto�ci wsp�rz�dnych punkt
�w si� powtarzaj�.  
Napisz program w j�zyku PL/SQL, kt�ry pozostawi w t
abeli punkt unikatowe wsp�rz�dne 
punkt�w (x,y). 
(Nale�y usun�� wielokrotne wyst�pienia danego punkt
u (x,y) zachowuj�c pojedyncze wyst�pienie 
tego  punktu w tabeli punkt.)  U�yj p�tli FOR z podz
apytaniem. 
*/

CREATE TABLE punkt(x INT, y INT); 
BEGIN 
  FOR v_i IN 1..1000 LOOP 
    INSERT INTO punkt(x,y) VALUES (MOD(123*v_i,MOD(127*v_i,27)),MOD(147*v_i,37)); 
  END LOOP; 
END; 
/

SELECT x,y,count(*) AS ile FROM punkt GROUP BY x,y ORDER BY ile DESC;
SELECT count(*) AS ile FROM punkt;
select count(*) as ile from (Select x,y, count(*) from punkt group by x,y );

BEGIN
    FOR rekord IN (
        SELECT * FROM punkt
    ) LOOP
        DELETE punkt WHERE
            punkt.x = rekord.x
        AND punkt.y = rekord.y
        AND ROWID > ANY (
                SELECT ROWID FROM punkt WHERE 
                        punkt.x = rekord.x
                    AND punkt.y = rekord.y
               );
    END LOOP;
END;