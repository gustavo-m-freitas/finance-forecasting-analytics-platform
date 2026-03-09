-- ==========================================================
-- 🔹 LIMPEZA PREVENTIVA
-- ==========================================================
DROP VIEW IF EXISTS finance_ifrs_dw.vw_pl_annual_pivot CASCADE;
DROP VIEW IF EXISTS finance_ifrs_dw.vw_pl_total CASCADE;
DROP VIEW IF EXISTS finance_ifrs_dw.vw_pl_annual CASCADE;
DROP VIEW IF EXISTS finance_ifrs_dw.vw_pl_monthly CASCADE;

CREATE EXTENSION IF NOT EXISTS tablefunc;


-- ==========================================
-- 🔹 View: P&L Mensal (IFRS-format)
-- ==========================================

CREATE OR REPLACE VIEW finance_ifrs_dw.vw_pl_monthly AS
WITH 
rev AS (
    SELECT d.DateKey, SUM(fs.Amount) AS Revenue
    FROM fact_sales fs
    JOIN dim_date d ON fs.DateKey = d.DateKey
    WHERE fs.ScenarioKey = 1
    GROUP BY d.DateKey
),
cogs AS (
    SELECT d.DateKey, SUM(fc.Amount) AS COGS
    FROM fact_cogs fc
    JOIN dim_date d ON fc.DateKey = d.DateKey
    WHERE fc.ScenarioKey = 1
    GROUP BY d.DateKey
),
opex AS (
    SELECT d.DateKey, SUM(fo.Amount) AS OPEX
    FROM fact_opex fo
    JOIN dim_date d ON fo.DateKey = d.DateKey
    WHERE fo.ScenarioKey = 1
    GROUP BY d.DateKey
),
dep AS (
    SELECT d.DateKey, SUM(fd.Amount) AS Depreciation
    FROM fact_depreciation fd
    JOIN dim_date d ON fd.DateKey = d.DateKey
    WHERE fd.ScenarioKey = 1
    GROUP BY d.DateKey
),
fin AS (
    SELECT d.DateKey,
           SUM(CASE 
                   WHEN a.AccountGroup = 'Financial Income' THEN f.Amount
                   WHEN a.AccountGroup = 'Financial Expense' THEN -f.Amount
               END) AS Financial_Results
    FROM fact_debt f
    JOIN dim_account a ON f.AccountName = a.AccountName
    JOIN dim_date d ON f.DateKey = d.DateKey
    WHERE f.ScenarioKey = 1
    GROUP BY d.DateKey
),
tax AS (
    SELECT d.DateKey,
           SUM(CASE WHEN t.AccountName = 'TotalTaxes' THEN t.Amount ELSE 0 END) AS TotalTaxes
    FROM fact_taxes t
    JOIN dim_date d ON t.DateKey = d.DateKey
    WHERE t.ScenarioKey = 1
    GROUP BY d.DateKey
)
SELECT 
    d.DateKey,
    EXTRACT(YEAR FROM TO_DATE(d.DateKey::text || '01', 'YYYYMMDD')) AS Year,
    EXTRACT(MONTH FROM TO_DATE(d.DateKey::text || '01', 'YYYYMMDD')) AS Month,
    COALESCE(r.Revenue,0)                                   AS Revenue,
    COALESCE(c.COGS,0)                                      AS COGS,
    ROUND((COALESCE(c.COGS,0)/NULLIF(r.Revenue,0))*100,2)   AS "COGS (%)",
    (COALESCE(r.Revenue,0)-COALESCE(c.COGS,0))              AS Gross_Profit,
    ROUND(((COALESCE(r.Revenue,0)-COALESCE(c.COGS,0))/NULLIF(r.Revenue,0))*100,2) AS "Gross (%)",
    COALESCE(o.OPEX,0)                                      AS Opex,
    ROUND((COALESCE(o.OPEX,0)/NULLIF(r.Revenue,0))*100,2)   AS "Opex (%)",
    (COALESCE(r.Revenue,0) - COALESCE(c.COGS,0) - COALESCE(o.OPEX,0))   AS EBITDA,
    ROUND(((COALESCE(r.Revenue,0) - COALESCE(c.COGS,0)
    - COALESCE(o.OPEX,0)) / NULLIF(r.Revenue,0))*100,2)    AS "EBITDA (%)",
    COALESCE(dp.Depreciation,0)                             AS Depreciation,
    COALESCE(f.Financial_Results,0)                         AS Financial_Results,
    (COALESCE(r.Revenue,0)-COALESCE(c.COGS,0)
     -COALESCE(o.OPEX,0)-COALESCE(dp.Depreciation,0)
     +COALESCE(f.Financial_Results,0))                      AS EBT,
    COALESCE(t.TotalTaxes,0)                               AS TotalTaxes,
    (COALESCE(r.Revenue,0)-COALESCE(c.COGS,0)
     -COALESCE(o.OPEX,0)-COALESCE(dp.Depreciation,0)
     +COALESCE(f.Financial_Results,0)
     -COALESCE(t.TotalTaxes,0))                            AS Net_Income,
    ROUND(((COALESCE(r.Revenue,0)-COALESCE(c.COGS,0)
     -COALESCE(o.OPEX,0)-COALESCE(dp.Depreciation,0)
     +COALESCE(f.Financial_Results,0)
     -COALESCE(t.TotalTaxes,0))/NULLIF(r.Revenue,0))*100,2) AS "Net Margin (%)"
FROM dim_date d
LEFT JOIN rev r  ON r.DateKey = d.DateKey
LEFT JOIN cogs c ON c.DateKey = d.DateKey
LEFT JOIN opex o ON o.DateKey = d.DateKey
LEFT JOIN dep dp ON dp.DateKey = d.DateKey
LEFT JOIN fin f  ON f.DateKey = d.DateKey
LEFT JOIN tax t  ON t.DateKey = d.DateKey
WHERE d.IsYearEnd IS NOT NULL  
ORDER BY d.DateKey;


-- ==========================================
-- 🔹 View: Anual (IFRS-format)
-- ==========================================

CREATE OR REPLACE VIEW finance_ifrs_dw.vw_pl_annual AS
SELECT
    EXTRACT(YEAR FROM TO_DATE(m.DateKey::text || '01', 'YYYYMMDD')) AS Year,
    SUM(m.Revenue)                    AS Revenue,
    SUM(m.COGS)                             AS COGS,
    ROUND((SUM(m.COGS) / NULLIF(SUM(m.Revenue),0)) * 100, 2)  AS "COGS (%)",
    SUM(m.Revenue - m.COGS)           AS Gross_Profit,
    ROUND((SUM(m.Revenue - m.COGS) / NULLIF(SUM(m.Revenue),0)) * 100, 2) AS "Gross (%)",
    SUM(m.Opex)                             AS Opex,
    ROUND((SUM(m.Opex) / NULLIF(SUM(m.Revenue),0)) * 100, 2)  AS "Opex (%)",
    SUM(m.Revenue - m.COGS - m.Opex)  AS EBITDA,
    ROUND((SUM(m.Revenue - m.COGS - m.Opex) / NULLIF(SUM(m.Revenue),0)) * 100, 2)  AS "EBITDA (%)",
    SUM(m.Depreciation)                     AS Depreciation,
    SUM(m.Financial_Results)                AS Financial_Results,
    SUM(m.Revenue - m.COGS - m.Opex - m.Depreciation + m.Financial_Results) AS EBT,
    SUM(m.TotalTaxes)                      AS TotalTaxes,
    SUM(m.Net_Income)                       AS Net_Income,
    ROUND((SUM(m.Net_Income) / NULLIF(SUM(m.Revenue),0)) * 100, 2) AS "Net Margin (%)"
FROM finance_ifrs_dw.vw_pl_monthly m
GROUP BY EXTRACT(YEAR FROM TO_DATE(m.DateKey::text || '01', 'YYYYMMDD'))
ORDER BY Year;


-- ==========================================
-- 🔹 View: P&L Total 
-- ==========================================

CREATE OR REPLACE VIEW finance_ifrs_dw.vw_pl_total AS
SELECT
    SUM(m.Revenue)                    AS Revenue,
    SUM(m.COGS)                             AS COGS,
    ROUND((SUM(m.COGS) / NULLIF(SUM(m.Revenue),0)) * 100, 2)  AS "COGS (%)",
    SUM(m.Revenue - m.COGS)           AS Gross_Profit,
    ROUND((SUM(m.Revenue - m.COGS) / NULLIF(SUM(m.Revenue),0)) * 100, 2) AS "Gross (%)",
    SUM(m.Opex)                             AS Opex,
    ROUND((SUM(m.Opex) / NULLIF(SUM(m.Revenue),0)) * 100, 2)  AS "Opex (%)",
    SUM(m.Revenue - m.COGS - m.Opex)  AS EBITDA,
    ROUND((SUM(m.Revenue - m.COGS - m.Opex) / NULLIF(SUM(m.Revenue),0)) * 100, 2)  AS "EBITDA (%)",
    SUM(m.Depreciation)                     AS Depreciation,
    SUM(m.Financial_Results)                AS Financial_Results,
    SUM(m.Revenue - m.COGS - m.Opex - m.Depreciation + m.Financial_Results) AS EBT,
    SUM(m.TotalTaxes)                      AS TotalTaxes,
    SUM(m.Net_Income)                       AS Net_Income,
    ROUND((SUM(m.Net_Income) / NULLIF(SUM(m.Revenue),0)) * 100, 2) AS "Net Margin (%)"
FROM finance_ifrs_dw.vw_pl_monthly m;


-- ==========================================
-- 🔹 View: Pivot (IFRS-format)
-- ==========================================



CREATE OR REPLACE VIEW finance_ifrs_dw.vw_pl_annual_pivot AS
SELECT *
FROM crosstab(
    $$
    SELECT 
        a.accountkey,
        a.accountname AS account,
        a.ifrs_reference,
        m.year,
        COALESCE(
            CASE a.accountname
                WHEN 'Revenue'           THEN m.revenue
                WHEN 'CostOfGoodsSold'   THEN m.cogs
                WHEN 'GrossProfit'       THEN m.gross_profit
                WHEN 'OperatingExpenses' THEN m.opex
                WHEN 'EBITDA'            THEN m.ebitda
                WHEN 'DepreciationExpense' THEN m.depreciation
                WHEN 'FinancialResults'  THEN m.financial_results
                WHEN 'EBT'               THEN m.ebt
                WHEN 'TotalTaxes'        THEN m.totaltaxes
                WHEN 'NetIncome'         THEN m.net_income
            END, 0
        ) AS value
    FROM finance_ifrs_dw.vw_pl_annual AS m
    JOIN finance_ifrs_dw.dim_account AS a 
        ON a.accountname IN (
            'Revenue',
            'CostOfGoodsSold',
            'GrossProfit',
            'OperatingExpenses',
            'EBITDA',
            'DepreciationExpense',
            'FinancialResults',
            'EBT',
            'TotalTaxes',
            'NetIncome'
        )
    WHERE a.statementtype = 'P&L'
    ORDER BY a.accountkey, m.year
    $$,
    $$ SELECT DISTINCT year FROM finance_ifrs_dw.vw_pl_annual ORDER BY year $$
)
AS ct (
    accountkey int,
    account text,
    ifrs_reference text,
    "2010" numeric,
    "2011" numeric,
    "2012" numeric,
    "2013" numeric,
    "2014" numeric,
    "2015" numeric,
    "2016" numeric,
    "2017" numeric,
    "2018" numeric,
    "2019" numeric,
    "2020" numeric,
    "2021" numeric,
    "2022" numeric,
    "2023" numeric,
    "2024" numeric
)
ORDER BY accountkey;

-- ==========================================================
-- ✅ END OF SCRIPT
-- ==========================================================

