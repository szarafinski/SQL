
-- Autor: Krzysztof Szarafiński
-- nr albumu: 155441
-- Data: 12.01.2017

set serveroutput on
/* Funkcja 1
-- ponizsza funkcja zwraca cene samochodu uwzgledniajac: model, wybrany kolor, silnik oraz wybrane pakiety dodatkowe
-- jako argument przyjmuje numer indeksu wybranego samochodu z dostepnych modeli
*/
create or replace function cena_samochodu(numer int) return number is
cursor ceny is select jeden.model, jeden.kolor, jeden.silnik, nvl(dwa.cena,0) as pakiet from
  (select s.id as numer, model.cena as model, kolor.cena as kolor, silnik.cena as silnik
  from model, kolor, silnik, samochod s 
  where s.model_id=model.id and s.silnik_id=silnik.id and s.kolor_id=kolor.id and s.id = numer) jeden 
left join
  (select s.id as numer, p.cena as cena 
    from samochod s, wybrane_pakiety w, pakiet_dodatkowy p 
    where s.id = w.SAMOCHOD_ID and p.id = w.PAKIET_DODATKOWY_ID and s.id = numer) dwa 
on dwa.numer=jeden.numer;
cena MODEL.CENA%type := 0;
begin
for rekord in ceny loop
  cena := cena + rekord.silnik + rekord.kolor + rekord.model+ rekord.pakiet;
end loop;
return cena;
exception
  when no_data_found then
    return 0;
end;
/

-- sprawdzenie
begin
dbms_output.put_line('cena samochodu 15 to: ' || cena_samochodu(15) || ' PLN.');
end;
/

/* Funkcja 2
 zwraca wyliczony maksymalny upust jaki mogl zastosowac sprzedawca w dniu zawarcia umowy.
 ograniczeniem jest ze wysokosc upustu pomimo ze z wykorzystaniem promocji mogla nawet przekroczyc 50% ceny,
 to zostala ograniczona do maksymalnie 20%. Funkcja przyjmuje jako argument numer zamowienia (id zamowienia)
*/
create or replace function upust_zamowienia(numer int) return number is
wynik UPUST.WYSOKOSC%type :=0;
begin
SELECT sum(upust.wysokosc) into wynik
FROM  upust  INNER JOIN upust_oddzialu
    ON upust.id = upust_oddzialu.upust_id
    INNER JOIN oddzial
    ON oddzial.id = upust_oddzialu.oddzial_id
    INNER JOIN sprzedawca
    ON oddzial.id = sprzedawca.oddzial_id
    INNER JOIN zamowienie 
    ON sprzedawca.id = zamowienie.sprzedawca_id
WHERE zamowienie.data_zawarcia between upust.data_start and UPUST.DATA_KONIEC and zamowienie.id = numer
GROUP BY zamowienie.id;

if wynik >=20 then
    return 20;
ELSE
    return wynik;
end if;
exception
  when no_data_found then
    return 0;
end;
/

-- sprawdzenie
begin
dbms_output.put_line('Wartosc upustu dla sprzedazy numer 5: ' || upust_zamowienia(5)|| '%.');
end;
/

/* Funkcja 3
funkcja cena_zamowienia zwraca cene dla zamowienia o zadanym parametrze jakim jest NR_ZAMOWIENIA (id tablicy zamowienia).
wykorzystuje wczesniej wyliczone funkcje dotyczace upustu oraz ceny samochodu. funkcja uwzglednia takze dodatkowo polise ubezpieczeniowa oraz uslugi dodatkowe,
ktore zostaly wybrane przez klienta skaldajac zamowienie - te dwie pozycje nie podlegaja rabatowi, sa swiadczone przez firmy zewnetrzne
ostateczna cena zostaje zaokraglona do pelnych setek zlotych (jest to marza salonu).
*/

CREATE OR REPLACE FUNCTION cena_zamowienia (
    numer   INT
) RETURN NUMBER IS
    wynik MODEL.CENA%type := 0;
    cena_ubezpieczenia   UBEZPIECZENIE.CENA%type := 0;
    dodatek PAKIET_DODATKOWY.CENA%type :=0;
-- begin dla ceny samochodu z rabatem
BEGIN
  -- begin dla ubezpieczenia
  BEGIN
      -- begin dla uslug dodatkowych
      BEGIN
          SELECT SUM(uslugi_dodatkowe.cena) into dodatek
          FROM zamowienie INNER JOIN  wybrane_uslugi
              ON zamowienie.id = wybrane_uslugi.zamowienie_id
              INNER JOIN uslugi_dodatkowe 
              ON uslugi_dodatkowe.id = wybrane_uslugi.uslugi_dodatkowe_id
          WHERE zamowienie.id = numer
          GROUP BY  zamowienie.id;
  
     --     dbms_output.put_line('cena dodatku to: ' ||  dodatek ||  ' PLN.');
      EXCEPTION
          WHEN no_data_found THEN
              dodatek := 0;
      END;
      SELECT ubezpieczenie.cena into  cena_ubezpieczenia
      FROM (SELECT  u.cena AS cena
              FROM zamowienie z, ubezpieczenie u
              WHERE z.ubezpieczenie_id = u.id AND z.id = numer ) ubezpieczenie;
  --    dbms_output.put_line('cena ubezpieczenia to: ' ||  cena_ubezpieczenia ||  ' PLN.');
  EXCEPTION
      WHEN no_data_found THEN
          cena_ubezpieczenia :=0;
  END;
wynik := dodatek + cena_ubezpieczenia + ( 1 - upust_zamowienia(numer) / 100 ) * cena_samochodu(numer);
wynik := round(wynik/100,0)*100;
RETURN wynik;
EXCEPTION
      WHEN no_data_found THEN
          return 0;
end;
/

-- sprawdzenie
declare
numer_zamowienia int :=12;
begin
dbms_output.put_line('cena samochodu '|| numer_zamowienia || ' to: ' || cena_samochodu(numer_zamowienia) || ' PLN.');
dbms_output.put_line('Wartosc upustu dla sprzedazy numer ' || numer_zamowienia || ' to: ' || upust_zamowienia(numer_zamowienia)|| '%.');
dbms_output.put_line('Wartosc sprzedazy dla zamowienia ' || numer_zamowienia || ' to: ' || cena_zamowienia(numer_zamowienia)|| ' PLN.');
end;
/

/* Funkcja 4:
funkcja zwraca informacje czy suma oplat wniesionych przez klientow dla danego zamowienia jest rowna cenie zamowienia
*/
create or replace function czy_oplacone_zamowienie (numer int) return boolean is
wynik boolean := false;
cena platnosc.kwota%type :=0;
begin
SELECT
    SUM(platnosc.kwota) into cena
FROM  platnosc INNER JOIN zamowienie
    ON  zamowienie.id = platnosc.zamowienie_id
WHERE   zamowienie.id = numer  
GROUP BY zamowienie.id;

--dbms_output.put_line('wplaty dokonano na: ' ||  platnosc ||  ' PLN.');
if (cena >= cena_zamowienia(numer)) then
  wynik := true;
end if;

return wynik;
exception 
  when no_data_found then return false;
end;
/

-- sprawdzenie
declare
numer_zamowienia int :=3;
begin
dbms_output.put_line('Wartosc sprzedazy dla zamowienia ' || numer_zamowienia || ' to: ' || cena_zamowienia(numer_zamowienia)|| ' PLN.');
if (czy_oplacone_zamowienie(numer_zamowienia)) then
dbms_output.put_line('Dokonano oplaty w calosci.');
else
dbms_output.put_line('Nie dokonano oplaty w calosci.');
end if;
end;
/

/* Funkcja 5
zwraca ilosc sprzedanych samochodow przez pracownika w stosunku do wszystkich zarejestrownych na niego zamowien zarowno zwiazanych
ze sprzedaza samochodu jak i tylko zakupieniem np. ubezpieczenia lub uslug dodatkowych
*/
create or replace function efektywnosc_pracownika(numer int) return number is
licznik number(4,2):=0;
mianownik number(4,2):=0;
begin
select count(*) into licznik from zamowienie z, samochod s where z.id = s.zamowienie_id
and z.sprzedawca_id = numer
group by z.SPRZEDAWCA_ID;
--dbms_output.put_line('licznik ' || licznik);
select count(*) into mianownik from zamowienie z 
where z.sprzedawca_id = numer
group by z.SPRZEDAWCA_ID;
--dbms_output.put_line('licznik ' || mianownik);
return round(licznik/mianownik,2);
EXCEPTION
  when no_data_found then
    RETURN 0;
end;
/
-- sprawdzenie
begin
dbms_output.put_line('Efektywnosc pracownika 9 to: ' || efektywnosc_pracownika(9));
end;
/

-- analogiczna funkcja jak Funkcja n 4 tylko zwraca informacje czy suma dokonanych wplat jest wieksza od wymaganej kwoty za zamowienie
-- w funkcji 4 bylo wieksza lub rowna
create or replace function sprawdz (numer int)  return boolean is
wynik boolean := false;
cena platnosc.kwota%type :=0;
begin
SELECT
    SUM(platnosc.kwota) into cena
FROM  platnosc INNER JOIN zamowienie
    ON  zamowienie.id = platnosc.zamowienie_id
WHERE   zamowienie.id = numer  
GROUP BY zamowienie.id;

--dbms_output.put_line('wplaty dokonano na: ' ||  platnosc ||  ' PLN.');
if (cena > cena_zamowienia(numer)) then
  wynik := true;
end if;

return wynik;
exception 
  when no_data_found then return false;
end;
/

