
WITH
  product_orders AS (
    SELECT
      oi.product_id,
      p.name AS product_name,
      DATE(o.created_at) AS order_date,
      COUNT(*) AS quantity_ordered,
      SUM(CASE WHEN oi.status = 'Returned' THEN 1 ELSE 0 END) AS quantity_returned
    FROM
      {{ source('thelook_ecommerce', 'order_items') }} oi
      JOIN {{ source('thelook_ecommerce', 'orders') }} o ON oi.order_id = o.order_id
      JOIN {{ source('thelook_ecommerce', 'products') }} p ON oi.product_id = p.id
    GROUP BY
      oi.product_id,
      p.name,
      DATE(o.created_at)
  )
SELECT
  product_id,
  product_name,
  SUM(quantity_ordered) AS total_quantity_ordered,
  SUM(quantity_returned) AS total_quantity_returned,
  CASE
    WHEN SUM(quantity_ordered) > 0 THEN SAFE_DIVIDE(SUM(quantity_returned), SUM(quantity_ordered))
    ELSE 0
  END AS return_rate
FROM
  product_orders
GROUP BY
  product_id,
  product_name,
  order_date
ORDER BY
  total_quantity_returned DESC