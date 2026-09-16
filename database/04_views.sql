CREATE OR REPLACE VIEW vw_employee_payroll AS
SELECT
    p.payroll_id,
    p.pay_month,
    e.employee_id,
    e.first_name || ' ' || e.last_name AS employee_name,
    e.job_title,
    d.department_name,
    p.gross_salary,
    p.tax,
    p.provident_fund,
    p.other_deductions,
    p.net_salary,
    ROUND((p.tax + p.provident_fund + p.other_deductions) / NULLIF(p.gross_salary, 0) * 100, 2)
        AS deduction_percentage
FROM payroll p
JOIN employees e ON e.employee_id = p.employee_id
JOIN departments d ON d.department_id = e.department_id;

CREATE OR REPLACE VIEW vw_department_payroll AS
SELECT
    p.pay_month,
    d.department_id,
    d.department_name,
    COUNT(*) AS employees_paid,
    SUM(p.gross_salary) AS total_gross_salary,
    SUM(p.net_salary) AS total_net_salary,
    AVG(p.net_salary) AS average_net_salary
FROM payroll p
JOIN employees e ON e.employee_id = p.employee_id
JOIN departments d ON d.department_id = e.department_id
GROUP BY p.pay_month, d.department_id, d.department_name;
