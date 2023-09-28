-- 1. If a Meat Lovers pizza costs $12 and Vegetarian costs $10 and there were no
-- charges for changes - how much money has Pizza Runner made so far if there are
-- no delivery fees?
-- Creating a view of cleaned data
CREATE OR REPLACE VIEW clean_runner_orders AS
select order_id,
    runner_id,
    CASE
        WHEN pickup_time = 'null' THEN NULL
        ELSE pickup_time::TIMESTAMP
    END,
    cast(substring(distance, '[0-9\-+\.]+') as float) as distance,
    cast(substring(duration, '[0-9\-+\.]+') as float) as duration,
    nullif(cancellation, '') || nullif(cancellation, 'null') as cancellation
from runner_orders;
--
with cte1 as (
    select co.pizza_id,
        count(co.pizza_id) as quantity_sold
    from clean_runner_orders ro
        inner join customer_orders co on co.order_id = ro.order_id
    where cancellation is null
    GROUP BY 1
)
select pizza_id,
    quantity_sold * price as revenue
from (
        select *,
            CASE
                WHEN cte1.pizza_id = 1 THEN 12
                WHEN cte1.pizza_id = 2 THEN 10
            END AS price
        from cte1
    ) sq 
    
-- 2. What if there was an additional $1 charge for any pizza extras?
    -- Add cheese is $1 extra
    -- 3. The Pizza Runner team now wants to add an additional ratings system that allows
    -- customers to rate their runner, how would you design an additional table for this
    -- new dataset - generate a schema for this new table and insert your own data for
    -- ratings for each successful customer order between 1 to 5.
    -- 4. Using your newly generated table - can you join all of the information together to
    -- form a table which has the following information for successful deliveries?
    -- customer_id
    -- order_id
    -- 8/31/23, 3:45 PM Case Study #2 - Pizza Runner – 8 Week SQL Challenge – Start your SQL learning journey today!
    -- https://8weeksqlchallenge.com/case-study-2/ 11/14
    -- runner_id
    -- rating
    -- order_time
    -- pickup_time
    -- Time between order and pickup
    -- Delivery duration
    -- Average speed
    -- Total number of pizzas
    -- 5. If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for
    -- extras and each runner is paid $0.30 per kilometre traveled - how much money
    -- does Pizza Runner have left over after these deliveries?