-- A. Pizza Metrics


-- 1. How many pizzas were ordered?
select count(pizza_id)
from customer_orders;
-- 14
-- 2. How many unique customer orders were made?
SELECT count(DISTINCT order_id)
from customer_orders;
-- 10
-- 3. How many successful orders were delivered by each runner?
select runner_id,
    count(order_id) as count_of_successful_orders
from runner_orders
WHERE cancellation is NULL
    or cancellation not IN (
        'Restaurant Cancellation',
        'Customer Cancellation'
    )
GROUP BY runner_id;
-- 4. How many of each type of pizza was delivered?
select pn.pizza_name as pizza,
    count(co.pizza_id) as count_of_pizza_delivered
from customer_orders co
    INNER JOIN runner_orders ro on co.order_id = ro.order_id
    INNER JOIN pizza_names pn on pn.pizza_id = co.pizza_id
WHERE cancellation is NULL
    or cancellation not IN (
        'Restaurant Cancellation',
        'Customer Cancellation'
    )
GROUP by pn.pizza_name;
-- 5. How many Vegetarian and Meatlovers were ordered by each customer?
select co.customer_id as customers,
    count(co.pizza_id) as count_of_pizza_ordered
from customer_orders co
    INNER JOIN pizza_names pn on pn.pizza_id = co.pizza_id
group by 1;
-- 6. What was the maximum number of pizzas delivered in a single order?
select ro.order_id as order,
    count(co.pizza_id) as number_of_pizzas
from runner_orders ro
    INNER JOIN customer_orders co ON ro.order_id = co.order_id
GROUP BY 1
ORDER BY 2 DESC
LIMIT 1;
-- 7. For each customer, how many delivered pizzas had at least 1 change and how many
-- had no changes?
-- PART 1
-- delivered orders
with cte1 as (
    select *
    from runner_orders
    where cancellation is null
        or cancellation in ('null', '')
),
-- orders with at least 1 changes
cte2 as (
    select *
    from customer_orders
    where exclusions <> ''
        and extras <> ''
        or (
            exclusions not in ('', 'null')
            or extras not in ('', 'null', null)
        )
)
select cte2.customer_id,
    count(pizza_id) delivered_pizzas_with_changes
from cte1
    inner join cte2 on cte1.order_id = cte2.order_id
GROUP BY 1;
-- PART 2: orders with no changes
with cte1 as (
    select *
    from runner_orders
    where cancellation is null
        or cancellation in ('null', '')
),
cte2 as (
    select *
    from customer_orders
    where exclusions = ''
        and extras = ''
        or (
            exclusions in ('', 'null')
            or extras in ('', 'null', null)
        )
)
select cte2.customer_id,
    count(pizza_id) delivered_pizzas_with_no_changes
from cte1
    inner join cte2 on cte1.order_id = cte2.order_id
GROUP BY 1;
-- 8. How many pizzas were delivered that had both exclusions and extras?
-- delivered orders
with cte1 as (
    select *
    from runner_orders
    where cancellation is null
        or cancellation in ('null', '')
),
-- orders with both exclusions and extras
cte2 as (
    select *
    from customer_orders
    where (
            exclusions <> 'null'
            and extras <> 'null'
        )
        and exclusions <> ''
        and extras <> ''
)
select *
from cte1
    inner join cte2 on cte1.order_id = cte2.order_id;
-- 9. What was the total volume of pizzas ordered for each hour of the day?
select EXTRACT (
        hour
        from order_time
    ) as hour_of_day,
    count(pizza_id) as pizza_volume
from customer_orders
GROUP BY 1;
-- 10. What was the volume of orders for each day of the week?
select EXTRACT (
        dow
        from order_time
    ) as day_of_week,
    count(pizza_id) as pizza_volume
from customer_orders
GROUP BY 1;
-- or
select to_char(order_time, 'Day') as day_of_week,
    count(pizza_id) as pizza_volume
from customer_orders
GROUP BY 1;