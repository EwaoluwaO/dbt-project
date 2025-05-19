WITH
  customer_orders AS (
    SELECT
      o.user_id,
      u.first_name,
      u.last_name,
      u.email,
      u.age,
      u.gender,
      u.country,
      COUNT(o.order_id) AS total_orders,
      SUM(oi.sale_price) AS total_spent,
      MIN(o.created_at) AS first_order_date,
      MAX(o.created_at) AS last_order_date
    FROM
      {{ source('thelook_ecommerce', 'orders') }} o  -- Use source function
      JOIN {{ source('thelook_ecommerce', 'users') }} u ON o.user_id = u.id
      JOIN {{ source('thelook_ecommerce', 'order_items') }} oi ON o.order_id = oi.order_id
    GROUP BY
      o.user_id,
      u.first_name,
      u.last_name,
      u.email,
      u.age,
      u.gender,
      u.country
  ),
  customer_order_stats AS (
    SELECT
      user_id,
      AVG(total_spent) AS average_order_value,
      MAX(total_spent) AS largest_order_value
    FROM
      customer_orders
    GROUP BY
      user_id
  )
SELECT
  co.*,
  cos.average_order_value,
  cos.largest_order_value
FROM
  customer_orders co
  JOIN customer_order_stats cos ON co.user_id = cos.user_id
ORDER BY
  co.last_order_date DESC