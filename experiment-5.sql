CREATE TABLE Department (
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(50),
    location VARCHAR(50)
);
CREATE TABLE Employee (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(100),
    job_title VARCHAR(50),
    salary DECIMAL(10,2),
    dept_id INT,
    manager_id INT NULL,
    FOREIGN KEY (dept_id) REFERENCES Department(dept_id),
    FOREIGN KEY (manager_id) REFERENCES Employee(emp_id)
);
INSERT INTO Department VALUES
(1, 'IT', 'Lucknow'),
(2, 'HR', 'Delhi'),
(3, 'Finance', 'Mumbai'),
(4, 'Marketing', 'Pune'),
(5, 'Sales', 'Bangalore');
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
CREATE VIEW Department_Salary_Summary AS
SELECT
    d.dept_id,
    d.dept_name,
    COUNT(e.emp_id) AS employee_count,
    SUM(e.salary) AS total_salary,
    AVG(e.salary) AS average_salary,
    MIN(e.salary) AS minimum_salary,
    MAX(e.salary) AS maximum_salary
FROM Department d
LEFT JOIN Employee e
    ON d.dept_id = e.dept_id
GROUP BY d.dept_id, d.dept_name;
SELECT * FROM Department_Salary_Summary;
CREATE VIEW Employee_Hierarchy AS
SELECT
    e.emp_id,
    e.emp_name,
    e.job_title,
    e.salary,
    d.dept_name,
    e.manager_id,
    m.emp_name AS manager_name
FROM Employee e
LEFT JOIN Department d
    ON e.dept_id = d.dept_id
LEFT JOIN Employee m
    ON e.manager_id = m.emp_id;
SELECT * FROM Employee_Hierarchy;
UPDATE Employee
SET salary = 65000
WHERE emp_id = 104;
SELECT * FROM Employee
WHERE emp_id = 104;
CREATE VIEW IT_Employees AS
SELECT
    emp_id,
    emp_name,
    job_title,
    salary,
    dept_id,
    manager_id
FROM Employee
WHERE dept_id = 1;
SELECT * FROM IT_Employees;
UPDATE IT_Employees
SET salary = 85000
WHERE emp_id = 103;
SELECT *
FROM Employee
WHERE emp_id = 103;
WITH RECURSIVE ReportingChain AS
(
    -- Anchor member
    SELECT
        emp_id,
        emp_name,
        manager_id,
        0 AS level,
        CAST(emp_name AS CHAR(500)) AS reporting_chain
    FROM Employee
    WHERE manager_id IS NULL
    UNION ALL
    -- Recursive member
    SELECT
        e.emp_id,
        e.emp_name,
        e.manager_id,
        rc.level + 1,
        CONCAT(rc.reporting_chain, ' -> ', e.emp_name)
    FROM Employee e
    INNER JOIN ReportingChain rc
        ON e.manager_id = rc.emp_id
)
SELECT
    emp_id,
    emp_name,
    manager_id,
    level,
    reporting_chain
FROM ReportingChain
ORDER BY reporting_chain;
WITH RECURSIVE ReportingChain AS
(
    SELECT
        emp_id,
        emp_name,
        manager_id,
        0 AS level
    FROM Employee
    WHERE emp_id = 103
    UNION ALL
    SELECT
        e.emp_id,
        e.emp_name,
        e.manager_id,
        rc.level + 1
    FROM Employee e
    JOIN ReportingChain rc
        ON e.emp_id = rc.manager_id
)
SELECT
    level,
    emp_id,
    emp_name,
    manager_id
FROM ReportingChain
ORDER BY level;
