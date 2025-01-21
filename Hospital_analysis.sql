---1. Patient Admission Trends  ---
SELECT 
    FORMAT(Start, 'yyyy-MM') AS Month, -- Extract year and month from the Start date
    COUNT(DISTINCT Patient) AS Unique_Patient_Count, -- Count unique patients admitted
    COUNT(Id) AS Total_Encounters -- Total number of admissions (including readmissions)
FROM 
    dbo.encounters$
GROUP BY 
    FORMAT(Start, 'yyyy-MM')
ORDER BY 
    Month;
		
---2. Top Diagnosed Conditions---
SELECT TOP 5 
    code, 
    COUNT(PATIENT) AS num_patient, 
    description
FROM 
    dbo.procedures$
GROUP BY 
    code, description
ORDER BY 
    num_patient DESC;

-- 3.Cost Encounters --
SELECT code,DESCRIPTION, ROUND(AVG(BASE_COST),2) as average_cost
FROM procedures$
GROUP BY code,DESCRIPTION

-- 4. Length of Stay by Condition  --
SELECT 
    p.Code AS Condition_Code,
    p.Description AS Condition_Description,
    AVG(DATEDIFF(DAY, e.Start, e.Stop)) AS Average_Length_of_Stay_Days
FROM 
    dbo.procedures$ p
JOIN 
    dbo.encounters$ e ON p.ENCOUNTER = e.Id
WHERE 
    e.Start IS NOT NULL AND e.Stop IS NOT NULL
GROUP BY 
    p.Code, p.Description
ORDER BY 
    Average_Length_of_Stay_Days DESC;

-- 5. Insurance Coverage Insights --
SELECT e.PAYER, p.NAME,ROUND(SUM(Total_Claim_Cost),2) AS Total_Cost,
ROUND(SUM(Payer_Coverage),2) AS Total_Covered_By_Insurance,
CAST(SUM(Payer_Coverage) * 100.0 / SUM(Total_Claim_Cost) AS DECIMAL(5, 2)) AS Coverage_Percentage
FROM dbo.encounters$ as e
LEFT JOIN dbo.payers$ as p
ON e.PAYER = p.Id
WHERE p.name <> 'NO_INSURANCE'
GROUP BY e.PAYER,p.NAME ;

--6.Peak Times for Hospital Visits--
SELECT 
    DATENAME(WEEKDAY, Start) AS Day_of_Week, -- Extract the weekday name
    COUNT(*) AS Total_Visits
FROM 
   dbo.encounters$
GROUP BY 
    DATENAME(WEEKDAY, Start)
ORDER BY 
    Total_Visits DESC;

--7. Cost Distribution by Procedure Type--
SELECT 
    p.CODE AS Procedure_Code,
    p.DESCRIPTION AS Procedure_Description,
    COUNT(*) AS Total_Procedures,
    ROUND(SUM(TOTAL_CLAIM_COST),2) AS Total_Cost,
    ROUND(AVG(Total_Claim_Cost),2) AS Average_Cost,
    ROUND(MIN(Total_Claim_Cost),2) AS Minimum_Cost,
    ROUND(MAX(Total_Claim_Cost),2) AS Maximum_Cost
FROM 
    dbo.encounters$ as e
JOIN dbo.procedures$ as p
ON e.Id = p.ENCOUNTER
GROUP BY 
    p.CODE, p.DESCRIPTION
ORDER BY 
    Total_Cost DESC;


