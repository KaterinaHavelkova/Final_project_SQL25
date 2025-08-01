--Tabulka 1: Mzdy a Ceny v ČR (2006-2018):t_Katerina_Havelkova_project_SQL_primary_final
--Tato tabulka agreguje data o průměrných hrubých mzdách a cenách vybraných potravin za Českou republiku. 
--Data jsou sjednocena na totožné porovnatelné období od roku 2006 do roku 2018.
--Dotaz:
-- Tabulka 1: Mzdy a ceny v ČR (2006–2018)
--Krok 1: Sloučíme data z tabulky s cenami a tabulky se mzdami
CREATE TABLE t_Katerina_Havelkova_project_SQL_primary_final AS
SELECT
  date_part('year', cp.date_from) AS price_year_of_entry,
  cpc.name AS food_category,
  cp.value AS price,
  cpc.price_unit AS unit_of_measure,
  czpay.payroll_year,
  cpib.name AS payroll_industry,
  czpay.value AS average_wages
FROM
  czechia_price AS cp
  JOIN czechia_price_category AS cpc ON cp.category_code = cpc.code
  JOIN czechia_payroll AS czpay ON date_part('year', cp.date_from) = czpay.payroll_year
  JOIN czechia_payroll_industry_branch AS cpib ON czpay.industry_branch_code = cpib.code
  --Krok 2: Vybere pouze data o průměrné hrubé mzdě na zaměstnance, pouze celostátní průměrné ceny (region_code je NULL), 
  --a výběr omezíme na časový rozsah společných let pro ceny i mzdy
WHERE
  czpay.value_type_code = 5958
  AND cp.region_code IS NULL
  AND date_part('year', cp.date_from) BETWEEN 2006 AND 2018
  AND czpay.payroll_year BETWEEN 2006 AND 2018;

--Tabulka 2: Dodatečná data o dalších evropských státech (2006-2018):t_Katerina_Havelkova_project_SQL_secondary_final
--Tato sekundární tabulka slouží jako doplňkový přehled vybraných ekonomických ukazatelů a statických informací o evropských státech v období 2006-2018.
--Krok 1: Sloučíme data z tabulky economies s tabulkou countries pro statická data o zemích
CREATE TABLE t_Katerina_Havelkova_project_SQL_secondary_final AS
SELECT DISTINCT
  e.country,
  e.year,
  e.gdp,
  e.population,
  e.gini,
  e.taxes,
  c.continent,
  c.capital_city,
  c.currency_code
FROM
  countries AS c
  JOIN economies AS e ON c.country = e.country
   --Krok 2: Vybere pouze data pro Evropu a omezíme časovový rozsah na společné období pro analýzu
WHERE
  c.continent IN ('Europe')
  AND e.year BETWEEN 2006 AND 2018
ORDER BY
  e.country ASC,
  e.year;