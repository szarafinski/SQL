SET SERVEROUTPUT ON
/*1. Sprowokuj wyj�tek w sekcji wykonawczej i go obs�u�.*/
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

/*2. Sprowokuj wyj�tek w sekcji deklaracyjnej i go obs�u�.
Wskaz�wka: Wyj�tek powinien by� sprowokowany w bloku wewn�trznym, a obs�u�ony w bloku zewn�trznym.
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
3. Sprowokuj wyj�tek w sekcji obs�ugi wyj�tk�w i go obs�u�.
Wskaz�wka: Wyj�tek powinien by� sprowokowany w bloku wewn�trznym, a obs�u�ony w bloku zewn�trznym.
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