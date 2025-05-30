{{ config(
    materialized='table'
) }}

select
    e.session_id,
    e.user_id,
    min(e.created_at) as visit_started_at,
    max(e.created_at) as visit_ended_at,
    e.traffic_source,
    e.browser,
    e.ip_address,
    e.city,
    e.state,
    e.postal_code,
    max(e.sequence_number) as sequences,
    sum(case when e.event_type = 'purchase' then 1 else 0 end) as purchases,
    sum(case when e.event_type = 'cart' then 1 else 0 end) as cart_adds,
    sum(
        case when e.event_type in ('product', 'department', 'home') then 1 else 0 end
    ) as page_views,
    sum(case when e.event_type = 'cancel' then 1 else 0 end) as cancels
from {{ ref("stg_events") }} e
group by
    e.session_id,
    e.user_id,
    e.traffic_source,
    e.browser,
    e.ip_address,
    e.city,
    e.state,
    e.postal_code
