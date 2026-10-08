CREATE TABLE Department (
    dept_id INT PRIMARY KEY,
    dept_name VARCHAR(50),
    location VARCHAR(50)
);
CREATE TABLE Employee (
    emp_id INT PRIMARY KEY,
    emp_name VARCHAR(50),
    manager_id INT,
    dept_id INT,
    salary DECIMAL(10,2),
    job_title VARCHAR(50),
    FOREIGN KEY (dept_id) REFERENCES Department(dept_id),
    FOREIGN KEY (manager_id) REFERENCES Employee(emp_id)
);
CREATE TABLE Project (
    project_id INT PRIMARY KEY,
    project_name VARCHAR(100),
    dept_id INT,
    FOREIGN KEY (dept_id) REFERENCES Department(dept_id)
);
-- 2. INSERT DEPARTMENTS
INSERT INTO Department VALUES
(1, 'IT', 'Lucknow'),
(2, 'HR', 'Delhi'),
(3, 'Finance', 'Mumbai'),
(4, 'Marketing', 'Pune'),
(5, 'Sales', 'Bangalore');
-- 3. INSERT EMPLOYEES
INSERT INTO Employee
(emp_id, emp_name, manager_id, dept_id, salary, job_title)
VALUES
(101, 'Rahul', NULL, 1, 80000, 'IT Manager'),
(102, 'Priya', 101, 1, 60000, 'Developer'),
(103, 'Amit', 101, 1, 55000, 'Developer'),
(104, 'Neha', 101, 1, 45000, 'Tester'),
(105, 'Ravi', NULL, 2, 70000, 'HR Manager'),
(106, 'Sneha', 105, 2, 50000, 'HR Executive'),
(107, 'Karan', 105, 2, 45000, 'Recruiter'),
(108, 'Anjali', NULL, 3, 90000, 'Finance Manager'),
(109, 'Vikas', 108, 3, 60000, 'Accountant'),
(110, 'Pooja', 108, 3, 55000, 'Accountant'),
(111, 'Rohan', NULL, 4, 75000, 'Marketing Manager'),
(112, 'Simran', 111, 4, 50000, 'Marketing Executive'),
(113, 'Arjun', NULL, 5, 85000, 'Sales Manager'),
(114, 'Meena', 113, 5, 55000, 'Sales Executive');
-- 4. INSERT PROJECTS
INSERT INTO Project VALUES
(201, 'Website Development', 1),
(202, 'Cloud Migration', 1),
(203, 'Recruitment System', 2),
(204, 'Financial Analysis', 3),
(205, 'Digital Marketing', 4),
(206, 'Sales Dashboard', 5),
(207, 'Mobile Application', 1),
(208, 'Payroll System', 2);
-- Inner join
SELECT e.emp_id, e.emp_name, d.dept_name
FROM Employee e
INNER JOIN Department d
ON e.dept_id = d.dept_id;
-- Left join
SELECT e.emp_id, e.emp_name, d.dept_name
FROM Employee e
LEFT JOIN Department d
ON e.dept_id = d.dept_id;
-- Self join
SELECT 
    e.emp_name AS Employee,
    m.emp_name AS Manager
FROM Employee e
LEFT JOIN Employee m
ON e.manager_id = m.emp_id;
-- 3 Way join
SELECT 
    e.emp_name,
    d.dept_name,
    p.project_name
FROM Employee e
INNER JOIN Department d
    ON e.dept_id = d.dept_id
INNER JOIN Project p
    ON d.dept_id = p.dept_id;
-- Correlated subquery
SELECT e.emp_id, e.emp_name, e.salary, e.dept_id
FROM Employee e
WHERE e.salary > (
    SELECT AVG(e2.salary)
    FROM Employee e2
    WHERE e2.dept_id = e.dept_id
);
-- Exists
SELECT e.emp_id, e.emp_name, e.dept_id
FROM Employee e
WHERE EXISTS (
    SELECT 1
    FROM Project p
    WHERE p.dept_id = e.dept_id
);
-- Simulating INTERSECT
SELECT emp_id
FROM Employee
WHERE dept_id = 1
INTERSECT
SELECT emp_id
FROM Employee
WHERE salary > 50000;
-- EXCEPT
SELECT emp_id
FROM Employee
WHERE dept_id = 1
EXCEPT
SELECT emp_id
FROM Employee
WHERE salary > 50000;
