/* --------------------
 Case Study Questions
 --------------------*/
-- 1. What is the total amount each customer spent at the restaurant?
select s.customer_id as customer,
   sum(m.price) as total_amount
from sales s
   inner join menu m on s.product_id = m.product_id
group by customer;

--  customer | total_amount
-- ----------+--------------
--  B        |           74
--  C        |           36
--  A        |           76
-- (3 rows)


-- 2. How many days has each customer visited the restaurant?
select customer_id,
   count(
      distinct extract(
         day
         from order_date
      )
   ) as no_of_days_visited
from sales
group by customer_id
order by customer_id;

--  customer_id | no_of_days_visited
-- -------------+--------------------
--  A           |                  4
--  B           |                  5
--  C           |                  2
-- (3 rows)


-- 3. What was the first item from the menu purchased by each customer?
with cte as (
   select customer_id,
      order_date,
      row_number() over (
         partition by customer_id
         order by order_date
      ) as order_rank,
      product_id
   from sales
)
select c.customer_id,
   c.order_date,
   c.order_rank,
   m.product_name
from cte c
   natural join menu m
where order_rank = 1;

--  customer_id | order_date | order_rank | product_name
-- -------------+------------+------------+--------------
--  A           | 2021-01-01 |          1 | sushi
--  B           | 2021-01-01 |          1 | curry
--  C           | 2021-01-01 |          1 | ramen
-- (3 rows)


-- 4. What is the most purchased item on the menu and how many times was it purchased by all customers?
with cte as(
   select product_id,
      count(product_id)
   from sales
   group by product_id
   order by count(product_id) desc
   limit 1
) -- Most purchased item on the menu is the product with the id 3 which is ramen, according to cte
select customer_id,
   count(product_id) as count_of_most_purchased_product
from sales
where product_id in (
      select product_id
      from cte
   )
group by customer_id;

--  customer_id | count_of_most_purchased_product
-- -------------+---------------------------------
--  A           |                               3
--  B           |                               2
--  C           |                               3
-- (3 rows)


-- 5. Which item was the most popular for each customer?
with cte_1 as (
   select customer_id,
      product_id,
      count(product_id) as count_of_item
   from sales
   group by customer_id,
      product_id
),
cte_2 as (
   select *,
      row_number() over (
         partition by customer_id
         order by count_of_item desc
      ) as order_rank
   from cte_1
)
select c.customer_id,
   m.product_name,
   c.count_of_item
from cte_2 c
   natural join menu m
where order_rank = 1;

--  customer_id | product_name | count_of_item
-- -------------+--------------+---------------
--  C           | ramen        |             3
--  B           | ramen        |             2
--  A           | ramen        |             3
-- (3 rows)


-- 6. Which item was purchased first by the customer after they became a member?
with cte_1 as (
   select *
   from members
      natural join sales
   order by order_date
),
cte_2 as (
   select customer_id,
      product_id,
      order_date,
      row_number() over(
         partition by customer_id
         order by order_date
      ) as order_rank
   from cte_1
   where order_date > join_date
)
select c.customer_id,
   m.product_name,
   c.order_date,
   c.order_rank
from cte_2 c
   natural join menu m
where order_rank = 1;

--  customer_id | product_name | order_date | order_rank
-- -------------+--------------+------------+------------
--  A           | ramen        | 2021-01-10 |          1
--  B           | sushi        | 2021-01-11 |          1
-- (2 rows)


-- 7. Which item was purchased just before the customer became a member?
with cte_1 as (
   select *
   from members
      natural join sales
   order by order_date
),
cte_2 as (
   select customer_id,
      product_id,
      join_date,
      order_date,
      row_number() over(
         partition by customer_id
         order by order_date desc
      ) as order_rank
   from cte_1
   where order_date < join_date
)
select c.customer_id,
   m.product_name,
   c.order_date,
   c.order_rank
from cte_2 c
   natural join menu m
where order_rank = 1;

--  customer_id | product_name | order_date | order_rank
-- -------------+--------------+------------+------------
--  A           | sushi        | 2021-01-01 |          1
--  B           | sushi        | 2021-01-04 |          1
-- (2 rows)


-- 8. What is the total items and amount spent for each member before they became a member?
with cte_1 as (
   select *
   from members
      natural join sales
      natural join menu
   order by order_date
)
select customer_id,
   count(distinct product_id) as count_of_products,
   sum(price) as total_amount_spent
from cte_1
where order_date < join_date
group by customer_id;

--  customer_id | count_of_products | total_amount_spent
-- -------------+-------------------+--------------------
--  A           |                 2 |                 25git 
--  B           |                 2 |                 40
-- (2 rows)


-- 9.  If each $1 spent equates to 10 points and sushi has a 2x points multiplier - how many points would each customer have?
with cte as (
   select *,
      case
         when product_name = 'sushi' then price * 10 * 2
         else price * 10
      end points
   from members
      natural join sales
      natural join menu
)
select customer_id,
   sum(points) as total_points
from cte
group by customer_id;

--  customer_id | total_points
-- -------------+--------------
--  A           |          860
--  B           |          940
-- (2 rows)


-- 10. In the first week after a customer joins the program (including their join date) they earn 2x points on all items, 
-- not just sushi - how many points do customer A and B have at the end of January?
with cte as (
   select *,
      case
         when product_name = 'sushi' then price * 10 * 2
         else price * 10
      end points,
      case
         when order_date - join_date <= 7 then 2
         else 1
      end multiplier
   from members
      natural join sales
      natural join menu
),
cte_2 as (
   select *,
      points * multiplier as total_points
   from cte
)
select customer_id,
   sum(total_points) as total_points
from cte_2
group by customer_id;

--  customer_id | total_points
-- -------------+--------------
--  A           |         1720
--  B           |         1760
-- (2 rows)