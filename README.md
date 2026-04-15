📊 Digital Finance Forecasting & Analytics Platform

This project is an **end-to-end financial analytics platform** designed to replicate a modern corporate **Finance and FP&A analytical environment.**

The platform integrates **financial modeling, data engineering, statistical forecasting, and business intelligence** into a unified architecture capable of transforming raw financial data into **decision-ready analytics and executive insights.**

It demonstrates how modern finance teams can move from traditional spreadsheet-based reporting to a scalable analytics-driven **finance data stack.**

#### Keywords

Finance Analytics, Financial Forecasting, FP&A, Financial Modeling, Data Warehouse, Time Series Forecasting, SARIMA Models, Monte Carlo Simulation, Business Intelligence, Power BI, Finance Data Stack.


📌 Project Overview

The project simulates the financial operations of a **synthetic industrial engine manufacturer** operating across multiple products and sales channels.

The platform integrates several layers of financial analytics:

**Financial Modeling → Data Warehouse → Python Automation → Forecasting → BI Dashboards → Streamlit Application**

The objective is to demonstrate how financial data can be transformed into structured analytical pipelines capable of supporting **forecasting, planning, and executive decision-making.**

## 🏗 Platform Architecture & Technology Stack

The platform is structured as a modular **financial analytics pipeline**, transforming operational financial drivers into decision-ready analytics through an integrated data and analytics stack.

The architecture integrates financial modeling, data warehousing, analytics automation, statistical forecasting, and business intelligence into a unified **Finance Data Stack** used in modern FP&A environments.

**Technology Stack**

Layer | Technology
--- | ---
Financial Modeling | Excel (Integrated IFRS 3-Statement Model)
Database | PostgreSQL
Data Modeling | Star Schema Financial Data Warehouse
SQL Development | PostgreSQL (DDL, Views) – managed via DBeaver
Data Engineering | Python (Pandas, NumPy, SQLAlchemy)
Statistical Modeling | Python (statsmodels, scikit-learn)
Forecasting | Time-Series Analysis, SARIMA Models
Simulation | Monte Carlo Simulations
Visualization | Power BI, Streamlit, Plotly, Matplotlib, Seaborn
Development Environment | Jupyter Notebooks, VS Code, Streamlit


📂 Repository Structure

```
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
│   ├── Module3.1_py_anomaly.ipynb
│   ├── Module3.2_reporting.ipynb
│   └── README.md
│
├── module-4-forecasting
│   ├── Module4.1_py_reg.ipynb
│   ├── Module4.2_py.ipynb
│   ├── Module4.3_excel.pdf
│   ├── Module4.4_py_anomaly.ipynb
│   ├── Module4.5_fpa_bridge.ipynb
│   ├── Module4.6_ml_forecast.ipynb
│   └── README.md
│
├── module-5-bi-dashboard
│   ├── powerbi/
│   │   └── Power_BI_finance_ifrs_dw.pbix
│   ├── assets/
│   │   └── dashboard_preview.pdf
│   └── README.md
│
├── module-6-streamlit-dashboard
│   ├── app.py
│   ├── data
│   └── README.md
│ 
└── README.md
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

The warehouse exposes **IFRS reporting views** used for analytics and financial reporting.

A detailed explanation of the dimensional model, including the structure of dimension tables, fact tables, and the datasets contained in the `data/` directory, is available in the **Module 2 README**. Please refer to that documentation for the complete schema description and data definitions.

### Module 3 — IFRS Reporting Automation & Anomaly Detection

Python-based pipeline to extract, validate, and transform financial data from the Data Warehouse, enriched with anomaly detection capabilities.

Key components:
- SQLAlchemy data extraction from PostgreSQL
- Pandas-based transformations and KPI calculations
- data validation and financial integrity checks
- multi-layer anomaly detection (Z-score, STL, Isolation Forest)
- ensemble scoring for robust anomaly identification
- standardized reporting outputs (CSV / Excel)

The module replaces manual reporting with a reproducible financial analytics and monitoring workflow.

### Module 4 — FP&A Intelligence: Forecasting, Planning & Variance Analytics

Advanced financial analytics layer responsible for transforming historical financial data into forward-looking insight, financial plans, and performance explanations.

The module implements a structured FP&A workflow:

**diagnostic analysis → statistical forecasting → financial planning → forecast governance → variance analysis → driver-based forecasting enhancement**

Core analytical components include:

- **Statistical diagnostics and model selection**, including EDA, stationarity testing, seasonality analysis, and feature evaluation  
- **SARIMA-based forecasting**, generating multi-horizon projections with probabilistic confidence intervals  
- **Scenario modeling**, supporting FP&A planning through base, upside, and downside financial projections  
- **Forecast governance**, using anomaly detection frameworks to validate accuracy, plausibility, and consistency  
- **Variance analysis**, decomposing performance into price, volume, and mix effects across business segments  
- **Driver-based machine learning models**, capturing nonlinear relationships between revenue and operational drivers (price, volume, channel, product mix)

The module integrates statistical rigor with business interpretability, enabling a complete FP&A intelligence cycle — from forecast generation to validation and performance explanation — supporting data-driven financial decision-making.

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

### Module 6 — Streamlit Dashboard (Interactive Web Application)

Development of an interactive Streamlit application for financial analysis and executive exploration.

Includes:

- Financial Journey view
- Revenue Drivers analysis
- Forecast & Scenario Analysis
- dynamic filters and KPI cards
- PostgreSQL integration via SQLAlchemy
- interactive visualizations with Plotly

The module transforms the platform into a web-based analytical application for interactive decision support.

### 💼 Business Impact

The **Digital Finance Forecasting & Analytics Platform** demonstrates how finance teams can transform fragmented financial data into a structured analytics architecture capable of supporting forecasting, planning, and executive decision-making.

**📌 Financial Data Integration & Governance**

Corporate finance environments often rely on disconnected spreadsheets and manual reporting processes. This platform demonstrates how financial data can be centralized in a governed **Financial Data Warehouse** structured around IFRS reporting logic.

**📌 Automated Financial Reporting**

The Python automation pipeline replaces manual reporting workflows with reproducible data processes and automated KPI generation.

**📌 Data-Driven Forecasting & Risk Awareness**

Statistical forecasting models (SARIMA) and Monte Carlo simulations allow finance teams to quantify revenue uncertainty and evaluate financial scenarios.

**📌 FP&A Planning & Scenario Analysis**

Forecast outputs are integrated into an FP&A planning framework supporting budgeting, scenario evaluation, and variance analysis.

**📌 Executive Decision Support**

Power BI dashboards translate complex financial analytics into intuitive executive insights for strategic decision-making.

---
⚠ Data Disclaimer

The dataset used in this project represents **synthetic financial data** created to simulate realistic corporate financial dynamics.

The purpose is to demonstrate financial analytics architecture and methodology, not to represent a real company dataset.

---

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
