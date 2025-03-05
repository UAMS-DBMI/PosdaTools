#!/usr/bin/env python3

import os
import sys
import csv
import argparse
import pydicom
import requests
from posda.config import Config
from posda.database import Database
from posda.queries import Query
from posda.background.process import BackgroundProcess


about="""\
This script adds segmentation linkage data to the posda database and reports to the user if any linked SOPs are missing.
"""

def  call_api(unique_url, call_type):
    base_url = '{}/v1/segs'.format(Config.get('internal-api-url'))
    #base_url = '{}/v1/pathology'.format(POSDA_INTERNAL_API_URL)
    API_KEY = Config.get('api_system_token')
    HEADERS = {'Authorization': f'Bearer {API_KEY}'}
    url = "{}{}".format(base_url,unique_url)
    if call_type == 0:
        response = requests.get(url,headers=HEADERS)
    elif call_type == 1:
        response = requests.patch(url,headers=HEADERS)
    elif call_type == 2:
        response = requests.put(url,headers=HEADERS)

    # Check if the response status code indicates success
    if response.ok:
        try:
            res = response.json()
            return res
        except ValueError as e:  # Catch JSON decoding errors
            print(f"Error decoding JSON from response: {e}")
            return None  # or {}, [] based on expected data type
    else:
        print(f"Error fetching data. Status code: {response.status_code}, Response: {response.text}")
        return None  # or {}, [] based on expected data type

def find_segs_in_activity(activity_id):
        str = "/find_segs_in_activity/{}".format(activity_id)
        return call_api(str, 0)

def populate_seg_linkages(file_id, seg_id, linked_sop_instance_uid, linked_sop_class_uid):
        str = "/populate_seg_linkages/{}/{}/{}/{}".format(file_id, seg_id, linked_sop_instance_uid, linked_sop_class_uid)
        return call_api(str, 2)

def get_linked_file_info(sop_instance_uid):
    str = "/getLatestFileForSop/{}".format(sop_instance_uid)
    return call_api(str, 0)

def get_Linked_FileFOR(file_id):
    str = "/getFORfromfile/{}".format(file_id)
    return call_api(str, 0)

def getSeries(file_id):
    str = "/getSeries/{}".format(file_id)
    return call_api(str, 0)

def createCSVReports(args,background,result_data,cname,direction):
     result_list = list(result_data)
     result_container = []
     firstline = True
     for i in range(0,len(result_list),500):
        result_container.append(result_list[i:i+500])
     for j in range(len(result_container)):
        r = background.create_report(cname)
        writer = csv.writer(r)
        writer.writerow(['series_instance_uid','op','tag','val1','val2','Operation','activity_id','edit_description','notify'])
        lastSeries = ''
        for k in result_container[j]:
                if k[0] != lastSeries:
                    if(firstline):
                        writer.writerow([k[0],'','','','','BackgroundEditTp', args.activity_id, 'Repairing SEG Frame of Reference Linkages', args.notify])
                        firstline = False
                    else:
                        writer.writerow([k[0]])
                if(direction):
                        writer.writerow(['','set_tag', '<(0020,0052)>','<{}>'.format(k[1]),'<{}>'.format(k[2])])
                else:
                    if(firstline):
                        writer.writerow(['', 'set_tag', '<(0020,0052)>','<{}>'.format(k[2]),'<{}>'.format(k[1])])
                        firstline = False
                    else:
                        writer.writerow(['', 'set_tag', '<(0020,0052)>','<{}>'.format(k[2]),'<{}>'.format(k[1])])

def main(args):
    background = BackgroundProcess(args.background_id, args.notify, args.activity_id)
    background.daemonize()
    success = 0
    fail = 0
    for_fail = 0
    numSEGs = 0
    csv_data = set()
    mySEGFiles = find_segs_in_activity(args.activity_id)
    if (mySEGFiles):
        numSEGs = len(mySEGFiles)
        for f in mySEGFiles:
            current = success
            ds = pydicom.dcmread(f['path'])
            try:
                if hasattr(ds, "FrameOfReferenceUID"):
                    segFOR = ds.FrameOfReferenceUID
                    print("\nSegmentation {} found. Frame of Reference UID: {} \n".format(f['file_id'], segFOR))
                if hasattr(ds, "ReferencedSeriesSequence"):
                    referenced_series = ds.ReferencedSeriesSequence[0]
                    if hasattr(referenced_series, "ReferencedInstanceSequence"):
                        referenced_instances = referenced_series.ReferencedInstanceSequence
                        for instance in referenced_instances:
                            #get the file_id for the SOP proving the linked file is in posda
                            linked_file = get_linked_file_info(instance.ReferencedSOPInstanceUID)[0]['file_id']
                            if (linked_file):
                                    #Get the series and frame of reference
                                    linked_FOR = get_Linked_FileFOR(linked_file)[0]['for_uid']
                                    linked_series = getSeries(linked_file)[0]['series_instance_uid']
                                    #if the FOR matches the linkage is good
                                    if linked_FOR and segFOR == linked_FOR:
                                        success = success + 1
                                        populate_seg_linkages(linked_file, f['file_id'], str(instance.ReferencedSOPInstanceUID), str(instance.ReferencedSOPClassUID))
                                    else:
                                        for_fail = for_fail + 1
                                        if segFOR is None:
                                            segFOR = ''
                                        if linked_FOR is None:
                                                linked_FOR = ''
                                        triple = (linked_series, segFOR, linked_FOR)
                                        csv_data.add(triple)
                                        #print ("Reference SOP: {} was found, but has non-matching Frame of Reference {}".format(linked_file,linked_FOR))
                            else:
                                print ("Reference SOP: {} was not found".format(instance))
                                fail = fail + 1
            except Exception as e:
                print( "Linkage failed. {}".format(e))
                fail = fail + 1
            print("\n{} linkages found for this segmentation.\n".format((success - current)))
    else:
        print("No Segmentation objects found in activity.")

    if numSEGs > 0:
        print("\n{} missing SOPs. {} files had non matching Frame OF References.\n{} file linkages verified for {} segmentations.\n".format( fail, for_fail,success, numSEGs))
        name = "change_seg_for_{}{}{}{}.csv".format(args.background_id,numSEGs,for_fail,args.activity_id)
        createCSVReports(args,background,csv_data,name,1)
        name = "change_image_fors_{}{}{}{}.csv".format(args.background_id,numSEGs,for_fail,args.activity_id)
        createCSVReports(args, background,csv_data,name,0)
    background.finish("Process complete")

def parse_args():
    parser = argparse.ArgumentParser(description=about)
    parser.add_argument('background_id', nargs='?', default='', help='the background_subprocess_id (blank for CL Mode)')
    parser.add_argument('activity_id', help='the activity seg files are in')
    parser.add_argument('notify', help='user to notify when complete')
    return parser.parse_args()

if __name__ == '__main__':
    main(parse_args())
