-- Logistics & Operations Analytics | PostgreSQL
-- Load Dataset/logistics_shipments_synthetic.csv into a table named shipments.

-- 1. Data quality checks
SELECT COUNT(*) AS row_count, COUNT(DISTINCT shipment_id) AS unique_shipments
FROM shipments;

SELECT shipment_id, COUNT(*) AS duplicate_count
FROM shipments
GROUP BY shipment_id
HAVING COUNT(*) > 1;

SELECT
  SUM(CASE WHEN region IS NULL THEN 1 ELSE 0 END) AS missing_region,
  SUM(CASE WHEN carrier IS NULL THEN 1 ELSE 0 END) AS missing_carrier,
  SUM(CASE WHEN shipping_cost_eur < 0 THEN 1 ELSE 0 END) AS negative_costs,
  SUM(CASE WHEN distance_km <= 0 THEN 1 ELSE 0 END) AS invalid_distance
FROM shipments;

-- 2. Overall operational KPIs (exclude cancelled shipments from delivery metrics)
WITH completed AS (
  SELECT *
  FROM shipments
  WHERE shipment_status IN ('Delivered', 'Delayed')
)
SELECT
  COUNT(*) AS completed_shipments,
  ROUND(100.0 * COUNT(*) FILTER (WHERE shipment_status = 'Delivered') / NULLIF(COUNT(*),0), 2) AS on_time_delivery_pct,
  ROUND(AVG(actual_transit_days), 2) AS avg_transit_days,
  ROUND(SUM(shipping_cost_eur), 2) AS total_shipping_cost_eur,
  ROUND(AVG(shipping_cost_eur), 2) AS avg_cost_per_shipment_eur
FROM completed;

-- 3. Carrier performance
SELECT carrier,
       COUNT(*) AS completed_shipments,
       ROUND(100.0 * COUNT(*) FILTER (WHERE shipment_status='Delivered') / NULLIF(COUNT(*),0), 2) AS on_time_pct,
       ROUND(AVG(actual_transit_days),2) AS avg_transit_days,
       ROUND(AVG(shipping_cost_eur),2) AS avg_cost_eur
FROM shipments
WHERE shipment_status IN ('Delivered','Delayed')
GROUP BY carrier
ORDER BY on_time_pct DESC;

-- 4. Regional performance
SELECT region, COUNT(*) AS completed_shipments,
       ROUND(100.0 * COUNT(*) FILTER (WHERE shipment_status='Delivered') / NULLIF(COUNT(*),0), 2) AS on_time_pct,
       ROUND(AVG(actual_transit_days - planned_transit_days),2) AS avg_variance_days,
       ROUND(SUM(shipping_cost_eur),2) AS total_cost_eur
FROM shipments
WHERE shipment_status IN ('Delivered','Delayed')
GROUP BY region
ORDER BY on_time_pct ASC;

-- 5. Delay drivers by service, carrier and weather
SELECT service_level, carrier, weather_condition,
       COUNT(*) AS completed_shipments,
       ROUND(100.0 * COUNT(*) FILTER (WHERE shipment_status='Delayed') / NULLIF(COUNT(*),0), 2) AS delayed_pct
FROM shipments
WHERE shipment_status IN ('Delivered','Delayed')
GROUP BY service_level, carrier, weather_condition
HAVING COUNT(*) >= 10
ORDER BY delayed_pct DESC;

-- 6. Monthly trend
SELECT DATE_TRUNC('month', TO_DATE(order_date, 'YYYY-MM-DD'))::date AS order_month,
       COUNT(*) AS shipments,
       ROUND(100.0 * COUNT(*) FILTER (WHERE shipment_status='Delivered') / NULLIF(COUNT(*) FILTER (WHERE shipment_status IN ('Delivered','Delayed')),0), 2) AS on_time_pct,
       ROUND(AVG(shipping_cost_eur) FILTER (WHERE shipment_status IN ('Delivered','Delayed')),2) AS avg_cost_eur
FROM shipments
GROUP BY 1
ORDER BY 1;

-- 7. High-cost shipments (top 10%)
WITH completed AS (
 SELECT *, NTILE(10) OVER (ORDER BY shipping_cost_eur) AS cost_decile
 FROM shipments
 WHERE shipment_status IN ('Delivered','Delayed')
)
SELECT shipment_id, carrier, region, service_level, distance_km, weight_kg, shipping_cost_eur
FROM completed
WHERE cost_decile = 10
ORDER BY shipping_cost_eur DESC;
