SELECT e.session_id, e.user_id, MIN(e.created_at) as visit_started_at, e.traffic_source, e.browser, e.ip_address, 
    SUM(case when e.event_type='purchase' then 1 else 0 end) as purchases,
    SUM(case when e.event_type='cart' then 1 else 0 end) as cart_adds,
    SUM(case when e.event_type in ('product','department','home') then 1 else 0 end) as page_views,
    SUM(case when e.event_type='cancel' then 1 else 0 end) as cancels
FROM {{ source('thelook_ecommerce', 'events') }} e
GROUP BY e.session_id, e.user_id, e.traffic_source, e.browser, e.ip_address