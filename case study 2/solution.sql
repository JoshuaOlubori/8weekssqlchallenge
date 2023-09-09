-- 1. How many pizzas were ordered?
select count(pizza_id) from customer_orders;
-- 14

-- 2. How many unique customer orders were made?
SELECT count(DISTINCT order_id) from customer_orders;
-- 10

-- 3. How many successful orders were delivered by each runner?
select runner_id, count(order_id)  as count_of_successful_orders
from runner_orders
WHERE cancellation is NULL or cancellation not IN ('Restaurant Cancellation', 'Customer Cancellation')
GROUP BY runner_id;
-- 4. How many of each type of pizza was delivered?


--WHERE cancellation is NOT NULL AND cancellation not IN ('null', 'Restaurant Cancellation', 'Customer Cancellation')
