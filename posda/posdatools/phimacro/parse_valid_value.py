#!/usr/bin/env python3
# -*- coding: utf-8 -*-

"""
Normalize valid values from valid_value_raw.csv.

Input CSV format (headers):
  tag,list

- tag: DICOM tag string, e.g. "<(0008,0060)>"
- list: JSON object as a string mapping allowed values -> description

Output JSON format (to --output):
	{
		"<(0008,0060)>": ["ANN", "AR", ...],
		"<(0008,0064)>": ["DF", "DI", ...],
		...
	}

For repeated rows of the same tag, values are merged and de-duplicated. If a
value appears multiple times with differing descriptions, the non-empty and/or
longer description is preferred during merge, though descriptions are not
emitted in the JSON.
"""

from __future__ import annotations

import argparse
import csv
import json
import os
import sys
from collections import defaultdict
from typing import Dict, Tuple

HERE = os.path.dirname(__file__)
DEFAULT_INPUT = os.path.join(HERE, "valid_value_raw.csv")
DEFAULT_OUTPUT = os.path.join(HERE, "valid_values.json")

def best_desc(current: str, new: str) -> str:
	"""Choose the better description between current and new.

	Preference order:
	  1) Non-empty over empty
	  2) Longer non-empty string wins
	"""
	cur = (current or "").strip()
	nxt = (new or "").strip()
	if not cur and nxt:
		return nxt
	if cur and not nxt:
		return cur
	if len(nxt) > len(cur):
		return nxt
	return cur


def parse_raw_valid_values(path: str) -> Dict[str, Dict[str, str]]:
	"""Read raw CSV and return mapping: tag -> { value -> description }"""
	merged: Dict[str, Dict[str, str]] = defaultdict(dict)

	with open(path, "r", encoding="utf-8", newline="") as f:
		reader = csv.DictReader(f)
		if not {"tag", "list"}.issubset(reader.fieldnames or {}):
			raise ValueError("Input CSV must have headers: tag,list")

		for i, row in enumerate(reader, start=2):  # header is line 1
			tag = (row.get("tag") or "").strip("<>")
			raw_list = row.get("list")
			if not tag:
				print(f"Skipping row {i}: empty tag", file=sys.stderr)
				continue
			if raw_list is None:
				print(f"Skipping row {i}: missing 'list'", file=sys.stderr)
				continue

			text = raw_list.strip()
			if not text:
				# No values to merge
				continue
			try:
				obj = json.loads(text)
			except json.JSONDecodeError as e:
				# Provide context for debugging and continue
				preview = text[:200].replace("\n", " ")
				print(
					f"Row {i}: JSON parse error: {e}. Snippet: {preview}",
					file=sys.stderr,
				)
				continue

			# Merge values
			for value, desc in obj.items():
				v = (str(value) if value is not None else "").strip()
				d = (str(desc) if desc is not None else "").strip()
				if not v:
					# skip empty keys
					continue

				existing = merged[tag].get(v, "")
				merged[tag][v] = best_desc(existing, d)

	return merged


def write_json_values(data: Dict[str, Dict[str, str]], out_path: str) -> None:
	"""Write mapping tag -> sorted list of unique values as JSON."""
	# Build lightweight structure: tag -> [values...]
	simplified = {tag: sorted(inner.keys()) for tag, inner in data.items()}

	# Sort tags for deterministic output
	ordered = {tag: simplified[tag] for tag in sorted(simplified.keys())}

	# Always write to a file path for JSON output
	with open(out_path, "w", encoding="utf-8") as f:
		json.dump(ordered, f, ensure_ascii=False, indent=2)


def main(argv: list[str] | None = None) -> int:
	p = argparse.ArgumentParser(description="Parse and normalize valid values from CSV to JSON")
	p.add_argument("input", nargs="?", default=DEFAULT_INPUT, help="Path to input CSV (default: valid_value_raw.csv)")
	p.add_argument("-o", "--output", default=DEFAULT_OUTPUT, help="Path to output JSON (default: valid_values.json)")
	args = p.parse_args(argv)

	merged = parse_raw_valid_values(args.input)
	write_json_values(merged, args.output)

	# Simple summary to stderr
	tags = len(merged)
	values = sum(len(v) for v in merged.values())
	print(f"Wrote {values} values across {tags} tags -> {args.output}", file=sys.stderr)
	return 0


if __name__ == "__main__":
	raise SystemExit(main())

