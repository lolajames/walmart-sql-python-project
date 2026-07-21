# Walmart Sales Data — End-to-End Python & SQL Analysis

## Overview
This project is an end-to-end data pipeline built to practice real-world data
cleaning and analysis skills. It takes a raw 10,000+ row Walmart sales dataset
from Kaggle, cleans it using Python (pandas), loads it into a PostgreSQL
database, and answers 12 business questions using SQL — progressing from
basic aggregation to multi-layer subqueries and window functions.

**Dataset:** Walmart 10K Sales Dataset (Kaggle)
**Tools:** Python, pandas, PostgreSQL, SQLAlchemy, psycopg2

---

## Project Structure
```
├── data_cleaning.py       # Python script: load, clean, and push data to PostgreSQL
├── business_analysis.sql  # SQL file: all 12 business question queries
└── README.md               # This file
```

---

## Data Cleaning Process
The raw dataset (10,051 rows) was cleaned using a 6-stage methodology:

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
| 7 | What is the total revenue per month across the full dataset (2019-2023)? |
| 8 | Which day of the week has the highest average transaction value? |
| 9 | Is there a noticeable revenue trend year-over-year? |
| 10 | Rank branches by revenue within each city (window function) |
| 11 | Find the top 3 best-selling categories per branch (window function + partition) |
| 12 | Compare each branch's monthly revenue to the overall monthly average (subquery + window function) |

Full queries are in [`business_analysis.sql`](./business_analysis.sql).

---

## Key Findings
*(Fill in your actual results here after re-running each query)*

- **Total revenue:** $[insert total from Q1]
- **City with most transactions:** [insert from Q2]
- **Highest average-rated category:** [insert from Q3]
- **Top-performing branch:** [insert from Q4]
- **Most common payment method:** [insert from Q5]
- **Highest profit margin category:** [insert from Q6]
- **Revenue trend 2019–2023:** [insert observation from Q9 — increasing / decreasing / stable]
- **Best day of week (by avg transaction value):** [insert from Q8]
- **Notable branch/category insight (Q10–Q12):** [insert observation, e.g. any branch consistently below the monthly average]

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
