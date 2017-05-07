SET SERVEROUTPUT ON
/*1. Sprowokuj wyj¹tek w sekcji wykonawczej i go obs³u¿.*/
DECLARE
    blad   exception;
    CURSOR kursor IS SELECT * FROM pracownicy ORDER BY nazwisko, imie;
BEGIN
    open kursor;
    
    IF 1 = 1 THEN
        begin
        open kursor;
        DBMS_OUTPUT.put_line('tekst');
        exception
            WHEN CURSOR_ALREADY_OPEN THEN
      dbms_output.put_line('niedozwolona operacja na kursorze');
        end;
    END IF;
    raise blad;
    close kursor;
EXCEPTION
    WHEN blad THEN
        dbms_output.put_line('wystapil blad zdefiniowany przez uzytkownika.');
    WHEN OTHERS THEN
      dbms_output.put_line('inny blad');
END;
/

/*2. Sprowokuj wyj¹tek w sekcji deklaracyjnej i go obs³u¿.
Wskazówka: Wyj¹tek powinien byæ sprowokowany w bloku wewnêtrznym, a obs³u¿ony w bloku zewnêtrznym.
*/
DECLARE
imie NUMBER;
BEGIN
  DECLARE
    bledne_imie NUMBER := 'JOLA';
  BEGIN
    DBMS_OUTPUT.PUT_LINE('wypisz bledne imie ' || bledne_imie);
  EXCEPTION
   WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('inny blad wewnatrz');
  END;
EXCEPTION
 WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('inny blad na zewnatrz');
END;
/

/*
3. Sprowokuj wyj¹tek w sekcji obs³ugi wyj¹tków i go obs³u¿.
Wskazówka: Wyj¹tek powinien byæ sprowokowany w bloku wewnêtrznym, a obs³u¿ony w bloku zewnêtrznym.
*/

DECLARE
wyjatek EXCEPTION;
BEGIN
  DECLARE
    liczba NUMBER :=2;
    cursor kursor is select * from osoba;
  BEGIN
    DBMS_OUTPUT.PUT_LINE('wypisz liczbe ' || liczba/0);
    close kursor;
  EXCEPTION
  when zero_divide then
  raise wyjatek;
   WHEN OTHERS THEN
    DBMS_OUTPUT.PUT_LINE('inny blad wewnatrz');
   END;
EXCEPTION
WHEN wyjatek THEN
DBMS_OUTPUT.PUT_LINE('wyjatek na zewnatrz');
 WHEN OTHERS THEN
  DBMS_OUTPUT.PUT_LINE('inny blad na zewnatrz');
END;
/