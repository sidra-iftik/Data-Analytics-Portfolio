-- Step 1: Create tables from your imported CSVs if not done via GUI
-- These assume you've already imported the CSVs as the following table names:
-- daily_activity, hourly_steps, hourly_calories, minute_sleep, weight_log

-- Step 2: Aggregate hourly steps into daily
SELECT Id, CAST(ActivityHour AS DATE) AS ActivityDate, SUM(StepTotal) AS HourlyStepTotal
INTO hourly_steps_daily
FROM hourly_steps
GROUP BY Id, CAST(ActivityHour AS DATE);

-- Step 3: Aggregate hourly calories into daily
SELECT Id, CAST(ActivityHour AS DATE) AS ActivityDate, SUM(Calories) AS HourlyCaloriesTotal
INTO hourly_calories_daily
FROM hourly_calories
GROUP BY Id, CAST(ActivityHour AS DATE);

-- Step 4: Aggregate sleep to daily level
SELECT Id, CAST([date] AS DATE) AS ActivityDate, SUM([value]) AS TotalMinutesAsleep
INTO sleep_daily
FROM minute_sleep
GROUP BY Id, CAST([date] AS DATE);

-- Step 5: Aggregate weight to daily level
SELECT Id, CAST([Date] AS DATE) AS ActivityDate, AVG(WeightKg) AS AvgWeightKg
INTO weight_daily
FROM weight_log
GROUP BY Id, CAST([Date] AS DATE);

-- Step 6: Merge all into final cleaned dataset
SELECT 
    da.*,
    hs.HourlyStepTotal,
    hc.HourlyCaloriesTotal,
    sd.TotalMinutesAsleep,
    wd.AvgWeightKg
INTO fitbit_final
FROM daily_activity da
LEFT JOIN hourly_steps_daily hs ON da.Id = hs.Id AND da.ActivityDate = hs.ActivityDate
LEFT JOIN hourly_calories_daily hc ON da.Id = hc.Id AND da.ActivityDate = hc.ActivityDate
LEFT JOIN sleep_daily sd ON da.Id = sd.Id AND da.ActivityDate = sd.ActivityDate
LEFT JOIN weight_daily wd ON da.Id = wd.Id AND da.ActivityDate = wd.ActivityDate;
