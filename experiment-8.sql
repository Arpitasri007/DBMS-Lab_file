-- BANKING TRANSACTIONS AND CONCURRENCY DEMONSTRATION
-- Database: MySQL 8.0+
DROP TABLE IF EXISTS Transactions;
DROP TABLE IF EXISTS Accounts;
CREATE TABLE Accounts (
    account_id INT PRIMARY KEY,
    account_holder VARCHAR(50) NOT NULL,
    balance DECIMAL(12,2) NOT NULL,
    CHECK (balance >= 0)
) ENGINE = InnoDB;
CREATE TABLE Transactions (
    transaction_id INT AUTO_INCREMENT PRIMARY KEY,
    from_account INT,
    to_account INT,
    amount DECIMAL(12,2) NOT NULL,
    status VARCHAR(20) NOT NULL,
    transaction_time TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    FOREIGN KEY (from_account) REFERENCES Accounts(account_id),
    FOREIGN KEY (to_account) REFERENCES Accounts(account_id)
) ENGINE = InnoDB;
INSERT INTO Accounts VALUES
(101, 'Amit', 10000.00),
(102, 'Neha', 5000.00),
(103, 'Rahul', 8000.00);
-- 1. SUCCESSFUL TRANSFER USING BEGIN AND COMMIT
-- Transfer 2000 from Amit to Neha
START TRANSACTION;
UPDATE Accounts
SET balance = balance - 2000
WHERE account_id = 101 AND balance >= 2000;
UPDATE Accounts
SET balance = balance + 2000
WHERE account_id = 102;
INSERT INTO Transactions
(from_account, to_account, amount, status)
VALUES (101, 102, 2000, 'SUCCESS');
COMMIT;
SELECT 'After successful transfer' AS Stage;
SELECT * FROM Accounts;
-- 2. ROLLBACK AFTER A SIMULATED PARTIAL FAILURE
-- Amit's deduction is undone
START TRANSACTION;
UPDATE Accounts
SET balance = balance - 1000
WHERE account_id = 101 AND balance >= 1000;
-- Simulated failure before crediting the receiver.
ROLLBACK;
SELECT 'After rollback' AS Stage;
SELECT * FROM Accounts;
-- 3. SAVEPOINT AND PARTIAL ROLLBACK
-- First transfer is retained; second is cancelled
START TRANSACTION;
-- Transfer 1000 from Amit to Neha
UPDATE Accounts
SET balance = balance - 1000
WHERE account_id = 101 AND balance >= 1000;
UPDATE Accounts
SET balance = balance + 1000
WHERE account_id = 102;
SAVEPOINT first_transfer_done;
INSERT INTO Transactions
(from_account, to_account, amount, status)
VALUES (101, 102, 1000, 'SUCCESS');
-- Attempt a second transfer from Neha to Rahul
UPDATE Accounts
SET balance = balance - 500
WHERE account_id = 102 AND balance >= 500;
UPDATE Accounts
SET balance = balance + 500
WHERE account_id = 103;
-- Simulate failure: undo everything after the savepoint.
ROLLBACK TO SAVEPOINT first_transfer_done;
-- Record only the successful first transfer.
-- Remove the earlier uncommitted log entry.
-- The log entry was inserted after the savepoint, so undo it
-- by rolling back to the savepoint and inserting it again.
INSERT INTO Transactions
(from_account, to_account, amount, status)
VALUES (101, 102, 1000, 'SUCCESS');
COMMIT;
SELECT 'After savepoint demonstration' AS Stage;
SELECT * FROM Accounts;
SELECT * FROM Transactions;
-- 4. SET AND DISPLAY ISOLATION LEVEL
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;
SELECT @@transaction_isolation AS Current_Isolation_Level;
-- 5. DIRTY READ DEMONSTRATION
-- Run Session 1 and Session 2 separately.
-- SESSION 1:
-- START TRANSACTION;
-- UPDATE Accounts SET balance = 6000 WHERE account_id = 103;
-- Do not commit.
--
-- SESSION 2:
-- SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
-- START TRANSACTION;
-- SELECT balance FROM Accounts WHERE account_id = 103;
-- COMMIT;
--
-- SESSION 1:
-- ROLLBACK;
-- 6. NON-REPEATABLE READ DEMONSTRATION
-- SESSION 1:
-- SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;
-- START TRANSACTION;
-- SELECT balance FROM Accounts WHERE account_id = 102;
--
-- SESSION 2:
-- START TRANSACTION;
-- UPDATE Accounts SET balance = balance + 500
-- WHERE account_id = 102;
-- COMMIT;
--
-- SESSION 1:
-- SELECT balance FROM Accounts WHERE account_id = 102;
-- COMMIT;
-- The two SELECT results may differ.
-- 7. LOST UPDATE DEMONSTRATION
-- Use only in two separate sessions.
--
-- SESSION 1:
-- SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;
-- START TRANSACTION;
-- SELECT balance FROM Accounts WHERE account_id = 103;
-- Assume balance = 8000 and calculate 9000.
--
-- SESSION 2:
-- SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;
-- START TRANSACTION;
-- SELECT balance FROM Accounts WHERE account_id = 103;
-- UPDATE Accounts SET balance = 10000 WHERE account_id = 103;
-- COMMIT;
--
-- SESSION 1, after Session 2 commits:
-- UPDATE Accounts SET balance = 9000 WHERE account_id = 103;
-- COMMIT;
-- The final value becomes 9000, overwriting Session 2's update.
-- 8. COMPARE ISOLATION LEVELS
SET SESSION TRANSACTION ISOLATION LEVEL READ UNCOMMITTED;
SELECT @@transaction_isolation AS Isolation_Level;
SET SESSION TRANSACTION ISOLATION LEVEL READ COMMITTED;
SELECT @@transaction_isolation AS Isolation_Level;
SET SESSION TRANSACTION ISOLATION LEVEL REPEATABLE READ;
SELECT @@transaction_isolation AS Isolation_Level;
SET SESSION TRANSACTION ISOLATION LEVEL SERIALIZABLE;
SELECT @@transaction_isolation AS Isolation_Level;
-- 9. FINAL OUTPUT
SELECT account_id, account_holder, balance
FROM Accounts
ORDER BY account_id;
SELECT *
FROM Transactions
ORDER BY transaction_id;
