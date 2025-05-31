{{ config(
    materialized='table'
) }}

SELECT
    oi.order_id,
    oi.product_id,
    oi.created_at,
    oi.status,
    oi.returned_at,
    oi.sale_price,
    p.product_name,
    p.category,
    p.brand,
    p.retail_price
FROM
    {{ ref("stg_order_items") }} oi  
    JOIN {{ ref("stg_products") }} p ON oi.product_id = p.id