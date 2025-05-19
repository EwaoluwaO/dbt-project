SELECT
  p.id AS product_id,
  p.category,
  p.department,
  p.brand,
  p.name AS product_name,
  count(oi.product_id) as items_sold,
  SUM(oi.sale_price) AS total_sales,
  SUM(oi.sale_price - p.cost) AS total_profit
FROM
  {{ source('thelook_ecommerce', 'products') }} AS p
  JOIN {{ source('thelook_ecommerce', 'order_items') }} AS oi ON p.id = oi.product_id
GROUP BY
  p.id,
  p.name,
  p.department,
  p.category,
  p.brand
ORDER BY
  total_profit DESC