-- Run after loading the schema and generated sample data.

-- Expected: 120
SELECT COUNT(*) AS employee_count FROM employees;

-- Expected: 0 (no orphan employees)
SELECT COUNT(*) AS orphan_employees
FROM employees e
LEFT JOIN departments d ON d.department_id = e.department_id
WHERE d.department_id IS NULL;

-- Expected: 0 (invalid salary structures)
SELECT COUNT(*) AS invalid_salary_rows
FROM salary_structure
WHERE basic_salary <= 0 OR hra < 0 OR allowances < 0
   OR provident_fund < 0 OR tax_rate NOT BETWEEN 0 AND 100;

-- After running payroll_pkg.process_monthly_payroll for a month,
-- expected: no duplicate employee/month payroll rows.
SELECT employee_id, pay_month, COUNT(*) duplicate_count
FROM payroll
GROUP BY employee_id, pay_month
HAVING COUNT(*) > 1;
