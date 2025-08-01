--Má výška HDP vliv na změny ve mzdách a cenách potravin? Neboli, pokud HDP vzroste výrazněji v jednom roce, projeví se to na cenách potravin či mzdách ve stejném nebo následujícím roce výraznějším růstem?
--Cilem je zjistit zda existuje souvislost mezi meziročním růstem HDP a meziročním růstem mezd a cen potravin v ČR. 
--Postup řešení:
--1. Výpočet průměrné ceny potravin a mzdy za každý rok. 
--2.Spojit primární a sekundární tabulku na základě sloupce "year" a vyfiltrovat pouze Českou republiku. 
--3. Vypočítat meziroční růst HDP, mezd a cen potravin. 
--4. Porovnat změny HDP, cen potravin a mezd. 
--Závěr:
--Z analyzovaných dat vyplývá, že neexistuje přímá a jednoznačná lineární souvislost mezi meziročním růstem HDP a růstem mezd či cen potravin ve stejném roce. 
--Pokud se určitá korelace objevuje, není patrná jako konzistentní lineární vztah.
--Mzdy rostly téměř každý rok, s výjimkou roku 2013, kdy zaznamenaly pokles.
--HDP vykazoval ve sledovaném období nestabilní růst s poklesy v letech 2009, 2012 a 2013.
--Dotaz:
WITH
  --Krok 1: Spočítání průměrné roční ceny potravin
  yearly_avg_price AS (
    SELECT
      price_year_of_entry AS year,
      ROUND(AVG(price::numeric), 2) AS avg_price
    FROM
      t_katerina_havelkova_project_sql_primary_final
    GROUP BY
      price_year_of_entry
  ),
  ---Krok 2: Spočítání průměrné roční mzdy
  yearly_avg_wage AS (
    SELECT
      payroll_year AS year,
      ROUND(AVG(average_wages::numeric), 2) AS avg_wage
    FROM
      t_katerina_havelkova_project_sql_primary_final
    GROUP BY
      payroll_year
  ),
  --Krok 3: Seřazení HDP dat pro ČR
  gdp_data AS (
    SELECT
      year,
      GDP::numeric AS gdp
    FROM
      t_katerina_havelkova_project_sql_secondary_final
    WHERE
      country = 'Czech Republic'
  ),
  --Krok 4:Spojení průměrných hodnot podle roku
  combo_tab AS (
    SELECT
      w.year,
      w.avg_wage,
      p.avg_price,
      g.gdp
    FROM
      yearly_avg_wage AS w
      JOIN yearly_avg_price AS p ON w.year = p.year
      JOIN gdp_data AS g ON w.year = g.year
  ),
  -- Krok 5:Finální výpočet meziročního růstu s ošetřením dělení nulou
  comparison AS (
    SELECT
      curr.year,
      ROUND(
        (
          (curr.gdp::numeric - prev.gdp::numeric) / NULLIF(prev.gdp::numeric, 0)
        ) * 100,
        2
      ) AS gdp_growth,
      ROUND(
        (
          (curr.avg_price::numeric - prev.avg_price::numeric) / NULLIF(prev.avg_price::numeric, 0)
        ) * 100,
        2
      ) AS price_growth,
      ROUND(
        (
          (curr.avg_wage::numeric - prev.avg_wage::numeric) / NULLIF(prev.avg_wage::numeric, 0)
        ) * 100,
        2
      ) AS wage_growth
    FROM
      combo_tab curr
      JOIN combo_tab prev ON curr.year = prev.year + 1
  )
 SELECT
  year,
  gdp_growth,
  wage_growth,
  price_growth
FROM
  comparison
ORDER BY
  year;