# Module 3 — IFRS Reporting Automation & Anomaly Detection

## Overview

This module implements the **Python automation pipeline** used to extract, validate, transform, and monitor financial data from the **Financial Data Warehouse**.

It extends traditional reporting by introducing a **financial control and anomaly detection layer**, enabling the identification of unusual patterns in financial performance.

The goal is to replace manual financial reporting with **reproducible and auditable analytical workflows**.

## Key Components

- **SQLAlchemy** database connection to PostgreSQL  
- **Pandas** data extraction, transformation, and KPI calculations  
- **Data validation and financial integrity checks**  
- **Multi-layer anomaly detection** (Z-score, STL, Isolation Forest)  
- **Ensemble scoring** for robust anomaly identification  
- Standardized **reporting datasets** (CSV / Excel)  

## Role in the Platform

This module connects the **Data Warehouse** with the **analytics and forecasting layers**, ensuring data reliability and enabling financial performance monitoring.
