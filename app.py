from flask import Flask, render_template_string

app = Flask(__name__)

EMPLOYEES = [
    {"id": 101, "name": "Aarav Sharma", "department": "Engineering", "basic": 72000, "hra": 14400, "allowances": 6500, "pf": 8640, "tax_rate": 10},
    {"id": 102, "name": "Meera Nair", "department": "Analytics", "basic": 68000, "hra": 13600, "allowances": 6000, "pf": 8160, "tax_rate": 10},
    {"id": 103, "name": "Rohan Gupta", "department": "Finance", "basic": 76000, "hra": 15200, "allowances": 7000, "pf": 9120, "tax_rate": 15},
]


def payroll(e):
    gross = e["basic"] + e["hra"] + e["allowances"]
    tax = gross * e["tax_rate"] / 100
    net = gross - tax - e["pf"]
    return round(gross, 2), round(tax, 2), round(net, 2)


@app.route("/")
def home():
    rows = []
    for e in EMPLOYEES:
        gross, tax, net = payroll(e)
        rows.append({**e, "gross": gross, "tax": tax, "net": net})
    return render_template_string('''
<!doctype html><html><head><title>Payroll Demo</title>
<style>body{font-family:Arial;max-width:1100px;margin:40px auto;padding:0 20px;background:#f7f8fb;color:#222}h1{margin-bottom:8px}.card{background:white;padding:24px;border-radius:14px;box-shadow:0 4px 16px #0001}table{width:100%;border-collapse:collapse;margin-top:20px}th,td{padding:12px;border-bottom:1px solid #ddd;text-align:left}th{background:#f0f3f8}.tag{display:inline-block;padding:5px 10px;border-radius:12px;background:#e8eefc}</style></head><body>
<h1>Employee Payroll Management System</h1><p>Portfolio demo of payroll calculations and reporting logic backed by the Oracle SQL/PLSQL project.</p>
<div class="card"><span class="tag">Oracle SQL + PL/SQL</span><span class="tag">Stored Procedures</span><span class="tag">Audit Triggers</span>
<table><tr><th>ID</th><th>Employee</th><th>Department</th><th>Gross</th><th>Tax</th><th>PF</th><th>Net Salary</th></tr>
{% for r in rows %}<tr><td>{{r.id}}</td><td>{{r.name}}</td><td>{{r.department}}</td><td>₹{{'{:,.0f}'.format(r.gross)}}</td><td>₹{{'{:,.0f}'.format(r.tax)}}</td><td>₹{{'{:,.0f}'.format(r.pf)}}</td><td><b>₹{{'{:,.0f}'.format(r.net)}}</b></td></tr>{% endfor %}</table></div>
</body></html>''', rows=rows)


if __name__ == "__main__":
    app.run(host="0.0.0.0", port=10000)
