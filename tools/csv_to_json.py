# Turns your Google Sheet (saved as CSV) into mcqs.json and version.json.
# Use:  python tools/csv_to_json.py my_sheet.csv 2
# (the last number is the new version number. Make it bigger each time.)
import csv, json, sys, datetime
if len(sys.argv) < 3:
    sys.exit("Use: python csv_to_json.py my_sheet.csv VERSION_NUMBER")
rows = []
with open(sys.argv[1], encoding="utf-8-sig", newline="") as f:
    for r in csv.DictReader(f):
        r = {k.strip(): (v or "").strip() for k, v in r.items() if k}
        if r.get("question") and r.get("correct", "").lower() in list("abcd"):
            r["correct"] = r["correct"].lower()
            rows.append(r)
json.dump(rows, open("mcqs.json", "w", encoding="utf-8"), ensure_ascii=False)
json.dump({"version": int(sys.argv[2]), "file": "mcqs.json", "count": len(rows),
           "updated": datetime.date.today().isoformat()}, open("version.json", "w"))
print(len(rows), "questions written to mcqs.json and version.json")
