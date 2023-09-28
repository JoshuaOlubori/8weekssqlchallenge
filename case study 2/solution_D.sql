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
    ) sq -- 2. What if there was an additional $1 charge for any pizza extras?
    -- Add cheese is $1 extra
    -- 3. The Pizza Runner team now wants to add an additional ratings system that allows
    -- customers to rate their runner, how would you design an additional table for this
    -- new dataset - generate a schema for this new table and insert your own data for
    -- ratings for each successful customer order between 1 to 5.
    create table ratings (
        order_id INT,
        customer_id INT,
        runner_id INT,
        rating INT
    );
-- Creating a random integer generator
create or replace function random_between(low int, high int) returns int as $$ begin return floor(random() * (high - low + 1) + low);
end;
$$ language 'plpgsql' STRICT;
-- Inserting data into newly created table
insert into ratings (order_id, customer_id, runner_id, rating)
select ro.order_id,
    co.customer_id,
    ro.runner_id,
    random_between(1, 5)
from clean_runner_orders ro
    INNER JOIN customer_orders co ON ro.order_id = co.order_id;
SELECT *
FROM ratings;
-- 4. Using your newly generated table - can you join all of the information together to
-- form a table which has the following information for successful deliveries?
-- customer_id
-- order_id
-- runner_id
-- rating
-- order_time
-- pickup_time
-- Time between order and pickup
-- Delivery duration
-- Average speed
-- Total number of pizzas
CREATE OR REPLACE VIEW master_table AS with cte as (
        SELECT co.pizza_id,
            co.customer_id,
            co.order_id,
            ro.runner_id,
            ra.rating,
            co.order_time,
            ro.pickup_time,
            round(
                EXTRACT(
                    epoch
                    from (
                            ro.pickup_time::TIMESTAMP - co.order_time::TIMESTAMP
                        )
                ) / 60,
                2
            ) as duration_till_pickup_min,
            ro.duration / 60 as delivery_duration_hr,
            ro.distance as cleaned_distance_km
        from clean_runner_orders ro
            INNER JOIN customer_orders co ON ro.order_id = co.order_id
            INNER JOIN ratings ra on ra.order_id = ro.order_id
    )
select customer_id,
    order_id,
    runner_id,
    rating,
    order_time,
    pickup_time,
    duration_till_pickup_min,
    round(delivery_duration_hr::numeric, 2) as delivery_duration_hr,
    round(
        avg(cleaned_distance_km / delivery_duration_hr) over (partition by runner_id)::numeric,
        2
    ) as avg_speed_km_hr,
    count(pizza_id) over () as total_pizza
from cte;
-- 5. If a Meat Lovers pizza was $12 and Vegetarian $10 fixed prices with no cost for
-- extras and each runner is paid $0.30 per kilometre traveled - how much money
-- does Pizza Runner have left over after these deliveries?
with cte as (
    select co.pizza_id,
        ro.distance * 0.3 as runner_cost,
        CASE
            WHEN co.pizza_id = 1 THEN 12
            WHEN co.pizza_id = 2 THEN 10
        END AS price
    from clean_runner_orders ro
        inner join customer_orders co on co.order_id = ro.order_id
    where cancellation is null
)
select sum(price) revenue,
    round(sum(runner_cost)::numeric, 2) cost,
    round(sum(price) - sum(runner_cost)::numeric, 2) profit
from cte