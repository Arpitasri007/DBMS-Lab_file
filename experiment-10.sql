DROP TABLE IF EXISTS BenchmarkResults;
DROP TABLE IF EXISTS RailwayBooking;
-- 1. CREATE TABLE
CREATE TABLE RailwayBooking (
    booking_id INT PRIMARY KEY,
    pnr VARCHAR(20) NOT NULL UNIQUE,
    passenger_name VARCHAR(100) NOT NULL,
    train_no INT NOT NULL,
    source_station VARCHAR(50) NOT NULL,
    destination_station VARCHAR(50) NOT NULL,
    journey_date DATE NOT NULL,
    booking_status VARCHAR(20) NOT NULL,
    seat_no INT,
    fare DECIMAL(10,2) NOT NULL
);
-- 2. GENERATE 12,000 RECORDS
INSERT INTO RailwayBooking
SELECT
    n + 1,
    CONCAT('PNR', LPAD(n + 1, 10, '0')),
    CONCAT('Passenger_', n + 1),
    12000 + MOD(n, 100),
    CASE MOD(n, 6)
        WHEN 0 THEN 'Lucknow'
        WHEN 1 THEN 'Delhi'
        WHEN 2 THEN 'Mumbai'
        WHEN 3 THEN 'Kanpur'
        WHEN 4 THEN 'Jaipur'
        ELSE 'Bhopal'
    END,
    CASE MOD(n, 6)
        WHEN 0 THEN 'Delhi'
        WHEN 1 THEN 'Lucknow'
        WHEN 2 THEN 'Pune'
        WHEN 3 THEN 'Agra'
        WHEN 4 THEN 'Chennai'
        ELSE 'Kolkata'
    END,
    DATE_ADD('2024-01-01', INTERVAL MOD(n,1095) DAY),
    CASE MOD(n,4)
        WHEN 0 THEN 'Confirmed'
        WHEN 1 THEN 'Waiting'
        WHEN 2 THEN 'Cancelled'
        ELSE 'RAC'
    END,
    1 + MOD(n,72),
    250 + MOD(n*37,1750)
FROM (
    SELECT a.d + 10*b.d + 100*c.d + 1000*d.d
           + 10000*e.d AS n
    FROM
    (SELECT 0 d UNION ALL SELECT 1 UNION ALL SELECT 2
     UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL
     SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7
     UNION ALL SELECT 8 UNION ALL SELECT 9) a
    CROSS JOIN
    (SELECT 0 d UNION ALL SELECT 1 UNION ALL SELECT 2
     UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL
     SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7
     UNION ALL SELECT 8 UNION ALL SELECT 9) b
    CROSS JOIN
    (SELECT 0 d UNION ALL SELECT 1 UNION ALL SELECT 2
     UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL
     SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7
     UNION ALL SELECT 8 UNION ALL SELECT 9) c
    CROSS JOIN
    (SELECT 0 d UNION ALL SELECT 1 UNION ALL SELECT 2
     UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL
     SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7
     UNION ALL SELECT 8 UNION ALL SELECT 9) d
    CROSS JOIN
    (SELECT 0 d UNION ALL SELECT 1 UNION ALL SELECT 2
     UNION ALL SELECT 3 UNION ALL SELECT 4 UNION ALL
     SELECT 5 UNION ALL SELECT 6 UNION ALL SELECT 7
     UNION ALL SELECT 8 UNION ALL SELECT 9) e
) AS nums
WHERE n < 12000;
SELECT COUNT(*) AS total_records FROM RailwayBooking;
ANALYZE TABLE RailwayBooking;
-- 3. BENCHMARK TABLE
CREATE TABLE BenchmarkResults (
    query_no INT,
    query_description VARCHAR(100),
    stage VARCHAR(30),
    execution_time_ms DECIMAL(12,3)
);
-- 4. FIVE QUERIES BEFORE OPTIMIZATION
-- EXPLAIN ANALYZE shows the execution plan and timing.
-- Save the reported times for comparison.
EXPLAIN ANALYZE
SELECT * FROM RailwayBooking
WHERE train_no = 12015;
EXPLAIN ANALYZE
SELECT * FROM RailwayBooking
WHERE train_no = 12015
  AND journey_date = '2025-02-15'
  AND booking_status = 'Confirmed';
EXPLAIN ANALYZE
SELECT * FROM RailwayBooking
WHERE YEAR(journey_date) = 2025;
EXPLAIN ANALYZE
SELECT * FROM RailwayBooking
WHERE LOWER(source_station) = 'lucknow'
  AND booking_status = 'Confirmed';
-- Use EXPLAIN here: executing this correlated query before indexing can time out.
EXPLAIN
SELECT b.booking_id, b.train_no, b.fare
FROM RailwayBooking b
WHERE b.fare > (
    SELECT AVG(b2.fare)
    FROM RailwayBooking b2
    WHERE b2.train_no = b.train_no
);
-- 5. CREATE INDEXES
CREATE INDEX idx_train
ON RailwayBooking(train_no);
CREATE INDEX idx_train_date_status
ON RailwayBooking(train_no, journey_date, booking_status);
CREATE INDEX idx_journey_date
ON RailwayBooking(journey_date);
CREATE INDEX idx_station_status
ON RailwayBooking(source_station, booking_status);
CREATE INDEX idx_train_fare
ON RailwayBooking(train_no, fare);
ANALYZE TABLE RailwayBooking;
-- 6. FIVE OPTIMIZED QUERIES
-- Query 1: Single-column index
EXPLAIN ANALYZE
SELECT * FROM RailwayBooking
WHERE train_no = 12015;
-- Query 2: Composite index
EXPLAIN ANALYZE
SELECT * FROM RailwayBooking
WHERE train_no = 12015
  AND journey_date = '2025-02-15'
  AND booking_status = 'Confirmed';
-- Query 3: Rewrite YEAR() as a date range
EXPLAIN ANALYZE
SELECT * FROM RailwayBooking
WHERE journey_date >= '2025-01-01'
  AND journey_date < '2026-01-01';
-- Query 4: Remove LOWER() from the indexed column
EXPLAIN ANALYZE
SELECT * FROM RailwayBooking
WHERE source_station = 'Lucknow'
  AND booking_status = 'Confirmed';
-- Query 5: Replace correlated subquery with grouped derived table
EXPLAIN ANALYZE
SELECT b.booking_id, b.train_no, b.fare
FROM RailwayBooking b
JOIN (
    SELECT train_no, AVG(fare) AS avg_fare
    FROM RailwayBooking
    GROUP BY train_no
) AS t ON t.train_no = b.train_no
WHERE b.fare > t.avg_fare;
-- 7. VERIFY INDEXES AND DATA
SELECT COUNT(*) AS total_records FROM RailwayBooking;
SHOW INDEX FROM RailwayBooking;
-- 8. BENCHMARK REPORT TEMPLATE
-- Enter actual timings from EXPLAIN ANALYZE manually.
SELECT
    'Query 1: Train search' AS query_name,
    'Record original and optimized timings above' AS result
UNION ALL
SELECT
    'Query 2: Train/date/status',
    'Compare rows examined and execution time'
UNION ALL
SELECT
    'Query 3: Journey year',
    'Compare function predicate against date range'
UNION ALL
SELECT
    'Query 4: Station/status',
    'Compare LOWER() against indexed equality'
UNION ALL
SELECT
    'Query 5: Average fare',
    'Compare correlated subquery against grouped join';
