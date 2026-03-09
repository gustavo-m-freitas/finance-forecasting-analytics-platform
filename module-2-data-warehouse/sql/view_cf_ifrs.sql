-- ==========================================
-- 🔹 View: Cash Flow Mensal (IFRS - IAS 7)
-- ==========================================

CREATE OR REPLACE VIEW finance_ifrs_dw.vw_cf_monthly AS
SELECT
    d.DateKey,
    d.Year,
    d.Month,
    
    SUM(CASE WHEN TRIM(cf.AccountName) = 'DeltaAR'        THEN cf.Amount ELSE 0 END) AS Delta_AR,
    SUM(CASE WHEN TRIM(cf.AccountName) = 'DeltaInventory' THEN cf.Amount ELSE 0 END) AS Delta_Inventory,
    SUM(CASE WHEN TRIM(cf.AccountName) = 'DeltaAP'        THEN cf.Amount ELSE 0 END) AS Delta_AP,
    SUM(CASE WHEN TRIM(cf.AccountName) = 'DeltaDebt'      THEN cf.Amount ELSE 0 END) AS Delta_Debt,
    SUM(CASE WHEN TRIM(cf.AccountName) = 'RevolvingCredit' THEN cf.Amount ELSE 0 END) AS Revolving_Credit,
    SUM(CASE WHEN TRIM(cf.AccountName) = 'CFO'            THEN cf.Amount ELSE 0 END) AS CFO,
    SUM(CASE WHEN TRIM(cf.AccountName) = 'CFI'            THEN cf.Amount ELSE 0 END) AS CFI,
    SUM(CASE WHEN TRIM(cf.AccountName) = 'CFF'            THEN cf.Amount ELSE 0 END) AS CFF,
    SUM(CASE WHEN TRIM(cf.AccountName) = 'CashEnd'        THEN cf.Amount ELSE 0 END) AS Cash_End

FROM finance_ifrs_dw.fact_cashflow cf
JOIN finance_ifrs_dw.dim_date d ON cf.DateKey = d.DateKey
WHERE cf.ScenarioKey = 1
GROUP BY d.DateKey, d.Year, d.Month
ORDER BY d.Year, d.Month;


-- ==========================================
-- 🔹 View: Cash Flow Anual (IFRS - IAS 7)
-- ==========================================

CREATE OR REPLACE VIEW finance_ifrs_dw.vw_cf_annual AS
SELECT
    d.Year,
    SUM(CASE WHEN TRIM(cf.AccountName) = 'DeltaAR'        THEN cf.Amount ELSE 0 END) AS Delta_AR,
    SUM(CASE WHEN TRIM(cf.AccountName) = 'DeltaInventory' THEN cf.Amount ELSE 0 END) AS Delta_Inventory,
    SUM(CASE WHEN TRIM(cf.AccountName) = 'DeltaAP'        THEN cf.Amount ELSE 0 END) AS Delta_AP,
    SUM(CASE WHEN TRIM(cf.AccountName) = 'DeltaDebt'      THEN cf.Amount ELSE 0 END) AS Delta_Debt,
    SUM(CASE WHEN TRIM(cf.AccountName) = 'RevolvingCredit' THEN cf.Amount ELSE 0 END) AS Revolving_Credit,
    SUM(CASE WHEN TRIM(cf.AccountName) = 'CFO'            THEN cf.Amount ELSE 0 END) AS CFO,
    SUM(CASE WHEN TRIM(cf.AccountName) = 'CFI'            THEN cf.Amount ELSE 0 END) AS CFI,
    SUM(CASE WHEN TRIM(cf.AccountName) = 'CFF'            THEN cf.Amount ELSE 0 END) AS CFF,
    SUM(CASE WHEN TRIM(cf.AccountName) = 'CashEnd'        THEN cf.Amount ELSE 0 END) AS Cash_End
FROM finance_ifrs_dw.fact_cashflow cf
JOIN finance_ifrs_dw.dim_date d ON cf.DateKey = d.DateKey
WHERE cf.ScenarioKey = 1
GROUP BY d.Year
ORDER BY d.Year;


-- ==========================================
-- 🔹 View: CashFlow Total 
-- ==========================================

CREATE OR REPLACE VIEW finance_ifrs_dw.vw_cf_total AS
SELECT
    SUM(CASE WHEN TRIM(AccountName) = 'DeltaAR'        THEN Amount ELSE 0 END) AS Delta_AR,
    SUM(CASE WHEN TRIM(AccountName) = 'DeltaInventory' THEN Amount ELSE 0 END) AS Delta_Inventory,
    SUM(CASE WHEN TRIM(AccountName) = 'DeltaAP'        THEN Amount ELSE 0 END) AS Delta_AP,
    SUM(CASE WHEN TRIM(AccountName) = 'DeltaDebt'      THEN Amount ELSE 0 END) AS Delta_Debt,
    SUM(CASE WHEN TRIM(AccountName) = 'RevolvingCredit' THEN Amount ELSE 0 END) AS Revolving_Credit,
    SUM(CASE WHEN TRIM(AccountName) = 'CFO'            THEN Amount ELSE 0 END) AS CFO,
    SUM(CASE WHEN TRIM(AccountName) = 'CFI'            THEN Amount ELSE 0 END) AS CFI,
    SUM(CASE WHEN TRIM(AccountName) = 'CFF'            THEN Amount ELSE 0 END) AS CFF,
    SUM(CASE WHEN TRIM(AccountName) = 'CashEnd'        THEN Amount ELSE 0 END) AS Cash_End
FROM finance_ifrs_dw.fact_cashflow
WHERE ScenarioKey = 1;

-- ==========================================================
-- 🔹 View: Cash Flow Pivot (IFRS - IAS 7)
-- ==========================================================

CREATE EXTENSION IF NOT EXISTS tablefunc;

DROP VIEW IF EXISTS finance_ifrs_dw.vw_cf_annual_pivot CASCADE;
CREATE OR REPLACE VIEW finance_ifrs_dw.vw_cf_annual_pivot AS
SELECT *
FROM crosstab(
    $$
    SELECT 
        a.accountkey,
        a.accountname AS account,
        a.ifrs_reference,
        c.year,
        COALESCE(
            CASE a.accountname
                WHEN 'DeltaAR'          THEN c.Delta_AR
                WHEN 'DeltaInventory'   THEN c.Delta_Inventory
                WHEN 'DeltaAP'          THEN c.Delta_AP
                WHEN 'DeltaDebt'        THEN c.Delta_Debt
                WHEN 'RevolvingCredit'  THEN c.Revolving_Credit
                WHEN 'CFO'              THEN c.CFO
                WHEN 'CFI'              THEN c.CFI
                WHEN 'CFF'              THEN c.CFF
                WHEN 'CashEnd'          THEN c.Cash_End
            END, 0
        ) AS value
    FROM finance_ifrs_dw.vw_cf_annual c
    JOIN finance_ifrs_dw.dim_account a 
        ON a.accountname IN (
            'DeltaAR','DeltaInventory','DeltaAP',
            'DeltaDebt','RevolvingCredit','CFO',
            'CFI','CFF','CashEnd'
        )
    WHERE a.statementtype = 'CashFlow'
    ORDER BY a.accountkey, c.year
    $$,
    $$ SELECT DISTINCT year FROM finance_ifrs_dw.vw_cf_annual ORDER BY year $$
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
