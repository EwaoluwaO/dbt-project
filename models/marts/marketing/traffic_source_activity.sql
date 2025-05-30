{{ config(
    materialized='table'
) }}

select
    date(c.visit_started_at) as event_day,
    c.traffic_source,
    sum(c.page_views) as page_views,
    sum(c.cart_adds) as cart_adds,
    sum(c.purchases) as purchases,
    sum(c.cancels) as cancels
from {{ ref("Campaign_Analysis") }} c
group by event_day, c.traffic_source
order by event_day desc, purchases desc
