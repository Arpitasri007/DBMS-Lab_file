-- Department Table
CREATE TABLE Department (
    department_id INT PRIMARY KEY,
    department_name VARCHAR(50) NOT NULL,
    location VARCHAR(50)
);
-- Employee Table
CREATE TABLE Employee (
    employee_id INT PRIMARY KEY,
    employee_name VARCHAR(50) NOT NULL,
    email VARCHAR(100) UNIQUE,
    salary DECIMAL(10,2),
    hire_date DATE,
    department_id INT,
    FOREIGN KEY (department_id) REFERENCES Department(department_id)
);
-- Project Table
CREATE TABLE Project (
    project_id INT PRIMARY KEY,
    project_name VARCHAR(100) NOT NULL,
    budget DECIMAL(12,2),
    department_id INT,
    FOREIGN KEY (department_id) REFERENCES Department(department_id)
);
-- Employee_Project Table
CREATE TABLE Employee_Project (
    employee_id INT,
    project_id INT,
    hours_worked INT,
    PRIMARY KEY (employee_id, project_id),
    FOREIGN KEY (employee_id) REFERENCES Employee(employee_id),
    FOREIGN KEY (project_id) REFERENCES Project(project_id)
);
INSERT INTO Department VALUES
(1, 'IT', 'Lucknow'),
(2, 'HR', 'Delhi'),
(3, 'Finance', 'Mumbai'),
(4, 'Marketing', 'Bangalore'),
(5, 'Operations', 'Pune');
INSERT INTO Employee VALUES
(101, 'Aarav Sharma', 'aarav@gmail.com', 55000, '2022-01-15', 1),
(102, 'Priya Singh', 'priya@gmail.com', 62000, '2021-03-20', 1),
(103, 'Rohan Verma', 'rohan@gmail.com', 48000, '2023-06-10', 1),
(104, 'Ananya Gupta', 'ananya@gmail.com', 75000, '2020-08-12', 1),
(105, 'Karan Mishra', 'karan@gmail.com', 58000, '2022-11-05', 1),
(106, 'Neha Kapoor', 'neha@gmail.com', 67000, '2021-09-18', 1),
(107, 'Rahul Mehta', 'rahul@gmail.com', 45000, '2023-01-10', 2),
(108, 'Sneha Jain', 'sneha@gmail.com', 52000, '2022-04-15', 2),
(109, 'Vikram Yadav', 'vikram@gmail.com', 60000, '2020-07-22', 2),
(110, 'Pooja Agarwal', 'pooja@gmail.com', 49000, '2023-05-11', 2),
(111, 'Aditya Rao', 'aditya@gmail.com', 57000, '2021-12-01', 2),
(112, 'Simran Kaur', 'simran@gmail.com', 63000, '2022-08-19', 2),
(113, 'Manish Kumar', 'manish@gmail.com', 70000, '2020-02-14', 3),
(114, 'Riya Sharma', 'riya@gmail.com', 65000, '2021-06-25', 3),
(115, 'Sahil Khan', 'sahil@gmail.com', 52000, '2023-03-18', 3),
(116, 'Ishita Roy', 'ishita@gmail.com', 78000, '2019-10-10', 3),
(117, 'Nitin Joshi', 'nitin@gmail.com', 59000, '2022-01-28', 3),
(118, 'Meera Patel', 'meera@gmail.com', 72000, '2020-11-17', 3),
(119, 'Arjun Malhotra', 'arjun@gmail.com', 54000, '2022-05-20', 4),
(120, 'Kavya Nair', 'kavya@gmail.com', 61000, '2021-08-16', 4),
(121, 'Varun Sethi', 'varun@gmail.com', 47000, '2023-02-12', 4),
(122, 'Tanya Bansal', 'tanya@gmail.com', 69000, '2020-09-30', 4),
(123, 'Mohit Saxena', 'mohit@gmail.com', 56000, '2022-12-05', 4),
(124, 'Divya Iyer', 'divya@gmail.com', 74000, '2021-04-21', 4),
(125, 'Akash Tiwari', 'akash@gmail.com', 50000, '2023-07-15', 5),
(126, 'Nisha Choudhary', 'nisha@gmail.com', 58000, '2022-03-11', 5),
(127, 'Ravi Shukla', 'ravi@gmail.com', 63000, '2020-06-19', 5),
(128, 'Aditi Pandey', 'aditi@gmail.com', 55000, '2021-10-08', 5),
(129, 'Yash Thakur', 'yash@gmail.com', 68000, '2019-12-15', 5),
(130, 'Komal Singh', 'komal@gmail.com', 46000, '2023-04-17', 5);
INSERT INTO Project VALUES
(201, 'Website Development', 500000, 1),
(202, 'Mobile Application', 750000, 1),
(203, 'Employee Management System', 400000, 2),
(204, 'Financial Analysis System', 900000, 3),
(205, 'Marketing Campaign', 350000, 4),
(206, 'Customer Analytics', 600000, 4),
(207, 'Inventory Management', 800000, 5),
(208, 'Business Automation', 1000000, 5);
INSERT INTO Employee_Project VALUES
(101, 201, 120),
(102, 201, 150),
(103, 202, 100),
(104, 202, 180),
(105, 201, 130),
(106, 202, 160),
(107, 203, 100),
(108, 203, 140),
(109, 203, 120),
(110, 203, 90),
(111, 203, 150),
(112, 203, 110),
(113, 204, 160),
(114, 204, 140),
(115, 204, 100),
(116, 204, 180),
(117, 204, 120),
(118, 204, 150),
(119, 205, 100),
(120, 205, 130),
(121, 206, 110),
(122, 206, 160),
(123, 205, 90),
(124, 206, 140),
(125, 207, 120),
(126, 207, 150),
(127, 208, 180),
(128, 207, 100),
(129, 208, 160),
(130, 208, 110);
SELECT *
FROM Employee
WHERE salary > 60000;
SELECT *
FROM Employee
WHERE department_id = 1;
SELECT employee_id, employee_name, salary
FROM Employee;
SELECT employee_name, email
FROM Employee;
SELECT COUNT(*) AS total_employees
FROM Employee;
SELECT AVG(salary) AS average_salary
FROM Employee;
SELECT MAX(salary) AS highest_salary
FROM Employee;
SELECT MIN(salary) AS lowest_salary
FROM Employee;
SELECT SUM(salary) AS total_salary
FROM Employee;
SELECT department_id, COUNT(*) AS employee_count
FROM Employee
GROUP BY department_id;
SELECT department_id, AVG(salary) AS average_salary
FROM Employee
GROUP BY department_id;
SELECT department_id, SUM(salary) AS total_salary
FROM Employee
GROUP BY department_id;
SELECT d.department_name,
       COUNT(e.employee_id) AS employee_count,
       AVG(e.salary) AS average_salary
FROM Department d
JOIN Employee e
ON d.department_id = e.department_id
GROUP BY d.department_name;
SELECT department_id, COUNT(*) AS employee_count
FROM Employee
GROUP BY department_id
HAVING COUNT(*) > 5;
SELECT department_id, AVG(salary) AS average_salary
FROM Employee
GROUP BY department_id
HAVING AVG(salary) > 60000;
SELECT employee_name,
       salary,
       CASE
           WHEN salary >= 70000 THEN 'High Salary'
           WHEN salary >= 55000 THEN 'Medium Salary'
           ELSE 'Low Salary'
       END AS salary_category
FROM Employee;
SELECT employee_name,
       department_id,
       CASE department_id
           WHEN 1 THEN 'IT'
           WHEN 2 THEN 'HR'
           WHEN 3 THEN 'Finance'
           WHEN 4 THEN 'Marketing'
           WHEN 5 THEN 'Operations'
           ELSE 'Unknown'
       END AS department_name
FROM Employee;
SELECT employee_name, salary
FROM Employee
ORDER BY salary ASC;
SELECT employee_name, salary
FROM Employee
ORDER BY salary DESC;
SELECT employee_name, department_id, salary
FROM Employee
ORDER BY department_id ASC, salary DESC;
SELECT e.employee_id,
       e.employee_name,
       d.department_name,
       e.salary
FROM Employee e
JOIN Department d
ON e.department_id = d.department_id;
SELECT e.employee_name,
       p.project_name,
       ep.hours_worked
FROM Employee e
JOIN Employee_Project ep
ON e.employee_id = ep.employee_id
JOIN Project p
ON ep.project_id = p.project_id;

SELECT 
    e.employee_id,
    e.employee_name,
    d.department_name,
    p.project_name,
    e.salary,
    ep.hours_worked,

    CASE
        WHEN e.salary >= 70000 THEN 'High Salary'
        WHEN e.salary >= 55000 THEN 'Medium Salary'
        ELSE 'Low Salary'
    END AS salary_category

FROM Employee e
JOIN Department d
    ON e.department_id = d.department_id
JOIN Employee_Project ep
    ON e.employee_id = ep.employee_id
JOIN Project p
    ON ep.project_id = p.project_id

ORDER BY d.department_name, e.salary DESC;

