--Existuje rok, ve kterém byl meziroční nárůst cen potravin výrazně vyšší než růst mezd (větší než 10 %)?
--Cilem je zjistit zda se v letech 2006–2018 vyskytl rok, kdy procentuální nárůst průměrné ceny potravin převýšil meziroční růst mezd o více než 10 procentních bodů.
--Postup řešení:
--1. Výpočet průměrné ceny potravin a mzdy za každý rok. 
--2. Spojit data tak, aby bylo možné porovnat každý rok s předchozím rokem.
--3. Výpočet meziročního procentuálního nárůstu cen a mezd. 
--4. Výběr let, kde růst jídla - růst mezd > 10%. WHERE (food_growth - wage_growth) > 10-- Tuto podmínku jsem dodala jako poslední, abych nejprve viděla celý vývoj. 
--Závěr:
--Z výsledku vyplívá, že v žádném roce nepřesáhl rozdíl mezi růstem cen potravin a mezd v ltech 2007-2018 hranici 10%.
--Největší rozdíl mezi růstem cen potravin a vývojem mezd byl v roce 2013. Kdy ceny vzrostly o 5,55 %, zatímco mzdy klesly o 1,56%. 
--V roce 2009 došlo k poklesu cen potravin a současně k výraznému růstu mezd a to téměř o 10 %. 
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
  --Krok 2: Spočítání průměrné roční mzdy
  yearly_avg_wage AS (
    SELECT
      payroll_year AS year,
      ROUND(AVG(average_wages::numeric), 2) AS avg_wage
    FROM
      t_katerina_havelkova_project_sql_primary_final
    GROUP BY
      payroll_year
  ),
  -- Krok 3: Spojení ročních průměrů z kroku 1 a 2
  combo_prices_wages AS (
    SELECT
      price.year,
      price.avg_price,
      wage.avg_wage
    FROM
      yearly_avg_price AS price
      JOIN yearly_avg_wage AS wage ON price.year = wage.year
  ),
  -- Krok 4: Výpočet meziročního růstu s ošetřením dělení nulou
  comparison AS (
    SELECT
      curr.year,
      ROUND(
        (
          (curr.avg_price::numeric - prev.avg_price::numeric) / NULLIF(prev.avg_price::numeric, 0)
        ) * 100,
        2
      ) AS food_growth,
      ROUND(
        (
          (curr.avg_wage::numeric - prev.avg_wage::numeric) / NULLIF(prev.avg_wage::numeric, 0)
        ) * 100,
        2
      ) AS wage_growth
    FROM
      combo_prices_wages AS curr
      JOIN combo_prices_wages AS prev ON curr.year = prev.year + 1
  )
  --Krok 5: Finální výstup a filtrace
SELECT
  year,
  food_growth,
  wage_growth,
  ROUND(food_growth - wage_growth, 2) AS difference
FROM
  comparison
WHERE
  (food_growth - wage_growth) > 10
ORDER BY
  year;