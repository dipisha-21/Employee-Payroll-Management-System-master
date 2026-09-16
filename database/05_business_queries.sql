-- 1. Department payroll cost
SELECT department_name, SUM(net_salary) total_net_payroll
FROM vw_employee_payroll
GROUP BY department_name
ORDER BY total_net_payroll DESC;

-- 2. Top three earners in every department (window function)
SELECT department_name, employee_name, net_salary, salary_rank
FROM (
    SELECT department_name, employee_name, net_salary,
           DENSE_RANK() OVER (PARTITION BY department_name ORDER BY net_salary DESC) salary_rank
    FROM vw_employee_payroll
)
WHERE salary_rank <= 3
ORDER BY department_name, salary_rank;

-- 3. Monthly payroll trend
SELECT pay_month,
       SUM(gross_salary) gross_payroll,
       SUM(net_salary) net_payroll,
       SUM(gross_salary - net_salary) deductions
FROM payroll
GROUP BY pay_month
ORDER BY pay_month;

-- 4. Employees with above-department-average pay
SELECT employee_name, department_name, net_salary
FROM (
    SELECT employee_name, department_name, net_salary,
           AVG(net_salary) OVER (PARTITION BY department_name) dept_avg
    FROM vw_employee_payroll
)
WHERE net_salary > dept_avg
ORDER BY department_name, net_salary DESC;

-- 5. Payroll audit history
SELECT a.audit_id, a.employee_id,
       e.first_name || ' ' || e.last_name employee_name,
       a.action_type, a.old_net_salary, a.new_net_salary,
       a.changed_at, a.changed_by
FROM payroll_audit a
JOIN employees e ON e.employee_id = a.employee_id
ORDER BY a.changed_at DESC;
