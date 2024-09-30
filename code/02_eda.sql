-- Setup the database by running the following code in terminal
/*
sqlite3 mealkit_delivery.db
.mode csv
CREATE TABLE campaigns (
    campaign_id INTEGER,
    campaign_name TEXT,
    description TEXT,
    start_date DATE,
    end_date DATE,
    budget REAL,
    target_audience TEXT,
    channel TEXT,
    total_cost REAL
);
.import --skip 1 /Users/ekin/Documents/Projects/mealkit-delivery/data/campaigns.csv campaigns
*/

-- Check if the import has been successful
SELECT *
FROM campaigns
LIMIT 5;

-- Count the total number of rows
SELECT COUNT(*)
FROM campaigns;

-- Check the data types of the columns
PRAGMA table_info(campaigns);

-- Check the first 5 rows
SELECT *
FROM campaigns
LIMIT 5;

-- Check null values
SELECT COUNT(*)
FROM campaigns
WHERE campaign_id IS NULL
    OR campaign_name IS NULL
    OR description IS NULL
    OR start_date IS NULL
    OR end_date IS NULL
    OR budget IS NULL
    OR target_audience IS NULL
    OR channel IS NULL
    OR total_cost IS NULL;

-- Check the unique values in the target_audience column
SELECT DISTINCT target_audience
FROM campaigns;

-- Check the unique values in the channel column
SELECT DISTINCT channel
FROM campaigns;

-- End date must not be before the start date
SELECT COUNT(*)
FROM campaigns
WHERE end_date < start_date;

-- Start date must not be in the future
SELECT COUNT(*)
FROM campaigns
WHERE start_date > DATE('now');

-- Show the first campaign
SELECT *
FROM campaigns
ORDER BY start_date
LIMIT 1;

-- Summary statistics for the campaign duration
SELECT 
    COUNT(*) AS total_campaigns,
    AVG(julianday(end_date) - julianday(start_date)) AS avg_duration,
    MIN(julianday(end_date) - julianday(start_date)) AS min_duration,
    MAX(julianday(end_date) - julianday(start_date)) AS max_duration,
    ROUND(
        sqrt(AVG((julianday(end_date) - julianday(start_date)) * (julianday(end_date) - julianday(start_date))) 
        - (AVG(julianday(end_date) - julianday(start_date)) * AVG(julianday(end_date) - julianday(start_date)))),
    2) AS std_duration

FROM campaigns;