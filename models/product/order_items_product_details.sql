SELECT
    oi.order_id,
    oi.product_id,
    oi.created_at,
    oi.status,
    oi.returned_at,
    oi.sale_price,
    p.name,
    p.category,
    p.brand,
    p.retail_price
FROM
    {{ source('thelook_ecommerce', 'order_items') }} oi  
    JOIN {{ source('thelook_ecommerce', 'products') }} p ON oi.product_id = p.id