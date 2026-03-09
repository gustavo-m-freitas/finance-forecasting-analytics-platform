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
Automation | Python (Pandas, NumPy, SQLAlchemy)
Forecasting | Time-Series Analysis, SARIMA Models
Scenario Simulation | Monte Carlo Simulations
Visualization | Power BI

📂 Repository Structure

```
digital-finance-forecasting-platform

├── sql/
│   ├── ddl_tables.sql
│   ├── views_ifrs.sql
│   └── load_data.sql
│
├── python/
│   ├── ifrs_pipeline.py
│   ├── data_quality.py
│   └── config.py
│
├── notebooks/
│   ├── forecasting_analysis.ipynb
│   └── scenario_simulation.ipynb
│
├── data/
│   ├── sample_exports/
│   └── schema_reference/
│
├── docs/
│   ├── data_warehouse.md
│   ├── forecasting_methodology.md
│   └── architecture.md
│
├── powerbi/
│   └── ifrs_dashboard.pbix
│
├── assets/
│   ├── architecture_diagram.png
│   ├── dashboard_screenshots.png
│   └── forecasting_plots.png
│
├── requirements.txt
├── .env.example
└── .gitignore
```

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

Advanced financial analytics layer focused on forecasting and scenario analysis.

Key techniques include:

- Exploratory data analysis
- Time series diagnostics
- SARIMA forecasting models
- regime-adjusted forecasting
- Monte Carlo scenario simulation

Forecast outputs are integrated into a planning framework used for **FP&A scenario analysis**.

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
