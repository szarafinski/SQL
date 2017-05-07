SET SERVEROUTPUT ON
/*
Dana jest tabela ciastko(id_ciastko,nazwa,cena).  
Zdefiniuj wyzwalacz, który dla ka¿dego dodawanego ciastka bêdzie automatycznie przydziela³ 
kolejny wolny identyfikator id_ciastko. 
Przyk³adowo instrukcja: 
INSERT INTO ciastko(nazwa,cena) VALUES ('Beza',3.15);  
powinna poprawnie dodaæ ciastko, a kolumna id_ciastko nie mo¿e mieæ wartoœci NULL. 
Przetestuj dzia³anie utworzonego wyzwalacza. 
*/

CREATE TABLE ciastko(id NUMBER, nazwa VARCHAR2(20), cena NUMBER(11,2));
/
CREATE SEQUENCE ciastko_sek START WITH 1 INCREMENT BY 1 NOMAXVALUE;
/
CREATE TRIGGER insert_ciastko BEFORE INSERT ON ciastko FOR EACH ROW
BEGIN
  SELECT ciastko_sek.NEXTVAL INTO :NEW.id FROM dual;
END;
/

INSERT INTO ciastko(nazwa,cena) VALUES ('Beza',3.15); 
INSERT INTO ciastko(nazwa,cena) VALUES ('Paczek',2.95);
INSERT INTO ciastko(nazwa,cena) VALUES ('Bajaderka',1.79); 

/*
.
Dana jest tabela dane(id_dane,imie,nazwisko,pesel,data_ur,plec). Po wykonaniu instrukcji: 
INSERT INTO dane(imie,nazwisko,pesel) VALUES ('Jan','Kowalski','75052503553');  
a) Wyzwalacz powinien automatycznie zdefiniowaæ kolejny numer id_dane. 
b) Wyzwalacz powinien z numeru pesel wyci¹gn¹æ datê urodzenia i wpisaæ j¹ do kolumny 
data_ur. 
c) Wyzwalacz powinien z numeru pesel odczytaæ p³eæ i wpisaæ wartoœci 'K' lub 'M' do kolumny plec. 
Przetestuj dzia³anie utworzonego wyzwalacza. 
*/

CREATE TABLE dane(id NUMBER, imie VARCHAR2(20), nazwisko VARCHAR2(40), pesel NUMBER(11), data_ur DATE, plec CHAR);
/
CREATE SEQUENCE dane_sek START WITH 1 INCREMENT BY 1 NOMAXVALUE;
/
CREATE OR REPLACE TRIGGER insert_dane BEFORE INSERT ON dane FOR EACH ROW
DECLARE
tekst char;
BEGIN
  SELECT dane_sek.NEXTVAL INTO :new.id FROM DUAL;
  
  tekst := substr(:new.pesel,3,1);
  IF (tekst = 0) or (tekst = 1) Then
    SELECT to_date('19' || substr(:new.pesel,1,2),'yyyymmdd') into :new.data_ur from dual;
  elsif (tekst=8) or (tekst=9) then
    SELECT to_date('18' || substr(:new.pesel,1,2) || to_char((substr(:new.pesel,3,2) - 80),'09') || substr(:new.pesel,5,2), 'yyyy mmdd') into :new.data_ur from dual;
  elsif (tekst=2) or (tekst = 3) then
    SELECT to_date('20' || substr(:new.pesel,1,2) || to_char((substr(:new.pesel,3,2) - 20),'09') || substr(:new.pesel,5,2), 'yyyy mmdd') into :new.data_ur from dual;
  END IF;
  
  tekst := substr(:new.pesel,10,1);
  if (tekst =0) or (mod(tekst,2)=0) THEN
    SELECT 'K' INTO :new.plec FROM dual;
  ELSE
    SELECT 'M' INTO :new.plec from dual;
  end if;
END;
/

BEGIN
INSERT INTO dane(imie, nazwisko, pesel) values ('Jan', 'Kowalski', '75052503553');
END;
/


/*
3.Dana jest tabela: 
CREATE TABLE lista(id_slowo INT, slowo VARCHAR2(20)); 
i przyk³adowe rekordy: 
INSERT INTO lista(id_slowo,slowo) VALUES(1,'red'); 
INSERT INTO lista(id_slowo,slowo) VALUES(2,'blue');
INSERT INTO lista(id_slowo,slowo) VALUES(3,'green'); 
Napisaæ wyzwalacz, który uniemo¿liwi usuwanie i modyfikacjê rekordów w tabeli lista. 
Przetestuj dzia³anie utworzonego wyzwalacza. 
*/
CREATE TABLE lista (id INT, slowo VARCHAR2(20));
/
INSERT INTO lista(id,slowo) VALUES(1,'red'); 
INSERT INTO lista(id,slowo) VALUES(2,'blue');
INSERT INTO lista(id,slowo) VALUES(3,'green'); 
/
CREATE OR REPLACE TRIGGER insert_lista before update or delete ON lista FOR EACH ROW
BEGIN
  if UPDATING  then
  raise_application_error(-20015, 'Nie mozesz modyfikowaæ tego wiersza');
  elsif DELETING  then
  raise_application_error(-20015, 'Nie mozesz skasowac tego wiersza');
  end if; 
END;
/

begin
update lista set slowo = 'czarny' where id = 3;
delete from lista where id = 1;
end;
/

/*4.
Dane s¹ tabele imiona(id,imie) oraz imiona_historia(id,imie,data_zmiany,zmiana).  
Napisaæ wyzwalacz, który bêdzie archiwizowa³ modyfikowane i usuwane rekordy z tabeli imiona 
do tabeli imiona_historia. Dodatkowo w tabeli imiona_historia powinna byæ zapisana data zmiany 
i rodzaj zmiany: 'U' (od update), 'D' (od delete). 
Przetestuj dzia³anie utworzonego wyzwalacza. */
CREATE TABLE imiona(id NUMBER, imie VARCHAR2(30));
/
CREATE TABLE imiona_historia(id NUMBER, imie VARCHAR(30), data_zmiany DATE, zmiana char);
/
CREATE SEQUENCE imiona_historia_sek START WITH 1 INCREMENT BY 1 NOMAXVALUE;
/
CREATE OR REPLACE TRIGGER insert_imiona_historia BEFORE UPDATE ON imiona_historia FOR EACH ROW
BEGIN
  SELECT imiona_historia_sek.NEXTVAL INTO :new.id FROM dual;
END;
/
CREATE OR REPLACE TRIGGER update_imiona BEFORE UPDATE ON imiona FOR EACH ROW
BEGIN
  INSERT INTO imiona_historia VALUES(:old.id,:old.imie,sysdate,'U');
END;
/
CREATE OR REPLACE TRIGGER delete_imiona BEFORE DELETE ON imiona FOR EACH ROW
BEGIN
  INSERT INTO imiona_historia VALUES(:old.id, :old.imie,sysdate,'D');
END;
/
BEGIN
INSERT INTO imiona VALUES (1, 'Jan');
INSERT INTO imiona VALUES (2, 'Karol');
UPDATE imiona SET imie = 'Kuba' WHERE id=2;
INSERT INTO imiona VALUES (3, 'Magda');
INSERT INTO imiona VALUES (4, 'Zosia');
UPDATE imiona SET imie = 'Ksia' WHERE id=4;
DELETE FROM imiona WHERE id = 3;
INSERT INTO IMIONA VALUES (5, 'Robert');
DELETE FROM imiona WHERE id = 1;
END;
/
SELECT * FROM imiona;
SELECT * FROM imiona_historia;