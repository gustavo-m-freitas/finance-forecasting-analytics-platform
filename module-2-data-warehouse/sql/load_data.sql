SET search_path TO finance_ifrs_dw;

-- Dimensions
COPY dim_date(DateKey, Year, Month, Quarter, MonthName, MonthYear, Semester, IsYearEnd)
FROM '/path/to/dim_date.csv'
DELIMITER ','
CSV HEADER;

COPY dim_product(ProductKey, ProductName)
FROM '/path/to/dim_product.csv'
DELIMITER ','
CSV HEADER;

COPY dim_channel(ChannelKey, ChannelName)
FROM '/path/to/dim_channel.csv'
DELIMITER ','
CSV HEADER;

COPY dim_businessunit(BusinessUnitKey, BusinessUnitName)
FROM '/path/to/dim_businessunit.csv'
DELIMITER ','
CSV HEADER;

COPY dim_scenario(ScenarioKey, ScenarioName)
FROM '/path/to/dim_scenario.csv'
DELIMITER ','
CSV HEADER;

COPY dim_account(AccountKey, AccountName, Account_Nature, StatementType, AccountGroup, IFRS_Reference, Description, IsCalculated)
FROM '/path/to/dim_account.csv'
DELIMITER ','
CSV HEADER;

-- Facts
COPY fact_sales(DateKey, AccountKey, AccountName, ChannelKey, ProductKey, Amount, ScenarioKey)
FROM '/path/to/fact_sales.csv'
DELIMITER ','
CSV HEADER;

COPY fact_cogs(DateKey, AccountKey, AccountName, ProductKey, Amount, ScenarioKey)
FROM '/path/to/fact_cogs.csv'
DELIMITER ','
CSV HEADER;

COPY fact_opex(DateKey, AccountKey, AccountName, BusinessUnitKey, Amount, ScenarioKey)
FROM '/path/to/fact_opex.csv'
DELIMITER ','
CSV HEADER;

COPY fact_depreciation(DateKey, AccountKey, AccountName, Amount, ScenarioKey)
FROM '/path/to/fact_depreciation.csv'
DELIMITER ','
CSV HEADER;

COPY fact_assets(DateKey, AccountKey, AccountName, Amount, ScenarioKey)
FROM '/path/to/fact_assets.csv'
DELIMITER ','
CSV HEADER;

COPY fact_debt(DateKey, AccountKey, AccountName, Amount, ScenarioKey)
FROM '/path/to/fact_debt.csv'
DELIMITER ','
CSV HEADER;

COPY fact_equity(DateKey, AccountKey, AccountName, Amount, ScenarioKey)
FROM '/path/to/fact_equity.csv'
DELIMITER ','
CSV HEADER;

COPY fact_taxes(DateKey, AccountKey, AccountName, Amount, ScenarioKey)
FROM '/path/to/fact_taxes.csv'
DELIMITER ','
CSV HEADER;

COPY fact_workingcapital(DateKey, AccountKey, AccountName, Amount, ScenarioKey)
FROM '/path/to/fact_workingcapital.csv'
DELIMITER ','
CSV HEADER;

COPY fact_cashflow(DateKey, AccountKey, AccountName, Amount, ScenarioKey)
FROM '/path/to/fact_cashflow.csv'
DELIMITER ','
CSV HEADER;

COPY fact_price_volume(DateKey, ChannelKey, ProductKey, Price, Units, ScenarioKey)
FROM '/path/to/fact_price_volume.csv'
DELIMITER ','
CSV HEADER;
