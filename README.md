# Walmart Sales Data — End-to-End Python & SQL Analysis

## Overview
This project is an end-to-end data pipeline built to practice real-world data
cleaning and analysis skills. It takes a raw 10,000+ row Walmart sales dataset
from Kaggle, cleans it using Python (pandas), loads it into a PostgreSQL
database, and answers business questions using SQL — progressing from
basic aggregation to multi-layer subqueries and window functions.

**Dataset:** Walmart 10K Sales Dataset (Kaggle) — spans January–March 2019,
then full years 2020–2023. See the Data Quality Note below regarding the
partial 2019 coverage.
**Tools:** Python, pandas, PostgreSQL, SQLAlchemy, psycopg2

---

## Project Structure
```
├── data_cleaning.py       # Python script: load, clean, and push data to PostgreSQL
├── business_analysis.sql  # SQL file: all business question queries
└── README.md               # This file
```

---

## Data Cleaning Process
The raw dataset (10,051 rows) was cleaned using a 6-stage methodology. Note:
the dataset's date coverage is uneven — see the Data Quality Note further
below for details on the partial 2019 records.

1. **Understand the shape of the data** — reviewed row/column counts, data types
2. **Missing values** — found 31 rows missing both `unit_price` and `quantity`
   (the same rows for both columns). Since these fields are essential for
   revenue calculations and represented only ~0.3% of the data, the rows
   were dropped rather than imputed.
3. **Duplicates** — found 51 duplicate `invoice_id` entries (exact full-row
   duplicates, each appearing exactly twice). Removed, keeping the first
   occurrence of each.
4. **Data type fixes:**
   - `unit_price`: stored as text due to a `$` symbol → cleaned and converted to float
   - `date`: stored as text in `DD/MM/YY` format → converted to proper datetime
   - `time`: stored as text (`HH:MM:SS`) → converted to time objects
5. **Standardization** — checked `Branch`, `City`, `category`, and
   `payment_method` for inconsistent casing/spacing. All were already clean;
   no changes needed.
6. **Outliers / logic errors** — reviewed summary statistics for all numeric
   columns. No negative prices, no impossible quantities, no broken dates.
   All values fell within realistic ranges.

**Result:** 10,051 raw rows → **9,969 clean rows**, loaded into PostgreSQL.

---

## Business Questions Answered

| # | Question |
|---|----------|
| 1 | What is the total revenue generated across all transactions? |
| 2 | Which city has the highest number of transactions? |
| 3 | What is the average rating per category? |
| 4 | Which branch generated the highest total revenue? |
| 5 | What is the most commonly used payment method, and how does it vary by city? |
| 6 | Which product category has the highest average profit margin? |
| 7 | What is the total revenue per month across the full dataset? |
| 7B | What's driving the Nov/Dec revenue spike identified in Q7 — more transactions, larger basket sizes, or higher prices? |
| 8 | Which day of the week has the highest average transaction value? |
| 9 | Is there a noticeable revenue trend year-over-year? |
| 10 | Rank branches by revenue within each city (window function) |
| 10B | Filtering to only the cities with multiple branches (Waxahachie, Weslaco), how do same-city branches compare? |
| 11 | Find the top 3 best-selling categories per branch (window function + partition) |
| 12 | Compare each branch's monthly revenue to the overall monthly average (subquery + window function) |
| 12B | Which branches most consistently outperform or underperform their monthly cohort average across the full dataset? |

Full queries are in [`business_analysis.sql`](./business_analysis.sql).

---

## Data Quality Note

The dataset's 2019 records only cover **January–March**, while 2020–2023 each
contain a full 12 months. Transaction volume and average quantity per
transaction in that 2019 window are also roughly 2–3x higher than the
equivalent months in later years, suggesting this slice isn't representative
of a typical year. As this is a Kaggle-sourced dataset rather than real
company records, the likely explanation is a partial or non-representative
sample rather than a genuine business event. **Findings involving 2019
(including the Q9 year-over-year comparison) should be interpreted with
this in mind.**

---

## Key Findings

- **Total revenue:** $1,209,726.38 across all transactions.

- **City with most transactions:** Weslaco (396), followed closely by
  Waxahachie (378) — though this is influenced by both cities having two
  branches, unlike almost every other city in the dataset, which has only
  one.

- **Highest average-rated category:** Food and beverages (7.11), with
  Health and beauty close behind (7.00). Ratings cluster into two tiers:
  Food and beverages, Health and beauty, and Sports and travel sit around
  6.9–7.1, while Electronic accessories, Fashion accessories, and Home and
  lifestyle sit lower, around 5.7–5.9.

- **Top-performing branch:** WALM009 in Plano ($25,688.34), only narrowly
  ahead of WALM074 in Weslaco ($25,555.42) — a gap of about $133.

- **Most common payment method:** Credit card (4,256 transactions),
  followed by Ewallet (3,881) and Cash (1,832). This varies by city:
  Credit card dominates in the higher-volume cities (e.g. Waxahachie,
  Weslaco, Port Arthur), while Ewallet is the leading method in most
  smaller cities.

- **Highest average profit margin:** Food and beverages (~40.0%), though
  essentially tied with Health and beauty (~40.0%) — Food and beverages
  leads in both average rating and profit margin. All six categories sit
  within a tight 38–40% range overall.

- **Monthly revenue pattern (Q7):** Revenue is heavily seasonal. November
  and December consistently show a sharp spike each year, reaching roughly
  $58,000–$67,000 compared to $5,000–$9,000 in most other months.

- **Cause of the Nov/Dec spike (Q7B):** Average quantity per transaction
  (~1.9–2.2) and average unit price (~$47–54) stay flat year-round,
  including in Nov/Dec. The spike is driven almost entirely by a roughly
  3x increase in transaction count during those two months — pointing to
  higher shopper volume/seasonal foot traffic rather than larger basket
  sizes or promotional pricing.

- **Best day of the week (by avg. transaction value):** Saturday
  ($128.82) narrowly leads Tuesday ($123.45) and Sunday ($121.24). The
  spread across all seven days is modest (~$11.50 between highest and
  lowest), and transaction counts are fairly even by day (1,300–1,470) —
  so this is a mild effect, not a dramatic one.

- **Year-over-year revenue trend (Q9):** Excluding 2019 (see Data Quality
  Note above), annual revenue across 2020–2023 has stayed relatively flat,
  fluctuating narrowly between $217,000–$233,000 with no clear upward or
  downward trend.

- **Branch ranking within multi-branch cities (Q10/10B):** In Waxahachie,
  the two branches perform almost identically (within ~2%). In Weslaco,
  one branch (WALM074) outperforms its city-mate (WALM082) by roughly
  23%, suggesting a meaningful difference in location, demand, or
  operations worth investigating further.

- **Top categories by branch (Q11):** Nearly every branch shows the same
  top two best-selling categories — Home and lifestyle and Fashion
  accessories — just swapping which one ranks #1. This holds true across
  almost all 100 branches regardless of location, suggesting these
  categories are universal revenue drivers company-wide rather than being
  city-specific. Interestingly, Home and lifestyle sells the most despite
  having the lowest average rating and among the lowest profit margins
  (see Q3, Q6).

- **Most consistent branch performance (Q12B):** WALM003 (San Antonio) is
  the most consistent over-performer relative to its monthly cohort,
  averaging about $378 above the monthly average across the full dataset
  — ahead of WALM074 (Weslaco, ~$320), which also stood out in Q10/10B as
  the stronger of Weslaco's two branches. WALM092 (Lake Jackson) is the
  most consistent under-performer, averaging about $210 below its monthly
  cohort.

---

## Tools & Tech Stack
- **Python** — pandas for data cleaning
- **PostgreSQL** — data storage and SQL analysis
- **SQLAlchemy + psycopg2** — Python-to-PostgreSQL connection
- **VS Code** — development environment
- **Kaggle API** — dataset retrieval

---

## How to Run This Project

1. **Clone the repository**
   ```bash
   git clone <your-repo-url>
   cd walmart-project
   ```

2. **Install dependencies**
   ```bash
   pip install pandas sqlalchemy psycopg2-binary
   ```

3. **Set up PostgreSQL**
   - Create a database named `walmart_db`
   - Set your PostgreSQL password as an environment variable (never hardcoded
     in the script). In PowerShell:
     ```powershell
     $env:POSTGRES_PASSWORD = "your_actual_password"
     ```
     Optional overrides (defaults shown): `POSTGRES_USER` (postgres),
     `POSTGRES_HOST` (localhost), `POSTGRES_PORT` (5432),
     `POSTGRES_DB` (walmart_db)

4. **Set the CSV path (optional)**
   By default, the script looks for `Walmart.csv` in your Downloads folder.
   To use a different location:
   ```powershell
   $env:WALMART_CSV_PATH = "C:\path\to\your\Walmart.csv"
   ```

5. **Run the cleaning script**
   ```bash
   python data_cleaning.py
   ```
   This loads the raw CSV, applies all 6 cleaning stages, and pushes the
   cleaned table into PostgreSQL.

6. **Run the business analysis queries**
   Open `business_analysis.sql` in pgAdmin's Query Tool (or any PostgreSQL
   client) and run each query to explore the findings.

---

## Author
Ololade Gbodogbe — self-directed learner building toward a Data Analyst / Analytics
Engineer role, focused on SQL, Python, and BI tools (Power BI, Tableau, Excel).
