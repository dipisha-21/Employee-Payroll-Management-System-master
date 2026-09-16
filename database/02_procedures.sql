-- Payroll processing package

CREATE OR REPLACE PACKAGE payroll_pkg AS
    PROCEDURE process_employee_payroll(
        p_employee_id IN NUMBER,
        p_pay_month IN DATE,
        p_bonus IN NUMBER DEFAULT 0,
        p_other_deductions IN NUMBER DEFAULT 0
    );
    PROCEDURE process_monthly_payroll(p_pay_month IN DATE);
END payroll_pkg;
/

CREATE OR REPLACE PACKAGE BODY payroll_pkg AS
    PROCEDURE process_employee_payroll(
        p_employee_id IN NUMBER,
        p_pay_month IN DATE,
        p_bonus IN NUMBER DEFAULT 0,
        p_other_deductions IN NUMBER DEFAULT 0
    ) IS
        v_basic salary_structure.basic_salary%TYPE;
        v_hra salary_structure.hra%TYPE;
        v_allowances salary_structure.allowances%TYPE;
        v_pf salary_structure.provident_fund%TYPE;
        v_tax_rate salary_structure.tax_rate%TYPE;
        v_gross NUMBER(12,2);
        v_tax NUMBER(12,2);
        v_net NUMBER(12,2);
        v_month DATE := TRUNC(p_pay_month, 'MM');
    BEGIN
        IF NVL(p_bonus, 0) < 0 OR NVL(p_other_deductions, 0) < 0 THEN
            RAISE_APPLICATION_ERROR(-20001, 'Bonus and deductions cannot be negative.');
        END IF;

        SELECT basic_salary, hra, allowances, provident_fund, tax_rate
        INTO v_basic, v_hra, v_allowances, v_pf, v_tax_rate
        FROM salary_structure
        WHERE employee_id = p_employee_id;

        v_gross := v_basic + v_hra + v_allowances + NVL(p_bonus, 0);
        v_tax := ROUND(v_gross * (v_tax_rate / 100), 2);
        v_net := v_gross - v_tax - v_pf - NVL(p_other_deductions, 0);

        IF v_net < 0 THEN
            RAISE_APPLICATION_ERROR(-20002, 'Deductions exceed gross salary.');
        END IF;

        MERGE INTO payroll p
        USING (SELECT p_employee_id employee_id, v_month pay_month FROM dual) s
        ON (p.employee_id = s.employee_id AND p.pay_month = s.pay_month)
        WHEN MATCHED THEN UPDATE SET
            p.basic_salary = v_basic, p.hra = v_hra, p.allowances = v_allowances,
            p.bonus = NVL(p_bonus,0), p.tax = v_tax, p.provident_fund = v_pf,
            p.other_deductions = NVL(p_other_deductions,0),
            p.gross_salary = v_gross, p.net_salary = v_net,
            p.processed_at = SYSTIMESTAMP
        WHEN NOT MATCHED THEN INSERT
            (employee_id, pay_month, basic_salary, hra, allowances, bonus, tax,
             provident_fund, other_deductions, gross_salary, net_salary)
        VALUES
            (p_employee_id, v_month, v_basic, v_hra, v_allowances, NVL(p_bonus,0),
             v_tax, v_pf, NVL(p_other_deductions,0), v_gross, v_net);
    EXCEPTION
        WHEN NO_DATA_FOUND THEN
            RAISE_APPLICATION_ERROR(-20003, 'Salary structure not found for employee.');
    END process_employee_payroll;

    PROCEDURE process_monthly_payroll(p_pay_month IN DATE) IS
    BEGIN
        FOR r IN (
            SELECT e.employee_id
            FROM employees e
            JOIN salary_structure s ON s.employee_id = e.employee_id
            WHERE e.employment_status = 'ACTIVE'
        ) LOOP
            process_employee_payroll(r.employee_id, p_pay_month);
        END LOOP;
        COMMIT;
    EXCEPTION
        WHEN OTHERS THEN
            ROLLBACK;
            RAISE;
    END process_monthly_payroll;
END payroll_pkg;
/
