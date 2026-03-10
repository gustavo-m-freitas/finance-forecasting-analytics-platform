📊 Digital Finance Forecasting & Analytics Platform

This project is an **end-to-end financial analytics platform** designed to replicate a modern corporate **Finance and FP&A analytical environment.**

The platform integrates **financial modeling, data engineering, statistical forecasting, and business intelligence** into a unified architecture capable of transforming raw financial data into **decision-ready analytics and executive insights.**

It demonstrates how modern finance teams can move from traditional spreadsheet-based reporting to a scalable analytics-driven finance data stack.

📌 Project Overview

The project simulates the financial operations of a **synthetic industrial engine manufacturer** operating across multiple products and sales channels.

The platform integrates several layers of financial analytics:

Financial Modeling → Data Warehouse → Python Automation → Forecasting → BI Dashboards

The objective is to demonstrate how financial data can be transformed into structured analytical pipelines capable of supporting **forecasting, planning, and executive decision-making.**

🏗 Platform Architecture

The project is structured as a modular financial analytics pipeline:

Financial Drivers
      ↓
3-Statement Financial Model (Excel)
      ↓
Monthly Financial Dataset
      ↓
CSV Data Layer
      ↓
Financial Data Warehouse (PostgreSQL)
      ↓
Python Automation & Analytics
      ↓
Forecasting & FP&A Planning
      ↓
Executive BI Dashboards

This architecture replicates a **modern Finance Data Stack** used in corporate FP&A and finance transformation initiatives.

⚙️ Technology Stack

Layer | Technology
--- | ---
Financial Modeling | Excel (Integrated IFRS 3-Statement Model)
Database | PostgreSQL
Data Modeling | Star Schema Financial Data Warehouse
Data Engineering | Python (Pandas, NumPy, SQLAlchemy)
Statistical Modeling | Python (statsmodels, scikit-learn)
Forecasting | Time-Series Analysis, SARIMA Models
Simulation | Monte Carlo Simulations
Visualization | Power BI, Matplotlib, Seaborn
Development Environment | Jupyter Notebooks

📂 Repository Structure

digital-finance-forecasting-platform

├── module-1-financial-model
│   ├── git_Module1_3statement_IFRS.xlsx
│   └── README.md
│
├── module-2-data-warehouse
│   ├── sql/
│   │   ├── ddl_tables.sql
│   │   ├── views_ifrs.sql
│   │   └── load_data.sql
│   ├── data/
│   ├── assets/
│   │   └── star_schema_diagram.png
│   └── README.md
│
├── module-3-financial-reporting-automation
│   ├── Module3_py_sql.ipynb
│   └── README.md
│
├── module-4-forecasting
│   ├── Module4.1_py_reg.ipynb
│   ├── Module4.2_py.ipynb
│   ├── Module4.3_excel.pdf
│   ├── Module4.4_py_sql.ipynb
│   └── README.md
│
├── module-5-bi-dashboard
│   ├── powerbi/
│   │   └── Power_BI_finance_ifrs_dw.pbix
│   ├── assets/
│   │   └── dashboard_preview.pdf
│   └── README.md


📊 Business Context

The platform models the financial evolution of a **synthetic industrial engine manufacturer operating** through:

Sales Channels:

- Direct Sales
- Retail Distribution
- Online Sales

Product Lines:

- Automotive Engines
- Industrial Engines
- Electric Solutions

The financial dataset spans **2010–2024**, capturing a full corporate cycle:

- Growth phase
- Operational stress period (2018–2019)
- Post-crisis recovery (2020–2024)

This structure allows the simulation of realistic financial dynamics such as revenue growth, margin compression during stress periods, and financial stabilization during recovery.

📦 Project Modules

### Module 1 — Financial Operating Model

Development of an integrated IFRS-compliant **3-Statement financial model**.

Includes:

- Income Statement
- Balance Sheet
- Cash Flow Statement
- Financial driver assumptions
- Revenue seasonality allocation
- Monthly financial dataset generation

The model serves as the financial engine of the platform.

### Module 2 — Financial Data Warehouse

Implementation of a **PostgreSQL Financial Data Warehouse** using a **Star Schema architecture**.

Key components:

Dimensions:

- dim_date
- dim_product
- dim_channel
- dim_businessunit
- dim_scenario
- dim_account

Fact tables include:

- fact_sales
- fact_cogs
- fact_opex
- fact_assets
- fact_debt
- fact_equity
- fact_taxes
- fact_workingcapital
- fact_cashflow

The warehouse exposes **IFRS reporting views** used for analytics and reporting.

### Module 3 — Financial Reporting Automation

Python automation pipeline used to extract and transform financial data from the warehouse.

Key components:

- SQLAlchemy database connection
- Pandas data transformations
- automated KPI calculations
- financial validation checks
- standardized reporting outputs

The pipeline replaces manual reporting with reproducible analytical workflows.

### Module 4 — Forecasting & FP&A Analytics

Advanced financial analytics layer responsible for transforming historical financial data into statistically governed forecasts and FP&A planning inputs.

The module establishes a rigorous forecasting workflow combining statistical diagnostics, model selection, and scenario-based financial planning.

Core analytical components include:

- **Exploratory Data Analysis (EDA)** to understand distributional behavior, revenue dynamics, and structural patterns in financial drivers  
- **Time-series diagnostics**, including stationarity testing, seasonal decomposition, and autocorrelation analysis  
- **Model evaluation and selection**, comparing regression-based approaches and time-series frameworks  
- **SARIMA forecasting models** calibrated to capture long-term trend and seasonal revenue behavior  
- **Regime-adjusted forecasting**, incorporating structural shifts in historical financial dynamics  
- **Forecast validation**, using out-of-sample evaluation metrics such as MAPE, WAPE, and RMSE  
- **Probabilistic forecasting**, generating confidence intervals and uncertainty envelopes  
- **Monte Carlo scenario simulation** for probabilistic revenue and financial outcome analysis  

Forecast outputs are translated into **FP&A planning inputs**, enabling scenario analysis, financial variance monitoring, and integration with corporate budgeting and executive decision-support workflows.

### Module 5 — Executive BI Dashboard

Power BI dashboards transform the analytical outputs into **interactive executive insights**.

The dashboard includes three analytical perspectives:

- Financial Performance Journey
- Revenue Drivers Analysis
- Forecast & Scenario Planning

The goal is to translate complex financial analytics into **decision-support dashboards**.

📈 Key Analytical Capabilities

The platform demonstrates several advanced finance analytics capabilities:

- Integrated IFRS financial modeling
- Financial data warehouse design
- automated financial reporting pipelines
- statistical forecasting models
- probabilistic scenario analysis
- executive financial dashboards

⚠ Data Disclaimer

The dataset used in this project represents **synthetic financial data** created to simulate realistic corporate financial dynamics.

The purpose is to demonstrate financial analytics architecture and methodology, not to represent a real company dataset.

🔧 Environment Setup

Install required Python dependencies:

```
pip install -r requirements.txt
```

Configure database credentials using `.env.example`:

```
DB_USER=your_user
DB_PASS=your_password
DB_HOST=localhost
DB_PORT=5432
DB_NAME=finance_ifrs_dw
```

📬 Contact

📩 Email: gustavo.provento@gmail.com

💼 LinkedIn: linkedin.com/in/gustavo-m-freitas  
📂 GitHub: github.com/gustavo-m-freitas
