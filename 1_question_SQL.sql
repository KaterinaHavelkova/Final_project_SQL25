--Rostou v průběhu let mzdy ve všech odvětvích, nebo v některých klesají?
--Cílem je porovnat mzdy v jednotlivých odvětvích mezi každým rokem a předchozím rokem. Zjistit zda mzdy v jednotlivých odvětvích rostou, nebo jestli v některých došlo k poklesu v letech 2006- 2018
--Postup řešení:
--1. Agregace průměrné mzdy za každý rok a odvětví.
--2. Výpočet meziročního rozdílu mezd pro každé odvětví. 
--3. Identifikace případů, kdy byl meziroční rozdíl záporný – tedy mzda oproti předchozímu roku poklesla.
--4. Porovnání těchto výsledků s úplným přehledem odvětví za celé období za účelem identifikace odvětví, ve kterých mzdy nepřetržitě rostly. 
--Závěr: 
-- Vývoj průměrných mezd v letech 2006–2018 ukazuje, že ve většině odvětví mzdy dlouhodobě rostou.
-- Neplatí to však ve všech letech – v některých odvětvích došlo k meziročnímu poklesu.
-- Nejvýraznější pokles byl zaznamenán v roce 2013, kdy mzdy klesly ve více než deseti odvětvích.
-- Navzdory těmto výkyvům zůstává celkový trend pozitivní – tedy růstový.
-- Čtyři odvětví vykazují stabilní růst mezd bez meziročních poklesů: *Ostatní činnosti*, *Zdravotní a sociální péče*, *Doprava a skladování* a *Zpracovatelský průmysl*.
--Dotaz:
--Možnost č.1-Pomocí CET
WITH
  ---- Krok 1: Spočítání průměrné roční mzdy pro každé odvětví
  industry_wages AS (
    SELECT
      payroll_industry,
      payroll_year,
      AVG(average_wages) AS avg_wage
    FROM
      t_katerina_havelkova_project_sql_primary_final
    WHERE
      payroll_year BETWEEN 2006 AND 2018
    GROUP BY
      payroll_industry,
      payroll_year
  )
  --Krok 2: Získání mzdy z předchozího roku pomocí self joinu
SELECT
  a.payroll_industry,
  a.payroll_year AS current_year,
  b.payroll_year AS previous_year,
  ROUND(a.avg_wage - b.avg_wage, 2) AS wage_difference
FROM
  industry_wages AS a
  JOIN industry_wages AS b ON a.payroll_industry = b.payroll_industry
  AND a.payroll_year = b.payroll_year + 1
WHERE
  a.avg_wage < b.avg_wage
ORDER BY
  a.payroll_industry,
  a.payroll_year;

--Možnost č.2: Pomocí LAG funkce
WITH
  -- Krok 1: Spočítání průměrné roční mzdy pro každé odvětví
  industry_wages AS (
    SELECT
      payroll_industry,
      payroll_year,
      AVG(average_wages) AS avg_wage
    FROM
      t_katerina_havelkova_project_sql_primary_final
    WHERE
      payroll_year BETWEEN 2006 AND 2018
    GROUP BY
      payroll_industry,
      payroll_year
  ),
  -- Krok 2: Získání mzdy z předchozího roku pomocí funkce LAG(), seřazeno dle roku a odvětví
  wage_changes AS (
    SELECT
      payroll_industry,
      payroll_year,
      avg_wage,
      LAG(avg_wage, 1) OVER (
        PARTITION BY
          payroll_industry
        ORDER BY
          payroll_year
      ) AS previous_avg_wage
    FROM
      industry_wages
  )
  -- Krok 3: Finální výběr a filtrace na poklesy
SELECT
  payroll_industry,
  payroll_year AS current_year,
  payroll_year - 1 AS previous_year,
  ROUND(avg_wage - previous_avg_wage, 2) AS wage_difference
FROM
  wage_changes
WHERE
  avg_wage < previous_avg_wage -- Klíčová podmínka pro filtrování poklesu mezd
ORDER BY
  payroll_industry,
  current_year;