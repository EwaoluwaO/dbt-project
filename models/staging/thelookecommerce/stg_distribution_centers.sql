
{{ config(
    materialized='view'
) }}


SELECT
    *
FROM
    {{ source('thelook_ecommerce', 'distribution_centers') }}