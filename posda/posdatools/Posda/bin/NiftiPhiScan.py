#!/usr/bin/env python3

import sys
import os
import csv
import argparse
from pathlib import Path
import nibabel as nib
import pydicom as dcm

from posda.database import Database
from posda.queries import Query
from posda.background.process import BackgroundProcess
from posda.nifti.parser import NiftiParser

about="""\
This script creates a Nifti PHI review.
"""

def create_nifti_phi_scan(args):
    
    desc = f"NIfTI PHI Scan for activity {args.activity_id}"
    background = BackgroundProcess(args.background_id, args.notify, args.activity_id)
    background.daemonize()

    background.print_to_email(f"Activity {args.activity_id} ")
    phi_scan_id = Query("CreateNiftiPHIScan").get_single_value(description = desc)
    background.print_to_email(f"Nifti PHI Scan ID: {phi_scan_id}")

    nifti_files = []    
    for row in Query("NiftiFilePathsFromActivity").run(activity_id=args.activity_id):
        nifti_files.append((row.file_id, os.path.join(row.root_path, row.rel_path)))
        
    report_vars = ['data_type', 'db_name', 'descrip', 'aux_file', 'intent_name', 'magic']
    report_files = {}
    for (file_id, file_path) in nifti_files:
        #print(f'file: {file_id} ----------------------------------------------')
        orig_file_path = Query("SimpleFilenameFetch").get_single_value(file_id = file_id)
        report_files[file_id] = {'file_id': file_id, 'file_path': Path(orig_file_path).parent, 'file_name': Path(orig_file_path).name}
        #print(f'file_id : {file_id}')
        #print(f'file_path : {Path(orig_file_path).parent}')
        #print(f'file_name : {Path(orig_file_path).name}')
        
        nifti = NiftiParser(file_path)
        header = nifti.header_parsed
        for tag, value in header.items():
            #if tag == 'extensions':
                # for tag, value in value.items():
                #     report_files[file_id][tag] = value
                #     print(f'{tag} : {value}')
            #elif tag in report_vars:
            if tag in report_vars and tag != 'extensions':    
                report_files[file_id][tag] = value
                #print(f'{tag} : {value}')            
                
        # header = nifti.file_nib.header
        # for var in report_vars:
        #     report_files[file_id][var] = header[var].item()
        #     print(f'{var} : {header[var].item()}')
            
        extensions = nifti.file_nib.header.extensions
        for i, extension in enumerate(extensions):
            ext_name = f'ext_{i}'
            report_files[file_id][ext_name] = extension
            #print(f'{ext_name} : {extension}')
              
    #print(report_files)

    saveNiftiMetaData(nifti, report_files, args.activity_id, phi_scan_id)

    createCSVReports(report_files, phi_scan_id, background)
    
    background.finish(f"Nifti PHI Scan ID:{phi_scan_id}")

    return None

def saveNiftiMetaData(nifti, report_files, activity_id, phi_scan_id):
    for file_id, file_data in report_files.items():
        #print(f'file: {file_id} ----------------------------------------------')        
        for tag, value in file_data.items():
            #print(f'{tag} : {value}')
            if sys.getsizeof(value) < 2500:
                tag_seen_id = Query("GetNiftiTagSeen").get_single_value(tag_name = tag)
                if not tag_seen_id:
                    tag_seen_id = Query("InsertNiftiTagSeen").get_single_value(tag_name = tag)
                value_seen_id = Query("GetNiftiValueSeen").get_single_value(value = str(value))
                if not value_seen_id:
                    value_seen_id = Query("InsertNiftiValueSeen").get_single_value(value = str(value))
                Query("InsertNiftiValueOccurrence").execute(nifti_tag_seen_id = tag_seen_id, nifti_value_seen_id = value_seen_id, nifti_phi_scan_instance_id = phi_scan_id, file_id = file_id)
            else:
                print(f'*** Tag: {tag.name} has data too large to save. ***'.format())


def createCSVReports(report_files, phi_scan_id, background):

    batch_size = 500
    file_ids = list(report_files.keys())    
    batches = [{file_id: report_files[file_id] for file_id in file_ids[i:i + batch_size]} for i in range(0, len(file_ids), batch_size)]

    for i, batch in enumerate(batches):

        report_lines = []

        for file_id, file_data in batch.items():
            file_path = file_data['file_path']
            file_name = file_data['file_name']
            file_template = {'file_id':file_id, 'file_path':file_path, 'file_name':file_name}
            for tag, value in file_data.items():
                if tag not in ['file_id', 'file_path', 'file_name']:
                    tag_dict = file_template.copy()
                    tag_dict['tag_name'] = tag
                    tag_dict['tag_value'] = value
                    report_lines.append(tag_dict)

        report_name = f"nifti_phi_{phi_scan_id}_{i}.csv"
        r = background.create_report(report_name)
        writer = csv.writer(r)
        writer.writerow(['File ID', 'File Path', 'File Name', 'Tag Name','Tag Value'])
        for line in report_lines:
            writer.writerow([line['file_id'],line['file_path'],line['file_name'],line['tag_name'],line['tag_value']])


def main(args):
    create_nifti_phi_scan(args)


def parse_args():
    parser = argparse.ArgumentParser(description=about)
    parser.add_argument('background_id', nargs='?', default='', help='the background_subprocess_id (blank for CL Mode)')
    parser.add_argument('activity_id', help='the activity nifti files are in')
    parser.add_argument('notify', help='user to notify when complete')
    return parser.parse_args()

if __name__ == '__main__':
    main(parse_args())
