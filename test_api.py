import os, json, requests
from dotenv import load_dotenv

load_dotenv()
TOKEN = os.getenv("CR_TOKEN")
TAG = "%2392CP0QJVG"  # el # se escribe como %23
URL = f"https://proxy.royaleapi.dev/v1/players/{TAG}/battlelog"

r = requests.get(URL, headers={"Authorization": f"Bearer {TOKEN}"}, timeout=15)
print("Estado:", r.status_code)
r.raise_for_status()

battles = r.json()
print("Partidas recibidas:", len(battles))
for b in battles[:5]:
    yo, rival = b["team"][0], b["opponent"][0]
    print(b["battleTime"], b["type"], f'{yo["crowns"]}-{rival["crowns"]}', rival["name"])

with open("battlelog_raw.json", "w", encoding="utf-8") as f:
    json.dump(battles, f, ensure_ascii=False, indent=2)