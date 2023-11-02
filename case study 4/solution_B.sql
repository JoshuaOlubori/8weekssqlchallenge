-- B. Customer Transactions
select * from customer_nodes;
SELECT * from customer_transactions;
select * from regions;
-- 1. What is the unique count and total amount for each transaction type?
select txn_type as transaction_type, count(distinct (customer_id, txn_date, txn_amount, txn_amount)) as txn_dcount, sum(txn_amount) as txn_amount_sum
from customer_transactions
group by 1;
-- 2. What is the average total historical deposit counts and amounts for all customers?

select avg(txn_amount) as avg_historical_deposit_counts ,count(txn_type) as deposit_counts
from customer_transactions
where txn_type = 'deposit';
-- 3. For each month - how many Data Bank customers make more than 1 deposit and
-- either 1 purchase or 1 withdrawal in a single month?


-- 4. What is the closing balance for each customer at the end of the month?

-- 5. What is the percentage of customers who increase their closing balance by more
-- than 5%?
