-- 1. Create Department table
DROP TABLE IF EXISTS Salary_Audit;
DROP TABLE IF EXISTS Employee;
DROP TABLE IF EXISTS Department;
CREATE TABLE Department (
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(50) NOT NULL,
    location VARCHAR(50)
);
-- 2. Create Employee table
CREATE TABLE Employee (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(100) NOT NULL,
    job_title VARCHAR(50),
    salary DECIMAL(10,2),
    dept_id INT,
    manager_id INT NULL,
    FOREIGN KEY (dept_id) REFERENCES Department(dept_id),
    FOREIGN KEY (manager_id) REFERENCES Employee(emp_id)
);
-- 3. Insert departments
INSERT INTO Department VALUES
(1, 'IT', 'Lucknow'),
(2, 'HR', 'Delhi'),
(3, 'Finance', 'Mumbai'),
(4, 'Marketing', 'Pune'),
(5, 'Sales', 'Bangalore');
-- 4. Insert employees
INSERT INTO Employee VALUES
(101, 'Rahul', 'CEO', 150000, 1, NULL),
(102, 'Priya', 'IT Manager', 100000, 1, 101),
(103, 'Amit', 'Senior Developer', 80000, 1, 102),
(104, 'Neha', 'Developer', 60000, 1, 102),
(105, 'Ravi', 'HR Manager', 95000, 2, 101),
(106, 'Sneha', 'HR Executive', 55000, 2, 105),
(107, 'Vikas', 'Finance Manager', 90000, 3, 101),
(108, 'Pooja', 'Accountant', 50000, 3, 107),
(109, 'Karan', 'Marketing Manager', 85000, 4, 101),
(110, 'Anjali', 'Marketing Executive', 50000, 4, 109),
(111, 'Arjun', 'Sales Manager', 88000, 5, 101),
(112, 'Meena', 'Sales Executive', 48000, 5, 111);
-- 5. Create Salary Audit table
CREATE TABLE Salary_Audit (
    audit_id INT AUTO_INCREMENT PRIMARY KEY,
    emp_id INT,
    old_salary DECIMAL(10,2),
    new_salary DECIMAL(10,2),
    changed_at TIMESTAMP DEFAULT CURRENT_TIMESTAMP,
    action VARCHAR(50)
);
DELIMITER //
CREATE TRIGGER validate_salary_insert
BEFORE INSERT ON Employee
FOR EACH ROW
BEGIN
    IF NEW.salary <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Salary must be greater than zero';
    END IF;
END //
DELIMITER ;
DELIMITER //
CREATE TRIGGER validate_salary_update
BEFORE UPDATE ON Employee
FOR EACH ROW
BEGIN
    IF NEW.salary <= 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Salary must be greater than zero';
    END IF;
END //
DELIMITER ;
DELIMITER //
CREATE TRIGGER salary_audit
AFTER UPDATE ON Employee
FOR EACH ROW
BEGIN
    IF OLD.salary <> NEW.salary THEN
        INSERT INTO Salary_Audit
        (
            emp_id,
            old_salary,
            new_salary,
            action
        )
        VALUES
        (
            OLD.emp_id,
            OLD.salary,
            NEW.salary,
            'SALARY UPDATED'
        );
    END IF;
END //
DELIMITER ;
DELIMITER //
CREATE PROCEDURE transfer_employee(
    IN p_emp_id INT,
    IN p_new_dept_id INT
)
BEGIN
    DECLARE v_old_dept_id INT;
    DECLARE v_emp_exists INT DEFAULT 0;
    DECLARE v_dept_exists INT DEFAULT 0;
    -- Error handling
    DECLARE EXIT HANDLER FOR SQLEXCEPTION
    BEGIN
        ROLLBACK;
        RESIGNAL;
    END;
    START TRANSACTION;
    -- Check employee
    SELECT COUNT(*)
    INTO v_emp_exists
    FROM Employee
    WHERE emp_id = p_emp_id;
    IF v_emp_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Employee does not exist';
    END IF;
    -- Check department
    SELECT COUNT(*)
    INTO v_dept_exists
    FROM Department
    WHERE dept_id = p_new_dept_id;
    IF v_dept_exists = 0 THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT = 'Department does not exist';
    END IF;
    -- Find current department
    SELECT dept_id
    INTO v_old_dept_id
    FROM Employee
    WHERE emp_id = p_emp_id;
    -- Check same department
    IF v_old_dept_id = p_new_dept_id THEN
        SIGNAL SQLSTATE '45000'
        SET MESSAGE_TEXT =
        'Employee is already in this department';
    END IF;
    -- Transfer employee
    UPDATE Employee
    SET dept_id = p_new_dept_id
    WHERE emp_id = p_emp_id;
    COMMIT;
    SELECT
        'Employee transferred successfully' AS message,
        p_emp_id AS employee_id,
        v_old_dept_id AS old_department,
        p_new_dept_id AS new_department;
END //
DELIMITER ;
CALL transfer_employee(103, 2);
-- Check employee after transfer
SELECT
    emp_id,
    emp_name,
    dept_id
FROM Employee
WHERE emp_id = 103;
UPDATE Employee
SET salary = 85000
WHERE emp_id = 103;
-- Check updated salary
SELECT
    emp_id,
    emp_name,
    salary
FROM Employee
WHERE emp_id = 103;
-- Check salary audit
SELECT *
FROM Salary_Audit;
-- UPDATE Employee
-- SET salary = -5000
-- WHERE emp_id = 103;
-- Expected:
-- ERROR: Salary must be greater than zero 
-- CALL transfer_employee(999, 2);
-- Expected:
-- ERROR: Employee does not exist
-- CALL transfer_employee(104, 99);
-- Expected:
-- ERROR: Department does not exist
-- CALL transfer_employee(103, 2);
-- Expected:
-- ERROR: Employee is already in this department
SELECT
    e.emp_id,
    e.emp_name,
    e.job_title,
    e.salary,
    d.dept_name,
    e.manager_id
FROM Employee e
JOIN Department d
    ON e.dept_id = d.dept_id
ORDER BY e.emp_id;
SELECT
    audit_id,
    emp_id,
    old_salary,
    new_salary,
    changed_at,
    action
FROM Salary_Audit
ORDER BY audit_id;
