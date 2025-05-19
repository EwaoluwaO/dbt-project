SELECT
  DATE(o.created_at) AS order_date,
  COUNT(DISTINCT o.order_id) AS orders_count,
 SUM(CASE WHEN o.status = 'Shipped' THEN oi.sale_price ELSE 0 END) AS shipped_sales_amount,
  SUM(CASE WHEN o.status = 'Complete' THEN oi.sale_price ELSE 0 END) AS complete_sales_amount,
  SUM(CASE WHEN o.status = 'Returned' THEN oi.sale_price ELSE 0 END) AS returned_sales_amount,
  SUM(CASE WHEN o.status = 'Cancelled' THEN oi.sale_price ELSE 0 END) AS cancelled_sales_amount,
  SUM(CASE WHEN o.status = 'Processing' THEN oi.sale_price ELSE 0 END) AS processing_sales_amount,
  COUNT(CASE WHEN o.status = 'Shipped' THEN o.order_id END) AS shipped_orders_count,
  COUNT(CASE WHEN o.status = 'Complete' THEN o.order_id END) AS complete_orders_count,
  COUNT(CASE WHEN o.status = 'Returned' THEN o.order_id END) AS returned_orders_count,
  COUNT(CASE WHEN o.status = 'Cancelled' THEN o.order_id END) AS cancelled_orders_count,
  COUNT(CASE WHEN o.status = 'Processing' THEN o.order_id END) AS processing_orders_count,
  SUM(oi.sale_price) AS total_sales_amount,
  SUM(oi.sale_price) / COUNT(DISTINCT o.order_id) AS average_order_value
FROM
  {{ source('thelook_ecommerce', 'orders') }} o
  JOIN {{ source('thelook_ecommerce', 'order_items') }} oi ON o.order_id = oi.order_id
GROUP BY
  order_date
ORDER BY
  order_date desc