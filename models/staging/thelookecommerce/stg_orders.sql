{{ config(
    materialized='view'
) }}

SELECT
    *
FROM
    {{ source('thelook_ecommerce', 'orders') }}