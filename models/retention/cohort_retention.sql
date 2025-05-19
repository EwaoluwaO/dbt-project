-- creating a dimension table with each user's first order date
with first_purchase as (
  select
  user_id,
  min(date_trunc(created_at, MONTH )) as cohort_month
from {{ source('thelook_ecommerce', 'orders') }}
group by 
  user_id),
-- joiuning the first order table to the order table and truncating the order date to just the month
user_orders AS (
    SELECT
      o.user_id,
      DATE_TRUNC(o.created_at, MONTH) AS order_month,
      fp.cohort_month
    FROM
      {{ source('thelook_ecommerce', 'orders') }} o
      JOIN first_purchase fp ON o.user_id = fp.user_id
  ),
--counting the orders for each cohort each month
  cohort_activity AS (
    SELECT
      cohort_month,
      order_month,
      COUNT(DISTINCT user_id) AS active_users
    FROM
      user_orders
    GROUP BY
      cohort_month,
      order_month
  ),

  --selecting the initial order count for each month
    cohort_size AS (
    SELECT
      cohort_month,
      active_users AS initial_users
    FROM
      cohort_activity
    WHERE
      cohort_month = order_month
  )
  SELECT
  ca.cohort_month,
  ca.order_month,
  cs.initial_users,
  ca.active_users,
  ROUND(CAST(ca.active_users AS NUMERIC) * 100 / cs.initial_users, 2) AS retention_rate
FROM
  cohort_activity ca
  JOIN cohort_size cs ON ca.cohort_month = cs.cohort_month
ORDER BY
  ca.cohort_month desc,
  ca.order_month asc