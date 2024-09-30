-- Setup the database by running the following code in terminal
/*
sqlite3 mealkit_delivery.db
.mode csv
CREATE TABLE campaigns (
    campaign_id INTEGER PRIMARY KEY,
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

-- List all tables in the database
SELECT name 
FROM sqlite_master 
WHERE type='table';

-- Create a view to show the first 5 rows of the table
CREATE VIEW IF NOT EXISTS campaigns_view AS
SELECT *
FROM campaigns
LIMIT 5;

-- Show the newly created view
SELECT *
FROM campaigns_view;

-- List non-table items in the database
SELECT name
FROM sqlite_master
WHERE type IN ('index', 'view');

-- Check if the import has been successful
SELECT *
FROM campaigns
LIMIT 5;

-- Count the total number of rows
SELECT COUNT(*)
FROM campaigns;

-- Check the data types of the columns
PRAGMA table_info(campaigns);

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

-- Summary statistics for the campaign costs per channel
SELECT 
    channel,
    COUNT(*) AS total_campaigns,
    CAST(ROUND(AVG(total_cost)) AS INTEGER) AS avg_cost,
    MIN(total_cost) AS min_cost,
    MAX(total_cost) AS max_cost,
    ROUND(
        sqrt(AVG(total_cost * total_cost) - (AVG(total_cost) * AVG(total_cost))),
    2) AS std_cost
FROM campaigns
GROUP BY channel;

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

-- Find the count and percantage of campaigns within and over the budget per channel
SELECT
    channel,
    COUNT(*) AS total_campaigns,
    SUM(CASE WHEN total_cost <= budget THEN 1 ELSE 0 END) AS n_within_budget,
    SUM(CASE WHEN total_cost > budget THEN 1 ELSE 0 END) AS n_over_budget,
    ROUND(
        100.0 * SUM(CASE WHEN total_cost <= budget THEN 1 ELSE 0 END) / COUNT(*),
    2) AS pct_within_budget,
    ROUND(
        100.0 * SUM(CASE WHEN total_cost > budget THEN 1 ELSE 0 END) / COUNT(*),
    2) AS pct_over_budget
FROM campaigns
GROUP BY channel;

-- Find the correlation between campaign duration and budget
WITH stats AS (
    SELECT 
        AVG(julianday(end_date) - julianday(start_date)) AS avg_duration,
        AVG(total_cost) AS avg_cost,
        SUM((julianday(end_date) - julianday(start_date) - (SELECT AVG(julianday(end_date) - julianday(start_date)) FROM campaigns)) * (total_cost - (SELECT AVG(total_cost) FROM campaigns))) AS covariance,
        SUM((julianday(end_date) - julianday(start_date) - (SELECT AVG(julianday(end_date) - julianday(start_date)) FROM campaigns)) * (julianday(end_date) - julianday(start_date) - (SELECT AVG(julianday(end_date) - julianday(start_date)) FROM campaigns))) AS variance_duration,
        SUM((total_cost - (SELECT AVG(total_cost) FROM campaigns)) * (total_cost - (SELECT AVG(total_cost) FROM campaigns))) AS variance_cost
    FROM campaigns
)
SELECT 
    ROUND(
        covariance / (sqrt(variance_duration) * sqrt(variance_cost)),
    2) AS correlation
FROM stats;

-- Trend analysis for the total cost per month
SELECT 
    strftime('%Y-%m', start_date) AS month,
    SUM(total_cost) AS total_cost
FROM campaigns
GROUP BY month
ORDER BY month;

-- Drop events table if exists
DROP TABLE IF EXISTS events;

-- Create events table
CREATE TABLE IF NOT EXISTS events (
    event_id TEXT PRIMARY KEY,
    campaign_id INTEGER,
    customer_id INTEGER,
    event_type TEXT,
    event_date DATE,
    channel TEXT,
    FOREIGN KEY (campaign_id) REFERENCES campaigns(campaign_id)
);

-- Check if table is successfully created
SELECT name 
FROM sqlite_master 
WHERE type='table';

-- Check data types of the columns
PRAGMA table_info(events);

-- Import data into the events table (Run in the terminal line-by-line)
/*
    sqlite3 mealkit_delivery.db
    .mode csv
    .import --skip 1 /Users/ekin/Documents/Projects/mealkit-delivery/data/events.csv events
*/

-- Check the first 5 rows of the events table
SELECT *
FROM events;