

CREATE TABLE Regions (
    Region VARCHAR(50) PRIMARY KEY,
    Market VARCHAR(50)
);

--
-- Data for Table: Regions
--
INSERT INTO Regions (Region, Market) VALUES
('NE', 'East'),
('West', 'West'),
('South', 'South'),
('NW', 'NorthWest'),
('SW', 'SouthWest'),
('East', 'East'),
('North', 'North'),
('SE', 'SouthEast'),
('MidWest', 'MidWest'),
('Central', 'Central');





CREATE TABLE Customers (
    CustomerID VARCHAR(10) PRIMARY KEY,
    Industry VARCHAR(50),
    CompanySize VARCHAR(10),
    ChurnStatus CHAR(1)
);

--
-- Data for Table: Customers
--
INSERT INTO Customers (CustomerID, Industry, CompanySize, ChurnStatus) VALUES
('C1000', 'Finance', 'M', 'N'),
('C1001', 'Healthcare', 'L', 'N'),
('C1002', 'Finance', 'Small', 'N'),
('C1003', 'Healthcare', 's', 'Y'),
('C1004', 'Finance', 's', 'N'),
('C1005', 'Healthcare', 'SM', 'Y'),
('C1006', 'Technology', 'Small', 'N'),
('C1007', 'Technology', 'L', 'N'),
('C1008', 'Manufacturing', 'Large', 'N'),
('C1009', 'Technology', 'Small', 'Y');




--
-- Table: Sales
-- Description: Records individual sales transactions, linking to customers and regions.
--
CREATE TABLE Sales (
    SaleID VARCHAR(10) PRIMARY KEY,
    SaleDate DATE,
    CustomerID VARCHAR(10),
    ProductTier VARCHAR(20),
    Region VARCHAR(50),
    Revenue DECIMAL(10, 2),
    ContractLength INT,
    FOREIGN KEY (CustomerID) REFERENCES Customers(CustomerID),
    FOREIGN KEY (Region) REFERENCES Regions(Region)
);

--
-- Data for Table: Sales
-- Note: Date format is 'MM/DD/YYYY'. Adjust based on your SQL dialect's date parsing.
-- For MySQL/PostgreSQL, you might need STR_TO_DATE or TO_DATE functions if inserting directly.
-- Example for MySQL: STR_TO_DATE('06/12/2024', '%m/%d/%Y')
-- Example for PostgreSQL: TO_DATE('06/12/2024', 'MM/DD/YYYY')
--
INSERT INTO Sales (SaleID, SaleDate, CustomerID, ProductTier, Region, Revenue, ContractLength) VALUES
('S00001', '2024-06-12', 'C4186', 'Basic', 'NE', 532.07, 36),
('S00002', '2024-01-29', 'C5593', 'Enterprise', 'West', 26650.65, 12),
('S00003', '2024-01-07', 'C3691', 'Pro', 'South', 2843.36, 36),
('S00004', '2024-03-11', 'C2451', 'Pro', 'NW', 3767.70, 6),
('S00005', '2024-03-03', 'C5465', 'Basic', 'NE', 610.94, 24),
('S00006', '2024-02-27', 'C2640', 'Basic', 'SW', 519.70, NULL), -- NULL for missing contract length
('S00007', '2024-02-05', 'C1116', 'Basic', 'NW', 636.23, 36),
('S00008', '2024-01-27', 'C4518', 'Enterprise', 'East', 12323.66, 12),
('S00009', '2024-06-22', 'C1652', 'Pro', 'NE', 3690.00, 6),
('S00010', '2024-05-19', 'C3693', 'Pro', 'North', 2168.51, 36);




SET SQL_SAFE_UPDATES = 0;
UPDATE Customers
SET CompanySize = CASE
    WHEN CompanySize IN ('SM', 's', 'Small') THEN 'Small'
    WHEN CompanySize IN ('Med', 'M', 'Medium') THEN 'Medium'
    WHEN CompanySize IN ('L', 'large', 'Large') THEN 'Large'
    ELSE CompanySize
END;
SET SQL_SAFE_UPDATES = 1;


SELECT * FROM Sales WHERE ContractLength IS NULL;

UPDATE Sales
JOIN (
    SELECT ROUND(AVG(ContractLength)) AS avg_contract
    FROM Sales
    WHERE ContractLength IS NOT NULL
) AS avg_table
ON TRUE
SET Sales.ContractLength = avg_table.avg_contract
WHERE Sales.ContractLength IS NULL;




DROP VIEW IF EXISTS CustomerSalesData;
-- Or if it's a table:
DROP TABLE IF EXISTS CustomerSalesData;

CREATE VIEW CustomerSalesData AS
SELECT 
    s.SaleID,
    s.SaleDate,
    s.CustomerID,
    c.Industry,
    c.CompanySize,
    c.ChurnStatus,
    s.ProductTier,
    s.Region,
    r.Market,
    s.Revenue,
    s.ContractLength
FROM Sales s
JOIN Customers c ON s.CustomerID = c.CustomerID
JOIN Regions r ON s.Region = r.Region;


CREATE OR REPLACE VIEW CustomerSalesData AS
SELECT 
    s.SaleID,
    s.SaleDate,
    s.CustomerID,
    c.Industry,
    c.CompanySize,
    c.ChurnStatus,
    s.ProductTier,
    s.Region,
    r.Market,
    s.Revenue,
    s.ContractLength
FROM Sales s
JOIN Customers c ON s.CustomerID = c.CustomerID
JOIN Regions r ON s.Region = r.Region;


-- Churn rate by Company Size
SELECT CompanySize, 
       COUNT(*) AS Total_Customers,
       SUM(CASE WHEN ChurnStatus = 'Y' THEN 1 ELSE 0 END) AS Churned,
       ROUND(SUM(CASE WHEN ChurnStatus = 'Y' THEN 1 ELSE 0 END) / COUNT(*) * 100, 2) AS Churn_Rate_Percent
FROM CustomerSalesData
GROUP BY CompanySize;

-- Revenue by Industry
SELECT Industry, SUM(Revenue) AS Total_Revenue
FROM CustomerSalesData
GROUP BY Industry;

-- Average contract length by Region
SELECT Region, AVG(ContractLength) AS Avg_ContractLength
FROM CustomerSalesData
GROUP BY Region;

-- In MySQL Workbench or DBeaver, use the GUI export option after running:
SELECT * FROM CustomerSalesData;

SELECT DISTINCT CustomerID FROM Sales
WHERE CustomerID NOT IN (
    SELECT CustomerID FROM Customers
);

SELECT DISTINCT Region FROM Sales
WHERE Region NOT IN (
    SELECT Region FROM Regions
);


UPDATE Sales
SET CustomerID = 'C1000'
WHERE CustomerID = 'C4186';

-- Repeat similar updates for others (C5593 → C1001, etc.)


INSERT INTO Customers (CustomerID, Industry, CompanySize, ChurnStatus)
VALUES ('C4186', 'Technology', 'Small', 'N');

SELECT * FROM CustomerSalesData;

SELECT COUNT(*) FROM Sales;


INSERT INTO Sales (SaleID, SaleDate, CustomerID, ProductTier, Region, Revenue, ContractLength) VALUES
('S00001', '2024-06-12', 'C1000', 'Basic', 'NE', 532.07, 36),
('S00002', '2024-01-29', 'C1001', 'Enterprise', 'West', 26650.65, 12),
('S00003', '2024-01-07', 'C1002', 'Pro', 'South', 2843.36, 36),
('S00004', '2024-03-11', 'C1003', 'Pro', 'NW', 3767.70, 6),
('S00005', '2024-03-03', 'C1004', 'Basic', 'NE', 610.94, 24),
('S00006', '2024-02-27', 'C1005', 'Basic', 'SW', 519.70, NULL),
('S00007', '2024-02-05', 'C1006', 'Basic', 'NW', 636.23, 36),
('S00008', '2024-01-27', 'C1007', 'Enterprise', 'East', 12323.66, 12),
('S00009', '2024-06-22', 'C1008', 'Pro', 'NE', 3690.00, 6),
('S00010', '2024-05-19', 'C1009', 'Pro', 'North', 2168.51, 36);

SELECT * FROM Sales;

-- Example: Revenue per month
SELECT 
    *,
    ROUND(Revenue / ContractLength, 2) AS MonthlyRevenue
FROM CustomerSalesData;


SELECT *,
    CASE 
        WHEN Revenue >= 10000 THEN 'High Value'
        WHEN Revenue >= 3000 THEN 'Mid Value'
        ELSE 'Low Value'
    END AS CustomerValueTier
FROM CustomerSalesData;

SELECT * FROM CustomerSalesData;
