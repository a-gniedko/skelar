WITH user_table AS (
SELECT 
  registration_date
, channel
, geo
, device_os
, COUNT(DISTINCT id_user) AS users
, SUM(is_payer) AS payers
, SUM(revenue_7d) AS revenue_7d
, SUM(revenue_90d) AS revenue_90d
FROM marketing_report.users
GROUP BY
registration_date
, channel
, geo
, device_os
) 

SELECT 
  s.date
, s.channel
, s.geo
, s.spend
, u.users
, u.revenue_7d
, u.revenue_90d
, u.payers
, u.device_os
FROM user_table u
LEFT JOIN marketing_report.spend s
ON s.date=u.registration_date
AND s.channel =u.channel
AND s.geo=u.geo
