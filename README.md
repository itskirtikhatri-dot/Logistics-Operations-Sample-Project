# Logistics & Operations Performance Analysis

## Project overview
This portfolio project analyses a **synthetic shipment dataset** to demonstrate practical skills in data quality, operational reporting, logistics KPI analysis, and business insight generation.

The analysis explores delivery performance, carrier and regional comparisons, transit-time variance, shipping costs, and potential operational delay drivers.

> **Data notice:** All records are artificially generated for learning and portfolio demonstration. They do not represent a real company, carrier, customer, or shipment.

## Business questions
1. What proportion of completed shipments were delivered on time?
2. Which carriers and regions show the strongest and weakest delivery performance?
3. What is the average shipping cost per completed shipment?

## Tools
- Microsoft Excel: data review, data dictionary, KPI guide, and pivot-table exploration
- SQL (PostgreSQL): data-quality checks, aggregations, segmentation, CTEs, window functions
- Power BI: recommended interactive dashboard build using the supplied CSV

## Dataset description
The dataset contains 1,200 synthetic shipment records covering 2025. Fields include shipment dates, destination region, warehouse, carrier, service level, customer type, product category, distance, weight, planned and actual transit duration, estimated shipping cost and revenue, weather condition, and shipment status.

### KPI definitions
- **Completed shipments:** Delivered + Delayed; cancelled shipments are excluded.
- **On-time delivery rate:** Delivered / (Delivered + Delayed).
- **Delay rate:** Delayed / (Delivered + Delayed).
- **Average shipping cost:** Sum of shipping cost for completed shipments / completed shipments.

The source data includes simulated delivery timestamps for cancelled records to keep the file structurally consistent. Cancelled records must be excluded from delivery-time KPIs.

## Suggested Power BI measures (DAX)
```DAX

Total Shipments = COUNTROWS(Shipments)

Completed Shipments =
CALCULATE(
    COUNTROWS(Shipments),
    Shipments[shipment_status] IN {"Delivered", "Delayed"}
)

On-Time Shipments =
CALCULATE(
    COUNTROWS(Shipments),
    Shipments[shipment_status] = "Delivered"
)

On-Time Delivery % =
DIVIDE([On-Time Shipments], [Completed Shipments])

Delayed Shipments =
CALCULATE(
    COUNTROWS(Shipments),
    Shipments[shipment_status] = "Delayed"
)

Delay Rate % =
DIVIDE([Delayed Shipments], [Completed Shipments]
)

Total Shipping Cost € =
CALCULATE(
    SUM(Shipments[shipping_cost_eur]),
    Shipments[shipment_status] <> "Cancelled"
)


## Dashboard design
Recommended one-page layout:
- KPI cards: Total Shipments, On-Time Delivery %, Delay Rate %, Average Cost per Completed Shipment
- Gauge chart: monthly shipment volume and on-time delivery %
- Bar chart: on-time delivery % by carrier
- Bar chart: delay rate by region
- Column chart: average shipping cost by service level

## Findings and interpretation
Do not claim that the simulated patterns are real-world logistics facts. Once you run the analysis, record the actual results from your workbook or dashboard here. Investigate whether differences may be associated with distance, service level, weather, region, or carrier mix. Treat these as associations, not proof of causation.

## Limitations
- The dataset is synthetic and intentionally simplified.
- Cost, revenue, weather, and transit times are simulated, not sourced from a real logistics provider.
- The dataset does not include route-level GPS, failed delivery attempts, customs, fuel surcharges, or warehouse handling timestamps.
- On-time status is represented by the `shipment_status` field rather than inferred from an independently recorded promised delivery timestamp.

## Skills demonstrated
Data cleaning and validation · Excel · SQL · KPI reporting · Operational analysis · Logistics performance · Data storytelling · Power BI (after dashboard completion)
