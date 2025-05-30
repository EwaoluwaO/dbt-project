{{ config(
    materialized='view'
) }}

SELECT
    *
FROM
    {{ source('thelook_ecommerce', 'inventory_items') }}