{{ config(
    materialized='view'
) }}

SELECT
    id,
    cost,
    category,
    COALESCE(name, 'Unknown Product Name') AS product_name, -- This is the fix for a null product name
    brand,
    retail_price,
    department,
    sku,
    distribution_center_id
FROM
    {{ source('thelook_ecommerce', 'products') }}
