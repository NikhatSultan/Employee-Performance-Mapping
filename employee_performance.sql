
-- Create Database
CREATE DATABASE IF NOT EXISTS employee;
USE employee;

-- Create Employee Table (Structure based on queries)
CREATE TABLE emp_record_table (
    EMP_ID INT PRIMARY KEY,
    FIRST_NAME VARCHAR(50),
    LAST_NAME VARCHAR(50),
    GENDER VARCHAR(10),
    DEPT VARCHAR(50),
    ROLE VARCHAR(50),
    SALARY DECIMAL(10, 2),
    EXP INT,
    EMP_RATING INT,
    COUNTRY VARCHAR(50),
    CONTINENT VARCHAR(50),
    MANAGER_ID INT
);

-- Sample Queries

-- 1. Basic SELECT
SELECT EMP_ID, FIRST_NAME, LAST_NAME, GENDER, DEPT AS DEPARTMENT FROM emp_record_table;

-- 2. Rating-based filters
SELECT EMP_ID, FIRST_NAME, LAST_NAME, GENDER, DEPT AS DEPARTMENT, EMP_RATING 
FROM emp_record_table WHERE EMP_RATING < 2;

SELECT EMP_ID, FIRST_NAME, LAST_NAME, GENDER, DEPT AS DEPARTMENT, EMP_RATING 
FROM emp_record_table WHERE EMP_RATING > 4;

SELECT EMP_ID, FIRST_NAME, LAST_NAME, GENDER, DEPT AS DEPARTMENT, EMP_RATING 
FROM emp_record_table WHERE EMP_RATING BETWEEN 2 AND 4;

-- 3. Concatenate name in Finance
SELECT CONCAT(FIRST_NAME, ' ', LAST_NAME) AS NAME 
FROM emp_record_table WHERE DEPT = 'FINANCE';

-- 4. Employees with reporters
SELECT MANAGER_ID AS EMP_ID, COUNT(*) AS NUM_REPORTERS 
FROM emp_record_table 
WHERE MANAGER_ID IS NOT NULL 
GROUP BY MANAGER_ID 
ORDER BY NUM_REPORTERS DESC;

-- 5. Union of Healthcare and Finance
SELECT EMP_ID, FIRST_NAME, LAST_NAME, GENDER, DEPT AS DEPARTMENT 
FROM emp_record_table WHERE DEPT = 'HEALTHCARE'
UNION
SELECT EMP_ID, FIRST_NAME, LAST_NAME, GENDER, DEPT AS DEPARTMENT 
FROM emp_record_table WHERE DEPT = 'FINANCE';

-- 6. Group by dept with max rating
SELECT EMP_ID, FIRST_NAME, LAST_NAME, ROLE, DEPT AS DEPARTMENT, EMP_RATING,
MAX(EMP_RATING) OVER (PARTITION BY DEPT) AS MAX_EMP_RATING
FROM emp_record_table 
ORDER BY DEPT, EMP_RATING DESC;

-- 7. Min and Max salary per role
SELECT ROLE, MIN(SALARY) AS MIN_SALARY, MAX(SALARY) AS MAX_SALARY 
FROM emp_record_table 
GROUP BY ROLE 
ORDER BY ROLE;

-- 8. Rank employees by experience
SELECT EMP_ID, FIRST_NAME, LAST_NAME, ROLE, DEPT AS DEPARTMENT, EXP AS EXPERIENCE,
RANK() OVER (ORDER BY EXP DESC) AS RANK 
FROM emp_record_table;

-- 9. Create a view for high salary
CREATE VIEW HighSalaryEmployees AS 
SELECT EMP_ID, FIRST_NAME, LAST_NAME, GENDER, DEPT AS DEPARTMENT, COUNTRY, SALARY 
FROM emp_record_table WHERE SALARY > 6000;

-- Select from view
SELECT * FROM HighSalaryEmployees;

-- 10. Nested query: Experience > 10
SELECT EMP_ID, FIRST_NAME, LAST_NAME, ROLE, DEPT AS DEPARTMENT, EXP AS EXPERIENCE 
FROM emp_record_table WHERE EXP > (SELECT 10);

-- 11. Stored procedure: Experience > 3
DELIMITER $$
CREATE PROCEDURE GetEmployeesWithExperience()
BEGIN
    SELECT EMP_ID, FIRST_NAME, LAST_NAME, ROLE, DEPT AS DEPARTMENT, EXP AS EXPERIENCE 
    FROM emp_record_table WHERE EXP > 3;
END $$
DELIMITER ;

-- 12. Stored function: Check job profile
DELIMITER $$
CREATE FUNCTION CheckJobProfile(exp INT) RETURNS VARCHAR(50)
DETERMINISTIC
BEGIN
    DECLARE job_profile VARCHAR(50);
    IF exp <= 2 THEN
        SET job_profile = 'JUNIOR DATA SCIENTIST';
    ELSEIF exp > 2 AND exp <= 5 THEN
        SET job_profile = 'ASSOCIATE DATA SCIENTIST';
    ELSEIF exp > 5 AND exp <= 10 THEN
        SET job_profile = 'SENIOR DATA SCIENTIST';
    ELSEIF exp > 10 AND exp <= 12 THEN
        SET job_profile = 'LEAD DATA SCIENTIST';
    ELSEIF exp > 12 AND exp <= 16 THEN
        SET job_profile = 'MANAGER';
    ELSE
        SET job_profile = 'OTHER';
    END IF;
    RETURN job_profile;
END $$
DELIMITER ;

-- Use the function
SELECT EMP_ID, FIRST_NAME, LAST_NAME, EXP AS EXPERIENCE, ROLE AS ASSIGNED_ROLE,
CheckJobProfile(EXP) AS STANDARD_ROLE,
CASE 
    WHEN ROLE = CheckJobProfile(EXP) THEN 'MATCH'
    ELSE 'MISMATCH'
END AS VALIDATION_STATUS
FROM emp_record_table;

-- 13. Index creation
-- Before: check execution plan
EXPLAIN SELECT * FROM emp_record_table WHERE FIRST_NAME = 'Eric';

-- Create index
CREATE INDEX idx_first_name ON emp_record_table (FIRST_NAME);

-- After: recheck execution plan
EXPLAIN SELECT * FROM emp_record_table WHERE FIRST_NAME = 'Eric';

-- 14. Bonus calculation
SELECT EMP_ID, FIRST_NAME, LAST_NAME, SALARY, EMP_RATING, 
(SALARY * 0.05 * EMP_RATING) AS BONUS 
FROM emp_record_table;

-- 15. Average salary by continent and country
SELECT CONTINENT, COUNTRY, AVG(SALARY) AS AVG_SALARY 
FROM emp_record_table 
GROUP BY CONTINENT, COUNTRY 
ORDER BY CONTINENT, COUNTRY;
