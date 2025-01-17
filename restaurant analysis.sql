use restaurant_db ;
-- view menu items --
SELECT * 
FROM menu_items ;
-- find number of menu items--
SELECT COUNT(*) 
FROM menu_items ;
-- what are the lease and most expensive --
SELECT * 
FROM menu_items
ORDER BY price;
-- how many italian dishes is not the menu --
SELECT COUNT(*) 
FROM menu_items 
WHERE category = 'Italian' ;
-- what is the most expensive italian dishes--
SELECT * 
FROM menu_items 
WHERE category = 'Italian'
ORDER BY price desc;
-- how many dishes are in each category --
SELECT COUNT(item_name), category 
FROM menu_items
GROUP BY category;
-- average price each category --
SELECT  category, ROUND(AVG(price),2) as avg
FROM menu_items
GROUP BY category ;
-- view order detail --
SELECT * 
FROM order_details;
-- date range --
SELECT MIN(order_date), MAX(order_date) 
FROM order_details;
-- how many order were made with date range ---
SELECT COUNT(DISTINCT order_id) 
FROM order_details;
-- how many items were made --
SELECT count(*)
FROM order_details ;
-- which order has most no of items --
SELECT order_id, COUNT(item_id) as num_items
FROM order_details
GROUP BY order_id
ORDER BY num_items desc;
-- how many order had more than 12 items --
SELECT COUNT(*)
FROM 
(SELECT order_id, count(item_id) as num_items
FROM order_details
GROUP BY order_id
HAVING num_items>12
)num_orders;
-- Combine the menu_items with order_details table --
SELECT * 
FROM order_details as o
LEFT JOIN menu_items as m
ON o.item_id = m.menu_item_id ;
 -- What were the least and most ordered items ? what categories were they in ? --
 SELECT item_name,count(order_details_id) as num_purchases, category
FROM order_details as o
LEFT JOIN menu_items as m
ON o.item_id = m.menu_item_id
group by item_name, category
 ORDER BY num_purchases desc;
 -- What were top 5 orders that spend most money? --
 SELECT order_id, SUM(price) as total_spend
FROM order_details as o
LEFT JOIN menu_items as m
ON o.item_id = m.menu_item_id 
GROUP BY order_id
ORDER BY total_spend DESC
LIMIT 5;
 -- View the details of highest spend order. what insights can you gather from --
SELECT  order_id,category, count(item_id) as num_item
FROM order_details as o
LEFT JOIN menu_items as m
ON o.item_id = m.menu_item_id
WHERE order_id in ('404','2075','1957','330','2675')
GROUP BY order_id,category;
