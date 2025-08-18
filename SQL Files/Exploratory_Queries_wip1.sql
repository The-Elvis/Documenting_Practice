select *
from product_category_name_translation p ;

select *
from olist_customers_dataset o 


select distinct geolocation_city
from olist_geolocation_dataset o 

select *
from olist_geolocation_dataset o 

select *
from olist_order_items_dataset o 

select min(shipping_limit_date), max(shipping_limit_date) -- tells me the duration covered
from olist_order_items_dataset o 

select *
from olist_order_payments_dataset o 

select *
from olist_order_reviews_dataset o 

select min(order_purchase_timestamp), max(order_purchase_timestamp) -- tells me duration covered
from olist_orders_dataset o 

select *
from olist_orders_dataset o 

select *
from olist_products_dataset o ;

select *
from olist_sellers_dataset o 



select DATE(o.order_purchase_timestamp) as order_date, COUNT(*) as total_orders
from olist_orders_dataset o 
group by order_date 
order by order_date;

-- lets create a join

select *
from olist_orders_dataset o 
join olist_customers_dataset o2 
on o.customer_id = o2.customer_id
limit 1;

-- lets create a table from the join

create table customer_orders as
select order_id,
o.customer_id,
order_status,
order_purchase_timestamp,
order_approved_at,
order_delivered_carrier_date,
order_delivered_customer_date,
order_estimated_delivery_date,
customer_unique_id,
customer_zip_code_prefix,
customer_city,
customer_state
from olist_orders_dataset o 
join olist_customers_dataset o2 
on o.customer_id = o2.customer_id;


-- Let's view our table

select *
from customer_orders;

select *
from olist_products_dataset o 
where o.product_category_name = '';

create table product_dataset2
like olist_products_dataset;

insert product_dataset2
select *
from olist_products_dataset;

select count(*)
from product_dataset2
where product_category_name = '';

select count(*)
from product_dataset2;

select count(distinct product_id)
from product_dataset2;


update product_dataset2
set product_category_name = null
where product_category_name = '';

-- Now lets see if there are similar Product Ids but with product name

select t1.product_id, t2.product_id
from product_dataset2 t1
join product_dataset2 t2
on t1.product_id = t2.product_id
where t1.product_category_name is null
and t1.product_category_name is not null;

-- This shows there are none, now lets delete nulls


select *
from product_dataset2
where product_category_name is null;

delete 
from product_dataset2
where product_category_name is null;

select *
from product_dataset2 p 

-- Deleted

-- Translated the data set in google sheets

select count(*)
from product_dataset_translation_csv p 

select distinct product_category_name, product_category_name_1
from product_dataset_translation_csv p 
order by product_category_name;

select count(distinct product_category_name)
from product_dataset_translation_csv p 


select *
from product_category_name_translation2 p 

select *
from product_dataset_translation_csv p 
join product_category_name_translation2 p2 
on p.product_category_name = p2.product_category_name;

create table products
select product_id, p.product_category_name, product_category_name_1, product_category_name_english
from product_dataset_translation_csv p 
join product_category_name_translation2 p2 
on p.product_category_name = p2.product_category_name;

select distinct product_category_name, product_category_name_1, product_category_name_english
from products
order by product_category_name;


select distinct product_category_name
from products;


select *
from products
where product_category_name = '';

alter table products
drop column product_category_name;

alter table products
drop column product_category_name_1;

select *
from products
;

select count(distinct product_id)
from products
;

-- now let's join this to the order items dataset

select count(distinct product_id)
from olist_order_items_dataset;

select *
from olist_order_items_dataset o 
join products p 
on o.product_id = p.product_id;

create table order_items2
select product_category_name_english as product_category_name, 
order_id, 
order_item_id, 
o.product_id, 
seller_id, 
shipping_limit_date, 
price, 
freight_value
from olist_order_items_dataset o 
join products p 
on o.product_id = p.product_id;

-- Now lets see category sales revenue and potentially, highest sales by category

select *
from order_items2
order by price desc;

select product_category_name, count(product_category_name) Category_sales_volume, SUM(price) Category_Revenue 
from order_items2
group by product_category_name
order by 2 desc;

-- The Above Highlights Product categories with highest sales Volume


select product_category_name, count(product_category_name) Category_sales_volume, SUM(price) Category_Revenue 
from order_items2
group by product_category_name
order by 3 desc;

-- This Highlights product categories with highest revenue

-- Lets try to find sellers with highes sales and revenue

select count(distinct seller_id)
from order_items2 o

-- So we have just 3,033 sellers


select seller_id, count(order_id) sales_volume, SUM(price) sales_Revenue 
from order_items2
group by seller_id
order by 3 desc;

-- The above Highlights the sellers that brought in the most revenue

select seller_id, count(order_id) sales_volume, SUM(price) sales_Revenue 
from order_items2
group by seller_id
order by 2 desc;

-- The above Highlights the sellers with the most sales

/*
 * So in terms of sellers, In the revenue table, A seller sold 1,156 and brought in the most revenue
 * second on the list only made 410 sales 
 * third made 1987 sales
 * fourth made 586 sales
 * 5th made 1364 sales
 * 6th made only 340 sales
 * 
 * In the sales volume table
 * 
 * Seller 1 made 2,033 sales and brought in 123,304, 11th on the revenue table
 */

-- lets examine top 10 sellers and what percentage of the total revenue they contribute
select seller_id, count(order_id) sales_volume, SUM(price) sales_Revenue 
from order_items2
group by seller_id
order by 3 desc
limit 10;

-- total revenue

select SUM(price) total_sales_Revenue 
from order_items2;

-- total revenue is 13,406,593.94

-- total revenue contributed by top 10 sellers using a subquery

select sum(sales_revenue) total_top10_rev
from 
	(select seller_id, count(order_id) sales_volume, SUM(price) sales_Revenue 
	from order_items2
	group by seller_id
	order by 3 desc
	limit 10
		) as top10;

select SUM(price) total_sales_Revenue, 1787241.739999988 * 100/SUM(price)
from order_items2;

-- Total rev for the top 10 sellers is 1,787,241.739999
-- This reperesents 13.33% of the total revenue generated

-- in essence, top 0.33% of the sellers generate 13.33% of the total revenue

-- While this is significant, it also shows that to an extent, Olist is not heavily reliant on the top few sellers,
-- sales are somewhat spread out, 
-- well, let us examine top 20, then 50, then 100 and see if the story remains the same or concentration increases


select sum(sales_revenue) total_top20_rev
from 
	(select seller_id, count(order_id) sales_volume, SUM(price) sales_Revenue 
	from order_items2
	group by seller_id
	order by 3 desc
	limit 20
		) as top20; 

select SUM(price) total_sales_Revenue, 2856529.7099999874 * 100/SUM(price)
from order_items2;
		
-- for top 20 contributed 21.31%


select sum(sales_revenue) total_top50_rev
from 
	(select seller_id, count(order_id) sales_volume, SUM(price) sales_Revenue 
	from order_items2
	group by seller_id
	order by 3 desc
	limit 50
		) as top50; 

select SUM(price) total_sales_Revenue, 4451989.069999989 * 100/SUM(price)
from order_items2;
		
-- for top 50 contributed 33.21%
		
select sum(sales_revenue) total_top100_rev
from 
	(select seller_id, count(order_id) sales_volume, SUM(price) sales_Revenue 
	from order_items2
	group by seller_id
	order by 3 desc
	limit 100
		) as top100; 

select SUM(price) total_sales_Revenue, 6083000.989999993 * 100/SUM(price)
from order_items2;
		

-- top 100 contributed 45.37%
/*
 * From this analysis, we see that even the top 100 sellers dont contribute half of the revenue, 
 * out of 3033 sellers, 2933 contributes 55%. 
 * This tells us that The store's sales revenue concentration is spread out and if one top seller leaves, 
 * revenue impact will be limited.
 * This tells us that the long tail of smaller sellers is really the back bone here.
 * The company supporting smaller sellers either by incrising visibility will go a long way in improving revenue
 */
		
	
		
select count(distinct seller_id), 
count(distinct order_id), 
count(product_id), 
count(distinct product_category_name)
from order_items2;

select count(distinct customer_id)
from olist_customers_dataset o 

select order_id, COUNT(*) row_per_order
from order_items2
group by order_id
having count(*) > 1
order by 2 desc;














-- Rough Code that might be needed later



/*select seller_id, count(order_id) sales_volume, SUM(price) sales_Revenue 
	from order_items2
	group by seller_id
	order by 3 desc
	limit 50; 




/*select *
from product_dataset_translation_csv p

create table product_dataset3
like product_dataset_translation_csv;


select *
from product_dataset3;

insert product_dataset3
select *
from product_dataset_translation_csv;

alter table product_dataset3
drop column product_category_name;



























/*
 * 
 * 
 with customer_orders as
(
select *
from olist_orders_dataset o 
join olist_customers_dataset o2 
on o.customer_id = o2.customer_id
)
show *
from customer_orders
;


INSERT INTO `select *
from olist_orders_dataset o 
join olist_customers_dataset o2 
on o.customer_id = o2.customer_id
limit 1` () VALUES
	 ('47770eb9100c2d0c44946d9cf07ec65d','41ce2a54c0b03bf3443c3d931a367089','delivered','2018-08-08 08:38:49','2018-08-08 08:55:23','2018-08-08 13:50:00','2018-08-17 18:06:29','2018-09-04 00:00:00','41ce2a54c0b03bf3443c3d931a367089','3a653a41f6f9fc3d2a113cf8398680e8',75265,'vianopolis','GO');
