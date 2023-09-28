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
    round(
        avg(
            case
                when left(duration, 2) ~ '^\d+$' THEN cast(left(duration, 2) as integer)
                else null
            end
        ),
        2
    ) as extracted_minutes
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
SELECT co.customer_id as customer,
    round(
        avg(
            case
                when left(ro.duration, 2) ~ '^\d+$' THEN cast(left(ro.duration, 2) as integer)
                else null
            end
        ),
        2
    ) as avg_extracted_minutes
from customer_orders co
    INNER JOIN runner_orders ro ON co.order_id = ro.order_id
GROUP BY 1;
-- 5. What was the difference between the longest and shortest delivery times for all
-- orders?
-- If we define delivery times as the duration between ro.pickup_time - co.order_time + ro.duration
-- then:
with cte1 as (
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
        co.order_time,
        round(
            case
                when left(ro.duration, 2) ~ '^\d+$' THEN cast(left(ro.duration, 2) as integer)
                else null
            end,
            2
        ) as cleaned_duration_minutes
    from customer_orders co
        INNER JOIN runner_orders ro on co.order_id = ro.order_id
)
select max(duration_till_pickup + cleaned_duration_minutes) as longest_delivery_time,
    min(duration_till_pickup + cleaned_duration_minutes) as shortest_delivery_time,
    max(duration_till_pickup + cleaned_duration_minutes) - min(duration_till_pickup + cleaned_duration_minutes) as difference
from cte1;
-- 6. What was the average speed for each runner for each delivery and do you notice
-- any trend for these values?
with cte as (
    select runner_id,
        case
            when distance ~ '.*' THEN cast(substring(distance, '[0-9\-+\.]+') as float)
            else null
        end as cleaned_distance_km,
        case
            when duration ~ '.*' THEN cast(substring(duration, '[0-9\-+\.]+') as float) / 60
            else null
        end as cleaned_duration_hr
    from runner_orders
)
select runner_id,
    avg(cleaned_distance_km / cleaned_duration_hr) as speed_km_hr
from cte
group by 1;
-- 7. What is the successful delivery percentage for each runner?

with part as (
    select cte.runner_id,
        count(*) as part_cancel
    from (
            select runner_id,
                nullif(cancellation, '') || nullif(cancellation, 'null') as cancel
            from runner_orders
        ) cte
    where cancel is null
    group by runner_id
),
whole as (
    select runner_id,
        count(*) as whole_cancel
    from (
            select runner_id,
                nullif(cancellation, '') || nullif(cancellation, 'null') as cancel
            from runner_orders
        ) cte
    group by runner_id
)
select p.runner_id,
    case
        when w.whole_cancel = 0 then null
        else round(
            (p.part_cancel::numeric / w.whole_cancel) * 100,
            2
        )
    end as percent
from part p
    inner join whole w on p.runner_id = w.runner_id;


