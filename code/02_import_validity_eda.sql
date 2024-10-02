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

Table of Contents:
1. Database Setup
2. Campaigns Table
3. Events Table
4. Subscriptions Table
5. Exploratory Data Analysis
6. Key Performance Indicators (KPIs)
7. Miscellaneous


*/

-- =============================================================================
-- 1. Database Setup
-- =============================================================================

-- Setup the database by running the following code in terminal
/* 
    sqlite3 /Users/ekin/Documents/Projects/mealkit-delivery/data/mealkit_delivery.db
*/

-- =============================================================================
-- Campaigns Table
-- =============================================================================

-- Drop table campaigns if exists
DROP TABLE IF EXISTS campaigns;

-- Create campaigns table
CREATE TABLE IF NOT EXISTS campaigns (
    campaign_id INTEGER PRIMARY KEY,
    campaign_name TEXT,
    start_date TEXT,
    end_date TEXT,
    budget REAL,
    target_audience TEXT,
    channel TEXT
);

--Import data into the campaigns table
/* 
    sqlite3 /Users/ekin/Documents/Projects/mealkit-delivery/data/mealkit_delivery.db
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
-- Events Table
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
    sqlite3 /Users/ekin/Documents/Projects/mealkit-delivery/data/mealkit_delivery.db
    .mode csv
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
-- Subscriptions Table
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

-- Check the list of tables in the database
SELECT name
FROM sqlite_master
WHERE type='table';

-- Check the data types of the columns
PRAGMA table_info(subscriptions);

-- Import data into the events table (Run in the terminal line-by-line)
/* 
    sqlite3 /Users/ekin/Documents/Projects/mealkit-delivery/data/mealkit_delivery.db
    .mode csv
    .import /Users/ekin/Documents/Projects/mealkit-delivery/data/subscriptions.csv subscriptions
*/

-- Check for null values
SELECT COUNT(*)
FROM subscriptions
WHERE 
    subscription_id IS NULL
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
        AVG(budget) AS avg_budget,
        AVG(POWER(budget, 2)) AS avg_budget_squared,
        MIN(budget) AS min_budget,
        MAX(budget) AS max_budget,
        
        AVG(ec.event_count) AS avg_event_count,
        AVG(ec.event_count * ec.event_count) AS avg_event_count_squared,
        MIN(ec.event_count) AS min_event_count,
        MAX(ec.event_count) AS max_event_count,

        AVG(julianday(end_date) - julianday(start_date)) AS avg_duration,
        AVG(POWER(julianday(end_date) - julianday(start_date), 2)) AS avg_duration_squared,
        MIN(julianday(end_date) - julianday(start_date)) AS min_duration,
        MAX(julianday(end_date) - julianday(start_date)) AS max_duration,

        SUM(CASE WHEN budget <= budget THEN 1 ELSE 0 END) AS n_within_budget,
        SUM(CASE WHEN budget > budget THEN 1 ELSE 0 END) AS n_over_budget
    FROM campaigns
    LEFT JOIN event_counts ec ON campaigns.campaign_id = ec.campaign_id
    GROUP BY channel
)

SELECT 
    channel,
    total_campaigns,

    -- Cost summary statistics
    CAST(ROUND(avg_budget) AS INTEGER) AS avg_budget,
    min_budget,
    max_budget,
    ROUND(SQRT(avg_budget_squared - POWER(avg_budget, 2)), 2) AS std_budget,

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

-- Average (weekly) revenue per user (ARPU)
WITH price_per_meal_param AS (
    SELECT 6 AS price -- You can change the price here
),

arpu AS (
    SELECT 
        subscription_id,
        SUM(n_people * n_meals * (SELECT price FROM price_per_meal_param)) AS total_revenue
    FROM subscriptions
    GROUP BY subscription_id
)

SELECT 
    ROUND(AVG(total_revenue), 2) AS arpu
FROM arpu;

-- Temporarily replace NULLs in the end_date with today's date and calculate average customer lifespan in weeks
WITH customer_lifespan AS (
    SELECT 
        subscription_id,
        (julianday(
            COALESCE(end_date, DATE('now'))
        ) - julianday(subscription_date)) / 7.0 AS lifespan_weeks
    FROM subscriptions
    GROUP BY subscription_id
)

SELECT 
    ROUND(AVG(lifespan_weeks), 2) AS avg_lifespan_weeks
FROM customer_lifespan;

-- Calculate customer lifetime value (CLV) by multiplying weekly ARPU by the number of weeks in the average customer lifespan
WITH price_per_meal_param AS (
    SELECT 6 AS price -- You can change the price here
),

arpu AS (
    SELECT 
        subscription_id,
        SUM(n_people * n_meals * (SELECT price FROM price_per_meal_param)) AS total_revenue
    FROM subscriptions
    GROUP BY subscription_id
),

customer_lifespan AS (
    SELECT 
        subscription_id,
        (julianday(
            COALESCE(end_date, DATE('now'))
        ) - julianday(subscription_date)) / 7.0 AS lifespan_weeks
    FROM subscriptions
    GROUP BY subscription_id
)

SELECT 
    ROUND(AVG(total_revenue), 2) AS weekly_arpu,
    ROUND(AVG(lifespan_weeks), 2) AS avg_lifespan_weeks,
    ROUND(AVG(total_revenue) * AVG(lifespan_weeks), 2) AS clv
FROM arpu, customer_lifespan;

-- Calculate customer lifetime value (CLV) divided by customer acquisition cost (CAC)
WITH price_per_meal_param AS (
    SELECT 6 AS price -- You can change the price here
),

arpu AS (
    SELECT 
        subscription_id,
        SUM(n_people * n_meals * (SELECT price FROM price_per_meal_param)) AS total_revenue
    FROM subscriptions
    GROUP BY subscription_id
),

customer_lifespan AS (
    SELECT 
        subscription_id,
        (julianday(
            COALESCE(end_date, DATE('now'))
        ) - julianday(subscription_date)) / 7.0 AS lifespan_weeks
    FROM subscriptions
    GROUP BY subscription_id
),

budget_data AS (
    SELECT 
        SUM(budget) AS total_budget
    FROM campaigns
),

subscriber_data AS (
    SELECT 
        COUNT(DISTINCT subscription_id) AS total_subscribers
    FROM subscriptions
)

SELECT 
    ROUND(AVG(total_revenue) * AVG(lifespan_weeks) / (SELECT total_budget / total_subscribers FROM budget_data, subscriber_data), 2) AS clv_cac_ratio
FROM arpu, customer_lifespan;

-- Year-over-year subscriber growth rate

WITH subscriber_growth AS (
    SELECT 
        strftime('%Y', subscription_date) AS year,
        COUNT(DISTINCT subscription_id) AS n_subscribers
    FROM subscriptions
    GROUP BY year
    ORDER BY year
)

SELECT 
    year,
    n_subscribers,
    (n_subscribers - LAG(n_subscribers, 1) OVER (ORDER BY year)) AS new_subscribers,
    ROUND(100.0 * (n_subscribers - LAG(n_subscribers, 1) OVER (ORDER BY year)) / NULLIF(LAG(n_subscribers, 1) OVER (ORDER BY year), 0), 2) AS growth_rate
FROM subscriber_growth;

-- Find the number of subscriber_id for each campaign in the events table
WITH campaign_subscribers AS (
    SELECT 
        campaign_id,
        COUNT(DISTINCT subscription_id) AS n_subscribers
    FROM events
    GROUP BY campaign_id
)

SELECT 
    campaign_id,
    n_subscribers
FROM campaign_subscribers
ORDER BY n_subscribers DESC
LIMIT 5;

-- Find the total revenue generated by each campaign by joining the events and subscriptions tables
WITH campaign_revenue AS (
    SELECT 
        e.campaign_id,
        SUM(s.n_people * s.n_meals * 6 * (julianday(COALESCE(s.end_date, DATE('now'))) - julianday(s.subscription_date)) / 7.0) AS total_revenue
    FROM events e
    JOIN subscriptions s ON e.subscription_id = s.subscription_id
    GROUP BY e.campaign_id
)

SELECT 
    c.campaign_id,
    c.campaign_name,
    CASE 
        WHEN cr.total_revenue >= 1000 THEN '€' || ROUND(cr.total_revenue / 1000, 1) || 'k'
        ELSE '€' || ROUND(cr.total_revenue, 2)
    END AS total_revenue
FROM campaigns c
LEFT JOIN campaign_revenue cr ON c.campaign_id = cr.campaign_id
ORDER BY cr.total_revenue DESC
LIMIT 5;

-- Calculate conversion rate for each channel dividing the number of "subscribe" to the number of "click" events
WITH conversion_rate AS (
    SELECT 
        channel,
        COUNT(CASE WHEN TRIM(LOWER(event_type)) = 'click' THEN 1 END) AS n_clicks,
        COUNT(CASE WHEN TRIM(LOWER(event_type)) = 'subscribe' THEN 1 END) AS n_subscribes
    FROM events
    GROUP BY channel
)

SELECT 
    channel,
    n_clicks,
    n_subscribes,
    ROUND(100.0 * n_subscribes / NULLIF(n_clicks, 0), 2) AS conversion_rate
FROM conversion_rate;

-- Calculate the conversion rate across different channel x audience combinations
WITH conversion_rate AS (
    SELECT 
        e.channel,
        c.target_audience,
        COUNT(CASE WHEN TRIM(LOWER(e.event_type)) = 'click' THEN 1 END) AS n_clicks,
        COUNT(CASE WHEN TRIM(LOWER(e.event_type)) = 'subscribe' THEN 1 END) AS n_subscribes
    FROM events e
    JOIN campaigns c ON e.campaign_id = c.campaign_id
    GROUP BY e.channel, c.target_audience
)

SELECT 
    channel,
    target_audience,
    n_clicks,
    n_subscribes,
    ROUND(100.0 * n_subscribes / NULLIF(n_clicks, 0), 2) AS conversion_rate
FROM conversion_rate;

-- =============================================================================
-- Miscellaneous
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
