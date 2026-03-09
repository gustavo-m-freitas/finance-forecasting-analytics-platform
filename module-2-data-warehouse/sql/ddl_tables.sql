CREATE SCHEMA IF NOT EXISTS finance_ifrs_dw;
SET search_path TO finance_ifrs_dw;

-- ===========================================================
-- 1) DIMENSIONS
-- ===========================================================

CREATE TABLE dim_date (
    DateKey     INTEGER PRIMARY KEY,        -- YYYYMM (e.g., 201001)
    Year        INTEGER NOT NULL,
    Month       INTEGER NOT NULL CHECK (Month BETWEEN 1 AND 12),
    Quarter     VARCHAR(2) NOT NULL,
    MonthName   VARCHAR(20) NOT NULL,
    MonthYear   VARCHAR(7) NOT NULL,
    Semester    VARCHAR(10) NOT NULL,
    IsYearEnd   BOOLEAN NOT NULL
);

CREATE TABLE dim_product (
    ProductKey    INTEGER PRIMARY KEY,
    ProductName   VARCHAR(120) NOT NULL
);

CREATE TABLE dim_channel (
    ChannelKey    INTEGER PRIMARY KEY,
    ChannelName   VARCHAR(60) NOT NULL
);

CREATE TABLE dim_businessunit (
    BusinessUnitKey   INTEGER PRIMARY KEY,
    BusinessUnitName  VARCHAR(120) NOT NULL
);

CREATE TABLE dim_scenario (
    ScenarioKey   SERIAL PRIMARY KEY,
    ScenarioName  VARCHAR(20) NOT NULL UNIQUE
);

-- ===========================================================
-- DIMENSION: ACCOUNT (FINAL)
-- ===========================================================

CREATE TABLE dim_account (
    AccountKey       SERIAL PRIMARY KEY,
    AccountName      VARCHAR(100) NOT NULL UNIQUE,
    Account_Nature   CHAR(1) NOT NULL CHECK (Account_Nature IN ('D','C')),
    StatementType    VARCHAR(20) NOT NULL,       -- 'P&L', 'Balance', 'CashFlow'
    AccountGroup     VARCHAR(50) NOT NULL,       -- 'Revenue', 'Operating Expenses', etc.
    IFRS_Reference   VARCHAR(20),                -- IAS 1, IAS 7, etc.
    Description      VARCHAR(255),
    IsCalculated     BOOLEAN NOT NULL DEFAULT FALSE
);

-- ===========================================================
-- 2) FACT TABLES (com ScenarioKey)
-- ===========================================================

CREATE TABLE fact_assets (
    DateKey      INTEGER NOT NULL,
    AccountKey   INTEGER NOT NULL,
    AccountName  VARCHAR(100),
    Amount       NUMERIC(18,2) NOT NULL,
    ScenarioKey  INTEGER NOT NULL,
    CONSTRAINT pk_fact_assets PRIMARY KEY (DateKey, AccountKey, ScenarioKey),
    CONSTRAINT fk_fa_date FOREIGN KEY (DateKey) REFERENCES dim_date(DateKey),
    CONSTRAINT fk_fa_account FOREIGN KEY (AccountKey) REFERENCES dim_account(AccountKey),
    CONSTRAINT fk_fa_scenario FOREIGN KEY (ScenarioKey) REFERENCES dim_scenario(ScenarioKey)
);

CREATE TABLE fact_cashflow (
    DateKey      INTEGER NOT NULL,
    AccountKey   INTEGER NOT NULL,
    AccountName  VARCHAR(100),
    Amount       NUMERIC(18,2) NOT NULL,
    ScenarioKey  INTEGER NOT NULL,
    CONSTRAINT pk_fact_cashflow PRIMARY KEY (DateKey, AccountKey, ScenarioKey),
    CONSTRAINT fk_cf_date FOREIGN KEY (DateKey) REFERENCES dim_date(DateKey),
    CONSTRAINT fk_cf_account FOREIGN KEY (AccountKey) REFERENCES dim_account(AccountKey),
    CONSTRAINT fk_cf_scenario FOREIGN KEY (ScenarioKey) REFERENCES dim_scenario(ScenarioKey)
);

CREATE TABLE fact_debt (
    DateKey      INTEGER NOT NULL,
    AccountKey   INTEGER NOT NULL,
    AccountName  VARCHAR(100),
    Amount       NUMERIC(18,2) NOT NULL,
    ScenarioKey  INTEGER NOT NULL,
    CONSTRAINT pk_fact_debt PRIMARY KEY (DateKey, AccountKey, ScenarioKey),
    CONSTRAINT fk_fd_date FOREIGN KEY (DateKey) REFERENCES dim_date(DateKey),
    CONSTRAINT fk_fd_account FOREIGN KEY (AccountKey) REFERENCES dim_account(AccountKey),
    CONSTRAINT fk_fd_scenario FOREIGN KEY (ScenarioKey) REFERENCES dim_scenario(ScenarioKey)
);

CREATE TABLE fact_equity (
    DateKey      INTEGER NOT NULL,
    AccountKey   INTEGER NOT NULL,
    AccountName  VARCHAR(100),
    Amount       NUMERIC(18,2) NOT NULL,
    ScenarioKey  INTEGER NOT NULL,
    CONSTRAINT pk_fact_equity PRIMARY KEY (DateKey, AccountKey, ScenarioKey),
    CONSTRAINT fk_fe_date FOREIGN KEY (DateKey) REFERENCES dim_date(DateKey),
    CONSTRAINT fk_fe_account FOREIGN KEY (AccountKey) REFERENCES dim_account(AccountKey),
    CONSTRAINT fk_fe_scenario FOREIGN KEY (ScenarioKey) REFERENCES dim_scenario(ScenarioKey)
);

CREATE TABLE fact_taxes (
    DateKey      INTEGER NOT NULL,
    AccountKey   INTEGER NOT NULL,
    AccountName  VARCHAR(100),
    Amount       NUMERIC(18,2) NOT NULL,
    ScenarioKey  INTEGER NOT NULL,
    CONSTRAINT pk_fact_taxes PRIMARY KEY (DateKey, AccountKey, ScenarioKey),
    CONSTRAINT fk_ft_date FOREIGN KEY (DateKey) REFERENCES dim_date(DateKey),
    CONSTRAINT fk_ft_account FOREIGN KEY (AccountKey) REFERENCES dim_account(AccountKey),
    CONSTRAINT fk_ft_scenario FOREIGN KEY (ScenarioKey) REFERENCES dim_scenario(ScenarioKey)
);

CREATE TABLE fact_workingcapital (
    DateKey      INTEGER NOT NULL,
    AccountKey   INTEGER NOT NULL,
    AccountName  VARCHAR(100),
    Amount       NUMERIC(18,2) NOT NULL,
    ScenarioKey  INTEGER NOT NULL,
    CONSTRAINT pk_fact_wc PRIMARY KEY (DateKey, AccountKey, ScenarioKey),
    CONSTRAINT fk_fw_date FOREIGN KEY (DateKey) REFERENCES dim_date(DateKey),
    CONSTRAINT fk_fw_account FOREIGN KEY (AccountKey) REFERENCES dim_account(AccountKey),
    CONSTRAINT fk_fw_scenario FOREIGN KEY (ScenarioKey) REFERENCES dim_scenario(ScenarioKey)
);

CREATE TABLE fact_depreciation (
    DateKey      INTEGER NOT NULL,
    AccountKey   INTEGER NOT NULL,
    AccountName  VARCHAR(100),
    Amount       NUMERIC(18,2) NOT NULL,
    ScenarioKey  INTEGER NOT NULL,
    CONSTRAINT pk_fact_depreciation PRIMARY KEY (DateKey, AccountKey, ScenarioKey),
    CONSTRAINT fk_fd_date FOREIGN KEY (DateKey) REFERENCES dim_date(DateKey),
    CONSTRAINT fk_fd_account FOREIGN KEY (AccountKey) REFERENCES dim_account(AccountKey),
    CONSTRAINT fk_fd_scenario FOREIGN KEY (ScenarioKey) REFERENCES dim_scenario(ScenarioKey)
);

CREATE TABLE fact_cogs (
    DateKey      INTEGER NOT NULL,
    AccountKey   INTEGER NOT NULL,
    AccountName  VARCHAR(100),
    ProductKey   INTEGER NOT NULL,
    Amount       NUMERIC(18,2) NOT NULL,
    ScenarioKey  INTEGER NOT NULL,
    CONSTRAINT pk_fact_cogs PRIMARY KEY (DateKey, ProductKey, AccountKey, ScenarioKey),
    CONSTRAINT fk_fcogs_date FOREIGN KEY (DateKey) REFERENCES dim_date(DateKey),
    CONSTRAINT fk_fcogs_product FOREIGN KEY (ProductKey) REFERENCES dim_product(ProductKey),
    CONSTRAINT fk_fcogs_account FOREIGN KEY (AccountKey) REFERENCES dim_account(AccountKey),
    CONSTRAINT fk_fcogs_scenario FOREIGN KEY (ScenarioKey) REFERENCES dim_scenario(ScenarioKey)
);

CREATE TABLE fact_opex (
    DateKey          INTEGER NOT NULL,
    AccountKey       INTEGER NOT NULL,
    AccountName      VARCHAR(100),
    BusinessUnitKey  INTEGER NOT NULL,
    Amount           NUMERIC(18,2) NOT NULL,
    ScenarioKey      INTEGER NOT NULL,
    CONSTRAINT pk_fact_opex PRIMARY KEY (DateKey, BusinessUnitKey, AccountKey, ScenarioKey),
    CONSTRAINT fk_fopex_date FOREIGN KEY (DateKey) REFERENCES dim_date(DateKey),
    CONSTRAINT fk_fopex_businessunit FOREIGN KEY (BusinessUnitKey) REFERENCES dim_businessunit(BusinessUnitKey),
    CONSTRAINT fk_fopex_account FOREIGN KEY (AccountKey) REFERENCES dim_account(AccountKey),
    CONSTRAINT fk_fopex_scenario FOREIGN KEY (ScenarioKey) REFERENCES dim_scenario(ScenarioKey)
);

CREATE TABLE fact_sales (
    DateKey      INTEGER NOT NULL,
    AccountKey   INTEGER NOT NULL,
    AccountName  VARCHAR(100),
    ChannelKey   INTEGER NOT NULL,
    ProductKey   INTEGER NOT NULL,
    Amount       NUMERIC(18,2) NOT NULL,
    ScenarioKey  INTEGER NOT NULL,
    CONSTRAINT pk_fact_sales PRIMARY KEY (DateKey, ChannelKey, ProductKey, AccountKey, ScenarioKey),
    CONSTRAINT fk_fs_date FOREIGN KEY (DateKey) REFERENCES dim_date(DateKey),
    CONSTRAINT fk_fs_channel FOREIGN KEY (ChannelKey) REFERENCES dim_channel(ChannelKey),
    CONSTRAINT fk_fs_product FOREIGN KEY (ProductKey) REFERENCES dim_product(ProductKey),
    CONSTRAINT fk_fs_account FOREIGN KEY (AccountKey) REFERENCES dim_account(AccountKey),
    CONSTRAINT fk_fs_scenario FOREIGN KEY (ScenarioKey) REFERENCES dim_scenario(ScenarioKey)
);

CREATE TABLE fact_price_volume (
    DateKey       INTEGER NOT NULL,
    ChannelKey    INTEGER NOT NULL,
    ProductKey    INTEGER NOT NULL,
    Price         NUMERIC(18,2) NOT NULL,
    Units         NUMERIC(18,2) NOT NULL,
    ScenarioKey   INTEGER NOT NULL,

    CONSTRAINT pk_fact_price_volume 
        PRIMARY KEY (DateKey, ChannelKey, ProductKey, ScenarioKey),
    CONSTRAINT fk_fpv_date 
        FOREIGN KEY (DateKey) REFERENCES dim_date(DateKey),
    CONSTRAINT fk_fpv_channel 
        FOREIGN KEY (ChannelKey) REFERENCES dim_channel(ChannelKey),
    CONSTRAINT fk_fpv_product 
        FOREIGN KEY (ProductKey) REFERENCES dim_product(ProductKey),
    CONSTRAINT fk_fpv_scenario 
        FOREIGN KEY (ScenarioKey) REFERENCES dim_scenario(ScenarioKey)
);

-- ===========================================================
-- 3) AUTO-FILL TRIGGER FUNCTION (genérica)
-- ===========================================================

CREATE OR REPLACE FUNCTION finance_ifrs_dw.fill_account_name()
RETURNS TRIGGER AS $$
BEGIN
    IF NEW.AccountName IS NULL OR NEW.AccountName = '' THEN
        SELECT AccountName INTO NEW.AccountName
        FROM finance_ifrs_dw.dim_account
        WHERE AccountKey = NEW.AccountKey;
    END IF;
    RETURN NEW;
END;
$$ LANGUAGE plpgsql;

-- ===========================================================
-- 4) TRIGGERS PARA TODAS AS FACTS
-- ===========================================================

DO $$
DECLARE
    t TEXT;
BEGIN
    FOR t IN
        SELECT table_name
        FROM information_schema.tables
        WHERE table_schema = 'finance_ifrs_dw'
          AND table_name LIKE 'fact_%'
          AND table_name <> 'fact_price_volume'
    LOOP
        EXECUTE format(
            'CREATE TRIGGER trg_fill_account_name_%1$s
             BEFORE INSERT OR UPDATE ON finance_ifrs_dw.%1$s
             FOR EACH ROW
             EXECUTE FUNCTION finance_ifrs_dw.fill_account_name();',
             t
        );
    END LOOP;
END $$;


-- ===========================================================
-- 5) INDEXES
-- ===========================================================

CREATE INDEX ix_fs_date ON fact_sales (DateKey);
CREATE INDEX ix_fcogs_date ON fact_cogs (DateKey);
CREATE INDEX ix_fopex_date ON fact_opex (DateKey);
CREATE INDEX ix_fa_date ON fact_assets (DateKey);
CREATE INDEX ix_fe_date ON fact_equity (DateKey);
CREATE INDEX ix_ft_date ON fact_taxes (DateKey);
CREATE INDEX ix_cf_date ON fact_cashflow (DateKey);
CREATE INDEX ix_fpv_date ON fact_price_volume (DateKey);
