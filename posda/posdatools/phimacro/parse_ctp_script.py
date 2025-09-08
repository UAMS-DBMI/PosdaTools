#!/usr/bin/env python3
# -*- coding: utf-8 -*-

from __future__ import annotations

import argparse
import json
import os
import re
import sys
from collections import defaultdict
from typing import Dict, List, Tuple

HERE = os.path.dirname(__file__)
DEFAULT_INPUT = os.path.join(HERE, "CTP-TCIA-DicomAnonymizerIncDate-03-20-2025.script")
DEFAULT_OUTPUT = os.path.join(HERE, "ctp_rules.json")

def to_posda_format(tag_hex: str) -> str:
    s = (tag_hex or "").strip()
    if m:= re.fullmatch(r"([0-9A-Fa-f]{4})([0-9A-Fa-f]{4})", s):
        group, element = m.groups()
        return f"({group.lower()},{element.lower()})"
    elif m := re.fullmatch('([0-9A-Fa-f]{4})\[(.+)\]([0-9A-Fa-f]{2})', s):
        group, creator, element = m.groups()
        return f"({group.lower()},\"{creator}\",{element.lower()})"
    else:
        return s

def parse_params_and_elements(text: str) -> Tuple[Dict[str, str], Dict[str, List[dict]]]:
    # Tolerant regex-based parsing; the file may contain stray '>' etc.
    params: Dict[str, str] = {}
    rules_by_tag: Dict[str, List[dict]] = defaultdict(list)

    # Normalize newlines for regex simplicity
    src = text

    # Parse <p t="KEY">value</p>
    for m in re.finditer(r"<p\s+([^>]*?)>(.*?)</p>", src, flags=re.DOTALL | re.IGNORECASE):
        attrs_str, inner = m.group(1), m.group(2)
        attrs = dict(re.findall(r"(\w+)\s*=\s*\"([^\"]*)\"", attrs_str))
        key = attrs.get("t") or attrs.get("T")
        if not key:
            continue
        params[key] = (inner or "").strip()

    # Parse <e ...>action</e>
    for m in re.finditer(r"<e\s+([^>]*?)>(.*?)</e>", src, flags=re.DOTALL | re.IGNORECASE):
        attrs_str, inner = m.group(1), m.group(2)
        attrs = dict(re.findall(r"(\w+)\s*=\s*\"([^\"]*)\"", attrs_str))
        tag_hex = attrs.get("t") or attrs.get("T") or ""
        name = attrs.get("n") or attrs.get("N") or ""
        en = attrs.get("en") or attrs.get("EN") or ""
        enabled = str(en).strip().lower() in {"t", "true", "1", "y", "yes"}
        action = (inner or "").strip()

        tag_key = to_posda_format(tag_hex)
        rules_by_tag[tag_key].append({
            "name": name,
            "enabled": enabled,
            "action": action,
        })

    return params, rules_by_tag


def main(argv: List[str] | None = None) -> int:
    p = argparse.ArgumentParser(description="Parse a CTP anonymizer script to JSON")
    p.add_argument("input", nargs="?", default=DEFAULT_INPUT, help="Path to .script file")
    p.add_argument("-o", "--output", default=DEFAULT_OUTPUT, help="Path to output JSON file")
    args = p.parse_args(argv)

    try:
        with open(args.input, "r", encoding="utf-8") as f:
            text = f.read()
    except FileNotFoundError:
        print(f"Input not found: {args.input}", file=sys.stderr)
        return 2

    params, rules_by_tag = parse_params_and_elements(text)

    # Deterministic ordering of tags and keep rule order per tag
    ordered = {k: rules_by_tag[k] for k in sorted(rules_by_tag.keys())}
    out_obj = {"params": params, "rules_by_tag": ordered}

    with open(args.output, "w", encoding="utf-8") as f:
        json.dump(out_obj, f, ensure_ascii=False, indent=2)

    print(
        f"Parsed {len(params)} params and {sum(len(v) for v in rules_by_tag.values())} rules across {len(rules_by_tag)} tags -> {args.output}",
        file=sys.stderr,
    )
    return 0


if __name__ == "__main__":
    raise SystemExit(main())