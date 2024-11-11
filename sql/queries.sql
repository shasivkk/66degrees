--max sales day by product line
WITH
	sales_by_day
	AS
	(
		SELECT
			s.product_line ,
			s.date_of_purchase ,
			s.total,
			sum(total) OVER(PARTITION BY product_line,
	date(date_of_purchase)) total_sales_by_product_day,
			strftime('%d',
	date_of_purchase) day,
			strftime('%m',
	date_of_purchase) month,
			strftime('%Y',
	date_of_purchase) year
		FROM
			sales s
		ORDER BY
	date_of_purchase ,
	product_line
	)
SELECT round(max(total_sales_by_product_day),2) max_sales, product_line, DAY, MONTH, year
FROM sales_by_day
GROUP BY product_line
ORDER BY max_sales DESC

--max sales day by month -- which product sold most in the month of the given data
with
	monthly_sales
	as
	(
		SELECT
			s.product_line ,
			--s.date_of_purchase ,
			--s.total,
			sum(total) OVER(PARTITION BY product_line,
	strftime('%m',date_of_purchase)) total_sales_by_product_month,
			--strftime('%d',date_of_purchase) day,
			strftime('%m',date_of_purchase) month
		--strftime('%Y',date_of_purchase) year
		FROM sales s
	)
select max(total_sales_by_product_month), product_line, month
from monthly_sales

--branch which had max sales monthwise
select distinct b.Branch, sum(total) over(PARTITION by b.Branch, strftime('%m',s.date_of_purchase)) monthly_sales, strftime('%m',s.date_of_purchase) sales_month
from branch b , sales s
where s.branch_id = b.branch_id
order by sales_month


--total cash sales by members
select distinct c.customer_type , c.payment, sum(s.total) over(PARTITION by c.customer_type)
from customer c , sales s
where s.cust_info_id = c.cust_info_id
	and c.customer_type = 'Member'
	and c.payment ='Cash'

--max member sales by branch by month
select DISTINCT b.Branch, sum(s.total) over(PARTITION by c.customer_type,b.Branch,strftime('%m',s.date_of_purchase)) sales_by_month_branch, c.customer_type  , strftime('%m',s.date_of_purchase)
from branch b , customer c , sales s
where s.branch_id =b.branch_id
	and s.cust_info_id = c.cust_info_id
	and c.customer_type ='Member'
order by sales_by_month_branch desc

