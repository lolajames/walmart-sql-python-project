--TO CHECK ROW COUNT MATCHES

SELECT * 
FROM walmart ;

-- TO CHECK DUPLICATES
SELECT invoice_id, count(*)
FROM walmart
GROUP BY invoice_id
HAVING COUNT (*)>1;

--For null

SELECT count(*)
FROM walmart
WHERE unit_price IS NULL OR quantity IS NULL;

--CHECK DATA TYPE 

SELECT column_name, data_type
FROM information_schema.columns
WHERE table_name = 'walmart';

SELECT * 
FROM walmart ;

---BUSINESS QUESTIONS 
-- 1. WHAT IS THE TOTAL REVENUE GENERATED ACROSS ALL TRANSACTIONS?

select sum(revenue) as total_revenue
from
(SELECT (unit_price * quantity) as revenue 
FROM walmart) as sales

-- Another way without subquery

select sum(unit_price * quantity)
from walmart

--2. Which city has the highest number of transactions?

select "City", count(invoice_id) as number_of_transaction
from walmart
group by "City"
order by count(invoice_id) desc

-- 3. What is the average rating per category?

select category, avg(rating) as avg_rating
from walmart
group by category

--4. Which branch generated the highest total revenue?

select "Branch", sum(unit_price * quantity) as total_revenue
from walmart
GROUP BY "Branch"
ORDER BY total_revenue desc;

--5. What is the most commonly used payment method, and how does it vary by city?

select "City", payment_method, count(invoice_id)
from walmart
GROUP BY "City" , payment_method
ORDER BY count(invoice_id) desc;

select  payment_method, count(invoice_id)
from walmart
GROUP BY  payment_method
ORDER BY count(invoice_id) desc;

--6. Which product category has the highest average profit margin?

SELECT category, avg(profit_margin) as avg_profit_margin
FROM walmart
GROUP BY category
order by avg_profit_margin desc

--7. What is the total revenue per month across the full dataset (2019-2023)?

select extract(year from date) as  year_number,
       extract(month from date) as mon_number,
       TO_CHAR(date,'MON-YYYY') as month_year_name,
       sum(unit_price * quantity) as total_revenue
from walmart
group by  year_number, mon_number, month_year_name
order by   year_number, mon_number ;

--7B. What's driving the Nov/Dec revenue spike identified in Q7 — more transactions, larger basket sizes, or higher prices?

select extract(year from date) as  year_number,
           extract(month from date) as mon_number,
           TO_CHAR(date,'MON-YYYY') as month_year_name,
           sum(unit_price * quantity) as total_revenue,
	       count(invoice_id) as total_transaction,
	       avg(quantity) as  avg_quantity,
	        avg(unit_price) as avg_price
   from walmart
	group by  year_number, mon_number, month_year_name
order by  year_number, mon_number ;




-- 8. Which day of the week has the highest average transaction value?

select extract(ISODOW from date) as day_number_mon_to_sun,
       to_char(date,'FMDay') as day_name,
	   count(invoice_id) as total_transaction,
	   avg(unit_price * quantity) as avg_transaction_value
from walmart
group by day_number_mon_to_sun, day_name
order by avg_transaction_value desc;


-- 9. Is there a noticeable revenue trend year-over-year?

select extract (year from date) as year_number,
       sum(unit_price* quantity) as total_revenue
from walmart
group by year_number
order by year_number

-- 10. Rank branches by revenue within each city (window function).
select "City","Branch", total_revenue,
       RANK()OVER(PARTITION BY "City" order by total_revenue desc) as branch_rank
 from (select "City","Branch",sum(unit_price * quantity) total_revenue
       from walmart
       group by "City","Branch"
	   ) as Branch_total_revenue
ORDER BY branch_rank

select "City", count(distinct "Branch") as branch_count
from walmart
group by "City"
order by branch_count desc

-- 10B. Rank branches by revenue within each city (Filtering for cities with 2 branch i.e Waxahachie and Weslaco).
select "City","Branch", total_revenue,
       RANK()OVER(PARTITION BY "City" order by total_revenue desc) as branch_rank
 from (select "City","Branch",sum(unit_price * quantity) total_revenue
       from walmart
	   where "City" = 'Waxahachie' or "City" = 'Weslaco'
       group by "City","Branch"
	   ) as Branch_total_revenue
ORDER BY branch_rank

--11. Find the top 3 best-selling categories per branch (window function + partition).
  select "City","Branch",category,total_revenue,category_rank
   from (select "City","Branch",category,total_revenue,
                  RANK()OVER(PARTITION BY "Branch" ORDER BY total_revenue DESC) as category_rank
           from (SELECT "City","Branch",category,sum(unit_price * quantity) as total_revenue
                  FROM walmart
                   group by category,"Branch","City"
	                ) as category_total_revenue
	               ) as ranked_categories
   where category_rank <= 3
   order by category_rank
--12. Compare each branch's monthly revenue to the overall monthly average.

select     year_number,
           mon_number,
		   mon_year_name,
          "City",
           "Branch",
		   total_revenue, 
		   avg_monthly_revenue,
		   total_revenue - avg_monthly_revenue as difference_from_average	
from (select "City",
           "Branch",
		   mon_number,
		   year_number,
		   mon_year_name,
		   total_revenue,
		   avg(total_revenue)over(partition by mon_number, year_number) as avg_monthly_revenue
      from (SELECT "City","Branch",
            extract(month from date) as mon_number,
	        extract(YEAR from date) as year_number,
	        to_char(date, 'MON-YYYY') as mon_year_name,
	        sum(unit_price*quantity) as total_revenue
            from walmart
             group by "City","Branch", mon_number,year_number,mon_year_name
	         ) as monthly_revenue
	 ) as average_mon_revenue


--12B. Which branches most consistently outperform or underperform their monthly cohort average across the full dataset (not just in a single month)?
select "Branch",
        avg(difference_from_average) as avg_diff
from      (select year_number,
                mon_number,
		        mon_year_name,
                "City",
                 "Branch",
		         total_revenue, 
		         avg_monthly_revenue,
		          total_revenue - avg_monthly_revenue as difference_from_average	
             from (select "City",
                     "Branch",
		            mon_number,
		            year_number,
		            mon_year_name,
		            total_revenue,
		            avg(total_revenue)over(partition by mon_number, year_number) as avg_monthly_revenue
                    from (SELECT "City","Branch",
                               extract(month from date) as mon_number,
	                            extract(YEAR from date) as year_number,
	                            to_char(date, 'MON-YYYY') as mon_year_name,
	                            sum(unit_price*quantity) as total_revenue
                            from walmart
                                group by "City","Branch", mon_number,year_number,mon_year_name
	                        ) as monthly_revenue
	               ) as average_mon_revenue
               ) Branch_monthly_performance
   group by "Branch"
   order by avg_diff DESC