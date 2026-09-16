-- Validation and audit triggers

CREATE OR REPLACE TRIGGER trg_salary_validation
BEFORE INSERT OR UPDATE ON salary_structure
FOR EACH ROW
BEGIN
    IF :NEW.basic_salary <= 0 OR :NEW.hra < 0 OR :NEW.allowances < 0 OR
       :NEW.provident_fund < 0 OR :NEW.tax_rate < 0 OR :NEW.tax_rate > 100 THEN
        RAISE_APPLICATION_ERROR(-20010, 'Invalid salary structure values.');
    END IF;
END;
/

CREATE OR REPLACE TRIGGER trg_payroll_audit
AFTER INSERT OR UPDATE OR DELETE ON payroll
FOR EACH ROW
BEGIN
    IF INSERTING THEN
        INSERT INTO payroll_audit
            (payroll_id, employee_id, old_net_salary, new_net_salary, action_type)
        VALUES
            (:NEW.payroll_id, :NEW.employee_id, NULL, :NEW.net_salary, 'INSERT');
    ELSIF UPDATING THEN
        INSERT INTO payroll_audit
            (payroll_id, employee_id, old_net_salary, new_net_salary, action_type)
        VALUES
            (:NEW.payroll_id, :NEW.employee_id, :OLD.net_salary, :NEW.net_salary, 'UPDATE');
    ELSIF DELETING THEN
        INSERT INTO payroll_audit
            (payroll_id, employee_id, old_net_salary, new_net_salary, action_type)
        VALUES
            (:OLD.payroll_id, :OLD.employee_id, :OLD.net_salary, NULL, 'DELETE');
    END IF;
END;
/
