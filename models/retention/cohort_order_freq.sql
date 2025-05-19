WITH
  UserFirstOrder AS (
    -- Determine the first order month for each user
    SELECT
      user_id,
      DATE_TRUNC(MIN(created_at), MONTH) AS first_order_month
    FROM
      {{ source('thelook_ecommerce', 'orders') }}
    GROUP BY
      user_id
  ),
  UserOrderCounts AS (
    -- Calculate the total number of orders for each user
    SELECT
      user_id,
      COUNT(order_id) AS total_orders
    FROM
      {{ source('thelook_ecommerce', 'orders') }}
    GROUP BY
      user_id
  ),
  CohortData AS (
    -- Join first order month and total order counts
    SELECT
      ufo.first_order_month,
      uoc.user_id,
      uoc.total_orders
    FROM
      UserFirstOrder ufo
      JOIN UserOrderCounts uoc ON ufo.user_id = uoc.user_id
  ),
  CohortSummary AS (
    -- Count users in each cohort by their total order count
    SELECT
      first_order_month,
      total_orders,
      COUNT(user_id) AS user_count
    FROM
      CohortData
    GROUP BY
      first_order_month,
      total_orders
    ORDER BY
      first_order_month,
      total_orders
  )
SELECT
  first_order_month,
  total_orders,
  user_count,
  SUM(user_count) OVER (PARTITION BY first_order_month) AS cohort_size,
  (
    CASE
      WHEN total_orders = 1 THEN 0
      ELSE user_count
    END
  ) AS returning_user_count
FROM
  CohortSummary
ORDER BY
  first_order_month,
  total_orders