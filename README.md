# Employee Payroll Management System

An Oracle SQL and PL/SQL payroll database project designed around a normalized employee data model, automated monthly payroll processing, validation controls, auditability, and practical reporting queries.

## Why this project
Payroll is a useful database engineering problem because correctness matters: employee records must remain consistent, salary components must be validated, and payroll changes should be traceable. This repository demonstrates those concerns with database constraints, PL/SQL procedures, triggers, views, and reproducible sample data.

## Tech Stack
- Oracle Database
- SQL
- PL/SQL
- Stored procedures and functions
- Database triggers
- Relational data modelling

## Architecture

```text
Departments ──< Employees ──< Attendance
                    │
                    ├──< Salary Structure
                    │
                    └──< Payroll ──< Payroll Audit
```

## Features
- Normalized schema for departments, employees, attendance, salary structure and payroll
- Primary/foreign keys, UNIQUE, CHECK and NOT NULL constraints
- Monthly payroll calculation using PL/SQL
- Validation for salary components and deductions
- Audit trigger for payroll changes
- Reporting views for employee payroll summaries
- Business-analysis SQL using joins, aggregates and window functions
- Deterministic generator for 100+ synthetic employee records

## Repository Structure

```text
database/
  01_schema.sql
  02_procedures.sql
  03_triggers.sql
  04_views.sql
  05_business_queries.sql
scripts/
  generate_sample_data.py
legacy/
  Original coursework files remain in the repository's historical folder
```

## Payroll Logic

For demonstration purposes:

```text
Gross Salary = Basic + HRA + Allowances + Bonus
Total Deductions = Tax + Provident Fund + Other Deductions
Net Salary = Gross Salary - Total Deductions
```

The implementation uses constraints and PL/SQL validation so invalid negative components cannot silently enter payroll calculations.

## Example Questions Answered
- Which departments have the highest payroll cost?
- Who are the highest-paid employees within each department?
- What is the monthly payroll trend?
- Which employees received the largest bonuses?
- What percentage of gross salary is deducted per employee?

## Run Locally
1. Create an Oracle schema/user for the project.
2. Run `database/01_schema.sql`.
3. Generate sample inserts with `python scripts/generate_sample_data.py`.
4. Execute the generated `database/06_sample_data.sql`.
5. Run procedures, triggers and views in numeric order.
6. Explore `database/05_business_queries.sql`.

## Interview Talking Points
This project demonstrates relational modelling, normalization, SQL joins and aggregation, PL/SQL procedural logic, constraints, triggers, transaction-safe payroll processing, auditing, and data-quality controls.

## Author
Dipisha Shivangi
