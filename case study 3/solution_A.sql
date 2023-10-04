-- B. Data Analysis Questions
-- 1. How many customers has Foodie-Fi ever had?
SELECT count(DISTINCT customer_id)
FROM subscriptions;
-- 2. What is the monthly distribution of trial plan start_date values for our dataset -
-- use the start of the month as the group by value
SELECT upper(to_char(start_date, 'month')) as start_month,
    count(*) frequency
from subscriptions
where plan_id = 0
group by 1
ORDER BY 2 desc;
-- 3. What plan start_date values occur after the year 2020 for our dataset? Show the
-- breakdown by count of events for each plan_name
SELECT p.plan_name,
    count(*) as count_of_events_after_2020
from subscriptions s
    natural join plans p
where EXTRACT(
        year
        from start_date
    ) > 2020
group by 1;
-- 4. What is the customer count and percentage of customers who have churned
-- rounded to 1 decimal place?
with cte1 as (
    select 1 as id,
        count(customer_id)::numeric as whole
    from subscriptions
),
cte2 as (
    select 1 as id,
        count(customer_id)::numeric as part
    from subscriptions
    where plan_id = 4
)
SELECT cte1.whole as total_customers,
    round(cte2.part / cte1.whole, 2) * 100 as pct_churned
from cte1
    natural join cte2;
-- 5. How many customers have churned straight after their initial free trial - what
-- percentage is this rounded to the nearest whole number?
select *
from subscriptions;
select *
from plans;
with cte as (
    -- using the lead window function to find the
    -- preceding row to a particular row
    select *,
        lead(plan_id) over(partition by customer_id) as lead_plan_id
    from subscriptions
    order by customer_id,
        plan_id
),
cte2 as (
    -- getting rows whose values satisfy the condition in the question
    select *
    from cte
    where plan_id = 0
        and lead_plan_id = 4
) -- solution
select count(*) as count_of_customers_who_churned_after_free_trial
from cte2 -- 6. What is the number and percentage of customer plans after their initial free trial?
select count(*)
from subscriptions
where plan_id <> 0;
with cte1 as (
    select 1 as id,
        count(customer_id)::numeric as whole
    from subscriptions
),
cte2 as (
    select 1 as id,
        count(customer_id)::numeric as part
    from subscriptions
    where plan_id <> 0
)
SELECT cte2.part as customer_count_after_trial_plan,
    round(cte2.part / cte1.whole, 2) * 100 as pct_ccatp
from cte1
    natural join cte2;
-- 7. What is the customer count and percentage breakdown of all 5 plan_name values at
-- 2020-12-31?
select *
from subscriptions
where start_date = '2020-12-31';
-- 8. How many customers have upgraded to an annual plan in 2020?
with cte1 as (
    -- using the lead window function to find the
    -- preceding row to a particular row
    select *,
        lead(plan_id) over(partition by customer_id) as lead_plan_id
    from subscriptions
    order by customer_id,
        plan_id
),
-- filtering to only annual plans
cte2 as (
    select *,
        lead_plan_id - plan_id as diff
    from cte1
    where lead_plan_id = 3
) -- excluding churned customers and unupgraded plans
select count(DISTINCT customer_id) as upgraded_customers_2020_count
from cte2
where (diff > 0)
    and (lead_plan_id <> 4)
    and EXTRACT(
        year
        from start_date
    ) = 2020;
-- 9. How many days on average does it take for a customer to upgrade to an annual plan from the
-- day they join Foodie-Fi?
with cte1 as (
    select *,
        max(plan_id) over (partition by customer_id) as highest_plan_suscribed,
        max(start_date) over (partition by customer_id) as date_of_hps,
        min(start_date) over (partition by customer_id) as date_of_lps,
        row_number() over (partition by customer_id) as sn
    from subscriptions
),
cte2 as(
    select *,
        date_of_hps - date_of_lps as diff_in_days
    from cte1
    where highest_plan_suscribed = 3
        and sn = 1
)
select round(avg(diff_in_days)::numeric, 2) as avg_days_to_upgrade_to_annual
from cte2 

-- 10. Can you further breakdown this average value into 30 day periods (i.e. 0-30 days,
    -- 31-60 days etc)
    -- 11. How many customers downgraded from a pro monthly to a basic monthly plan in
    -- 2020?