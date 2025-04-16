-- 1. User Activity Summary. Goal: Total steps, active minutes, and calories per user
SELECT 
    Id,
    COUNT(DISTINCT ActivityDate) AS DaysTracked,
    SUM(TotalSteps) AS TotalSteps,
    SUM(Calories) AS TotalCalories,
    SUM(VeryActiveMinutes + FairlyActiveMinutes + LightlyActiveMinutes) AS TotalActiveMinutes
FROM FitBitData.dbo.FitbitDataset
GROUP BY Id
ORDER BY TotalSteps DESC


-- 2. Average Daily Activity by Day of Week. Goal: Understand when users are most active
SELECT 
    DATENAME(WEEKDAY, ActivityDate) AS DayOfWeek,
    AVG(TotalSteps) AS AvgSteps,
    AVG(Calories) AS AvgCalories
FROM FitBitData.dbo.FitbitDataset
GROUP BY DATENAME(WEEKDAY, ActivityDate)
ORDER BY 
    CASE 
        WHEN DATENAME(WEEKDAY, ActivityDate) = 'Monday' THEN 1
        WHEN DATENAME(WEEKDAY, ActivityDate) = 'Tuesday' THEN 2
        WHEN DATENAME(WEEKDAY, ActivityDate) = 'Wednesday' THEN 3
        WHEN DATENAME(WEEKDAY, ActivityDate) = 'Thursday' THEN 4
        WHEN DATENAME(WEEKDAY, ActivityDate) = 'Friday' THEN 5
        WHEN DATENAME(WEEKDAY, ActivityDate) = 'Saturday' THEN 6
        WHEN DATENAME(WEEKDAY, ActivityDate) = 'Sunday' THEN 7
    END;


	-- 3. Sleep and Calorie Relationship. Goal: Investigate if more sleep = more calories burned
SELECT 
    Id,
    AVG(TotalMinutesAsleep) AS AvgSleepMinutes,
    AVG(Calories) AS AvgCalories
FROM FitBitData.dbo.FitbitDataset
WHERE TotalMinutesAsleep IS NOT NULL
GROUP BY Id
ORDER BY AvgSleepMinutes DESC;


-- 4. Steps vs Calories Correlation. Goal: Are more steps associated with more calories burned?
SELECT 
    Id,
	ActivityDate,
	TotalSteps,
    Calories
FROM FitBitData.dbo.FitbitDataset
WHERE TotalSteps IS NOT NULL AND Calories IS NOT NULL;


-- 5. Sedentary vs Active Minutes Per User. Goal: Compare user lifestyles
SELECT 
    Id,
    AVG(SedentaryMinutes) AS AvgSedentaryMinutes,
    AVG(VeryActiveMinutes + FairlyActiveMinutes + LightlyActiveMinutes) AS AvgActiveMinutes
FROM FitBitData.dbo.FitbitDataset
GROUP BY Id
ORDER BY AvgActiveMinutes DESC;


-- 6. Weight vs Activity. Goal: See if weight is related to daily step count
SELECT 
    Id,
    AVG(AvgWeightKg) AS AvgWeight,
    AVG(TotalSteps) AS AvgSteps
FROM FitBitData.dbo.FitbitDataset
WHERE AvgWeightKg IS NOT NULL
GROUP BY Id
ORDER BY AvgWeight DESC;


-- 7. Daily Activity Classification. Goal: Classify each day as Sedentary, Lightly Active, or Very Active
SELECT 
    Id,
    ActivityDate,
    TotalSteps,
    CASE 
        WHEN TotalSteps < 5000 THEN 'Sedentary'
        WHEN TotalSteps BETWEEN 5000 AND 9999 THEN 'Lightly Active'
        ELSE 'Very Active'
    END AS ActivityLevel
FROM FitBitData.dbo.FitbitDataset;


-- 8. Most Active Day Per User. Goal: Find the day with the highest steps for each user
SELECT Id, ActivityDate, TotalSteps
FROM FitBitData.dbo.FitbitDataset a
WHERE TotalSteps = (
    SELECT MAX(TotalSteps)
    FROM FitBitData.dbo.FitbitDataset b
    WHERE b.Id = a.Id
);


-- 9. Hourly Step Trends (using HourlyStepTotal if split). Goal: See step patterns by hour (if you keep a separate table)
--SELECT 
--    DATEPART(HOUR, ActivityHour) AS HourOfDay,
--    AVG(StepTotal) AS AvgSteps
--FROM HourlySteps
--GROUP BY DATEPART(HOUR, ActivityHour)
--ORDER BY HourOfDay;
SELECT 
    CAST(ActivityHour AS TIME) AS HourOnly,
    DATEPART(HOUR, CAST(ActivityHour AS DATETIME)) AS HourOfDay,
    AVG(StepTotal) AS AvgSteps
FROM FitBitData.dbo.hourlySteps
GROUP BY 
    CAST(ActivityHour AS TIME),
    DATEPART(HOUR, CAST(ActivityHour AS DATETIME))
ORDER BY HourOfDay;


-- 10. User Consistency Score. Goal: Score users based on how many days they were active (over 7500 steps)
SELECT 
    Id,
    COUNT(*) AS DaysTracked,
    SUM(CASE WHEN TotalSteps >= 7500 THEN 1 ELSE 0 END) AS ActiveDays,
    CAST(SUM(CASE WHEN TotalSteps >= 7500 THEN 1 ELSE 0 END) * 100.0 / COUNT(*) AS DECIMAL(5,2)) AS ActivityConsistencyPercent
FROM FitBitData.dbo.FitbitDataset
GROUP BY Id
ORDER BY ActivityConsistencyPercent DESC;


-- 11. Sleep Quality Band. Goal: Categorize sleep duration into sleep quality bands
SELECT 
    Id,
    ActivityDate,
    TotalMinutesAsleep,
    CASE 
        WHEN TotalMinutesAsleep < 360 THEN 'Poor'
        WHEN TotalMinutesAsleep BETWEEN 360 AND 480 THEN 'Adequate'
        ELSE 'Excellent'
    END AS SleepQuality
FROM FitBitData.dbo.FitbitDataset
WHERE TotalMinutesAsleep IS NOT NULL;


-- 12. Weight Change Over Time. Goal: Track weight loss/gain (requires dense weight logging)
SELECT 
    Id,
    MIN(ActivityDate) AS FirstDate,
    MAX(ActivityDate) AS LastDate,
    MIN(AvgWeightKg) AS StartingWeight,
    MAX(AvgWeightKg) AS EndingWeight,
    MAX(AvgWeightKg) - MIN(AvgWeightKg) AS WeightChange
FROM FitBitData.dbo.FitbitDataset
WHERE AvgWeightKg IS NOT NULL
GROUP BY Id;


-- 13. Weekly Activity Overview. Goal: Roll up total weekly steps and calories
SELECT 
    Id,
    DATEPART(YEAR, ActivityDate) AS Year,
    DATEPART(WEEK, ActivityDate) AS WeekNumber,
    SUM(TotalSteps) AS WeeklySteps,
    SUM(Calories) AS WeeklyCalories
FROM FitBitData.dbo.FitbitDataset
GROUP BY Id, DATEPART(YEAR, ActivityDate), DATEPART(WEEK, ActivityDate)
ORDER BY Id, Year, WeekNumber;


-- 14. Correlation Analysis Helper Table. Goal: Prepare table for correlation matrix in Python or Excel
SELECT 
    Id,
	TotalSteps,
    Calories,
    VeryActiveMinutes,
    FairlyActiveMinutes,
    LightlyActiveMinutes,
    SedentaryMinutes,
    TotalMinutesAsleep,
    AvgWeightKg
FROM FitBitData.dbo.FitbitDataset
WHERE TotalSteps IS NOT NULL AND Calories IS NOT NULL;


--15. Join Sleep with Daily Activity. Combine daily sleep totals with step and calorie performance.
SELECT 
    da.Id,
    da.ActivityDate,
    da.TotalSteps,
    da.Calories,
    ms.TotalMinutesAsleep
FROM FitBitData.dbo.dailyActivity_merged da
LEFT JOIN (
    SELECT 
        Id,
        CAST([date] AS DATE) AS SleepDate,
        SUM([value]) AS TotalMinutesAsleep
    FROM FitBitData.dbo.minuteSleep_merged
    GROUP BY Id, CAST([date] AS DATE)
) ms
ON da.Id = ms.Id AND da.ActivityDate = ms.SleepDate;


--16. Join Hourly Steps and Hourly Calories. Check how step counts and calories burned align hour-by-hour.
SELECT 
    hs.Id,
    hs.ActivityHour,
    hs.StepTotal,
    hc.Calories
FROM FitBitData.dbo.hourlySteps_merged hs
LEFT JOIN FitBitData.dbo.hourlyCalories_merged hc
ON hs.Id = hc.Id AND hs.ActivityHour = hc.ActivityHour;


--17. Join Weight Logs with Daily Activity. Evaluate how activity might influence weight changes.
SELECT 
    da.Id,
    da.ActivityDate,
    da.TotalSteps,
    da.Calories,
    wl.WeightKg
FROM FitBitData.dbo.dailyActivity_merged da
LEFT JOIN FitBitData.dbo.weightLogInfo_merged wl
ON da.Id = wl.Id AND da.ActivityDate = CAST(wl.Date AS DATE);


--18. Join Daily Activity with Aggregated Hourly Steps. Show how hourly step totals add up to match daily steps.
SELECT 
    da.Id,
    da.ActivityDate,
    da.TotalSteps AS DailySteps,
    hs.HourlyStepTotal
FROM FitBitData.dbo.dailyActivity_merged da
LEFT JOIN (
    SELECT 
        Id,
        CAST(ActivityHour AS DATE) AS Date,
        SUM(StepTotal) AS HourlyStepTotal
    FROM FitBitData.dbo.hourlySteps_merged
    GROUP BY Id, CAST(ActivityHour AS DATE)
) hs
ON da.Id = hs.Id AND da.ActivityDate = hs.Date;


--19. Full Combination: Activity + Sleep + Weight. Comprehensive user profile per day.
SELECT 
    da.Id,
    da.ActivityDate,
    da.TotalSteps,
    da.Calories,
    ms.TotalMinutesAsleep,
    wl.WeightKg
FROM FitBitData.dbo.dailyActivity_merged da
LEFT JOIN (
    SELECT Id, CAST([date] AS DATE) AS SleepDate, SUM([value]) AS TotalMinutesAsleep
    FROM FitBitData.dbo.minuteSleep_merged
    GROUP BY Id, CAST([date] AS DATE)
) ms ON da.Id = ms.Id AND da.ActivityDate = ms.SleepDate
LEFT JOIN (
    SELECT Id, CAST([Date] AS DATE) AS WeightDate, AVG(WeightKg) AS WeightKg
    FROM FitBitData.dbo.weightLogInfo_merged
    GROUP BY Id, CAST([Date] AS DATE)
) wl ON da.Id = wl.Id AND da.ActivityDate = wl.WeightDate;
