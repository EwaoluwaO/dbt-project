{{ config(
    materialized='view'
) }}

SELECT
    *
FROM
    {{ source('thelook_ecommerce', 'order_items') }}