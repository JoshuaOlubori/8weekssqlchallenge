select s.customer_id,
    s.order_date,
    men.product_name,
    men.price,
    CASE
        WHEN s.order_date >= m.join_date THEN 'Y'
        ELSE 'N'
    END
from sales s
    LEFT JOIN menu men ON s.product_id = men.product_id
    LEFT JOIN members m on m.customer_id = s.customer_id
ORDER BY s.customer_id,
    s.order_date;