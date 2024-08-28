#!/usr/bin/env python3

import os
import sys
import time
import shutil
import argparse
from posda.database import Database
from posda.queries import Query
from posda.background.process import BackgroundProcess
from posda.nifti.parser import NiftiParser

about="""\
This script detects nifti files in an activity and parses them into the File Nifti Table.
"""

def set_insert_parms(nifti, file_id):
    parms = [file_id]
    set_remaining_parms(parms, nifti)
    return parms

def set_update_parms(nifti, file_id):
    parms = []
    set_remaining_parms(parms, nifti)
    parms.append(file_id)
    return parms

def set_remaining_parms(parms, nifti):
    p = nifti.header_parsed
    parms.extend([
        p['magic'],
        nifti.is_zipped,
        p['descrip'], p['aux_file'], p['bitpix'], p['datatype'],
        p['dim'][0], p['dim'][1], p['dim'][2], p['dim'][3],
        p['dim'][4], p['dim'][5], p['dim'][6], p['dim'][7],
        p['pixdim'][0], p['pixdim'][1], p['pixdim'][2], p['pixdim'][3],
        p['pixdim'][4], p['pixdim'][5], p['pixdim'][6], p['pixdim'][7],
        p['intent_code'], p['intent_name'], p['intent_p1'],
        p['intent_p2'], p['intent_p3'], p['cal_max'], p['cal_min'],
        p['scl_slope'], p['scl_inter'], p['slice_start'], p['slice_end'],
        p['slice_code'], p['sform_code'], p['srow_x'][0], p['srow_x'][1],
        p['srow_x'][2], p['srow_x'][3], p['srow_y'][0], p['srow_y'][1],
        p['srow_y'][2], p['srow_y'][3], p['srow_z'][0], p['srow_z'][1],
        p['srow_z'][2], p['srow_z'][3], p['xyzt_units'], p['qform_code'],
        p['quatern_b'], p['quatern_c'], p['quatern_d'], p['qoffset_x'],
        p['qoffset_y'], p['qoffset_z'], p['vox_offset']
    ])

def main(args):

    invoc_id = args.background_id
    activity_id = args.activity_id
    update_existing = bool(int(str(args.update_existing).strip().lower() in ['true', '1']))
    notify = args.notify

    back = BackgroundProcess(invoc_id, notify, activity_id)
    back.daemonize()
    start = time.time()

    files = {}
    file_query = Query('FileIdTypePathFromActivity')
    file_query_results = file_query.run(activity_id)
    for file_result in file_query_results:
        files[file_result[0]] = {'path': file_result[2], 'type': file_result[1]}
    #print(files)

    get_file_nifti = Query('GetFileNifti')
    create_file_nifti = Query('CreateFileNifti')
    update_file_nifti = Query('UpdateFileNifti')
    change_file_type = Query('ChangeFileType')

    num_files = len(files)
    current = 0
    num_skipped = 0
    num_not_parsed = 0
    num_inserted = 0
    num_updated = 0

    for file_id, file_info in files.items():
        file_type = file_info['type']
        file_path = file_info['path']
        
        row_count = get_file_nifti.execute(file_id)
        existing_row = True if row_count > 0 else False
        
        current += 1
        back.set_activity_status(f"Processing {current} of {num_files}; skipped: {num_skipped}; inserted: {num_inserted}; not_parsed: {num_not_parsed}; updated: {num_updated}")
    
        if existing_row:
            if not update_existing:
                num_skipped += 1
                continue

        nifti = None
        if file_type.startswith("Nifti") or file_type.startswith("gzip"):
            nifti = NiftiParser(file_path)
        elif file_type == "data":
            file_data = open(file_path, 'rb')
            file_data.seek(0)
            type_check = file_data.read(352)
            if type_check[344:348] in [b'n+1\0', b'ni1\0'] or type_check[4:8] in [b'n+2\0', b'ni2\0']:
                nifti = NiftiParser(file_path)
    
        if nifti:
            back.print_to_email(f"Nifti File: {file_id}")
        else:
            num_not_parsed += 1
            continue

        nifti_file_type = "Nifti Image (gzipped)" if nifti.is_zipped else "Nifti Image"
        
        if nifti_file_type != file_type:
            change_file_type.execute(nifti_file_type, file_id)
            
        if existing_row:
            back.print_to_email(f"Existing Row for {file_id}")
            parms = set_update_parms(nifti, file_id)
            update_file_nifti.execute(*parms)
            num_updated += 1
        else:
            back.print_to_email(f"No Existing Row for {file_id}")
            parms = set_insert_parms(nifti, file_id)
            create_file_nifti.execute(*parms)
            num_inserted += 1
            
        nifti.close()

    elapsed = time.time() - start
    back.print_to_email(f"Processed {num_files} files in {elapsed} seconds.")
    back.print_to_email(f"Processed {current} of {num_files}; skipped: {num_skipped}; inserted: {num_inserted}; not_parsed: {num_not_parsed}; updated: {num_updated} \n")
    back.finish(f"Processed {current} of {num_files}; skipped: {num_skipped}; inserted: {num_inserted}; not_parsed: {num_not_parsed}; updated: {num_updated}")

def parse_args():
    parser = argparse.ArgumentParser(description=about)
    parser.add_argument('background_id', nargs='?', default='', help='the background_subprocess_id (blank for CL Mode)')
    parser.add_argument('activity_id', help='the activity nifti files are in')
    parser.add_argument('update_existing', help='update found records or skip')
    parser.add_argument('notify', help='user to notify when complete')
    return parser.parse_args()

if __name__ == '__main__':
    main(parse_args())