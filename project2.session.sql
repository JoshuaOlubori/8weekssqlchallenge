-- 1. How many pizzas were ordered?
SELECT COUNT(pizza_id)
FROM customer_orders;
-- 14
-- 2. How many unique customer orders were made?
SELECT COUNT(DISTINCT order_id)
FROM customer_orders;
-- 10
-- 3. How many successful orders were delivered by each runner?
select *
from runner_orders;
-- 4. How many of each type of pizza was delivered?