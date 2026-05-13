import urllib.request
import json
import sys

RANK_NAMES = {
    "1": "Rookie",
    "2": "Iron",
    "3": "Bronze",
    "4": "Silver",
    "5": "Gold",
    "6": "Platinum",
    "7": "Diamond",
    "8": "Master",
}

MASTER_RANK_NAMES = {
    "36": "Master",
    "40": "High Master",
    "41": "Grand Master",
    "42": "Ultimate Master",
}

HEADERS = {
    "User-Agent": "Mozilla/5.0 (Windows NT 10.0; Win64; x64) AppleWebKit/537.36",
    "Referer": "https://www.streetfighter.com/6/buckler/ja-jp/stats/dia_master",
    "Accept": "application/json",
}


def fetch(url: str) -> dict:
    req = urllib.request.Request(url, headers=HEADERS)
    with urllib.request.urlopen(req) as res:
        return json.loads(res.read())


def build_diagram(data: dict, rank_map: dict) -> dict:
    result = {}
    c_sort = data["diaData"]["c"]["ci_sort"]

    for rank_key, rank_name in rank_map.items():
        if rank_key not in c_sort:
            continue

        rank_data = c_sort[rank_key]
        opponent_map = {h["id"]: h["name_alpha"] for h in rank_data["opponent_header"]}

        characters = []
        for record in rank_data["records"]:
            matchups = {}
            for v in record["values"]:
                opponent_name = opponent_map.get(v["_oid"])
                val = v["val"]
                if opponent_name and val not in ("-", "-.---", None, ""):
                    try:
                        matchups[opponent_name] = float(val)
                    except ValueError:
                        pass

            try:
                total = float(record["total"])
            except (ValueError, TypeError):
                total = None

            characters.append({
                "name": record["name_alpha"],
                "tool_name": record["tool_name"],
                "total": total,
                "matchups": matchups,
            })

        result[rank_name] = characters

    return result


def main():
    mode = sys.argv[1] if len(sys.argv) > 1 else "all"
    year_month = sys.argv[2] if len(sys.argv) > 2 else "202603"
    output_path = sys.argv[3] if len(sys.argv) > 3 else f"diagram_{mode}_{year_month}.json"

    if mode == "master":
        url = f"https://www.streetfighter.com/6/buckler/api/ja-jp/stats/dia_master/{year_month}"
        rank_map = MASTER_RANK_NAMES
    else:
        url = f"https://www.streetfighter.com/6/buckler/api/ja-jp/stats/dia/{year_month}"
        rank_map = RANK_NAMES

    print(f"取得中: {url}")
    raw = fetch(url)
    diagram = build_diagram(raw, rank_map)

    with open(output_path, "w", encoding="utf-8") as f:
        json.dump(diagram, f, ensure_ascii=False, indent=2)

    print(f"保存完了: {output_path}")
    for rank, chars in diagram.items():
        print(f"  {rank}: {len(chars)}キャラ")


if __name__ == "__main__":
    main()
