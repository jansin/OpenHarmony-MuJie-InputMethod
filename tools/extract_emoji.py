import json
import pathlib
import re

SRC = pathlib.Path("D:/person/openboard/app/src/main/res/values/emoji-categories.xml")
DST = pathlib.Path("D:/person/MuJieInputMethod/entry/src/main/resources/rawfile/emoji_compact.json")

CATEGORY_NAMES = [
    "emoji_smileys_emotion",
    "emoji_people_body",
    "emoji_animals_nature",
    "emoji_food_drink",
    "emoji_travel_places",
    "emoji_activities",
    "emoji_objects",
    "emoji_symbols",
    "emoji_flags",
]
EMOJI_LIMIT_PER_CATEGORY = 400


def decode_item(item: str) -> str:
    core = item.split("||")[0]
    chars = []
    for code_point in core.split(","):
        cp = code_point.strip()
        if not cp:
            continue
        chars.append(chr(int(cp, 16)))
    return "".join(chars)


def main() -> None:
    src_text = SRC.read_text(encoding="utf-8")
    result: dict[str, list[str]] = {}
    for name in CATEGORY_NAMES:
        block_match = re.search(rf'<array\s+name="{name}"[\s\S]*?</array>', src_text)
        if not block_match:
            continue
        items = re.findall(r"<item>(.*?)</item>", block_match.group(0))
        emojis: list[str] = []
        for item in items:
            try:
                emojis.append(decode_item(item))
            except Exception:
                continue
        # 收缩数据量：每个分类保留前若干常用项
        result[name] = emojis[:EMOJI_LIMIT_PER_CATEGORY]

    DST.write_text(json.dumps(result, ensure_ascii=False), encoding="utf-8")
    print(f"Wrote {DST} with {len(result)} categories")


if __name__ == "__main__":
    main()
