-- Step 1: Converting Timestamp and aggregate daily averages
CREATE TABLE daily_sensor_agg AS
SELECT
    MachineID,
    DATE(Timestamp) AS ReadingDate,
    AVG(Temperature) AS AvgTemp,
    AVG(Vibration) AS AvgVibration,
    AVG(Pressure) AS AvgPressure,
    MAX(RuntimeHours) AS MaxRuntime
FROM `predictive maintenance`.sensor_readings
WHERE Vibration IS NOT NULL  -- Removing missing vibration entries
GROUP BY MachineID, DATE(Timestamp);


-- Created a cleaned version of maintenance logs with unified date format
CREATE TABLE cleaned_maintenance_logs AS
SELECT
    MachineID,
    -- Use LIKE to check format and parse accordingly
    CASE 
        WHEN Date LIKE '____-__-__' THEN STR_TO_DATE(Date, '%Y-%m-%d')
        WHEN Date LIKE '__/__/____' THEN STR_TO_DATE(Date, '%d/%m/%Y')
        ELSE NULL
    END AS MaintenanceDate,
    Failure,
    RepairType,
    DowntimeHours
FROM `predictive maintenance`.maintenance_logs;







-- Join all tables
-- Step 1: Created intermediate table with labeled failures
CREATE TABLE modeling_data AS
SELECT
    d.MachineID,
    d.ReadingDate,
    d.AvgTemp,
    d.AvgVibration,
    d.AvgPressure,
    d.MaxRuntime,
    m.MachineType,
    m.AgeYears,
    m.LastOverhaulDate,
    -- Label as 1 if a failure occurred in 30 days, else 0
    CASE 
        WHEN ml.MaintenanceDate IS NOT NULL AND ml.Failure = 'Y' THEN 1
        ELSE 0
    END AS FailureWithin30Days
FROM daily_sensor_agg d
JOIN `predictive maintenance`.machine_metadata m 
    ON d.MachineID = m.MachineID
LEFT JOIN cleaned_maintenance_logs ml 
    ON d.MachineID = ml.MachineID
   AND ml.MaintenanceDate BETWEEN d.ReadingDate AND DATE_ADD(d.ReadingDate, INTERVAL 30 DAY);
