--Která kategorie potravin zdražuje nejpomaleji (je u ní nejnižší percentuální meziroční nárůst)? 
--Cílem je identifikovat každou kategorii a spočítat její průměrný meziroční nárůst cen mezi roky 2006–2018,  
-- a následně najít tu, která má tento nárůst nejnižší. 
--Postup řešení:
--1.Výpočet průměrných cen za rok a kategorii.  
--2. Výpočet procentuálního meziročního nárustu cen.
--	(((Aktuální hodnota - Předchozí hodnota) / Předchozí hodnota) * 100)
--3. Vyhledání kategorie s nejnižším průměrným nárůstem za celé sledované období – pomocí LIMIT 1.
--Závěr:
--Nejpomaleji zdražující potravinou v období 2006–2018 byl cukr krystalový, u kterého došlo dokonce k průměrnému meziročnímu poklesu ceny o 1,92 %. 
--Naopak nejrychleji zdražujícími potravinami byly máslo (6,67 % ročně), papriky (7,29 %) a vejce (5,55 %).--> Po úpravě dotazu zmíněné níže. 
--Dotaz:
--Nejpomaleji zdražující potravina
WITH
  -- Krok 1: Spočítání průměrné ceny za roky a kategorie
  cleaned_prices AS (
    SELECT
      food_category,
      price_year_of_entry,
      ROUND(AVG(price::numeric), 2) AS avg_price
    FROM
      t_katerina_havelkova_project_sql_primary_final
    GROUP BY
      food_category,
      price_year_of_entry
  ),
  -- Krok 2: Výpočet meziročního růstu s ošetřením dělení nulou
  price_comparison AS (
    SELECT
      curr.food_category,
      curr.price_year_of_entry AS current_year,
      prev.price_year_of_entry AS previous_year,
      curr.avg_price AS current_price,
      prev.avg_price AS previous_price,
      ROUND(
        (
          (curr.avg_price - prev.avg_price) / NULLIF(prev.avg_price, 0)
        ) * 100,
        2
      ) AS annual_growth
    FROM
      cleaned_prices AS curr
      JOIN cleaned_prices AS prev ON curr.food_category = prev.food_category
      AND curr.price_year_of_entry = prev.price_year_of_entry + 1
  )
  -- Krok 3: Finální výstup a filtrace pro nejpomaleji zdražující potraviny
SELECT
  food_category,
  ROUND(AVG(annual_growth), 2) AS avg_percent_growth
FROM
  price_comparison
GROUP BY
  food_category
ORDER BY
  avg_percent_growth ASC
LIMIT
  1;

-----Nejrychleji zdražující potraviny (změní se pouze ORDER BY a LIMIT)

WITH
  -- Krok 1: Spočítání průměrné ceny za roky a kategorie
  cleaned_prices AS (
    SELECT
      food_category,
      price_year_of_entry,
      ROUND(AVG(price::numeric), 2) AS avg_price
    FROM
      t_katerina_havelkova_project_sql_primary_final
    GROUP BY
      food_category,
      price_year_of_entry
  ),
  -- Krok 2: Výpočet meziročního růstu s ošetřením dělení nulou
  price_comparison AS (
    SELECT
      curr.food_category,
      curr.price_year_of_entry AS current_year,
      prev.price_year_of_entry AS previous_year,
      curr.avg_price AS current_price,
      prev.avg_price AS previous_price,
      ROUND(
        (
          (curr.avg_price - prev.avg_price) / NULLIF(prev.avg_price, 0)
        ) * 100,
        2
      ) AS annual_growth
    FROM
      cleaned_prices AS curr
      JOIN cleaned_prices AS prev ON curr.food_category = prev.food_category
      AND curr.price_year_of_entry = prev.price_year_of_entry + 1
  )
  -- Krok 3: Finální výstup a filtrace pro nejrychleji zdražující potraviny
SELECT
  food_category,
  ROUND(AVG(annual_growth), 2) AS avg_percent_growth
FROM
  price_comparison
GROUP BY
  food_category
ORDER BY
  avg_percent_growth DESC
LIMIT
  5;