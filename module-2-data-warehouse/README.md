# Module 2 — Financial Data Warehouse

## Overview

This module implements the **Financial Data Warehouse (DW)** of the platform.

The warehouse is built in **PostgreSQL** using a **Star Schema architecture**, designed to store financial data aligned with **IFRS reporting structures**.

It serves as the **central analytical layer** connecting the financial model with the forecasting and BI components.

## Structure

The warehouse contains:

**Dimensions**
- dim_date
- dim_product
- dim_channel
- dim_businessunit
- dim_scenario
- dim_account

**Fact Tables**
- fact_sales
- fact_cogs
- fact_opex
- fact_depreciation
- fact_assets
- fact_debt
- fact_equity
- fact_taxes
- fact_workingcapital
- fact_cashflow

## SQL Scripts

All SQL scripts are located in:

- **ddl_tables.sql** — Creates database schema, dimension tables, fact tables, constraints, and indexes.
- **views_ifrs.sql** — Defines analytical views used for IFRS financial reporting.
- **load_data.sql** — Loads dimension and fact data from CSV files.

## Purpose

The Data Warehouse standardizes financial data and enables scalable analytics for:

- financial reporting
- forecasting models
- FP&A analysis
- BI dashboards
