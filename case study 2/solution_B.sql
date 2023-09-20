-- B. Runner and Customer Experience
-- 1. How many runners signed up for each 1 week period? (i.e. week starts 2021-01-01)
select EXTRACT(
        week
        from registration_date
    ),
    count(runner_id)
from runners
GROUP BY 1;
-- 2. What was the average time in minutes it took for each runner to arrive at the Pizza
-- Runner HQ to pickup the order?
select case
        when ro.pickup_time = 'null' then null
        else round(
            EXTRACT(
                epoch
                from (
                        ro.pickup_time::TIMESTAMP - co.order_time::TIMESTAMP
                    )
            ) / 60,
            2
        )
    end as duration_till_pickup,
    ro.pickup_time,
    co.order_time
from customer_orders co
    INNER JOIN runner_orders ro on co.order_id = ro.order_id 
    
--3 What was the average time in minutes it took for each runner to deliver pizzas?
select runner_id,
   round( avg(
        case
            when left(duration, 2) ~ '^\d+$' THEN cast(left(duration, 2) as integer)
            else null
        end
    ),2) as extracted_minutes
from runner_orders
group by runner_id;

-- 3. Is there any relationship between the number of pizzas and how long the order
-- takes to prepare?

-- with cte1 as (
-- select  co.order_id,
--     count(co.pizza_id) as number_of_pizza
-- from customer_orders co
--     INNER JOIN runner_orders ro ON co.order_id = ro.order_id
-- group by 1)

-- select ro.duration, round( avg(
--         case
--             when left(ro.duration, 2) ~ '^\d+$' THEN cast(left(ro.duration, 2) as integer)
--             else null
--         end
--     ),2) as extracted_minutes, cte1.*
-- from cte1 INNER JOIN runner_orders ro ON cte1.order_id = ro.order_id;
-- 4. What was the average distance travelled for each customer?
-- 5. What was the difference between the longest and shortest delivery times for all
-- orders?
-- 6. What was the average speed for each runner for each delivery and do you notice
-- any trend for these values?
-- 7. What is the successful delivery percentage for each runner?

select * from runner_orders;