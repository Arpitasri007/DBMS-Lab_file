-- RAILWAY BOOKING SYSTEM: INDEXING PERFORMANCE ANALYSIS
-- MySQL 8.0+
-- CREATE DATABASE AND TABLE
DROP TABLE IF EXISTS RailwayBooking;
CREATE TABLE RailwayBooking (
    booking_id INT PRIMARY KEY,
    pnr VARCHAR(15) NOT NULL UNIQUE,
    passenger_name VARCHAR(100) NOT NULL,
    train_no INT NOT NULL,
    source_station VARCHAR(50) NOT NULL,
    destination_station VARCHAR(50) NOT NULL,
    journey_date DATE NOT NULL,
    booking_status VARCHAR(20) NOT NULL,
    seat_no INT,
    fare DECIMAL(10,2) NOT NULL
);
--  INSERT 6000 AUTOMATICALLY GENERATED RECORDS
INSERT INTO RailwayBooking
(
    booking_id, pnr, passenger_name, train_no,
    source_station, destination_station,
    journey_date, booking_status, seat_no, fare
)
SELECT
    n + 1,
    CONCAT('PNR', LPAD(n + 1, 10, '0')),
    CONCAT('Passenger_', n + 1),
    12000 + MOD(n, 50),
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
    DATE_ADD('2026-01-01', INTERVAL MOD(n, 365) DAY),
    CASE MOD(n, 4)
        WHEN 0 THEN 'Confirmed'
        WHEN 1 THEN 'Waiting'
        WHEN 2 THEN 'Cancelled'
        ELSE 'RAC'
    END,
    1 + MOD(n, 72),
    250 + MOD(n * 37, 1750)
FROM
    (SELECT
        a.d + 10*b.d + 100*c.d + 1000*d.d AS n
     FROM
        (SELECT 0 d UNION ALL SELECT 1 UNION ALL
         SELECT 2 UNION ALL SELECT 3 UNION ALL
         SELECT 4 UNION ALL SELECT 5 UNION ALL
         SELECT 6 UNION ALL SELECT 7 UNION ALL
         SELECT 8 UNION ALL SELECT 9) a
     CROSS JOIN
        (SELECT 0 d UNION ALL SELECT 1 UNION ALL
         SELECT 2 UNION ALL SELECT 3 UNION ALL
         SELECT 4 UNION ALL SELECT 5 UNION ALL
         SELECT 6 UNION ALL SELECT 7 UNION ALL
         SELECT 8 UNION ALL SELECT 9) b
     CROSS JOIN
        (SELECT 0 d UNION ALL SELECT 1 UNION ALL
         SELECT 2 UNION ALL SELECT 3 UNION ALL
         SELECT 4 UNION ALL SELECT 5 UNION ALL
         SELECT 6 UNION ALL SELECT 7 UNION ALL
         SELECT 8 UNION ALL SELECT 9) c
     CROSS JOIN
        (SELECT 0 d UNION ALL SELECT 1 UNION ALL
         SELECT 2 UNION ALL SELECT 3 UNION ALL
         SELECT 4 UNION ALL SELECT 5 UNION ALL
         SELECT 6 UNION ALL SELECT 7 UNION ALL
         SELECT 8 UNION ALL SELECT 9) d
    ) numbers
WHERE n < 6000
ORDER BY n;
-- Verify the number of records
SELECT COUNT(*) AS total_bookings
FROM RailwayBooking;
-- View sample records
SELECT * FROM RailwayBooking
LIMIT 10;
-- BENCHMARK BEFORE CREATING INDEXES
-- Query 1: Search bookings by train number
EXPLAIN
SELECT *
FROM RailwayBooking
WHERE train_no = 12015;
-- Actual execution time and plan (MySQL 8.0.18+)
EXPLAIN ANALYZE
SELECT *
FROM RailwayBooking
WHERE train_no = 12015;
-- Query 2: Search by train number and journey date
EXPLAIN
SELECT *
FROM RailwayBooking
WHERE train_no = 12015
  AND journey_date = '2026-02-15';
EXPLAIN ANALYZE
SELECT *
FROM RailwayBooking
WHERE train_no = 12015
  AND journey_date = '2026-02-15';
-- CREATE A SINGLE-COLUMN INDEX
CREATE INDEX idx_train_no
ON RailwayBooking(train_no);
-- Inspect existing indexes
SHOW INDEX FROM RailwayBooking;
-- Benchmark with single-column index
EXPLAIN
SELECT *
FROM RailwayBooking
WHERE train_no = 12015;
EXPLAIN ANALYZE
SELECT *
FROM RailwayBooking
WHERE train_no = 12015;
-- Two-column query with only the single-column index
EXPLAIN
SELECT *
FROM RailwayBooking
WHERE train_no = 12015
  AND journey_date = '2026-02-15';
EXPLAIN ANALYZE
SELECT *
FROM RailwayBooking
WHERE train_no = 12015
  AND journey_date = '2026-02-15';
-- CREATE A COMPOSITE INDEX
CREATE INDEX idx_train_date
ON RailwayBooking(train_no, journey_date);
SHOW INDEX FROM RailwayBooking;
-- Benchmark the single-column search again
EXPLAIN
SELECT *
FROM RailwayBooking
WHERE train_no = 12015;
EXPLAIN ANALYZE
SELECT *
FROM RailwayBooking
WHERE train_no = 12015;
-- Benchmark the two-column search
EXPLAIN
SELECT *
FROM RailwayBooking
WHERE train_no = 12015
  AND journey_date = '2026-02-15';
EXPLAIN ANALYZE
SELECT *
FROM RailwayBooking
WHERE train_no = 12015
  AND journey_date = '2026-02-15';
-- ADDITIONAL PERFORMANCE TESTS
-- Search bookings by date range
EXPLAIN ANALYZE
SELECT booking_id, train_no, journey_date, booking_status
FROM RailwayBooking
WHERE train_no = 12015
  AND journey_date BETWEEN '2026-02-01' AND '2026-02-28';
-- Count bookings by train
EXPLAIN ANALYZE
SELECT train_no, COUNT(*) AS total_bookings
FROM RailwayBooking
WHERE train_no = 12015
GROUP BY train_no;
-- Refresh table statistics for the optimizer
ANALYZE TABLE RailwayBooking;
-- Final index list
SHOW INDEX FROM RailwayBooking;
