#!/usr/bin/env python3
"""
Build a Posda anonymizer command spreadsheet from:
  1) a Posda "patient mapping" table (queried from the Posda DB), AND
  2) a pydicom/deid "FORMAT dicom" recipe (%labels + %header)

Key requirements (per Michael):
- The source of truth is patient_mapping + recipe commands.
- Recipe %labels provide defaults, but patient_mapping may override them.
- DO NOT programmatically append site/collection codes to uid_root.
  If a uid_root needs any suffixing, it must be provided by the user (mapping or recipe label).

This script mirrors the logic of ProduceInitialAnonymizerCommandsTp.pl:
- Find the latest activity_timepoint_id for an activity
- Get patients (from_patient_id) and their SeriesInstanceUIDs for that timepoint
- Load patient mappings for (collection, site)
- For each patient (and for each series), emit Posda edit operations as CSV rows.

Supported recipe -> Posda operations:
- REMOVE <tag>                         -> delete_tag
- BLANK  <tag>                         -> empty_tag
- REPLACE/ADD <tag> var:<name>         -> set_tag (value from resolved context)
- REPLACE/ADD <tag> deid_func:hash_uid -> hash_unhashed_uid (val1=uid_root)
- REPLACE/ADD <tag> deid_func:increment_date -> shift_date (val1=date_shift_days)
- %labels remove_curves/remove_overlays -> delete_matching_group "50xx"/"60xx"

Notes:
- KEEP is ignored (not an edit op).
- Any other function calls are ignored (safely) unless you extend the mapping.
"""

from __future__ import annotations

import sys
import argparse
import csv
import re
from dataclasses import dataclass
from pathlib import Path
from typing import Any, Dict, Iterable, List, Optional, Tuple, DefaultDict
from collections import defaultdict
from pydicom.datadict import tag_for_keyword, keyword_for_tag

from posda.background.process import BackgroundProcess
from posda.database import Database
from posda.config import Config

import requests
from io import BytesIO

SECTION_RE = re.compile(r"^\s*(%labels|%header)\s*$")
LABEL_LINE_RE = re.compile(r"^\s*ADD\s+(?P<key>[A-Za-z0-9_]+)\s+(?P<val>.+?)\s*$")
ACTION_RE = re.compile(
    r"^\s*(?P<verb>REMOVE|KEEP|BLANK|REPLACE|ADD)\s+"
    r"(?P<tag>\([0-9A-Fa-f]{4},[0-9A-Fa-f]{4}\)"
    r"|\([0-9A-Fa-f]{4},\".*?\",[0-9A-Fa-f]{2}\)"
    r"|<[^>]+>"
    r"|[0-9A-Fa-f]{8}"
    r"|[A-Za-z][A-Za-z0-9_]*)"
    r"(?:\s+(?P<rhs>.+?))?\s*$"
)


#--------------------------------------------------


def call_api(endpoint, call_type):
    API_URL = f'{Config.get("internal-api-url")}/v1{endpoint}'
    HEADERS = {'Authorization': f'Bearer {Config.get("api_system_token")}'}
    try:
        if call_type == 0:
            response = requests.get(API_URL,headers=HEADERS)
        elif call_type == 1:
            response = requests.patch(API_URL,headers=HEADERS)
        elif call_type == 2:
            response = requests.put(API_URL,headers=HEADERS)
        if response.status_code == 200:
            return response, API_URL, True
        print(f'Bad response: {response.status_code} - {response.text}')
    except Exception as e:
        print(f'Error processing request: {e}')
    return None, API_URL, False


def get_file_data(file_id):
    resp, _, success = call_api(f'/files/{file_id}/data', 0)
    return resp.content if success else None


def get_file_path(file_id):
    resp, _, success = call_api(f'/files/{file_id}/path', 0)
    return resp.json() if success else None


def get_file_details(file_id):
    resp, _, success = call_api(f'/files/{file_id}/details', 0)
    return resp.json() if success else None


#--------------------------------------------------


@dataclass
class Recipe:
    labels: Dict[str, str]
    header_lines: List[str]


def parse_recipe(file_data: str) -> Recipe:
    labels: Dict[str, str] = {}
    header_lines: List[str] = []
    section: Optional[str] = None

    for raw in file_data.splitlines():
        line = raw.strip()
        if not line or line.startswith("#"):
            continue

        msec = SECTION_RE.match(line)
        if msec:
            section = msec.group(1)
            continue

        if section == "%labels":
            m = LABEL_LINE_RE.match(raw)
            if m:
                labels[m.group("key")] = m.group("val").strip()
            continue

        if section == "%header":
            header_lines.append(raw)

    return Recipe(labels=labels, header_lines=header_lines)


def get_file(file_id, force_api=False):
    if not force_api:
        # always try file path first
        path = get_file_path(file_id)
        if path and 'storage_path' in path:
            try:
                return open(path['storage_path'], 'rb')
            except Exception as e:
                print(f'Error opening file {file_id} at {path["storage_path"]}: {e}')

    # fallback to API if file path is not available or if forced
    data = get_file_data(file_id)
    if data is not None:
        return BytesIO(data)
    return None


def get_activity_files(args, conn):
    """
    Returns tuples of (file_id, storage_path, media_storage_sop_class, sop_instance_uid)
    """

    activity_id = args.activity_id

    file_query = """
            with files_in_activity as 
            (
                select file_id
                from activity_timepoint_file
                natural join file
                where activity_timepoint_id = (
                    select max(activity_timepoint_id)
                    from activity_timepoint
                    where activity_id = %s
                )
                and file.is_dicom_file = true                
            )
            select file_id,
                   storage_path(file_id),
                   media_storage_sop_class,
                   modality,
                   sop_instance_uid,
                   series_instance_uid,
                   study_instance_uid,
                   patient_id,
                   for_uid
            from files_in_activity
            natural left join file_meta
            natural left join file_sop_common
            natural left join file_series
            natural left join file_study
            natural left join file_patient
            natural left join file_for
        """    
    file_rows = []
    cur = conn.cursor()
    cur.execute(file_query, (activity_id,))
    file_rows = cur.fetchall()

    return file_rows


def get_recipe(args, file_id):
    recipe_file = get_file(file_id, force_api=args.force_api)
    if recipe_file is None:
        raise RuntimeError(f"Could not retrieve recipe file for file_id={file_id}")
    file_data = recipe_file.read().decode("utf-8", errors="replace")
    recipe = parse_recipe(file_data)
    return recipe


def get_patient_mapping(
    db: Database,
    collection: str,
    site: str,
) -> Dict[str, List[Dict[str, Any]]]:
    """
    Retrieve patient mapping rows for the given collection and site.    
    Note: Perl uses GetPatientMappingByCollectionSite(collection, site).
    """
    out: DefaultDict[str, List[Dict[str, Any]]] = defaultdict(list)
    with db.cursor() as cur:
        cur.execute(
            """
            select *
            from patient_mapping
            where collection_name = %s
              and site_name = %s
              -- and active = true
            """,
            (collection, site),
        )
        cols = [d[0] for d in cur.description]
        for row in cur.fetchall():
            rec = {cols[i]: row[i] for i in range(len(cols))}
            fp = (rec.get("from_patient_id") or "")
            if fp:
                out[str(fp)].append(rec)
    return dict(out)


#--------------------------------------------------


def _parse_bool(v: Any, default: bool = False) -> bool:
    if v is None:
        return default
    if isinstance(v, bool):
        return v
    s = str(v).strip().lower()
    if s in {"1", "true", "t", "yes", "y", "on"}:
        return True
    if s in {"0", "false", "f", "no", "n", "off"}:
        return False
    return default


def normalize_date_shift(val: Any) -> Optional[int]:
    """
    Perl normalizes values like "X days" and "00:00:00".
    Here we accept:
      - int / numeric string
      - "N days"
      - time strings "HH:MM:SS" -> 0
    """
    if val is None:
        return None

    # datetime.timedelta-like object (common from DB adapters)
    if hasattr(val, "days") and hasattr(val, "total_seconds"):
        try:
            return int(val.days)
        except Exception:
            pass

    s = str(val).strip()
    if not s:
        return None

    # "N days, HH:MM:SS" (typical timedelta string form)
    m = re.match(r"^\s*(-?\d+)\s+days?,\s+\d{1,2}:\d{2}:\d{2}\s*$", s, flags=re.IGNORECASE)
    if m:
        return int(m.group(1))

    # "N days"
    m = re.match(r"^\s*(-?\d+)\s+days\s*$", s, flags=re.IGNORECASE)
    if m:
        return int(m.group(1))
    # "HH:MM:SS" -> 0 (perl treats 00:00:00 as 0)
    if re.match(r"^\d{2}:\d{2}:\d{2}$", s):
        return 0
    # numeric
    try:
        return int(float(s))
    except Exception:
        return None


def resolve_context(
    recipe_labels: Dict[str, str],
    mapping_row: Optional[Dict[str, Any]],
) -> Dict[str, Any]:
    """
    Resolve variables with precedence:
      recipe %labels defaults < patient_mapping overrides
    """
    ctx: Dict[str, Any] = {
        "uid_root": (recipe_labels.get("uid_root") or "").strip(),
        "date_shift_days": normalize_date_shift((recipe_labels.get("date_shift_days") or "0").strip()),
        "site_code": (recipe_labels.get("site_code") or "").strip(),
        "site_name": (recipe_labels.get("site_name") or "").strip(),
        "collection_name": (recipe_labels.get("collection_name") or "").strip(),
        "pat_id": "",
        "pat_name": "",
    }

    if mapping_row:
        # patient id/name always mapping-driven
        if mapping_row.get("to_patient_id"):
            ctx["pat_id"] = str(mapping_row["to_patient_id"])
        if mapping_row.get("to_patient_name"):
            ctx["pat_name"] = str(mapping_row["to_patient_name"])

        # overrides
        if mapping_row.get("uid_root"):
            ctx["uid_root"] = str(mapping_row["uid_root"]).strip()

        # collection and site
        if mapping_row.get("collection_name"):
            ctx["collection_name"] = str(mapping_row["collection_name"]).strip()
        if mapping_row.get("site_name"):
            ctx["site_name"] = str(mapping_row["site_name"]).strip()

        # date shift from mapping overrides recipe default when present
        if mapping_row.get("date_shift"):
            ds = mapping_row.get("date_shift")
            nds = normalize_date_shift(ds)
            if nds is not None:
                ctx["date_shift_days"] = str(nds)

    return ctx


def _tag_for_csv(tag_expr: str) -> str:
    """
    Perl generally emits tags in angle brackets inside the CSV (e.g., "<(0010,0020)>").
    This helper ensures the tag is in <...> form unless the recipe already provides <...>.
    """
    t = tag_expr.strip()

    # If already wrapped, strip angle brackets and normalize inner tag.
    if t.startswith("<") and t.endswith(">"):
        t = t[1:-1].strip()

    # 8-hex form: ggggeeee -> (gggg,eeee)
    if re.match(r"^[0-9A-Fa-f]{8}$", t):
        return f"({t[:4].lower()},{t[4:].lower()})"

    # DICOM keyword form: PatientName -> (0010,0010)
    if re.match(r"^[A-Za-z][A-Za-z0-9_]*$", t):
        if t in ["DateOfInstallation", "DateOfManufacture"]:
            a='a'
        tag_num = tag_for_keyword(t)
        if tag_num is not None:
            g = (int(tag_num) >> 16) & 0xFFFF
            e = int(tag_num) & 0xFFFF
            tag = f"({g:04x},{e:04x})"
            return tag

    # private tag form: (gggg,"CREATOR",ee)
    # lowercase only group/element; preserve creator text exactly
    m_priv = re.match(r'^\(([0-9A-Fa-f]{4}),(".*?"),([0-9A-Fa-f]{2})\)$', t)
    if m_priv:
        return f"({m_priv.group(1).lower()},{m_priv.group(2)},{m_priv.group(3).lower()})"

    # standard tag form: (gggg,eeee)
    m_std = re.match(r'^\(([0-9A-Fa-f]{4}),([0-9A-Fa-f]{4})\)$', t)
    if m_std:
        return f"({m_std.group(1).lower()},{m_std.group(2).lower()})"

    if t.startswith("(") and t.endswith(")"):
        return t
    return t


def _strip_quotes(s: str) -> str:
    s = s.strip()
    if (s.startswith('"') and s.endswith('"')) or (s.startswith("'") and s.endswith("'")):
        return s[1:-1]
    return s


def _val1_for_csv(v: Any) -> str:
    s = str(v)
    if s == "<>":
        return s
    if s.startswith("<") and s.endswith(">"):
        return s
    return f"<{s}>"


def _tag_for_op_csv(tag: str, op: str) -> str:
    t = str(tag).strip()
    if t.startswith("<") and t.endswith(">"):
        t = t[1:-1].strip()

    if op in {"hash_unhashed_uid", "shift_date", "delete_tag", "empty_tag"}:
        if not t.startswith(".."):
            t = f"..{t}"
    return f"<{t}>"


def emit_rows_for_patient(
    recipe: Recipe,
    ctx: Dict[str, Any],
) -> List[List[Any]]:
    """
    Emit CSV edit rows once per patient, given the resolved context.
    """
    rows: List[List[Any]] = []

    # Group deletions driven by labels (recipe defaults; could be overridden if you add them to ctx in future)
    if _parse_bool(recipe.labels.get("remove_overlays"), default=False):
        rows.append(["", "delete_matching_group", "60xx", _val1_for_csv("<>"), "<>", ""])
    if _parse_bool(recipe.labels.get("remove_curves"), default=False):
        rows.append(["", "delete_matching_group", "50xx", _val1_for_csv("<>"), "<>", ""])

    for raw in recipe.header_lines:
        line = raw.strip()
        if not line or line.startswith("#"):
            continue
        m = ACTION_RE.match(raw)
        if not m:
            continue

        verb = m.group("verb")
        tag = m.group("tag")
        rhs = (m.group("rhs") or "").strip()

        # Keep is non-op
        if verb == "KEEP":
            continue

        tag_csv = _tag_for_csv(tag)

        if verb == "REMOVE":
            rows.append(["", "delete_tag", _tag_for_op_csv(tag_csv, "delete_tag"), _val1_for_csv("<>"), "<>", ""])
            continue

        if verb == "BLANK":
            rows.append(["", "empty_tag", _tag_for_op_csv(tag_csv, "empty_tag"), _val1_for_csv("<>"), "<>", ""])
            continue

        if verb in ("REPLACE", "ADD"):
            # UID hashing
            if rhs.startswith("deid_func:hash_uid"):
                uid_root = (ctx.get("uid_root") or "").strip()
                if not uid_root:
                    raise RuntimeError(f"Recipe requested hash_uid for {tag}, but uid_root resolved empty")
                rows.append(["", "hash_unhashed_uid", _tag_for_op_csv(tag_csv, "hash_unhashed_uid"), _val1_for_csv(uid_root), "<>", ""])
                continue

            # Date shifting
            if rhs.startswith("deid_func:increment_date"):
                days = str(ctx.get("date_shift_days") or "0")
                rows.append(["", "shift_date", _tag_for_op_csv(tag_csv, "shift_date"), _val1_for_csv(days), "<>", ""])
                continue

            # Variables
            if rhs.startswith("var:"):
                key = rhs.split(":", 1)[1].strip()
                val = str(ctx.get(key, ""))
                rows.append(["", "set_tag", _tag_for_op_csv(tag_csv, "set_tag"), _val1_for_csv(val), "<>", ""])
                continue

            # Literal sets (best-effort)
            if rhs:
                val = _strip_quotes(rhs)
                rows.append(["", "set_tag", _tag_for_op_csv(tag_csv, "set_tag"), _val1_for_csv(val), "<>", ""])
                continue

    return rows


def write_patient_series_edits(background, file_rows, mapping, recipe, args):

    edit_desc = "Initial DEID Recipe Anonymzer Edits"

    rpt = background.create_report("EditsFromDeidRecipe")
    writer = csv.writer(rpt)

    # write header
    writer.writerow(
        [
            "series_instance_uid",
            "op",
            "tag",
            "val1",
            "val2",
            "Operation",
            "activity_id",
            "edit_description",
            "notify",
        ]
    )

    # write operation row
    writer.writerow(
        [
            None,
            None,
            None,
            None,
            None,
            "BackgroundEditTp", 
            args.activity_id, 
            edit_desc, 
            args.notify
        ]
    )

    # Group series by patient
    patient_series: DefaultDict[str, List[str]] = defaultdict(list)
    for file_row in file_rows:
        # file_row indices: file_id, storage_path, media_storage_sop_class, modality, sop_instance_uid, series_instance_uid, study_instance_uid, patient_id, for_uid
        # Use patient_id and series_instance_uid
        from_patient_id = str(file_row.patient_id) if file_row.patient_id is not None else None
        series_uid = str(file_row.series_instance_uid) if file_row.series_instance_uid is not None else ""
        if not from_patient_id or not series_uid:
            continue

        if series_uid not in patient_series[from_patient_id]:
            patient_series[from_patient_id].append(series_uid)

    # For each patient, list series first, then patient-level edits once
    for from_patient_id, series_list in patient_series.items():
        for series_uid in series_list:
            writer.writerow([series_uid])

        map_rows = mapping.get(from_patient_id) or []
        if not map_rows:
            # Skip unmapped patients (Perl filters these out)
            continue

        # Use first mapping row only
        map_row = map_rows[0]
        ctx = resolve_context(recipe.labels, map_row)

        for row in emit_rows_for_patient(
            recipe=recipe,
            ctx=ctx,
        ):
            writer.writerow(row)


#--------------------------------------------------


def parse_args() -> argparse.Namespace:
    ap = argparse.ArgumentParser()
    ap.add_argument("background_id")
    ap.add_argument("collection")
    ap.add_argument("site")  
    ap.add_argument("recipe_file_id", help="Path to deid recipe file (FORMAT deid.dicom)")      
    ap.add_argument("activity_id", type=int)
    ap.add_argument("notify")
    ap.add_argument("--force_api", action="store_true", help="Force API calls for recipe file, even if local filesystem access is possible")
    return ap.parse_args()


#--------------------------------------------------


def main2(args, background) -> int:
    conn = Database("posda_files")
    recipe_file_id = args.recipe_file_id
    collection = args.collection
    site = args.site

    recipe = get_recipe(args, recipe_file_id)
    file_rows = get_activity_files(args, conn)
    mapping = get_patient_mapping(conn, collection, site)

    write_patient_series_edits(background, file_rows, mapping, recipe, args)

    background.finish("Complete")
    return 0


def main(args):
    """
    Main entry point, just wraps the other main and catches
    exceptions, so that the script always finishes. It still
    exits with a nonzero exit code so the script will be flagged
    as failed.
    """
    background = BackgroundProcess(args.background_id, args.notify, args.activity_id)
    background.daemonize()

    try:
        main2(args, background)
    except Exception as e:
        print("FATAL ERROR:", e)
        background.finish("Failed")
        raise e

    return 0


if __name__ == "__main__":
    sys.exit(main(parse_args()))







