{{ config(
    materialized='view'
) }}

SELECT
    id AS order_item_id,  -- Rename
    order_id,
    product_id,
    status AS order_item_status, -- Rename
    created_at,
    returned_at,
    sale_price
FROM
    {{ source('thelook_ecommerce', 'order_items') }}