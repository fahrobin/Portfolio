--Create Customers table 
SELECT C.*, R.Region  
INTO dbo.Customers  -- New table created with merged data and region info
FROM (
    -- Combine CustomerWest and CustomerEast, removing duplicates
    SELECT * FROM dbo.CustomerWest
    UNION  -- Ensures unique records across both tables
    SELECT * FROM dbo.CustomerEast
) AS C  -- Alias for the merged dataset
JOIN dbo.Regions AS R  
ON C.State = R.State;

-- Transform data, analyze Profit and catagorize data
With Profitability as(
SELECT 
    Order_ID,
    Sale_Price,
    Cost_per_Item,
    -- Extracting Category_Type (portion before the first '-')
    LEFT(Category, CHARINDEX('-', Category + '-') - 1) AS Category_Type,
    -- Extracting Category_Subtype (portion after the first '-')
    STUFF(Category, 1, CHARINDEX('-', Category + '-'), '') AS Category_Subtype,
    -- Determining the Payment Method
    CASE
        WHEN COD IS NOT NULL AND COD <> 0 THEN 'COD'
        WHEN CreditCard IS NOT NULL AND CreditCard <> 0 THEN 'Credit Card' 
        WHEN DebitCard IS NOT NULL AND DebitCard <> 0 THEN 'Debit Card'
        WHEN EFT IS NOT NULL AND EFT <> 0 THEN 'EFT'
        ELSE 'Unknown' -- Handles cases where all are NULL or 0
    END AS PaymentMethod,
    -- Calculating Quantity
    COALESCE(COD, CreditCard, DebitCard, EFT) AS Quantity,
    -- Calculating Profit
    (Sale_Price - Cost_per_Item) * COALESCE(COD, CreditCard, DebitCard, EFT) AS profit
FROM dbo.Orders)

select *, case when profit >2000 then 'High'
				when profit >1000 then 'Average'
				else 'Low' end As profitability
from Profitability

-- Data retrive to answer business question
--What were the top 25 most profitable orders?
select TOP 25 
	s.Order_Id,
	Order_date,
	sum(Profit) as total_profit,
	CustomerName 
From dbo.Sales as s
join dbo.Customers as c
on s.Order_id = c.Order_id
Group by CustomerName,s.Order_Id,Order_date
Order by total_profit desc

--What day of the week is most profitable?
select  DATENAME(WEEKDAY, Order_Date) AS DOW,
	sum(Profit) as total_profit
From dbo.Sales as s
join dbo.Customers as c
on s.Order_id = c.Order_id
Group by DATENAME(WEEKDAY, Order_Date)
Order by total_profit desc

--What sub-categories contributed to the most profit in each category?
WITH RankedCategories AS (
    SELECT
        s.Category_Type,
        s.Category_SubType,
        SUM(s.Profit) AS total_profit,
        RANK() OVER (PARTITION BY s.Category_Type ORDER BY SUM(s.Profit) DESC) AS rn
    FROM dbo.Sales AS s
    JOIN dbo.Customers AS c ON s.Order_id = c.Order_id
    GROUP BY s.Category_Type, s.Category_SubType
)
SELECT
    Category_Type,
    Category_SubType,
    total_profit
FROM RankedCategories
WHERE rn = 1
ORDER BY Category_Type ASC, total_profit DESC;