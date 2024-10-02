-- =============================================================================
-- Preamble
-- =============================================================================
/* 

Project: Campaign Performance
Author: Ekin Derdiyok
Contact: ekin.derdiyok@icloud.com
GitHub: https://github.com/ekinderdiyok
Date: October 2024

Description: 
- This script is used to import and validate data, 
perform data quality checks, and conduct exploratory 
data analysis on marketing campaign data for the Mealkit 
Delivery project. It includes steps to create tables, 
import CSV data, verify data integrity, and compute 
various summary statistics and trends based on the data. 
These analyses help to better understand campaign performance 
and customer engagement through different channels.

Dependencies:
- Database: SQLite version 3.43.2 or higher
- CSV Files: campaigns.csv, events.csv (available in the data folder)
- Command Line: SQLite3 tool must be installed
- File Path: Ensure the data files are in the correct directory

*/

-- =============================================================================
-- Setup
-- =============================================================================

-- Setup the database by running the following code in terminal
/* 
    sqlite3 /Users/ekin/Documents/Projects/mealkit-delivery/data/mealkit_delivery.db
*/

-- =============================================================================
-- Create campaigns table, import data, and perform data quality checks
-- =============================================================================

-- Drop table campaigns if exists
DROP TABLE IF EXISTS campaigns;

-- Create campaigns table
CREATE TABLE IF NOT EXISTS campaigns (
    campaign_id INTEGER PRIMARY KEY,
    campaign_name TEXT,
    start_date DATE,
    end_date DATE,
    budget REAL,
    target_audience TEXT,
    channel TEXT
);

--Import data into the campaigns table
/* 
    .mode csv
    .import /Users/ekin/Documents/Projects/mealkit-delivery/data/campaigns.csv campaigns
*/

-- Check if table is successfully created
SELECT name 
FROM sqlite_master 
WHERE type='table';

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

-- ===========================================================
-- Create events table, import data, and perform data quality checks
-- ===========================================================

-- Drop events table if exists
DROP TABLE IF EXISTS events;

-- Create events table
CREATE TABLE IF NOT EXISTS events (
    event_id TEXT PRIMARY KEY,
    campaign_id INTEGER,
    lead_id INTEGER,
    event_type TEXT,
    event_date DATE,
    channel TEXT,
    subscription_id INTEGER,
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
    .mode csv
    sqlite3 mealkit_delivery.db
    .import --skip 1 /Users/ekin/Documents/Projects/mealkit-delivery/data/events.csv events
*/

-- Check if the import has been successful
SELECT *
FROM events
LIMIT 5;

-- Count the total number of rows
SELECT COUNT(*)
FROM events;

-- Convert empty strings into null values in subscription_id column
UPDATE events
SET subscription_id = NULL
WHERE subscription_id = '';

-- Check null values
SELECT COUNT(*)
FROM events
WHERE 
    event_id IS NULL
    OR campaign_id IS NULL
    OR lead_id IS NULL
    OR event_type IS NULL
    OR event_date IS NULL
    OR channel IS NULL
    OR subscription_id IS NULL;

-- =============================================================================
-- SUBSCRIPTIONS TABLE
-- =============================================================================

-- Drop subscriptions table if it exists
DROP TABLE IF EXISTS subscriptions;

-- Create subscriptions table
CREATE TABLE IF NOT EXISTS subscriptions (
    subscription_id INTEGER PRIMARY KEY,
    subscription_date TEXT, -- Store as ISO8601 string
    end_date TEXT,          -- Store as ISO8601 string
    n_meals INTEGER,
    n_people INTEGER,
    n_orders INTEGER,
    food_choice TEXT
);


-- Import data into the events table (Run in the terminal line-by-line)
/* 
    sqlite3 mealkit_delivery.db
    .mode csv
    .import /Users/ekin/Documents/Projects/mealkit-delivery/data/subscriptions.csv subscriptions
*/

-- Data quality checks
-- Check for null values in critical columns
SELECT COUNT(*)
FROM subscriptions
WHERE subscription_id IS NULL
    OR subscription_date IS NULL
    OR n_meals IS NULL
    OR n_people IS NULL
    OR n_orders IS NULL
    OR food_choice IS NULL;

-- Check for duplicate subscription_id
SELECT subscription_id, COUNT(*)
FROM subscriptions
GROUP BY subscription_id
HAVING COUNT(*) > 1;

-- Replace empty strings with NULL values in the end_date column
UPDATE subscriptions
SET end_date = NULL
WHERE end_date = '';


-- =============================================================================
-- Exploratory Data Analysis
-- =============================================================================

-- Channel-wise summary statistics
WITH event_counts AS (
    SELECT campaign_id, COUNT(*) AS event_count
    FROM events
    GROUP BY campaign_id
),
campaign_stats AS (
    SELECT 
        channel,
        COUNT(*) AS total_campaigns,
        AVG(total_cost) AS avg_cost,
        AVG(POWER(total_cost, 2)) AS avg_cost_squared,
        MIN(total_cost) AS min_cost,
        MAX(total_cost) AS max_cost,
        
        AVG(ec.event_count) AS avg_event_count,
        AVG(ec.event_count * ec.event_count) AS avg_event_count_squared,
        MIN(ec.event_count) AS min_event_count,
        MAX(ec.event_count) AS max_event_count,

        AVG(julianday(end_date) - julianday(start_date)) AS avg_duration,
        AVG(POWER(julianday(end_date) - julianday(start_date), 2)) AS avg_duration_squared,
        MIN(julianday(end_date) - julianday(start_date)) AS min_duration,
        MAX(julianday(end_date) - julianday(start_date)) AS max_duration,

        SUM(CASE WHEN total_cost <= budget THEN 1 ELSE 0 END) AS n_within_budget,
        SUM(CASE WHEN total_cost > budget THEN 1 ELSE 0 END) AS n_over_budget
    FROM campaigns
    LEFT JOIN event_counts ec ON campaigns.campaign_id = ec.campaign_id
    GROUP BY channel
)

SELECT 
    channel,
    total_campaigns,

    -- Cost summary statistics
    CAST(ROUND(avg_cost) AS INTEGER) AS avg_cost,
    min_cost,
    max_cost,
    ROUND(SQRT(avg_cost_squared - POWER(avg_cost, 2)), 2) AS std_cost,

    -- Number of events summary statistics
    avg_event_count AS avg_events,
    min_event_count AS min_events,
    max_event_count AS max_events,
    ROUND(SQRT(avg_event_count_squared - POWER(avg_event_count, 2)), 2) AS std_events,

    -- Duration summary statistics
    avg_duration,
    min_duration,
    max_duration,
    ROUND(SQRT(avg_duration_squared - POWER(avg_duration, 2)), 2) AS std_duration,

    -- Budget statistics
    n_within_budget,
    n_over_budget,
    ROUND(100.0 * n_within_budget / total_campaigns, 2) AS pct_within_budget,
    ROUND(100.0 * n_over_budget / total_campaigns, 2) AS pct_over_budget

FROM campaign_stats;

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

-- Find the campaign with the most events
WITH most_events_campaign AS (
    SELECT 
        campaign_id,
        campaign_name,
        COUNT(*) AS total_events
    FROM events
    JOIN campaigns USING (campaign_id)
    GROUP BY campaign_id, campaign_name
    ORDER BY total_events DESC
    LIMIT 1
)

SELECT 
    me.campaign_id,
    me.campaign_name,
    me.total_events,
    SUM(CASE WHEN TRIM(LOWER(e.event_type)) = 'click' THEN 1 ELSE 0 END) AS n_clicks,
    SUM(CASE WHEN TRIM(LOWER(e.event_type)) = 'signup' THEN 1 ELSE 0 END) AS n_signups,
    SUM(CASE WHEN TRIM(LOWER(e.event_type)) = 'impression' THEN 1 ELSE 0 END) AS n_impressions,
    SUM(CASE WHEN TRIM(LOWER(e.event_type)) = 'page_view' THEN 1 ELSE 0 END) AS n_page_views,
    SUM(CASE WHEN TRIM(LOWER(e.event_type)) = 'conversion' THEN 1 ELSE 0 END) AS n_conversions
FROM most_events_campaign me
LEFT JOIN events e ON me.campaign_id = e.campaign_id
GROUP BY me.campaign_id, me.campaign_name, me.total_events;

-- Find the moving average of the number of events per month
WITH events_per_month AS (
    SELECT 
        strftime('%Y-%m', event_date) AS month,
        COUNT(*) AS total_events
    FROM events
    GROUP BY month
    ORDER BY month
),
ma3m_n_events AS (
    SELECT 
        month,
        total_events,
        AVG(total_events) OVER (ORDER BY month ROWS BETWEEN 2 PRECEDING AND CURRENT ROW) AS ma3m_n_events
    FROM events_per_month
)
SELECT 
    month,
    total_events,
    ROUND(ma3m_n_events, 2) AS ma3m_n_events
FROM ma3m_n_events;

-- Find the month of the year with the most events for the whole duration
SELECT 
    strftime('%m', event_date) AS month,
    COUNT(*) AS total_events
FROM events
GROUP BY month
ORDER BY total_events DESC
LIMIT 3;

-- =============================================================================
-- Non-Table Items
-- =============================================================================

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

SELECT *
FROM events;

-- =============================================================================
-- KPIs
-- =============================================================================

-- Calculate churn rate across different food choices
WITH churn_rate AS (
    SELECT 
        food_choice,
        COUNT(DISTINCT subscription_id) AS n_subscriptions,
        COUNT(DISTINCT CASE WHEN end_date IS NOT NULL THEN subscription_id END) AS n_churned_subscriptions
    FROM subscriptions
    GROUP BY food_choice
)

SELECT 
    food_choice,
    n_subscriptions,
    n_churned_subscriptions,
    ROUND(100.0 * n_churned_subscriptions / n_subscriptions, 2) AS churn_rate
FROM churn_rate;

-- Calculate retention rate over years
WITH retention_rate AS (
    SELECT 
        strftime('%Y', subscription_date) AS year,
        COUNT(DISTINCT subscription_id) AS n_subscriptions,
        COUNT(DISTINCT CASE WHEN end_date IS NULL THEN subscription_id END) AS n_retained_subscriptions
    FROM subscriptions
    WHERE strftime('%Y', subscription_date) <= '2025'
    GROUP BY year
)

SELECT 
    year,
    n_subscriptions,
    n_retained_subscriptions,
    ROUND(100.0 * n_retained_subscriptions / n_subscriptions, 2) AS retention_rate
FROM retention_rate;

-- Calculate total campaign budget
SELECT SUM(budget) AS total_budget
FROM campaigns;

-- Calculate total number of subscribers
SELECT COUNT(DISTINCT subscription_id) AS total_subscribers;

-- Calculate customer acquisition cost (CAC) by dividing total campaign budget by the number of subscribers
SELECT 
    total_budget,
    total_subscribers,
    ROUND(total_budget / total_subscribers, 2) AS cac
FROM (
    SELECT 
        SUM(budget) AS total_budget
    FROM campaigns
) AS budget_data, (
    SELECT 
        COUNT(DISTINCT subscription_id) AS total_subscribers
    FROM subscriptions
) AS subscriber_data;

-- Average revenue per user (ARPU)
WITH price_per_meal_param AS (
    SELECT 6 AS price -- You can change the price here
),

revenue_per_user AS (
    SELECT 
        subscription_id,
        SUM(n_orders * n_meals * (SELECT price FROM price_per_meal_param)) AS total_revenue
    FROM subscriptions
    GROUP BY subscription_id
)

SELECT 
    ROUND(AVG(total_revenue), 2) AS arpu
FROM revenue_per_user;

