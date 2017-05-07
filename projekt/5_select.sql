
-- Autor: Krzysztof Szarafiński
-- nr albumu: 155441
-- Data: 12.01.2017

-- ponizszy widok dziala dopiero po zaladowaniu procedur i funkcji

/* select nr 1: 
zwraca informacje o numerze zamwienia, jego cenie oraz sumie dokonanych platnosci. dodatkowo wyliczana jest kwota nadplaty.
kwota dodatnia nadplaty to nadplata,
kwota ujemna nadplatyto kwota ktora musi byc jeszcze wplcona
wartosci null to znaczy ze nie nie dokonano wplaty za dane zamowienie
*/
create or replace view oplaty_za_zamowienie as
select jeden.id as nr_zamowienia, cena_zamowienia(jeden.id) as cena, sum( dwa.platnosc )as platnosc, (sum( dwa.platnosc )-cena_zamowienia(jeden.id)) as nadplata
from  
  (select z.id as id, z.data_zawarcia as zawarcie, z.data_odbioru as odbior, z.status_zamowienia_id as status from zamowienie z) jeden 
full outer join 
  (SELECT SUM(platnosc.kwota) as platnosc, zamowienie.id as id, platnosc.id as nr_platnosci
  FROM  platnosc INNER JOIN zamowienie ON  zamowienie.id = platnosc.zamowienie_id 
  GROUP BY zamowienie.id, platnosc.id) dwa 
on jeden.id = dwa.id group by jeden.id order by nr_zamowienia;
/

select * from oplaty_za_zamowienie;

/* Select 2:
informacje o samochodach w magazyniej: marka, model, rok produkcji, liczba drzwi, kolor oraz cena
*/
create or replace view samochody_w_magazynie as select marka.nazwa as marka, model.nazwa as model, model.rok_produkcji as rok_produkcji, model.liczba_drzwi, 
k.nazwa as klasa, kolor.odcien as barwa, round(cena_samochodu(samochod.id),-2) as cena
from model 
inner join klasa_wyposazenia k
on k.id = model.KLASA_WYPOSAZENIA_ID 
inner join marka 
on model.MARKA_ID=marka.id
inner join samochod
on model.id = samochod.MODEL_ID
inner join kolor
on samochod.kolor_id = kolor.id
order by marka, model, rok_produkcji;

-- sprawdzenie
select * from samochody_w_magazynie;



