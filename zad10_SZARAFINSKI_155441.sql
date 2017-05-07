SET SERVEROUTPUT ON;
/*
Wymyœl i rozwi¹¿
a) 2 zadania na u¿ycie tablic asocjacyjnych,
b) 2 zadania na u¿ycie tablic VARRAY,
c) 2 zadania na u¿ycie tablic zagnie¿d¿onych.
Odpowiedz na pytanie: Kiedy warto u¿ywaæ poszczególne rodzaje tablic?
*/
declare
TYPE a_jeden is table of osoba.imie%type index by pls_integer;
v_tablica1 a_jeden;
indeks number;
begin
v_tablica1(1):= 'Prosiak';
v_tablica1(10):= 'Malpa';
v_tablica1(11):= 'Tygrys';
v_tablica1(7):= 'Szczur';
for licznik in 1..v_tablica1.count loop
  if licznik = 1 then indeks := v_tablica1.first;
  else indeks:= v_tablica1.next(indeks);
  end if;
  dbms_output.put_line(v_tablica1(indeks));
  end loop;
end;

declare
TYPE tablica_dwa is table of osoba%rowtype index by pls_integer;
tablica tablica_dwa;
begin
select * into tablica(1) from osoba where ID_OSOBA=3;
select * into tablica(-1) from osoba where ID_OSOBA=2;
dbms_output.put_line(tablica(-1).imie || ', ' || tablica(1).imie);
end;

/* varray*/
declare
  type tablicaa is varray(3) of integer;
  tablica tablicaa:=tablicaa(null,null,null);
  begin
  
  tablica(1):= 67;
  tablica(2):= 5;
  tablica(3):= 12;
  for licznik in 1..3 loop
  dbms_output.put(tablica(licznik) || ', ');
end loop;
dbms_output.new_line;
end;
/

create or replace type tablicab as varray(3) of integer;
/
declare
tablica tablicab:= tablicab();
begin
tablica.extend(3);
tablica(1):=4;
tablica(2):=12;
tablica(3):=99;
for licznik in 1..tablica.count loop
  dbms_output.put_line(tablica(licznik));
end loop;
end;
/
