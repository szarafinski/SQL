SET SERVEROUTPUT ON
BEGIN
  DBMS_OUTPUT.put_line('Run 1 : seed=2');
  DBMS_RANDOM.seed (val => 2);
  FOR i IN 1 ..5 LOOP
    DBMS_OUTPUT.put_line('i=' || i || ' : value=' || DBMS_RANDOM.value(low => 1, high => 10));
  END LOOP;

  DBMS_OUTPUT.put_line('Run 2 : seed=0');
  DBMS_RANDOM.seed (val => 0);
  FOR i IN 1 ..5 LOOP
    DBMS_OUTPUT.put_line('i=' || i || ' : value=' || DBMS_RANDOM.value(low => 1, high => 10));
  END LOOP;

END;
/

  declare 
    fHandle  UTL_FILE.FILE_TYPE;
  begin
    fHandle := UTL_FILE.FOPEN('my_directory', 'test_file.txt', 'w');
  
    UTL_FILE.PUT_LINE(fHandle, 'pierwsza linijka');
    UTL_FILE.PUT_LINE(fHandle, 'druga linijka');
    UTL_FILE.PUT_LINE(fHandle, 'trzecia linijka');
  
    UTL_FILE.FCLOSE(fHandle);
  EXCEPTION
    WHEN OTHERS THEN
      DBMS_OUTPUT.PUT_LINE('Exception: SQLCODE=' || SQLCODE || '  SQLERRM=' || SQLERRM);
      RAISE;
  end;
  /
  
CREATE PACKAGE cust_sal AS
   PROCEDURE find_sal(c_id OSOBA.ID_OSOBA%type);
END cust_sal;
/

  CREATE OR REPLACE PACKAGE BODY cust_sal AS
   PROCEDURE find_sal(c_id OSOBA.ID_OSOBA%TYPE) IS
   c_sal OSOBA.ID_OSOBA%TYPE;
   BEGIN
      SELECT pensja INTO c_sal
      FROM osoba
      WHERE id_osoba = c_id;
      dbms_output.put_line('Pensja: '|| c_sal);
   END find_sal;
END cust_sal;
/

DECLARE
   code OSOBA.ID_OSOBA%type := &cc_id;
BEGIN
   cust_sal.find_sal(code);
END;
/