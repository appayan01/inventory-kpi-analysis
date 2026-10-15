# Inventory KPI Analysis (SQL + Excel)

Analysis of FY2025 inventory and sales for a synthetic apparel retailer (60 SKUs, 6 categories, 3 warehouses: Kolkata, Bengaluru, Hyderabad).

> **Note:** the dataset is synthetic (generated with a fixed random seed for reproducibility). It is built for practice and portfolio purposes, not real company data.

## What is in this repo
| File | Contents |
|---|---|
| `products.csv`, `monthly_inventory.csv` | Input data (2,160 SKU-warehouse-month rows) |
| `inventory.db` | SQLite database with both tables |
| `queries.sql` | 6 queries: joins, aggregations, CTE and window function (`LAG`) |
| `Inventory_KPI_Report.xlsx` | Formula-driven KPI summary, category/warehouse/monthly sheets, charts |
| `dashboard_preview.png` | Static preview of the KPI dashboard |

## KPIs calculated
Revenue, COGS, gross margin %, inventory turnover, days of inventory, stock-out rate, sell-through %.
The Excel workbook uses `SUMIFS` formulas on the data sheet and matches the SQL results.

## Key findings
- Overall: inventory turnover of about 18.7x (about 20 days of inventory) with a 12.6% stock-out rate.
- **Bengaluru** has the highest stock-out rate (14.1%) vs 10.6% in Kolkata, so replenishment there needs attention.
- **Jackets** turn slowest (17.1x, 21 days of inventory); a few SKUs sell through under 50% of available stock.
- Revenue peaks in October (festive season) and dips in March and July.
- Several SKU-warehouse combinations end December at zero stock, below reorder level.

## Next step
Import the CSVs into Power BI to build an interactive dashboard with DAX measures.

## Tools
SQL (SQLite), Excel (SUMIFS, charts), Python (Pandas, Matplotlib) for data generation and the preview.
