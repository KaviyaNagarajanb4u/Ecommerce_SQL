select*
from Olist_customers_dataset;


-------count of city-----
select 
customer_city,
customer_state,count(*) as city_count
from Olist_customers_dataset
group by customer_city,customer_state
order by count(*) DESC;

----to know about orders---
select * from Olist_orders_dataset;
---count of orders----
select count(*) from Olist_orders_dataset;

----number of orders in each date and time---
select order_purchase_timestamp,count(*)
from Olist_orders_dataset
group by order_purchase_timestamp;

---cast the dates using two columns after column name----

SELECT 
    CAST(order_purchase_timestamp AS DATE) AS order_date,
    COUNT(*) AS order_count
FROM Olist_orders_dataset
GROUP BY CAST(order_purchase_timestamp AS DATE)
ORDER BY CAST(order_purchase_timestamp AS DATE) ASC;


---cast  dates by desc order---

SELECT 
    CAST(order_purchase_timestamp AS DATE) AS order_date,
    COUNT(*) AS order_count
FROM Olist_orders_dataset
GROUP BY CAST(order_purchase_timestamp AS DATE)
ORDER BY count(*) DESC;

------fetching data from Product table and using inner join in order_items table----
select
p.product_id,
p.product_category_name,
oi.order_id,
oi.order_item_id
from Olist_products_dataset p
inner join Olist_order_items_dataset oi on p.product_id=oi.product_id;


select
p.product_id,
p.product_category_name,
oi.order_id,
oi.order_item_id,oi.*
from Olist_products_dataset p
inner join Olist_order_items_dataset oi on p.product_id=oi.product_id;

----------------------count of product ------
select
p.product_category_name,
count(*)
from Olist_products_dataset p
inner join Olist_order_items_dataset oi on p.product_id=oi.product_id
group by p.product_category_name
order by count(*) DESC;

---------------


SELECT
    t.product_category_name_english,
    COUNT(*) AS count_orders
FROM Olist_products_dataset p
INNER JOIN Olist_order_items_dataset oi ON p.product_id = oi.product_id
INNER JOIN product_category_name_translation t ON p.product_category_name = t.product_category_name
GROUP BY t.product_category_name_english
ORDER BY count_orders DESC;
-----------average difference between two dates----
SELECT
    order_id,
    order_status,
    CAST(order_purchase_timestamp AS DATETIME) AS order_purchase_timestamp,
    CAST(order_delivered_customer_date AS DATETIME) AS order_delivered_customer_date,
    CAST(order_estimated_delivery_date AS DATETIME) AS order_estimated_delivery_date,
    DATEDIFF(DAY, order_delivered_customer_date, order_estimated_delivery_date) AS date_diff
FROM Olist_orders_dataset
WHERE order_status = 'delivered';

------------------identify month------------
SELECT
    order_id,
    order_status,
    DATEPART(MONTH, CAST(order_purchase_timestamp AS DATETIME)) AS order_month,
    CAST(order_delivered_customer_date AS DATETIME) AS order_delivered_customer_date,
    CAST(order_estimated_delivery_date AS DATETIME) AS order_estimated_delivery_date,
    DATEDIFF(DAY, order_delivered_customer_date, order_estimated_delivery_date) AS date_diff
FROM Olist_orders_dataset
WHERE order_status = 'delivered';

-----------------Identify Year---------------------------
SELECT
    order_id,
    order_status,
	DATEPART(YEAR, CAST(order_purchase_timestamp AS DATETIME)) AS order_year,
    DATEPART(MONTH, CAST(order_purchase_timestamp AS DATETIME)) AS order_month,
    CAST(order_delivered_customer_date AS DATETIME) AS order_delivered_customer_date,
    CAST(order_estimated_delivery_date AS DATETIME) AS order_estimated_delivery_date,
    DATEDIFF(DAY, order_delivered_customer_date, order_estimated_delivery_date) AS date_diff
FROM Olist_orders_dataset
WHERE order_status = 'delivered';


-------------------------------------------------------
SELECT
    DATEPART(YEAR, CAST(order_purchase_timestamp AS DATETIME)) AS order_year,
    DATEPART(MONTH, CAST(order_purchase_timestamp AS DATETIME)) AS order_month,
    AVG(DATEDIFF(DAY, order_delivered_customer_date, order_estimated_delivery_date)) AS date_diff
FROM Olist_orders_dataset
WHERE order_status = 'delivered'
  AND order_delivered_customer_date IS NOT NULL
GROUP BY 
    DATEPART(YEAR, CAST(order_purchase_timestamp AS DATETIME)),
    DATEPART(MONTH, CAST(order_purchase_timestamp AS DATETIME))
ORDER BY 
    order_year, 
    order_month;
--------------------------------------------------------------
SELECT
    order_id,
    order_year,
    order_month,
    actual_delivery_date,
    estimated_delivery_date,
    date_diff,
    avg_month_diff
FROM (
    SELECT
        order_id,
        order_year,
        order_month,
        actual_delivery_date,
        estimated_delivery_date,
        DATEDIFF(DAY, actual_delivery_date, estimated_delivery_date) AS date_diff, -- Calculate the date difference in days
        AVG(DATEDIFF(DAY, actual_delivery_date, estimated_delivery_date)) OVER(PARTITION BY order_year, order_month) AS avg_month_diff -- Avg diff for each month
    FROM (
        SELECT
            order_id,
            DATEPART(YEAR, CAST(order_purchase_timestamp AS DATETIME)) AS order_year,
            DATEPART(MONTH, CAST(order_purchase_timestamp AS DATETIME)) AS order_month,
            CAST(order_delivered_customer_date AS DATETIME) AS actual_delivery_date,
            CAST(order_estimated_delivery_date AS DATETIME) AS estimated_delivery_date
        FROM Olist_orders_dataset
        WHERE order_status = 'delivered'
        AND order_delivered_customer_date IS NOT NULL
    ) s
) t
WHERE date_diff < avg_month_diff;  


-----------------------------------------------------



