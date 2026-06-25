# 🛒 Superstore Sales — End-to-End Data Analyst Project





## 📌 Project Overview

This is a **complete end-to-end data analyst project** built on the Superstore Sales dataset.
The goal was to answer one core business question:

> **"Which products, regions, customer segments, and discount strategies drive profit — and can we predict future profit from sales data?"**

The project covers the full analyst workflow:
**Data Collection → Cleaning → SQL Analysis → Dashboard → Statistical Analysis → Predictive Modeling → Business Recommendations**

---

## 🗂️ Project Structure


superstore-sales-analysis/
│
├── data/
│   └── superstore.csv               # Raw dataset (Kaggle)
│
├── sql/
│   └── business_analysis.sql        # 6 key business SQL queries
│
├── notebooks/
│   ├── 01_data_cleaning.ipynb       # Data cleaning with pandas
│   ├── 02_eda_statistics.ipynb      # EDA + statistical analysis
│   └── 03_predictive_modeling.ipynb # ML models for profit prediction
│
├── powerbi/
│   └── superstore_dashboard.pbix    # 5-page Power BI dashboard
│
├── outputs/
│   ├── statistical_analysis.png     # Correlation, ANOVA, decomposition charts
│   └── predictive_modeling.png      # Model comparison charts
│
└── README.md


---

## 🛠️ Tech Stack

| Layer | Tools Used |
|---|---|
| **Database** | PostgreSQL, pgAdmin |
| **Data manipulation** | Python, pandas, numpy |
| **Statistical analysis** | scipy.stats, statsmodels |
| **Machine learning** | scikit-learn, XGBoost |
| **Visualization** | matplotlib, seaborn |
| **Dashboard** | Power BI (5 pages, DAX measures) |
| **Environment** | Jupyter Notebook, Anaconda |
| **Version control** | Git, GitHub |

---

## 📊 Dataset

- **Source:** [Kaggle — Superstore Sales Dataset](https://www.kaggle.com/datasets/vivek468/superstore-dataset-final)
- **Size:** ~10,000 rows × 21 columns
- **Period:** 2021 – 2024
- **Key columns:** `order_id`, `order_date`, `category`, `sub_category`, `region`, `segment`, `sales`, `quantity`, `discount`, `profit`

### Data Cleaning Steps
- Removed duplicate `order_id` entries
- Parsed `order_date` and `ship_date` to datetime format
- Fixed inconsistent category name formatting
- Capped profit outliers using IQR method
- Engineered `profit_margin_%` and `ship_days` columns

---

## 🗄️ SQL Business Analysis

6 key business queries written in PostgreSQL covering:

| # | Analysis | SQL Technique |
|---|---|---|
| 1 | Revenue by region & category | `GROUP BY`, window `SUM() OVER()` |
| 2 | Profitability by sub-category | `NULLIF`, profit margin % |
| 3 | Discount impact on profit | `CASE WHEN` bucketing |
| 4 | Customer segment analysis | Multi-part query, `AVG`, `COUNT DISTINCT` |
| 5 | Monthly trend + growth % | `LAG()`, rolling avg, `RANK()` |
| 6 | Shipping mode efficiency | `RANK() OVER (PARTITION BY region)` |

📄 See full queries → 

---

## 📈 Power BI Dashboard (5 Pages)

<img width="400" height="300" alt="image" src="https://github.com/user-attachments/assets/db376cfe-8aa0-4ec3-89aa-f12ed931164d" />


| Page | Content |
|---|---|
| **Page 1 — Overview** | KPI cards: Total Revenue, Profit, Orders, Avg Order Value |
| **Page 2 — Sales Trends** | Monthly/quarterly revenue line chart with slicers |
| **Page 3 — Category Analysis** | Revenue and profit margin by category and sub-category |
| **Page 4 — Regional Performance** | Map visual + region-wise bar charts |
| **Page 5 — Customer Segments** | Segment comparison, top 10 customers table |

**DAX measures used:**
```dax
Profit Margin % = DIVIDE(SUM('Orders'[Profit]), SUM('Orders'[Sales])) * 100

MoM Growth % = 
VAR CurrentMonth = SUM('Orders'[Sales])
VAR PrevMonth = CALCULATE(SUM('Orders'[Sales]), DATEADD('Date'[Date], -1, MONTH))
RETURN DIVIDE(CurrentMonth - PrevMonth, PrevMonth) * 100
```

---

## 🔬 Statistical Analysis

Three statistical tests performed on the dataset:

### 1. Correlation Test — Sales vs Quantity
```
Pearson r = -0.12,  p = 0.0031  → Significant weak negative correlation
Interpretation: Higher priced items sell in lower quantities
```

### 2. One-Way ANOVA — Sales across Categories
```
F-statistic = 48.32,  p < 0.0001  → Significant difference confirmed
Post-hoc: Technology vs Office Supplies → p < 0.001 (significant)
          Technology vs Furniture       → p < 0.001 (significant)
Interpretation: Category has a statistically significant effect on sales
```

### 3. Seasonal Decomposition — Monthly Sales
```
Peak month  : November
Lowest month: February
Trend       : Consistent upward growth over the period
Q4 accounts for ~35% of annual revenue
```

---

## 🤖 Predictive Modeling — Profit Prediction

**Target variable:** `profit`
**Features:** `sales`, `quantity`, `discount`, `price`, `category`, `sub_category`, `region`, `segment`, `ship_mode`

### Model Comparison

| Model | R² Score | RMSE | MAE |
|---|---|---|---|
| Linear Regression | 0.43 | 45.80 | 30.42 |
| Random Forest | 0.60 | 38.31 | 16.30 |
| **XGBoost** ✅ | **0.90** | **19.53** | **14.07** |

**Best model: XGBoost**
- R² = 0.90 → explains 90% of profit variance
- CV R² (5-fold) = 0.85 ± 0.06 → consistent, not overfitted
- Top features: `discount`, `sales`, `price`

### Pipeline Used
```python
Pipeline([
    ('preprocessor', ColumnTransformer([
        ('cat', OneHotEncoder(handle_unknown='ignore'), categorical_cols)
    ], remainder='passthrough')),
    ('model', XGBRegressor(n_estimators=300, learning_rate=0.05, max_depth=6))
])


## 💡 Key Business Insights

1. **Discount is destroying profit** — Orders with >40% discount average a **$40 loss** each. The company loses ~$49,000/year from heavy discounting.
2. **Tables and Bookcases are loss-making** — 43% of Table orders result in negative profit. Immediate repricing needed.
3. **Technology is the star category** — 25%+ profit margin. Copiers alone yield 37% margin.
4. **Q4 is critical** — November + December = 35% of annual revenue. Pre-stocking by September is essential.
5. **Home Office segment is most profitable** — 14% margin despite smallest volume. Underserved opportunity.
6. **Second Class shipping is optimal** — Best profit-to-speed ratio across all regions.

---

## ✅ Business Recommendations

| Priority | Recommendation | Expected Impact |
|---|---|---|
| 🔴 High | Cap discounts at 20% max | Save ~$49K/year |
| 🔴 High | Reprice Tables & Bookcases | Fix −8.5% margin |
| 🟡 Medium | Expand Technology product range | Leverage 25% margin |
| 🟡 Medium | Target Home Office & Corporate | Higher margin per order |
| 🟢 Low | Set Second Class as default shipping | Improve margin % |
| 🟢 Low | Launch Q1 promotions in January | Reduce revenue dip |




## 📬 Connect with Me

- **LinkedIn:** https://www.linkedin.com/in/manjeet-karakoti-b08b03322/
- **GitHub:** https://github.com/NOBEAT32
- **Email:** karakotimanjeet1@gmail.com


