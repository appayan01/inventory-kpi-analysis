-- Overall KPIs for 2025
SELECT ROUND(SUM(m.units_sold*p.unit_price),0) AS revenue,
       ROUND(SUM(m.units_sold*p.unit_cost),0)  AS cogs,
       ROUND(100.0*(SUM(m.units_sold*p.unit_price)-SUM(m.units_sold*p.unit_cost))/SUM(m.units_sold*p.unit_price),1) AS gross_margin_pct,
       ROUND(SUM(m.closing_stock*p.unit_cost)/12.0,0) AS avg_inventory_value,
       ROUND(SUM(m.units_sold*p.unit_cost)/(SUM(m.closing_stock*p.unit_cost)/12.0),2) AS inventory_turnover,
       ROUND(365.0/(SUM(m.units_sold*p.unit_cost)/(SUM(m.closing_stock*p.unit_cost)/12.0)),0) AS days_of_inventory,
       ROUND(100.0*SUM(m.stockout_days)/SUM(m.days_in_month),2) AS stockout_rate_pct
FROM monthly_inventory m JOIN products p ON p.sku=m.sku;

-- Revenue, margin, turnover, days of inventory and stock-out rate by category
SELECT p.category,
       ROUND(SUM(m.units_sold*p.unit_price),0) AS revenue,
       ROUND(100.0*(SUM(m.units_sold*p.unit_price)-SUM(m.units_sold*p.unit_cost))/SUM(m.units_sold*p.unit_price),1) AS gross_margin_pct,
       ROUND(SUM(m.units_sold*p.unit_cost)/(SUM(m.closing_stock*p.unit_cost)/12.0),2) AS inventory_turnover,
       ROUND(365.0/(SUM(m.units_sold*p.unit_cost)/(SUM(m.closing_stock*p.unit_cost)/12.0)),0) AS days_of_inventory,
       ROUND(100.0*SUM(m.stockout_days)/SUM(m.days_in_month),2) AS stockout_rate_pct
FROM monthly_inventory m JOIN products p ON p.sku=m.sku
GROUP BY p.category ORDER BY revenue DESC;

-- Stock-out rate and sell-through by warehouse
SELECT warehouse,
       SUM(stockout_days) AS stockout_days,
       ROUND(100.0*SUM(stockout_days)/SUM(days_in_month),2) AS stockout_rate_pct,
       ROUND(100.0*SUM(units_sold)/SUM(opening_stock+received),1) AS sell_through_pct
FROM monthly_inventory
GROUP BY warehouse ORDER BY stockout_rate_pct DESC;

-- 10 slowest-moving SKUs (lowest sell-through) with capital tied up in stock
SELECT m.sku, p.product_name, p.category,
       SUM(m.units_sold) AS units_sold,
       ROUND(100.0*SUM(m.units_sold)/SUM(m.opening_stock+m.received),1) AS sell_through_pct,
       ROUND(AVG(m.closing_stock*p.unit_cost),0) AS avg_stock_value
FROM monthly_inventory m JOIN products p ON p.sku=m.sku
GROUP BY m.sku, p.product_name, p.category
ORDER BY sell_through_pct ASC LIMIT 10;

-- Monthly revenue with month-over-month change (window function)
WITH monthly AS (
  SELECT m.month, SUM(m.units_sold*p.unit_price) AS revenue
  FROM monthly_inventory m JOIN products p ON p.sku=m.sku
  GROUP BY m.month)
SELECT month, ROUND(revenue,0) AS revenue,
       ROUND(100.0*(revenue-LAG(revenue) OVER (ORDER BY month))/LAG(revenue) OVER (ORDER BY month),1) AS mom_change_pct
FROM monthly ORDER BY month;

-- SKU-warehouse combinations below reorder level at year-end (needs replenishment)
SELECT m.warehouse, m.sku, p.product_name, m.closing_stock, m.reorder_level,
       m.reorder_level - m.closing_stock AS shortfall
FROM monthly_inventory m JOIN products p ON p.sku=m.sku
WHERE m.month='2025-12' AND m.closing_stock < m.reorder_level
ORDER BY shortfall DESC LIMIT 15;

