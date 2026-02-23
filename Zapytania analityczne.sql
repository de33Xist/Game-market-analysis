use raport_gry
select *
from gry_baza
---grupowanie segmentacji ze wzglêdu na krytera i flag-----------
select *,
case 
	when Rodzaj_gry in ('RPG','TPP/Akcja','Akcja','Przygodowa','Survival Horror') then 'Gry rozwojowe'
	when Rodzaj_gry in ('Strategia','Logiczna','Bijatyka','Platformowa','Symulator','FPP','Wyœcigi') then 'Gry symulatorowe'
	when Rodzaj_gry in ('FPS','TPS') then 'Gry strzelanki'
	when Rodzaj_gry in ('Roguelike', 'Soulslike') then 'Gry trudne'
	else 'brak przypisania'
end as Segregacja_gatunku,

case 
	when Cena_PLN_PC <= 100.00 
		or Cena_PLN_KONSOLA <= 100.00 then 'A'
	when Cena_PLN_PC between 101.00 and 199.00
		or Cena_PLN_KONSOLA between 101.00 and 199.00 then 'AA'
	when Cena_PLN_PC >= 200.00 
		or Cena_PLN_KONSOLA >= 200.00 then 'AAA'
	else 'brak'
end as Wielkoœæ_gry,

case
	when Przeznaczenie = 'PC' then 1 else 0 end as is_PC,
case
	when Przeznaczenie = 'Konsole' then 1 else 0 end as is_Konsole,
case
	when Przeznaczenie = 'PC/Konsole' then 1 else 0 end as is_Konsole_PC

from gry_baza as b
left join ceny as c on c.ID_Gry = b.ID_Gry
---Tworzenie tabeli z widokiem dat--------

create view daty as
select id_gry, data_premiery, YEAR(data_premiery) as rok_premiery, DATEPART(QUARTER,Data_premiery) as kwarta³, CONCAT(year(data_premiery),'-',DATEPART(quarter,data_premiery)) as rok_kwartal
from gry_baza

select *
from daty
-------tworzenie trendu rocznego

select YEAR(data_premiery) as rok_premiery, COUNT(*) as rok_ilosci
from gry_baza
group by YEAR(Data_premiery)
order by rok_premiery

with premiery_roczne as (
select YEAR(data_premiery) as rok_premiery, COUNT(*) as rok_ilosci
from gry_baza
group by YEAR(Data_premiery)
)
select rok_premiery, rok_ilosci,LAG(rok_ilosci) over (order by rok_premiery) as poprzedni_rok,
case 
	when LAG(rok_ilosci) over (order by rok_premiery) is null then null
	else ROUND(
            (rok_ilosci - LAG(rok_ilosci) OVER (ORDER BY rok_premiery)) 
            * 100.0
            / LAG(rok_ilosci) OVER (ORDER BY rok_premiery)
		,2)
end as zmiana_procentowa
from premiery_roczne
order by rok_premiery

----- struktura rynku wg przeznaczenia

select przeznaczenie as przeznaczenie, COUNT(*) as ilosc, ROUND(count(*) * 100.0 / sum(count(*)) over (),2) as procent_przeznaczenia
from gry_baza
group by przeznaczenie


-----struktura rynku wg gatunku

select rodzaj_gry as rodzaj_gatunku, count(*) as ilosc, round(count(*) * 100.0 / sum(count(*)) over (),2) as procent_gatunku
from gry_baza
group by rodzaj_gry


---- struktura gatunku YoY

select rodzaj_gry as rodzaj, YEAR(data_premiery) as premiera, COUNT(*) as ilosc
from gry_baza
group by Rodzaj_gry, YEAR(data_premiery)


WITH zmiana_Y AS (
    SELECT 
        rodzaj_gry AS rodzaj,
        YEAR(data_premiery) AS premiera,
        COUNT(*) AS ilosc
    FROM gry_baza
    GROUP BY rodzaj_gry, YEAR(data_premiery)
),
zmiana_Y_P AS (
    SELECT 
        rodzaj, 
        premiera, 
        ilosc,
        LAG(ilosc) OVER (PARTITION BY rodzaj ORDER BY premiera) AS poprzedni_rok
    FROM zmiana_Y
)
SELECT
    rodzaj,
    premiera,
    ilosc,
    poprzedni_rok,
    CASE
        WHEN poprzedni_rok IS NULL OR poprzedni_rok = 0 THEN NULL
        ELSE ROUND((ilosc - poprzedni_rok) * 100.0 / poprzedni_rok, 2)
    END AS zmianaYoY
FROM zmiana_Y_P
ORDER BY rodzaj, premiera;


---top3 gatunków w rynku
with ranking_segmentow as (
select Rodzaj_gry, COUNT(*) as ilosc_gier,
RANK() over (order by count(*) desc) as ranking
from gry_baza
group by Rodzaj_gry
),
rynek_caly as(
select *, SUM(ilosc_gier) over() as ilosc_rynku
from ranking_segmentow
)
select *, round(ilosc_gier * 100.0 / ilosc_rynku, 2) as udzia³_rynku_procentowy
from rynek_caly
where ranking <= 3

--- top 3 wydawców w rynku

select *
from gry_baza g
left join wydawcy w on w.ID_Wydawcy=g.ID_Wydawcy

with ranking_wydawcow as (
select nazwa_wydawcy, COUNT(*) as ilosc_gier,
RANK() over (order by count(*) desc) as ranking
from gry_baza g
left join wydawcy w on w.ID_Wydawcy=g.ID_Wydawcy
group by Nazwa_wydawcy
),
wydawcy_cali as (
select *, SUM(ilosc_gier) over() as ilosc_rynku
from ranking_wydawcow
)
select *, ROUND(ilosc_gier * 100.0 / ilosc_rynku,2 ) as udzial_wydawcy
from wydawcy_cali
where ranking <= 3