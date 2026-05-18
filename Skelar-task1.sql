create database marketing_cac;
use marketing_cac;

-- CTE для отримання останнього snapshot-у для кожного оголошення за кожен день  ad_id + date
-- Оскільки дані кумулятивні, нам потрібен лише фінальний стан на кінець дня

WITH daily_snapshots AS (
  SELECT
    source,
    date,
    ad_id,
    timestamp,
    spend,
    clicks,
    impressions,
    installs,
    registrations,
    -- Використовуємо віконну функцію, щоб знайти останній запис для конкретної дати оголошення,
    -- незалежно від того, чи сам timestamp потрапив у наступну добу.
    ROW_NUMBER() OVER (
      PARTITION BY ad_id
      ORDER BY timestamp DESC
    ) as latest_snapshot
  FROM marketing_ads_raw
)

SELECT
  source,
  -- Агрегуємо тільки фінальні snapshot-и
  ROUND(SUM(spend), 2) AS total_spend,
  SUM(registrations) AS total_registrations,
  -- Розраховуємо CAC
  ROUND(SUM(spend) / NULLIF(SUM(registrations), 0), 2) AS CAC,
  -- CPM
  ROUND((SUM(spend) / NULLIF(SUM(impressions),0)) * 1000, 2) AS CPM,
  -- CTR
  ROUND ((SUM(clicks) / NULLIF(SUM(impressions),0))*100,2) AS CTR,
  -- CR Click - Install
  ROUND ((SUM(installs) / NULLIF(SUM(clicks),0))*100,2) AS Click2Install,
  -- Install - Registration
  ROUND ((SUM(registrations) / NULLIF(SUM(installs),0))*100,2) AS Inst2Reg
FROM daily_snapshots
WHERE latest_snapshot = 1 -- Залишаємо тільки "найсвіжіші" дані за кожен ad_day
GROUP BY 1
ORDER BY CAC ASC
