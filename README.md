# Ecommerce Project: SQL & Python Data Analysis

## Overview
This project analyzes an e-commerce dataset to answer critical business questions and provide actionable recommendations for growth. I performed a full-stack analysis, from SQL data extraction to creating a final insights report with Python.

---
Business Insights & Recommendations
My analysis focused on three core business goals:

1. Goal: Identify and Scale Key Revenue Drivers

Insight: I discovered that the top 5 products generate 5.33% of total revenue.

Visualization: Top 5 Products by Revenue

Recommendation: The company should secure its supply chain for these key products and feature them heavily in marketing campaigns.

2.Goal: Optimize Marketing Spend & Find New Markets

Insight: The United Kingdom generates approximately 84.8% of total revenue, making it the company’s primary market. However, Netherlands, EIRE (Ireland), and Germany together contribute about 7.6%, and Germany stands out with an Average Revenue Per Product (AOV) of ₦126.06, which is significantly higher than several other regions.

This suggests that while the UK dominates in total volume, markets like Germany and Australia (AOV ₦233.37) show higher profitability potential per product—indicating an opportunity for targeted marketing investment in these regions.

Visualization: Revenue by Country

Recommendation: Reallocate part of the marketing budget to high-AOV markets (e.g., Germany, Australia).

Localize marketing campaigns to boost visibility and engagement in these regions.

Leverage insights from UK customer behavior to replicate successful campaigns in emerging markets with strong AOV.

3.Goal: Improve Customer Retention & Lifetime Value

Insight:
Out of a total of 4,364 customers, only 78 (1.8%) are one-time buyers, while 4,286 (98.2%) are repeat customers. This indicates strong customer loyalty and repeat purchase behavior, which contributes to consistent revenue performance over time.
Visualizations: Customer Purchase Frequency, Monthly Revenue Trends

Visualizations:

Customer Purchase Frequency Chart

Monthly Revenue Trend

Recommendation: Recommendation:
While retention is currently strong, focus should be placed on analyzing the purchase behavior of repeat customers to understand what drives their loyalty — such as product categories, order sizes, or promotional engagement. Additionally, targeted campaigns can be designed to convert the few one-time customers into regular buyers and sustain long-term revenue growth.

**Key Highlights:**
- Data extraction from SQL Server using **PyODBC**
- Data cleaning and preprocessing using **Pandas**
- Exploratory Data Analysis (EDA) and visualizations with **Matplotlib** and **Seaborn**
- Business insights such as revenue trends, top products, and customer behavior

---

## Dataset
The dataset includes the following columns:
- `InvoiceNo`: Unique invoice identifier  
- `Description`: Product description  
- `Quantity`: Number of items per invoice  
- `InvoiceDate`: Date and time of purchase  
- `CustomerID`: Unique customer identifier  
- `Country`: Customer country  
- `StockCode`: Product stock code  
- `UnitPrice`: Price per unit  

---

## Key Analyses & Visualizations
1. **Top 5 Products by Revenue** – Identifying the highest-grossing products  
2. **Revenue by Country** – Understanding which regions generate the most revenue  
3. **Customer Purchase Frequency** – Highlighting repeat customers and one-time buyers  
4. **Monthly Revenue Trends** – Month-over-month revenue growth  
5. **Average Order Value (AOV) & Items per Invoice** – Insights into customer purchasing behavior  
6. **Returned Products Analysis** – Detecting anomalies with negative quantities  
7. **Duplicate Invoice Detection** – Ensuring data quality and integrity  

All visualizations were created in **Python** and are included in this repository.

---

## Tools & Technologies
- **SQL Server**: Data storage and querying  
- **Python 3.12**: Data analysis and visualization  
- **PyODBC**: SQL Server connection in Python  
- **Pandas**: Data manipulation and cleaning  
- **Matplotlib & Seaborn**: Data visualization  
- **VS Code & Spyder**: Development environments
  
---
Data Quality & Anomaly Detection
To ensure the accuracy of these insights, I also performed data cleaning and integrity checks:

Returned Products: Identified and isolated products with negative quantities, which could signal issues with product quality or customer satisfaction.

Duplicate Invoices: Detected and flagged duplicate records to prevent over-inflation of revenue reports.
---

## How to Run
1. Clone the repository:
```bash
git clone https://github.com/Inemesit1/Ecommerce_Project.git
