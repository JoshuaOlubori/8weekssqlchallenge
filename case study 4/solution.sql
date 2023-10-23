-- A. Customer Nodes Exploration
-- 1. How many unique nodes are there on the Data Bank system?
select count(DISTINCT node_id) as unique_nodes
from customer_nodes;
--  unique_nodes
-- --------------
--             5
-- (1 row)
-- 2. What is the number of nodes per region?
select region_id,
    count(DISTINCT node_id) as nodes_per_region
from customer_nodes
GROUP BY region_id;
--  region_id | nodes_per_region
-- -----------+-------
--          1 |     5
--          2 |     5
--          3 |     5
--          4 |     5
--          5 |     5
-- (5 rows)
-- 3. How many customers are allocated to each region?
select r.region_name,
    count(distinct cn.customer_id) as customers_per_region
from customer_nodes cn
    natural JOIN regions r
GROUP BY region_name;
--  region_name | customers_per_region
-- -------------+----------------------
--  Africa      |                  102
--  America     |                  105
--  Asia        |                   95
--  Australia   |                  110
--  Europe      |                   88
-- (5 rows)
-- 4. How many days on average are customers reallocated to a different node?
with cte1 as(
    select customer_id,
        node_id,
        lead(node_id) over(
            partition by customer_id
            order by start_date
        ) as lead_node,
        start_date,
        lead(start_date) over(
            partition by customer_id
            order by start_date
        ) as lead_date
    from customer_nodes
),
cte2 as (
    select lead_date - start_date as days_btw_next_node
    from cte1
)
select round(avg(days_btw_next_node)::numeric, 2) as average_reallocation_period
from cte2;
-- 5. What is the median, 80th and 95th percentile for this same reallocation days metric
-- for each region?
with cte1 as(
    select customer_id,
        region_id,
        node_id,
        lead(node_id) over(
            partition by customer_id
            order by start_date
        ) as lead_node,
        start_date,
        lead(start_date) over(
            partition by customer_id
            order by start_date
        ) as lead_date
    from customer_nodes
),
cte2 as(
    select *,
        lead_date - start_date as days_btw_next_node
    from cte1
)
select region_id,
    percentile_disc (0.5) within group (
        order by days_btw_next_node
    ) as median_realloc_metric,
    percentile_disc (0.8) within group (
        order by days_btw_next_node
    ) as pctile_80_realloc_metric,
    percentile_disc (0.95) within group (
        order by days_btw_next_node
    ) as pctile_95_realloc_metric
from cte2
GROUP BY 1