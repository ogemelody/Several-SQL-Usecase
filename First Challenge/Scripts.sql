-- 1. What is the total amount each customer spent at the restaurant?
-- no need for ROW_NUMBER() since you are using GROUP BY already.

WITH CTE AS (
Select 
	customer_id,
	Sum(price) as total_price,
	ROW_NUMBER() OVER (Partition BY customer_id ORDER BY customer_id) as row_num

from sales
	Join menu on sales.product_id = menu.product_id
	GROUP BY customer_id
)
Select 
CTE.customer_id,
CTE.total_price
from CTE;



-- 2. How many days has each customer visited the restaurant?

SELECT 
	customer_id,
	COUNT(DISTINCT order_date) as no_of_visit
	from sales
	GROUP BY customer_id;

-- 3. What was the first item from the menu purchased by each customer?

With cte as (
SELECT 
	sales.customer_id, 
	menu.product_id,
	menu.product_name,
	ROW_NUMBER() OVER (PARTITION BY customer_id ORDER BY customer_id) as row_num 
	FROM sales
	JOIN menu ON sales.product_id = menu.product_id
)
SELECT 
cte.customer_id,
cte.product_id,
cte.product_name
from cte
Where cte.row_num = 1 ;

-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?

SELECT max(product_id) as most_purchased_item_on_the_menu
from sales;
--
With cte as(
Select 
	customer_id,
	sales.product_id as product_count,
	product_name
	FROM sales
	JOIN menu On sales.product_id= menu.product_id
	
)
SELECT 
cte.customer_id,
count(cte.product_count) as no_of_purchase,
cte.product_name
From cte
Where cte.product_count =3

GROUP BY cte.customer_id,cte.product_name;


WITH cte AS (
    SELECT 
        sales.product_id,
        menu.product_name,
        COUNT(*) AS purchase_count
    FROM sales
    JOIN menu ON sales.product_id = menu.product_id
    GROUP BY sales.product_id, menu.product_name
)
SELECT 
    cte.product_id AS most_purchased_item_on_the_menu,
    cte.purchase_count AS times_purchased
FROM cte
WHERE cte.purchase_count = (SELECT MAX(purchase_count) FROM cte);


-- 5. Which item was the most popular for each customer?
WITH cte AS (
    SELECT
        customer_id,
        sales.product_id,
        product_name,
        RANK() OVER (PARTITION BY customer_id ORDER BY COUNT(*) DESC) AS popularity_rank
    FROM
        sales
    JOIN
        menu ON sales.product_id = menu.product_id
    GROUP BY
        customer_id,
        sales.product_id,
        product_name
)
SELECT
    customer_id,
    product_id,
    product_name
FROM
    cte
WHERE
    popularity_rank = 1;


-- 6. Which item was purchased first by the customer after they became a member?
WITH cte as (
SELECT 
	sales.customer_id,
	product_id,
	order_date,
	members.join_date
	FROM sales
	INNER JOIN members On sales.order_date=members.join_date
	WHERE sales.customer_id=members.customer_id
)
Select 
cte.product_id,
cte.customer_id,
cte.order_date,
cte.join_date
from cte
 ;

select * from members;

WITH cte AS (
    SELECT
        sales.customer_id,
        sales.product_id,
        sales.order_date,
        members.join_date,
        MIN(sales.order_date) OVER (PARTITION BY sales.customer_id, members.join_date  ORDER BY sales.order_date) AS first_purchase_date
    FROM
        sales
    JOIN
        members ON sales.customer_id = members.customer_id
    WHERE
        sales.order_date >= members.join_date
)
SELECT
    cte.customer_id,
    cte.product_id,
    cte.order_date,
    cte.join_date
FROM
    cte
WHERE
    cte.order_date = cte.first_purchase_date;

-- 7. Which item was purchased just before the customer became a member? REDO
WITH cte AS (
    SELECT
        sales.customer_id,
        sales.product_id,
        sales.order_date,
        members.join_date,
        LAG(sales.order_date) OVER (PARTITION BY sales.customer_id ORDER BY sales.order_date) AS previous_order_date
    FROM
        sales
    JOIN
        members ON sales.customer_id = members.customer_id;
)
SELECT
    cte.customer_id,
    cte.product_id,
    cte.order_date,
    cte.join_date
FROM
    cte
WHERE
    cte.order_date = cte.previous_order_date;
