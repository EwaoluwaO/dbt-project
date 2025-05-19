select
    c.traffic_source,
    sum(c.page_views) as page_views,
    sum(c.cart_adds) as cart_adds,
    sum(c.purchases) as purchases,
    sum(c.cancels) as cancels
from {{ ref("Campaign_Analysis") }} c
group by c.traffic_source
order by purchases desc