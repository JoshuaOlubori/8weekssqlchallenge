
select * from pizza_names;
select * from pizza_recipes;
select * from pizza_toppings;

-- creating a new pizza recipes table where the topppings column has an array datatype
drop table if exists new_pizza_recipes;
CREATE TABLE new_pizza_recipes (
    pizza_id     integer,
    toppings  text[]
);

-- inserting data from old tbale into the new table while changing the values of the toppings column
-- into an array
INSERT into new_pizza_recipes(pizza_id, toppings)
select pizza_id, string_to_array(toppings, ',') as toppings from pizza_recipes;

-- checking results
select * from new_pizza_recipes;

--values inserted had spaces. Inserting values without spaces
UPDATE new_pizza_recipes SET toppings = '{
  "1",
  "2",
  "3",
  "4",
  "5",
  "6",
  "8",
  "10"
}'
    WHERE pizza_id = 1;

UPDATE new_pizza_recipes SET toppings = '{
  "4",
  "6",
  "7",
  "9",
  "11",
  "12"
}'
    WHERE pizza_id = 2;

--checking results 
select * from new_pizza_recipes;

-- 1. What are the standard ingredients for each pizza?
select pn.pizza_name, pt.topping_name
from pizza_names pn inner join new_pizza_recipes np
on pn.pizza_id = np.pizza_id
inner join pizza_toppings pt on pt.topping_id::text = ANY (np.toppings)
-- 2. What was the most commonly added extra?
with cte as(

select pn.pizza_name, pt.topping_name
from pizza_names pn inner join new_pizza_recipes np
on pn.pizza_id = np.pizza_id
inner join pizza_toppings pt on pt.topping_id::text = ANY (np.toppings)

)

-- creating a clean view to begin with
CREATE OR REPLACE VIEW clean_customer_orders AS
select order_id,
   customer_id,
   pizza_id, 
   case when exclusions in ('', 'null') then null else
    cast(exclusions as text) end as exclusions,
     case when extras in ('', 'null') then null else
    cast(extras as text) end as extras,
order_time::TIMESTAMP
from customer_orders;




-- 3. What was the most common exclusion?
-- 4. Generate an order item for each record in the customers_orders table in the
-- format of one of the following:
-- Meat Lovers
-- Meat Lovers - Exclude Beef
-- Meat Lovers - Extra Bacon
-- Meat Lovers - Exclude Cheese, Bacon - Extra Mushroom, Peppers
-- 5. Generate an alphabetically ordered comma separated ingredient list for each pizza
-- order from the customer_orders table and add a 2x in front of any relevant
-- ingredients
-- For example: "Meat Lovers: 2xBacon, Beef, ... , Salami"
-- 6. What is the total quantity of each ingredient used in all delivered pizzas sorted by
-- most frequent first?


