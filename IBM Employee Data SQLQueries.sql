--1. Overall attrition rate
SELECT 
    COUNT(*) AS TotalEmployees,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS AttritedEmployees,
    ROUND(
        100.0 * SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2
    ) AS AttritionRatePercent
FROM IBMHREmployeeData.dbo.EmployeeData

--2. Attrition Rate by Department and Job Role
SELECT 
    Department,
    JobRole,
    COUNT(*) AS TotalEmployees,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS AttritedEmployees,
    ROUND(
        100.0 * SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2
    ) AS AttritionRatePercent
FROM IBMHREmployeeData.dbo.EmployeeData
GROUP BY Department, JobRole
ORDER BY AttritionRatePercent DESC;

--3. Satisfaction Scores vs Attrition
--(a)
SELECT 
    Attrition,
    AVG(CAST(JobSatisfaction AS FLOAT)) AS AvgJobSatisfaction,
    AVG(CAST(EnvironmentSatisfaction AS FLOAT)) AS AvgEnvironmentSatisfaction
FROM IBMHREmployeeData.dbo.EmployeeData
GROUP BY Attrition;

--(b)
SELECT 
    Attrition,
    -- Job Satisfaction Label
    CASE JobSatisfaction
        WHEN 1 THEN 'Low'
        WHEN 2 THEN 'Medium'
        WHEN 3 THEN 'High'
        WHEN 4 THEN 'Very High'
    END AS JobSatisfactionLevel,
    
    -- Environment Satisfaction Label
    CASE EnvironmentSatisfaction
        WHEN 1 THEN 'Low'
        WHEN 2 THEN 'Medium'
        WHEN 3 THEN 'High'
        WHEN 4 THEN 'Very High'
    END AS EnvironmentSatisfactionLevel,
    
    -- Relationship Satisfaction Label
    CASE RelationshipSatisfaction
        WHEN 1 THEN 'Low'
        WHEN 2 THEN 'Medium'
        WHEN 3 THEN 'High'
        WHEN 4 THEN 'Very High'
    END AS RelationshipSatisfactionLevel,
    
    COUNT(*) AS EmployeeCount
FROM IBMHREmployeeData.dbo.EmployeeData
GROUP BY 
    Attrition, 
    JobSatisfaction, 
    EnvironmentSatisfaction, 
    RelationshipSatisfaction
ORDER BY 
    Attrition, 
    JobSatisfaction, 
    EnvironmentSatisfaction;

--(c)
SELECT 
    Attrition,
    AVG(CAST(JobSatisfaction AS FLOAT)) AS AvgJobSatisfactionScore,
    AVG(CAST(EnvironmentSatisfaction AS FLOAT)) AS AvgEnvironmentSatisfactionScore,
    AVG(CAST(RelationshipSatisfaction AS FLOAT)) AS AvgRelationshipSatisfactionScore
FROM IBMHREmployeeData.dbo.EmployeeData
GROUP BY Attrition;

--4. Age, Income, Experience Comparison
SELECT 
    Attrition,
    AVG(Age) AS AvgAge,
    AVG(MonthlyIncome) AS AvgMonthlyIncome,
    AVG(TotalWorkingYears) AS AvgExperience
FROM IBMHREmployeeData.dbo.EmployeeData
GROUP BY Attrition;

--5. Overtime and Attrition Correlation
SELECT 
    OverTime,
    COUNT(*) AS TotalEmployees,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS AttritedEmployees,
    ROUND(
        100.0 * SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2
    ) AS AttritionRatePercent
FROM IBMHREmployeeData.dbo.EmployeeData
GROUP BY OverTime;

--6. Attrition by Education Level and Business Travel
--(a)
SELECT 
    Education,
    BusinessTravel,
    COUNT(*) AS TotalEmployees,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS AttritedEmployees,
    ROUND(
        100.0 * SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2
    ) AS AttritionRatePercent
FROM IBMHREmployeeData.dbo.EmployeeData
GROUP BY Education, BusinessTravel
ORDER BY AttritionRatePercent DESC;

--(b)
SELECT 
    CASE Education
        WHEN 1 THEN 'Below College'
        WHEN 2 THEN 'College'
        WHEN 3 THEN 'Bachelor'
        WHEN 4 THEN 'Master'
        WHEN 5 THEN 'Doctor'
    END AS EducationLevel,
    BusinessTravel,
    COUNT(*) AS TotalEmployees,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS AttritedEmployees,
    ROUND(
        100.0 * SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2
    ) AS AttritionRatePercent
FROM IBMHREmployeeData.dbo.EmployeeData
GROUP BY Education, BusinessTravel
ORDER BY AttritionRatePercent DESC;

--7. Attrition by Monthly Income Bands
SELECT 
    CASE 
        WHEN MonthlyIncome < 3000 THEN 'Under 3K'
        WHEN MonthlyIncome BETWEEN 3000 AND 6000 THEN '3K-6K'
        WHEN MonthlyIncome BETWEEN 6001 AND 9000 THEN '6K-9K'
        ELSE 'Above 9K'
    END AS IncomeBand,
    COUNT(*) AS TotalEmployees,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS AttritedEmployees,
    ROUND(
        100.0 * SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2
    ) AS AttritionRatePercent
FROM IBMHREmployeeData.dbo.EmployeeData
GROUP BY 
    CASE 
        WHEN MonthlyIncome < 3000 THEN 'Under 3K'
        WHEN MonthlyIncome BETWEEN 3000 AND 6000 THEN '3K-6K'
        WHEN MonthlyIncome BETWEEN 6001 AND 9000 THEN '6K-9K'
        ELSE 'Above 9K'
    END;

--8. Attrition by Education Field
SELECT 
    EducationField,
    COUNT(*) AS TotalEmployees,
    SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) AS AttritedEmployees,
    ROUND(
        100.0 * SUM(CASE WHEN Attrition = 'Yes' THEN 1 ELSE 0 END) / COUNT(*), 2
    ) AS AttritionRatePercent
FROM IBMHREmployeeData.dbo.EmployeeData
GROUP BY EducationField
ORDER BY AttritionRatePercent DESC;

--9. Work-Life Balance and Job Involvement by Attrition
SELECT 
    Attrition,
    CASE WorkLifeBalance
        WHEN 1 THEN 'Bad'
        WHEN 2 THEN 'Good'
        WHEN 3 THEN 'Better'
        WHEN 4 THEN 'Best'
    END AS WorkLifeBalanceLabel,
    CASE JobInvolvement
        WHEN 1 THEN 'Low'
        WHEN 2 THEN 'Medium'
        WHEN 3 THEN 'High'
        WHEN 4 THEN 'Very High'
    END AS JobInvolvementLabel,
    COUNT(*) AS EmployeeCount
FROM IBMHREmployeeData.dbo.EmployeeData
GROUP BY Attrition, WorkLifeBalance, JobInvolvement
ORDER BY Attrition, EmployeeCount DESC;

--10. Performance Ratings by Department
SELECT 
    Department,
    CASE PerformanceRating
        WHEN 1 THEN 'Low'
        WHEN 2 THEN 'Good'
        WHEN 3 THEN 'Excellent'
        WHEN 4 THEN 'Outstanding'
    END AS PerformanceLabel,
    COUNT(*) AS EmployeeCount
FROM IBMHREmployeeData.dbo.EmployeeData
GROUP BY Department, PerformanceRating
ORDER BY EmployeeCount DESC;
