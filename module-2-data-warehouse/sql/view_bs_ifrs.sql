CREATE OR REPLACE VIEW finance_ifrs_dw.vw_bs_monthly AS
WITH
-- 🔸 Caixa
cash AS (
  SELECT d.DateKey, d.Year, d.Month, SUM(cf.Amount) AS CashEnd
  FROM finance_ifrs_dw.fact_cashflow cf
  JOIN finance_ifrs_dw.dim_date d ON d.DateKey = cf.DateKey
  WHERE TRIM(cf.AccountName) = 'CashEnd'
    AND cf.ScenarioKey = 1
  GROUP BY d.DateKey, d.Year, d.Month
),

-- 🔸 Ativo Circulante
ar AS (
  SELECT d.DateKey, d.Year, d.Month, SUM(wc.Amount) AS AccountsReceivable
  FROM finance_ifrs_dw.fact_workingcapital wc
  JOIN finance_ifrs_dw.dim_date d ON d.DateKey = wc.DateKey
  WHERE TRIM(wc.AccountName) = 'AccountsReceivable'
    AND wc.ScenarioKey = 1
  GROUP BY d.DateKey, d.Year, d.Month
),

inv AS (
  SELECT d.DateKey, d.Year, d.Month, SUM(wc.Amount) AS Inventory
  FROM finance_ifrs_dw.fact_workingcapital wc
  JOIN finance_ifrs_dw.dim_date d ON d.DateKey = wc.DateKey
  WHERE TRIM(wc.AccountName) = 'Inventory'
    AND wc.ScenarioKey = 1
  GROUP BY d.DateKey, d.Year, d.Month
),

-- 🔸 Ativos Não Circulantes
ppe AS (
  SELECT d.DateKey, d.Year, d.Month, SUM(fa.Amount) AS PPE
  FROM finance_ifrs_dw.fact_assets fa
  JOIN finance_ifrs_dw.dim_date d ON d.DateKey = fa.DateKey
  WHERE TRIM(fa.AccountName) = 'PPE'
    AND fa.ScenarioKey = 1
  GROUP BY d.DateKey, d.Year, d.Month
),

intang AS (
  SELECT d.DateKey, d.Year, d.Month, SUM(fa.Amount) AS IntangibleAssets
  FROM finance_ifrs_dw.fact_assets fa
  JOIN finance_ifrs_dw.dim_date d ON d.DateKey = fa.DateKey
  WHERE TRIM(fa.AccountName) = 'IntangibleAssets'
    AND fa.ScenarioKey = 1
  GROUP BY d.DateKey, d.Year, d.Month
),

deftax AS (
  SELECT d.DateKey, d.Year, d.Month, SUM(fa.Amount) AS DeferredTaxes
  FROM finance_ifrs_dw.fact_assets fa
  JOIN finance_ifrs_dw.dim_date d ON d.DateKey = fa.DateKey
  WHERE TRIM(fa.AccountName) = 'DeferredTaxes'
    AND fa.ScenarioKey = 1
  GROUP BY d.DateKey, d.Year, d.Month
),

other_nca AS (
  SELECT d.DateKey, d.Year, d.Month, SUM(fa.Amount) AS OtherNonCurrentAssets
  FROM finance_ifrs_dw.fact_assets fa
  JOIN finance_ifrs_dw.dim_date d ON d.DateKey = fa.DateKey
  WHERE TRIM(fa.AccountName) = 'OtherNonCurrentAssets'
    AND fa.ScenarioKey = 1
  GROUP BY d.DateKey, d.Year, d.Month
),

-- 🔸 Passivos
ap AS (
  SELECT d.DateKey, d.Year, d.Month, SUM(wc.Amount) AS AccountsPayable
  FROM finance_ifrs_dw.fact_workingcapital wc
  JOIN finance_ifrs_dw.dim_date d ON d.DateKey = wc.DateKey
  WHERE TRIM(wc.AccountName) = 'AccountsPayable'
    AND wc.ScenarioKey = 1
  GROUP BY d.DateKey, d.Year, d.Month
),

rev_credit AS (
  SELECT d.DateKey, d.Year, d.Month, SUM(cf.Amount) AS RevolvingCredit
  FROM finance_ifrs_dw.fact_cashflow cf
  JOIN finance_ifrs_dw.dim_date d ON d.DateKey = cf.DateKey
  WHERE TRIM(cf.AccountName) = 'RevolvingCredit'
    AND cf.ScenarioKey = 1
  GROUP BY d.DateKey, d.Year, d.Month
),

ncl AS (
  SELECT d.DateKey, d.Year, d.Month, SUM(fd.Amount) AS NonCurrentLiabilities
  FROM finance_ifrs_dw.fact_debt fd
  JOIN finance_ifrs_dw.dim_date d ON d.DateKey = fd.DateKey
  WHERE TRIM(fd.AccountName) = 'NonCurrentLiabilities'
    AND fd.ScenarioKey = 1
  GROUP BY d.DateKey, d.Year, d.Month
),

-- 🔸 Patrimônio Líquido
cap AS (
  SELECT d.DateKey, d.Year, d.Month, SUM(fe.Amount) AS Capital
  FROM finance_ifrs_dw.fact_equity fe
  JOIN finance_ifrs_dw.dim_date d ON d.DateKey = fe.DateKey
  WHERE TRIM(fe.AccountName) = 'Capital'
    AND fe.ScenarioKey = 1
  GROUP BY d.DateKey, d.Year, d.Month
),

re AS (
  SELECT d.DateKey, d.Year, d.Month, SUM(fe.Amount) AS RetainedEarnings
  FROM finance_ifrs_dw.fact_equity fe
  JOIN finance_ifrs_dw.dim_date d ON d.DateKey = fe.DateKey
  WHERE TRIM(fe.AccountName) = 'RetainedEarnings'
    AND fe.ScenarioKey = 1
  GROUP BY d.DateKey, d.Year, d.Month
),

divs AS (
  SELECT d.DateKey, d.Year, d.Month, SUM(fe.Amount) AS Dividends
  FROM finance_ifrs_dw.fact_equity fe
  JOIN finance_ifrs_dw.dim_date d ON d.DateKey = fe.DateKey
  WHERE TRIM(fe.AccountName) = 'Dividends'
    AND fe.ScenarioKey = 1
  GROUP BY d.DateKey, d.Year, d.Month
)

SELECT
  d.DateKey,
  d.Year,
  d.Month,

  -- ASSETS
  COALESCE(cash.CashEnd,0) AS Cash,
  COALESCE(ar.AccountsReceivable,0) AS AccountsReceivable,
  COALESCE(inv.Inventory,0) AS Inventory,
  (COALESCE(cash.CashEnd,0) + COALESCE(ar.AccountsReceivable,0) + COALESCE(inv.Inventory,0)) AS CurrentAssets,

  COALESCE(ppe.PPE,0) AS PPE,
  COALESCE(intang.IntangibleAssets,0) AS IntangibleAssets,
  COALESCE(deftax.DeferredTaxes,0) AS DeferredTaxes,
  COALESCE(other_nca.OtherNonCurrentAssets,0) AS OtherNonCurrentAssets,

  (COALESCE(ppe.PPE,0) + COALESCE(intang.IntangibleAssets,0)
   + COALESCE(deftax.DeferredTaxes,0)
   + COALESCE(other_nca.OtherNonCurrentAssets,0)) AS NonCurrentAssets,

  ((COALESCE(cash.CashEnd,0) + COALESCE(ar.AccountsReceivable,0) + COALESCE(inv.Inventory,0))
   + (COALESCE(ppe.PPE,0) + COALESCE(intang.IntangibleAssets,0)
      + COALESCE(deftax.DeferredTaxes,0)
      + COALESCE(other_nca.OtherNonCurrentAssets,0))) AS TotalAssets,

  -- LIABILITIES
  COALESCE(ap.AccountsPayable,0) AS AccountsPayable,
  COALESCE(rev_credit.RevolvingCredit,0) AS RevolvingCredit,
  (COALESCE(ap.AccountsPayable,0) + COALESCE(rev_credit.RevolvingCredit,0)) AS CurrentLiabilities,

  COALESCE(ncl.NonCurrentLiabilities,0) AS NonCurrentLiabilities,
  (COALESCE(ap.AccountsPayable,0) + COALESCE(rev_credit.RevolvingCredit,0)
   + COALESCE(ncl.NonCurrentLiabilities,0)) AS TotalLiabilities,

  -- EQUITY
  COALESCE(cap.Capital,0) AS Capital,
  COALESCE(re.RetainedEarnings,0) AS RetainedEarnings,
  COALESCE(divs.Dividends,0) AS Dividends,
  (COALESCE(cap.Capital,0) + COALESCE(re.RetainedEarnings,0)) AS TotalEquity,

  -- CHECK
  (
    ((COALESCE(cash.CashEnd,0) + COALESCE(ar.AccountsReceivable,0) + COALESCE(inv.Inventory,0))
      + (COALESCE(ppe.PPE,0) + COALESCE(intang.IntangibleAssets,0)
         + COALESCE(deftax.DeferredTaxes,0)
         + COALESCE(other_nca.OtherNonCurrentAssets,0)))
    -
    ((COALESCE(ap.AccountsPayable,0) + COALESCE(rev_credit.RevolvingCredit,0)
      + COALESCE(ncl.NonCurrentLiabilities,0))
     + (COALESCE(cap.Capital,0) + COALESCE(re.RetainedEarnings,0)))
  ) AS EquityCheck

FROM finance_ifrs_dw.dim_date d
LEFT JOIN cash       ON cash.DateKey = d.DateKey
LEFT JOIN ar         ON ar.DateKey = d.DateKey
LEFT JOIN inv        ON inv.DateKey = d.DateKey
LEFT JOIN ppe        ON ppe.DateKey = d.DateKey
LEFT JOIN intang     ON intang.DateKey = d.DateKey
LEFT JOIN deftax     ON deftax.DateKey = d.DateKey
LEFT JOIN other_nca  ON other_nca.DateKey = d.DateKey
LEFT JOIN ap         ON ap.DateKey = d.DateKey
LEFT JOIN rev_credit ON rev_credit.DateKey = d.DateKey
LEFT JOIN ncl        ON ncl.DateKey = d.DateKey
LEFT JOIN cap        ON cap.DateKey = d.DateKey
LEFT JOIN re         ON re.DateKey = d.DateKey
LEFT JOIN divs       ON divs.DateKey = d.DateKey
ORDER BY d.Year, d.Month;


-- ==========================================
-- 🔹 View: Anual (IFRS-format)
-- ==========================================


CREATE OR REPLACE VIEW finance_ifrs_dw.vw_bs_annual AS
SELECT
    m.Year,
    SUM(m.Cash) AS Cash,
    SUM(m.AccountsReceivable) AS AccountsReceivable,
    SUM(m.Inventory) AS Inventory,
    SUM(m.CurrentAssets) AS CurrentAssets,
    SUM(m.PPE) AS PPE,
    SUM(m.IntangibleAssets) AS IntangibleAssets,
    SUM(m.DeferredTaxes) AS DeferredTaxes,
    SUM(m.OtherNonCurrentAssets) AS OtherNonCurrentAssets,
    SUM(m.NonCurrentAssets) AS NonCurrentAssets,
    SUM(m.TotalAssets) AS TotalAssets,
    SUM(m.AccountsPayable) AS AccountsPayable,
    SUM(m.RevolvingCredit) AS RevolvingCredit,
    SUM(m.CurrentLiabilities) AS CurrentLiabilities,
    SUM(m.NonCurrentLiabilities) AS NonCurrentLiabilities,
    SUM(m.TotalLiabilities) AS TotalLiabilities,
    SUM(m.Capital) AS Capital,
    SUM(m.RetainedEarnings) AS RetainedEarnings,
    SUM(m.Dividends) AS Dividends,
    SUM(m.TotalEquity) AS TotalEquity,
    SUM(m.EquityCheck) AS EquityCheck
FROM finance_ifrs_dw.vw_bs_monthly m
GROUP BY m.Year
ORDER BY m.Year;

-- ==========================================
-- 🔹 View: BS Total 
-- ==========================================

CREATE OR REPLACE VIEW finance_ifrs_dw.vw_bs_total AS
SELECT
    SUM(m.Cash)                   AS Cash,
    SUM(m.AccountsReceivable)     AS AccountsReceivable,
    SUM(m.Inventory)              AS Inventory,
    SUM(m.CurrentAssets)          AS CurrentAssets,
    SUM(m.PPE)                    AS PPE,
    SUM(m.IntangibleAssets)       AS IntangibleAssets,
    SUM(m.DeferredTaxes)          AS DeferredTaxes,
    SUM(m.OtherNonCurrentAssets)  AS OtherNonCurrentAssets,
    SUM(m.NonCurrentAssets)       AS NonCurrentAssets,
    SUM(m.TotalAssets)            AS TotalAssets,
    SUM(m.AccountsPayable)        AS AccountsPayable,
    SUM(m.RevolvingCredit)        AS RevolvingCredit,
    SUM(m.CurrentLiabilities)     AS CurrentLiabilities,
    SUM(m.NonCurrentLiabilities)  AS NonCurrentLiabilities,
    SUM(m.TotalLiabilities)       AS TotalLiabilities,
    SUM(m.Capital)                AS Capital,
    SUM(m.RetainedEarnings)       AS RetainedEarnings,
    SUM(m.Dividends)              AS Dividends,
    SUM(m.TotalEquity)            AS TotalEquity,
    SUM(m.EquityCheck)            AS EquityCheck
FROM finance_ifrs_dw.vw_bs_monthly m;


-- ==========================================
-- 🔹 View: Pivot (IFRS-format)
-- ==========================================

CREATE OR REPLACE VIEW finance_ifrs_dw.vw_bs_annual_pivot AS
SELECT *
FROM crosstab(
    $$
    SELECT 
        a.accountkey,
        a.accountname AS account,
        a.ifrs_reference,
        b.year,
        COALESCE(
            CASE a.accountname
                WHEN 'Cash'                 THEN b.Cash
                WHEN 'AccountsReceivable'   THEN b.AccountsReceivable
                WHEN 'Inventory'            THEN b.Inventory
                WHEN 'CurrentAssets'        THEN b.CurrentAssets
                WHEN 'PPE'                  THEN b.PPE
                WHEN 'IntangibleAssets'     THEN b.IntangibleAssets
                WHEN 'DeferredTaxes'        THEN b.DeferredTaxes
                WHEN 'OtherNonCurrentAssets' THEN b.OtherNonCurrentAssets
                WHEN 'NonCurrentAssets'     THEN b.NonCurrentAssets
                WHEN 'TotalAssets'          THEN b.TotalAssets
                WHEN 'AccountsPayable'      THEN b.AccountsPayable
                WHEN 'RevolvingCredit'      THEN b.RevolvingCredit
                WHEN 'CurrentLiabilities'   THEN b.CurrentLiabilities
                WHEN 'NonCurrentLiabilities' THEN b.NonCurrentLiabilities
                WHEN 'TotalLiabilities'     THEN b.TotalLiabilities
                WHEN 'Capital'              THEN b.Capital
                WHEN 'RetainedEarnings'     THEN b.RetainedEarnings
                WHEN 'Dividends'            THEN b.Dividends
                WHEN 'TotalEquity'          THEN b.TotalEquity
                WHEN 'EquityCheck'          THEN b.EquityCheck
            END, 0
        ) AS value
    FROM finance_ifrs_dw.vw_bs_annual b
    JOIN finance_ifrs_dw.dim_account a 
        ON a.accountname IN (
            'Cash',
            'AccountsReceivable',
            'Inventory',
            'CurrentAssets',
            'PPE',
            'IntangibleAssets',
            'DeferredTaxes',
            'OtherNonCurrentAssets',
            'NonCurrentAssets',
            'TotalAssets',
            'AccountsPayable',
            'RevolvingCredit',
            'CurrentLiabilities',
            'NonCurrentLiabilities',
            'TotalLiabilities',
            'Capital',
            'RetainedEarnings',
            'Dividends',
            'TotalEquity',
            'EquityCheck'
        )
    WHERE a.statementtype = 'Balance'
    ORDER BY a.accountkey, b.year
    $$,
    $$ SELECT DISTINCT year FROM finance_ifrs_dw.vw_bs_annual ORDER BY year $$
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