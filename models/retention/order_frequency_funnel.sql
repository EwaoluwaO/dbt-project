WITH
  UserFirstOrderMonth AS (
    -- Determine the first order month for each user
    SELECT
      user_id,
      DATE_TRUNC( MIN(created_at), MONTH) AS first_order_month
    FROM
      {{ source('thelook_ecommerce', 'orders') }}
    GROUP BY
      user_id
  ),
  UserOrderNumber AS (
    -- Assign an order number to each order for each user, ordered by order time
    SELECT
      user_id,
      order_id,
      ROW_NUMBER() OVER (PARTITION BY user_id ORDER BY created_at) AS order_number
    FROM
      {{ source('thelook_ecommerce', 'orders') }}
  ),
  CohortOrderNumbers AS (
    -- Join the first order month with the order number for each order
    SELECT
      ufom.first_order_month,
      uon.order_number,
      uon.user_id  -- Include user_id for distinct counting later
    FROM
      UserFirstOrderMonth ufom
      JOIN UserOrderNumber uon ON ufom.user_id = uon.user_id
  ),
  CohortSize AS (
    -- Calculate the size of each cohort (number of users in the first month)
    SELECT
      first_order_month,
      COUNT(DISTINCT user_id) AS cohort_size
    FROM
      UserFirstOrderMonth
    GROUP BY
      first_order_month
  ),
  PurchaseCounts AS (
    -- Count the number of users in each cohort who made their 1st, 2nd, 3rd, etc. purchase
    SELECT
      first_order_month,
      order_number,
      COUNT(DISTINCT user_id) AS user_count
    FROM
      CohortOrderNumbers
    GROUP BY
      first_order_month,
      order_number
    ORDER BY
      first_order_month,
      order_number
  )
SELECT
  cs.first_order_month,
  cs.cohort_size,
  pc.order_number,
  pc.user_count,
  SAFE_DIVIDE(pc.user_count, cs.cohort_size)*100 AS retention_rate
FROM
  CohortSize cs
  JOIN PurchaseCounts pc ON cs.first_order_month = pc.first_order_month
ORDER BY
    cs.first_order_month,
    pc.order_number