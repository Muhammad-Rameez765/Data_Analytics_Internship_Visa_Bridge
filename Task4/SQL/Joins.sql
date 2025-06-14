# Inner Join

SELECT 
    s.EmployeeID,
    s.SatisfactionScore,
    s.WorkLifeBalance,
    s.Salary,
    s.YearsAtCompany,
    s.Department,
    h.Age,
    h.Gender,
    h.JobLevel,
    h.Turnover
FROM employee_satisfaction.cemployeesurvey AS s
INNER JOIN employee_satisfaction.hrrecords AS h
    ON s.EmployeeID = h.EmployeeID;

# Left Join

SELECT 
    s.EmployeeID,
    s.SatisfactionScore,
    s.WorkLifeBalance,
    s.Salary,
    s.YearsAtCompany,
    s.Department,
    h.Age,
    h.Gender,
    h.JobLevel,
    h.Turnover
FROM employee_satisfaction.cemployeesurvey AS s
LEFT JOIN employee_satisfaction.hrrecords AS h
    ON s.EmployeeID = h.EmployeeID;

