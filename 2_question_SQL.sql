WITH
  -- Krok 1: Průměrná mzda v daném roce 2006, 2018
  wages AS (
    SELECT
      payroll_year AS year,
      ROUND(AVG(average_wages), 2) AS total_avg_wage
    FROM
      t_katerina_havelkova_project_sql_primary_final
    WHERE
      payroll_year IN (2006, 2018)
    GROUP BY
      payroll_year
  ),
  -- Krok 2: Získání růměrné ceny pro vybrané kategorie
  prices AS (
    SELECT
      price_year_of_entry AS year,
      food_category,
      ROUND(AVG(price::numeric), 2) AS total_avg_price,
      MIN(unit_of_measure) AS unit
    FROM
      t_katerina_havelkova_project_sql_primary_final
    WHERE
      price_year_of_entry IN (2006, 2018)
      AND food_category IN (
        'Mléko polotučné pasterované',
        'Chléb konzumní kmínový'
      )
    GROUP BY
      price_year_of_entry,
      food_category
  )
  -- Krok 3: Finální výpočet: kolik jednotek potraviny lze koupit za průměrnou mzdu
SELECT
  p.year,
  p.food_category,
  -- Zde je přidána funkce NULLIF.
  -- Pokud by p.total_avg_price bylo 0, vrátí NULL a zabrání chybě dělení nulou.
  ROUND(w.total_avg_wage / NULLIF(p.total_avg_price, 0), 0) AS affordable_purchase,
  p.unit
FROM
  prices AS p
  JOIN wages AS w ON p.year = w.year
ORDER BY
  p.food_category,
  p.year;