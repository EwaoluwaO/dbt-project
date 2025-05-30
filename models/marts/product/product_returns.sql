{{ config(
    materialized='table'
) }}

with
    product_orders as (
        select
            oi.product_id,
            p.name as product_name,
            date(o.created_at) as order_date,
            count(*) as quantity_ordered,
            sum(case when oi.status = 'Returned' then 1 else 0 end) as quantity_returned
        from {{ ref('stg_order_items') }} oi
        join {{ ref('stg_orders') }} o on oi.order_id = o.order_id
        join {{ ref('stg_products') }} p on oi.product_id = p.id
        group by oi.product_id, p.name, date(o.created_at)
    )
select
    order_date
    product_id,
    product_name,
    sum(quantity_ordered) as total_quantity_ordered,
    sum(quantity_returned) as total_quantity_returned,
    case
        when sum(quantity_ordered) > 0
        then safe_divide(sum(quantity_returned), sum(quantity_ordered))
        else 0
    end as return_rate
from product_orders
group by product_id, product_name, order_date
order by total_quantity_returned desc
