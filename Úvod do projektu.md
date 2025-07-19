# Analýza životní úrovně v České republice  
## Dostupnost základních potravin optikou mezd a cen  

### Projekt SQL  
**Autor projektu:** Kateřina Havelková  
**Kurz:** Datová Akademie  

---

## Úvod a kontext projektu

*Tento projekt se zaměřuje na klíčový aspekt životní úrovně obyvatel České republiky – dostupnost základních potravin ve vztahu k vývoji průměrných mezd.*

---

## Cíl projektu

Cílem je analyzovat dynamiku vztahu mezi příjmy domácností a cenami základních spotřebních komodit v průběhu let.  
Pomocí SQL dotazů a datové analýzy se pokusíme zodpovědět sadu výzkumných otázek.

---

## Použitá data

Pro analýzu byly využity následující datové sady:

- `czechia_payroll`: Detailní informace o mzdách v různých odvětvích a regionech ČR v časovém průběhu.  
- `czechia_payroll_calculation`: Číselník typů kalkulací mezd.  
- `czechia_payroll_industry_branch`: Číselník odvětví české ekonomiky.  
- `czechia_payroll_unit`: Číselník jednotek hodnot (např. Kč, index).  
- `czechia_payroll_value_type`: Číselník typů hodnot mezd (např. průměrná hrubá mzda).  
- `czechia_price`: Informace o cenách vybraných základních potravin v ČR v časovém průběhu.  
- `czechia_price_category`: Číselník kategorií potravin.  
- `czechia_region`: Číselník krajů České republiky (CZ-NUTS 2).  
- `czechia_district`: Číselník okresů České republiky (LAU).  
- `countries`: Doplňující globální informace o zemích (hlavní město, měna, atd.).  
- `economies`: Ekonomické ukazatele (HDP, GINI koeficient, daňová zátěž) pro dané státy a roky.  

---

## Výzkumné otázky

Projekt se bude snažit poskytnout odpovědi na následující klíčové otázky:

1. **Mzdy napříč odvětvími:**  
   Rostou mzdy ve všech odvětvích v průběhu let, nebo v některých dochází k poklesu?

2. **Dostupnost potravin:**  
   Kolik litrů mléka a kilogramů chleba si bylo možné koupit za průměrnou mzdu v prvním a posledním dostupném období?

3. **Dynamika cen potravin:**  
   Která kategorie potravin zdražuje nejpomaleji (tj. má nejnižší meziroční procentuální nárůst)?

4. **Cenový a mzdový nárůst:**  
   Existuje rok, ve kterém byl meziroční růst cen potravin výrazně vyšší než růst mezd (např. o více než 10 %)?

5. **Vliv HDP:**  
   Má výše HDP vliv na změny ve mzdách a cenách potravin? Jinými slovy – pokud HDP v daném roce výrazně vzroste, projeví se to ve stejném nebo následujícím roce také růstem mezd nebo cen potravin?


---

## Poznatky k vytvořeným tabulkám

### 1. **Primární datová tabulka: Mzdy a ceny potravin v ČR (2006–2018)**

Tato tabulka agreguje data o průměrných hrubých mzdách a cenách vybraných potravin za Českou republiku. Data jsou sjednocena na totožné a porovnatelné období let 2006 až 2018.

**Klíčová rozhodnutí a filtrace:**

- **Filtrace mzdových dat:** Pro zajištění, že pracujeme pouze s daty o průměrné hrubé mzdě, byla použita podmínka `czpay.value_type_code = 5958`. Tento kód odpovídá položce *„Průměrná hrubá mzda na zaměstnance“* v číselníku `czechia_payroll_value_type`.

- **Agregace dle ČR:** Jelikož mzdová data nejsou detailně členěna podle regionů (jedná se o agregaci za celou ČR), byly z tabulky `czechia_price` vybrány pouze záznamy, kde `region_code IS NULL`. Tyto záznamy reprezentují celostátní průměrné ceny, čímž je zajištěna konzistentní úroveň agregace v obou datových sadách.

- **Propojení tabulek:** Tabulky mezd (`czechia_payroll`) a cen (`czechia_price`) byly propojeny na základě shody v roce. Původní regionální členění cen bylo pro účely této tabulky agregováno na úroveň celé ČR.					 

- **Vymezení časového rozsahu:** Pomocí agregačních funkcí `MIN` a `MAX` na sloupcích `czpay.payroll_year` a `date_part('year', cp.date_from)` bylo zjištěno, že společné porovnatelné období pro obě datové sady je **2006–2018**.

---

### 2. **Sekundární datová tabulka: Dodatečná data o evropských státech (2006–2018)**

Tato tabulka doplňuje kontext českých dat o makroekonomické ukazatele vybraných evropských států.

**Klíčová rozhodnutí a filtrace:**

- **Výběr evropských států:** Data byla omezena pouze na evropské země pomocí filtru `c.continent IN ('Europe')` z tabulky `countries`.

- **Sjednocení časového rozsahu:** Srovnatelné období bylo nastaveno na roky **2006–2018**, aby odpovídalo časovému rámci dat v primární tabulce. Toho bylo dosaženo pomocí filtru `e."year" BETWEEN 2006 AND 2018` z tabulky `economies`.

- **Statická vs. dynamická data:** Tabulka `countries` obsahuje statická (neměnná) data platná pro konkrétní rok – nejedná se o časové řady. Z této tabulky byly proto připojeny pouze vybrané identifikační údaje (např. název státu, hlavní město, měna).

- **Neúplnost dat:** Pro některé země nejsou dostupná všechna ekonomická data. Tato neúplnost může ovlivnit rozsah a validitu srovnání v rámci analýzy.
