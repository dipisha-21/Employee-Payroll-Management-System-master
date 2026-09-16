"""Generate reproducible Oracle INSERT statements for 120 synthetic employees."""
from pathlib import Path
import random
from datetime import date, timedelta

SEED = 42
EMPLOYEE_COUNT = 120
random.seed(SEED)

FIRST = ["Aarav", "Aditi", "Ananya", "Arjun", "Diya", "Ishaan", "Kabir", "Meera", "Neha", "Rahul", "Riya", "Rohan", "Saanvi", "Vikram", "Zoya"]
LAST = ["Sharma", "Patel", "Singh", "Gupta", "Iyer", "Nair", "Das", "Mehta", "Rao", "Verma"]
DEPARTMENTS = [(1, "Engineering", "Bengaluru"), (2, "Analytics", "Hyderabad"), (3, "Finance", "Mumbai"), (4, "Human Resources", "Pune"), (5, "Operations", "Delhi")]
JOBS = ["Data Analyst", "Software Engineer", "Data Engineer", "Business Analyst", "Operations Analyst", "HR Executive"]


def esc(value: str) -> str:
    return value.replace("'", "''")


def build_sql() -> str:
    lines = ["-- Generated deterministically with seed 42", ""]
    for dept_id, name, location in DEPARTMENTS:
        lines.append(f"INSERT INTO departments (department_id, department_name, location) VALUES ({dept_id}, '{name}', '{location}');")

    base_date = date(2019, 1, 1)
    for i in range(1, EMPLOYEE_COUNT + 1):
        first, last = random.choice(FIRST), random.choice(LAST)
        dept = random.randint(1, len(DEPARTMENTS))
        job = random.choice(JOBS)
        hire = base_date + timedelta(days=random.randint(0, 2400))
        email = f"{first.lower()}.{last.lower()}{i}@example.com"
        basic = random.randrange(30000, 120001, 1000)
        hra = round(basic * 0.20, 2)
        allowances = random.randrange(2000, 12001, 500)
        pf = round(basic * 0.12, 2)
        tax_rate = random.choice([5, 10, 15, 20])
        lines.append(
            "INSERT INTO employees (employee_id, first_name, last_name, email, hire_date, job_title, department_id) "
            f"VALUES ({i}, '{esc(first)}', '{esc(last)}', '{email}', DATE '{hire.isoformat()}', '{esc(job)}', {dept});"
        )
        lines.append(
            "INSERT INTO salary_structure (employee_id, basic_salary, hra, allowances, provident_fund, tax_rate) "
            f"VALUES ({i}, {basic}, {hra}, {allowances}, {pf}, {tax_rate});"
        )
    lines.extend(["", "COMMIT;", "", f"-- Employees generated: {EMPLOYEE_COUNT}"])
    return "\n".join(lines)


if __name__ == "__main__":
    output = Path(__file__).resolve().parents[1] / "database" / "06_sample_data.sql"
    output.write_text(build_sql(), encoding="utf-8")
    print(f"Wrote {EMPLOYEE_COUNT} employees to {output}")
