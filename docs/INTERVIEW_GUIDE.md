# Interview Guide

## 60-second explanation
I built an Oracle payroll database around a normalized relational model. Employees belong to departments and have a one-to-one salary structure. A PL/SQL package calculates gross salary, taxes, deductions and net salary and uses MERGE so payroll for an employee and month is idempotent. I added constraints and validation triggers to prevent invalid salary data, plus an audit trigger to record payroll changes. Reporting views and analytical SQL answer department-cost, salary-ranking and payroll-trend questions.

## Design decisions
- `UNIQUE(employee_id, pay_month)` prevents duplicate monthly payroll records.
- `MERGE` lets a payroll run safely update an existing month instead of inserting duplicates.
- Salary constraints enforce data quality at the database boundary.
- The audit table separates operational payroll data from change history.
- Window functions demonstrate department-relative analysis without losing row-level detail.

## Questions to prepare for
**Why PL/SQL instead of calculating salary in an application?**  
Keeping core payroll rules close to the data demonstrates stored-program logic and provides one consistent calculation path. A production system could still expose this through an application/service layer.

**How do you prevent duplicate payroll?**  
A composite unique constraint on employee and pay month plus MERGE in the procedure.

**How do you handle failure halfway through monthly processing?**  
The monthly procedure commits only after all active employees are processed and rolls back on an exception.

**Why synthetic data?**  
It makes the repository reproducible and avoids publishing real employee information. The generator uses a fixed seed and produces 120 employee records.

## Limitations / next steps
This is a portfolio database implementation, not a production payroll product. Production work would require jurisdiction-specific tax rules, access control, encryption, secrets management, stronger temporal salary modelling, automated Oracle integration tests, and formal audit/retention policies.
