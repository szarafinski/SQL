/* 
1. Zadeklaruj dwie zmienne o nazwach v_tekst, v_liczba i wartoœciach odpowiednio „Baza danych to
uporz¹dkowany zbiór danych” oraz 2,7182. Wyœwietl wartoœci tych zmiennych na ekranie. 
*/

SET SERVEROUTPUT ON;
/

DECLARE
 v_tekst VARCHAR2(50) := 'Baza danych to uporz¹dkowany zbiór danych' ;
 v_liczba NUMBER(5,4) := 2.7182;
BEGIN
  DBMS_OUTPUT.PUT_LINE('Zmienna tekst: ' || v_tekst);
  DBMS_OUTPUT.PUT_LINE('Zmienna liczba: ' || v_liczba);
END;
/

/*
2. Napisz program obliczaj¹cy iloczyn dwóch liczb ca³kowitych. Liczby powinny byæ podane z
konsoli przez u¿ytkownika. 
*/

DECLARE
v_liczba NUMBER (10,2) := &podaj_liczbe_1;
v_liczba2 NUMBER (10,2) := &podaj_liczbe_2;
BEGIN
v_liczba := v_liczba * v_liczba2;
DBMS_OUTPUT.PUT_LINE('Iloraz podanych liczb to: ' || v_liczba);
END;
/

/*
3. Napisaæ program obliczaj¹cy pole powierzchni ca³kowitej i objêtoœæ kuli. W programie pos³u¿ siê
zdefiniowan¹ przez siebie sta³¹ c_pi=3,14159265. Wczytaj promieñ kuli od u¿ytkownika i wyœwietl
wyniki na ekranie.
*/

DECLARE
c_pi CONSTANT NUMBER(10,8) := 3.14159265;
v_promien NUMBER(10,2) := &podaj_liczbe;
v_objetosc NUMBER(10,2);
v_powierzchnia NUMBER(10,2);
BEGIN
v_objetosc := (4/3*c_pi*v_promien**3);
v_powierzchnia := 4*c_pi*v_promien**2;
  DBMS_OUTPUT.PUT_LINE('Objêtoœæ: ' || v_objetosc);
  DBMS_OUTPUT.PUT_LINE('Powierzchnia: ' || v_powierzchnia);
END;
/

/*
4. Utwórz tabele pracownik(id_pracownik, imie, nazwisko) z przyk³adowymi rekordami:
1 Jan Kowalski, 2 Jerzy Nowak, 3 Anna Ga³ka, 4 Hanna Mia³ka.
Zadeklaruj zmienn¹ v_ilosc, oblicz iloœæ rekordów w tabeli pracownik i otrzymany wynik zapisz do
zmiennej v_ilosc. U¿ywaj¹c zmiennej v_ilosc wypisz na ekranie komunikat w formacie: „W tabeli
pracownik jest <iloœæ> rekordów”.
*/
-- utworzona wczeœniej
/*
CREATE TABLE pracownik (
id NUMBER(3) NOT NULL,
imie VARCHAR(15) NOT NULL, 
nazwisko VARCHAR(20) NOT NULL, 
PRIMARY KEY(id)
);

INSERT INTO pracownik (id, imie, nazwisko) VALUES (1, 'Jan', 'Kowalski');
INSERT INTO pracownik (id, imie, nazwisko) VALUES (2, 'Jerzy', 'Nowak');
INSERT INTO pracownik (id, imie, nazwisko) VALUES (3, 'Anna', 'Galka');
INSERT INTO pracownik (id, imie, nazwisko) VALUES (4, 'Hanna', 'Mialka');
*/
DECLARE 
v_ilosc NUMBER;
BEGIN
SELECT COUNT(*) INTO v_ilosc FROM pracownik;
DBMS_OUTPUT.PUT_LINE('W tabeli pracownik jest ' || v_ilosc || ' rekordów.');
END;
/

/*
5. U¿ywaj¹c typu zakotwiczonego zadeklaruj zmienne v_imie i v_nazwisko o tych samych typach co
typy kolumn imie i nazwisko z tabeli pracownik(id_pracownik, imie, nazwisko). Nastêpnie wczytaj
do nich imiê i nazwisko pracownika o identyfikatorze równym 3. Wyœwietl na ekranie wczytane
imiê i nazwisko. Przyjmijmy, ¿e pracownik o identyfikatorze równym 3 zawsze istnieje i jest
dok³adnie jeden taki pracownik. 
*/
DECLARE
 v_imie pracownik.imie%TYPE;
 v_nazwisko pracownik.nazwisko%TYPE;
BEGIN
  SELECT imie INTO v_imie FROM pracownik WHERE id=3;
  SELECT nazwisko INTO v_nazwisko FROM pracownik WHERE id=3;
  DBMS_OUTPUT.PUT_LINE('Pracownik nr 3 to: ' || v_imie || ' ' || v_nazwisko);
END;
/

/*
6. Do zmiennej v_rekord wczytaj rekord z danymi pracownika o identyfikatorze równym 2. 
(Zak³adamy, ¿e taki pracownik istnieje.) Wyœwietl wczytane dane na ekranie w formacie: 
„Pracownik o identyfikatorze równym <numer> to <imie> <nazwisko>”. Nastêpnie w zmiennej 
v_rekord zmieñ wartoœæ pola id_pracownik na 10 i do tabeli pracownik dodaj nowy rekord o 
wartoœci zmiennej v_rekord. Wyœwietl na ekranie zawartoœæ tabeli pracownik.   
*/
DECLARE
 v_rekord pracownik%ROWTYPE;
BEGIN
SELECT * INTO v_rekord FROM pracownik WHERE id = 2;
DBMS_OUTPUT.PUT_LINE('Pracownik o identyfikatorze równym ' || v_rekord.id || ' to ' || v_rekord.imie || ' ' || v_rekord.nazwisko);
v_rekord.id := 10;
DBMS_OUTPUT.PUT_LINE('Pracownik o identyfikatorze równym ' || v_rekord.id || ' to ' || v_rekord.imie || ' ' || v_rekord.nazwisko);
INSERT INTO pracownik VALUES v_rekord;
END;
/
SELECT * FROM pracownik;
/*
7. Zosta³a utworzona tabela: CREATE TABLE info(nazwa VARCHAR(50) NOT NULL, ilosc INT);
Dodaj do niej trzy rekordy, dla których kolumna nazwa przyjmuje odpowiednio wartoœci: tabele,
widoki, ograniczenia (ang. constraints). Nastêpnie zadeklaruj trzy zmienne i przypisz do nich
odpowiednio wartoœci obliczeñ ile zalogowany u¿ytkownik ma tabel, widoków i ograniczeñ w
bazie danych. Zaktualizuj rekordy w tabeli info poprzez uaktualnienie wartoœci kolumny ilosc
wpisuj¹c obliczon¹ wczeœniej iloœæ tabel, widoków i ograniczeñ. 
Wskazówka: Polecenie SELECT * FROM DICTIONARY;  wyœwietli listê nazw widoków s³owników 
systemowych zalogowanego u¿ytkownika. Odszukaj na niej nazwy widoków potrzebnych do 
rozwi¹zania zadania  (np.:  user_tables). 
*/

-- zrobiona tabela
/*
CREATE TABLE info(nazwa VARCHAR(50) NOT NULL, ilosc INT);
INSERT INTO info (nazwa) VALUES ('tabele');
INSERT INTO info (nazwa) VALUES ('widoki');
INSERT INTO info (nazwa) VALUES ('ograniczenia');
*/
DECLARE
v_tabeleIlosc info.ilosc%TYPE;
v_widokiIlosc info.ilosc%TYPE;
v_ograniczeniaIlosc info.ilosc%TYPE;
BEGIN
 SELECT COUNT(*) INTO v_tabeleIlosc FROM USER_TABLES;
 SELECT COUNT(*) INTO v_widokiIlosc FROM USER_VIEWS;
 SELECT COUNT(*) INTO v_ograniczeniaIlosc FROM USER_CONSTRAINTS;
 UPDATE info SET ilosc=v_tabeleIlosc WHERE nazwa='tabele';
 UPDATE info SET ilosc=v_widokiIlosc WHERE nazwa='widoki';
 UPDATE info SET ilosc=v_ograniczeniaIlosc WHERE nazwa='ograniczenia';
END;
/
SELECT * FROM info;
/

/*
8.
Utwórz tabelê osoba(id_osoba, imie, nazwisko, roczne_zarobki) oraz dodaj do niej rekordy:  
1 Jan Kowalski 8765,12; 2 Anna Nowak 6543,11; 3 Ewa Nowak 5555,55. 
Zdefiniuj w oparciu o typ NUMBER w³asny typ pochodny o nazwie KASA i zadeklaruj zmienn¹ 
tego typu. Wczytaj do niej roczne zarobki Jana Kowalskiego i wypisz je na ekranie. 
*/

-- ju¿ stworzono tablice
/*
CREATE TABLE osoby(
  id NUMBER(11) NOT NULL, 
  imie VARCHAR2(20),
  nazwisko VARCHAR2(50),
  roczne_zarobki NUMBER(10,2)
  );
/
INSERT INTO osoby (id, imie, nazwisko, roczne_zarobki) VALUES (1, 'Jan', 'Kowalski',8765.12);
INSERT INTO osoby (id, imie, nazwisko, roczne_zarobki) VALUES (2, 'Anna', 'Nowak', 6543.11);
INSERT INTO osoby (id, imie, nazwisko, roczne_zarobki) VALUES (3, 'Ewa', 'Nowak', 5555.55);
/
*/

DECLARE
  SUBTYPE s_kasa IS NUMBER(10,2);
  kasa s_kasa;
BEGIN
 SELECT roczne_zarobki INTO kasa FROM osoby WHERE id=1;
 kasa := kasa * 12;
 DBMS_OUTPUT.PUT_LINE('Roczne zarobki Jana Kowalskiego to: ' || kasa || ' PLN. ');
END;
/

