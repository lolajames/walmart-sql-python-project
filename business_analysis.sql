-- =========================================================
-- Walmart Sales Data - Business Analysis Queries
-- =========================================================
-- Database: walmart_db | Table: walmart
-- 12 business questions, from basic aggregation through
-- window functions and multi-layer subqueries.
-- =========================================================


-- ---------------------------------------------------------
-- Q1: What is the total revenue generated across all transactions?
-- ---------------------------------------------------------
SELECT SUM(unit_price * quantity) AS total_revenue
FROM walmart;


-- ---------------------------------------------------------
-- Q2: Which city has the highest number of transactions?
-- ---------------------------------------------------------
SELECT "City", COUNT(invoice_id) AS number_of_transactions
FROM walmart
GROUP BY "City"
ORDER BY number_of_transactions DESC;


-- ---------------------------------------------------------
-- Q3: What is the average rating per category?
-- ---------------------------------------------------------
SELECT category, AVG(rating) AS avg_rating
FROM walmart
GROUP BY category;


-- ---------------------------------------------------------
-- Q4: Which branch generated the highest total revenue?
-- ---------------------------------------------------------
SELECT "Branch", SUM(unit_price * quantity) AS total_revenue
FROM walmart
GROUP BY "Branch"
ORDER BY total_revenue DESC;


-- ---------------------------------------------------------
-- Q5: What is the most commonly used payment method,
--     and how does it vary by city?
-- ---------------------------------------------------------

-- 5a: Overall most common payment method
SELECT payment_method, COUNT(invoice_id) AS transaction_count
FROM walmart
GROUP BY payment_method
ORDER BY transaction_count DESC;

-- 5b: Breakdown by city
SELECT "City", payment_method, COUNT(invoice_id) AS transaction_count
FROM walmart
GROUP BY "City", payment_method
ORDER BY transaction_count DESC;


-- ---------------------------------------------------------
-- Q6: Which product category has the highest average profit margin?
-- ---------------------------------------------------------
SELECT category, AVG(profit_margin) AS avg_profit_margin
FROM walmart
GROUP BY category
ORDER BY avg_profit_margin DESC;


-- ---------------------------------------------------------
-- Q7: What is the total revenue per month across
--     the full dataset (2019-2023)?
-- ---------------------------------------------------------
SELECT
    EXTRACT(YEAR FROM date) AS year_number,
    EXTRACT(MONTH FROM date) AS mon_number,
    TO_CHAR(date, 'MON-YYYY') AS month_year_name,
    SUM(unit_price * quantity) AS total_revenue
FROM walmart
GROUP BY year_number, mon_number, month_year_name
ORDER BY year_number, mon_number;  -- chronological order to show trend


-- ---------------------------------------------------------
-- Q8: Which day of the week has the highest average
--     transaction value?
-- ---------------------------------------------------------
SELECT
    EXTRACT(ISODOW FROM date) AS day_number_mon_to_sun,
    TO_CHAR(date, 'FMDay') AS day_name,
    COUNT(invoice_id) AS total_transactions,
    AVG(unit_price * quantity) AS avg_transaction_value
FROM walmart
GROUP BY day_number_mon_to_sun, day_name
ORDER BY avg_transaction_value DESC;  -- ranking question


-- ---------------------------------------------------------
-- Q9: Is there a noticeable revenue trend year-over-year?
-- ---------------------------------------------------------
SELECT
    EXTRACT(YEAR FROM date) AS year_number,
    SUM(unit_price * quantity) AS total_revenue
FROM walmart
GROUP BY year_number
ORDER BY year_number;  -- chronological order to show trend


-- ---------------------------------------------------------
-- Q10: Rank branches by revenue within each city
-- ---------------------------------------------------------
SELECT
    "City",
    "Branch",
    total_revenue,
    RANK() OVER (PARTITION BY "City" ORDER BY total_revenue DESC) AS branch_rank
FROM (
    SELECT "City", "Branch", SUM(unit_price * quantity) AS total_revenue
    FROM walmart
    GROUP BY "City", "Branch"
) AS branch_total_revenue
ORDER BY branch_rank;

-- Note: most cities in this dataset have only one branch, so most
-- ranks default to 1. Waxahachie and Weslaco are the two cities
-- with 2 branches each, where ranking is actually meaningful:
SELECT
    "City",
    "Branch",
    total_revenue,
    RANK() OVER (PARTITION BY "City" ORDER BY total_revenue DESC) AS branch_rank
FROM (
    SELECT "City", "Branch", SUM(unit_price * quantity) AS total_revenue
    FROM walmart
    WHERE "City" = 'Waxahachie' OR "City" = 'Weslaco'
    GROUP BY "City", "Branch"
) AS branch_total_revenue
ORDER BY branch_rank;


-- ---------------------------------------------------------
-- Q11: Find the top 3 best-selling categories per branch
-- ---------------------------------------------------------
SELECT "City", "Branch", category, total_revenue, category_rank
FROM (
    SELECT
        "City",
        "Branch",
        category,
        total_revenue,
        RANK() OVER (PARTITION BY "Branch" ORDER BY total_revenue DESC) AS category_rank
    FROM (
        SELECT "City", "Branch", category, SUM(unit_price * quantity) AS total_revenue
        FROM walmart
        GROUP BY category, "Branch", "City"
    ) AS category_total_revenue
) AS ranked_categories
WHERE category_rank <= 3
ORDER BY category_rank;


-- ---------------------------------------------------------
-- Q12: Compare each branch's monthly revenue to the
--      overall monthly average
-- ---------------------------------------------------------
SELECT
    "City",
    "Branch",
    mon_number,
    year_number,
    mon_year_name,
    total_revenue,
    avg_monthly_revenue,
    total_revenue - avg_monthly_revenue AS difference_from_average
FROM (
    SELECT
        "City",
        "Branch",
        mon_number,
        year_number,
        mon_year_name,
        total_revenue,
        AVG(total_revenue) OVER (PARTITION BY mon_number, year_number) AS avg_monthly_revenue
    FROM (
        SELECT
            "City",
            "Branch",
            EXTRACT(MONTH FROM date) AS mon_number,
            EXTRACT(YEAR FROM date) AS year_number,
            TO_CHAR(date, 'MON-YYYY') AS mon_year_name,
            SUM(unit_price * quantity) AS total_revenue
        FROM walmart
        GROUP BY "City", "Branch", mon_number, year_number, mon_year_name
    ) AS monthly_revenue
) AS average_mon_revenue
ORDER BY year_number, mon_number, "Branch";
