#!/usr/bin/env python3

import argparse
import csv
import sys
import os
import httpx
import json
import requests
from posda.database import Database
from posda.queries import Query
from posda.background.process import BackgroundProcess
from posda.config import Config
from openslide import OpenSlide

URL = "https://pathdb.cancerimagingarchive.net"
USERNAME = "imageloader"
PASSWORD = "REDACTED"
DEBUGMODE = False

def  call_api(unique_url, call_type):
    base_url = '{}/v1/pathology'.format(Config.get('internal-api-url'))
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
            reso = response.json()
            return reso
        except ValueError as e:  # Catch JSON decoding errors
            print(f"Error decoding JSON from response: {e}")
            return None  # or {}, [] based on expected data type
    else:
        print(f"Error fetching data. Status code: {response.status_code}, Response: {response.text}")
        return None  # or {}, [] based on expected data type

#from pathdb-api-experiments
class Node:
    def from_node(node):
        format_str = "?_format=json"

        node_url = f"{URL}/node/{node}{format_str}"
        response = httpx.get(node_url)

        response.raise_for_status()  # Raise an error for bad responses

        return Node(response.json())

    def __init__(self, content):
        self.content = content

    def __getattr__(self, item):
        if item in self.content:
            val = self.content[item]
            if len(val) == 0:
                return None
            first = val[0]
            if len(first) == 1 and "value" in first:
                return first["value"]
            else:
                return first
        raise AttributeError(f"'{self.__class__.__name__}' object has no attribute '{item}'")

    def get_url(self):
        return self.field_wsiimage["url"]

#from pathdb-api-experiments
def get_all_collections():
    format_str = "?_format=json"
    # NOTE: must send login info to see ALL collections,
    # otherwise it only returns public ones
    response = httpx.get(
        f"{URL}/collections{format_str}",
        auth=(USERNAME, PASSWORD),
    )
    response.raise_for_status()  # Raise an error for bad responses

    data = response.json()

    return [(item["name"][0]["value"],
             item["tid"][0]["value"]
             ) for item in data]

#from pathdb-api-experiments
def get_nodes_for_collection(collection):

    response = httpx.get(f"{URL}/idmap/{collection}")
    response.raise_for_status()  # Raise an error for bad responses
    data = response.json()

    return [item["PathDBID"] for item in data]



def export_file(fileid, path, collectionname, studyid, clinicaltrialsubjectid, imageid ,reference_pixel_physical_value_x,reference_pixel_physical_value_y,image_volume_width, image_volume_height):
        # in order to get the collection ID, we need to look it up
        collection_id = next((tid for name, tid in get_all_collections() if name == collectionname), None)

        if DEBUGMODE:
            n = 1
            print("File {} is now Node {}.".format(fileid,n))
            print("Node Data: \n Collection {}\n Study {}\n Trial{}\n ImageId{}\n  Mppx {}\n  Mppy{}\n  Width {} \n Hieght {}\n".format(collectionname,studyid, clinicaltrialsubjectid, imageid ,reference_pixel_physical_value_x,reference_pixel_physical_value_y,image_volume_width, image_volume_height))
            call_api("/recordPathDBresponse/{}/{}".format(fileid,n), 2)
            return True
        else:
            if collection_id is None:
                print(f"Collection '{collectionname}' not found")
                return False
            # create the node on the server; it replies with more details about the node
            res = create_new_node(
                collection_id=collection_id,
                study_id=studyid,
                subject_id=clinicaltrialsubjectid,
                image_id=imageid,
                filename=path,
                image_volume_height=image_volume_height,
                image_volume_width=image_volume_width,
                reference_pixel_physical_value_x=reference_pixel_physical_value_x,
                reference_pixel_physical_value_y=reference_pixel_physical_value_y)
            n = Node(res)
            if n:
                call_api("/recordPathDBresponse/{}/{}".format(fileid,n.nid), 2)
                return True
            else:
                return False

#from pathdb-api-experiments
def create_new_node(
        collection_id: int,
        study_id: str,
        subject_id: str,
        image_id: str,
        filename: str,
        # need to get these values from the image metadata
        image_volume_height: int,
        image_volume_width: int,
        reference_pixel_physical_value_x: int,
        reference_pixel_physical_value_y: int):

    payload = {
        "clinicaltrialsubjectid" : [
            {
                "value" : subject_id
            }
        ],
        "field_collection" : [
            {
                "target_id" : collection_id,
                "url" : f"/taxonomy/term/{collection_id}"
            }
        ],
        "field_utarget" : [
            {
                "value" : f"private://wsi/ross/{filename}"
            }
        ],
        "imagedvolumeheight" : [
            {
                "value" : image_volume_height
            }
        ],
        "imagedvolumewidth" : [
            {
                "value" : image_volume_width
            }
        ],
        "imageid" : [
            {
                "value" : image_id
            }
        ],
        "referencepixelphysicalvaluex" : [
            {
                "value" : reference_pixel_physical_value_x
            }
        ],
        "referencepixelphysicalvaluey" : [
            {
                "value" : reference_pixel_physical_value_y
            }
        ],
        "studyid" : [
            {
                "value" : study_id
            }
        ],
        "title" : [
            {
                "value" : filename
            }
        ],
        "type" : [
            {
                "target_id" : "wsi"
            }
        ]
    }

    return post_basic_auth(f"{URL}/node?_format=json", USERNAME, PASSWORD, payload)

#from pathdb-api-experiments
def post_basic_auth(post_url, username, password, data):
    """
    POST a JSON object to a URL with Basic HTTP authentication

    Args:
        post_url (str): The URL to send the POST request to
        username (str): Username for Basic HTTP authentication
        password (str): Password for Basic HTTP authentication
        data (dict): The data to send in the POST request (as JSON)
    """

    if not DEBUGMODE:
        #Create the request with Basic auth
        response = httpx.post(
            post_url,
            json=data,
            auth=(username, password),
            headers={"Content-Type": "application/json"}
        )

    response.raise_for_status()  # Raise an error for bad responses

    returned_data = response.json()

    return returned_data


def main(pargs,records):

    background = BackgroundProcess(pargs.background_id, pargs.notify, pargs.activity_id)
    background.daemonize()

    totalSuccess = 0
    failures = 0

    for r in records:
        successful = False
        print(r['path'])
        try:
            myImage = OpenSlide(r['path'])
            prop = myImage.properties
            dims = myImage.dimensions
            image_volume_width = float(dims[0])
            image_volume_height =  float(dims[1])
            reference_pixel_physical_value_x = 0
            reference_pixel_physical_value_y = 0
            if prop.get("openslide.mpp-x", 0) and prop.get("openslide.mpp-y", 0):
                reference_pixel_physical_value_x = float(prop.get("openslide.mpp-x", 0))
                reference_pixel_physical_value_y = float(prop.get("openslide.mpp-y", 0))
            else: #calculate
                res_unit = prop.get("tiff.ResolutionUnit")  # 2 = inch, 3 = cm
                xres = prop.get("tiff.XResolution")
                yres = prop.get("tiff.YResolution")
                divisor = 10000.0 #cm default
                if res_unit:
                    if res_unit == "inch":
                        divisor = 25400.0
                if xres and yres:
                    reference_pixel_physical_value_x = divisor / (float(xres.split('/')[0]) / float(xres.split('/')[1]))
                    reference_pixel_physical_value_y = divisor / (float(yres.split('/')[0]) / float(yres.split('/')[1]))
            cropped_path = str(r['path']).replace('/nas/ross/','')
            successful = export_file(r['fileid'],cropped_path,r['collectionname'],r['studyid'],r['clinicaltrialsubjectid'],r['imageid'],reference_pixel_physical_value_x,reference_pixel_physical_value_y,image_volume_width, image_volume_height)
        except Exception as e:
            print(f"Error: {e}")
        if successful:
            totalSuccess=totalSuccess+1
        else:
            failures=failures+1

    print("Pathology export complete. {} files sent successfully. {} failures.".format(totalSuccess,failures))
    background.finish("Complete")

if __name__ == "__main__":
    parser = argparse.ArgumentParser(description="PathologyExporter")
    parser.add_argument("background_id")
    parser.add_argument("activity_id")
    parser.add_argument("notify")
    records = []
    for line in sys.stdin:
        root, path, collectionname, studyid, clinicaltrialsubjectid, imageid, fileid = (line.rstrip()).split('&')
        mappingData = {}
        mappingData['path'] = os.path.join(root, path)
        mappingData['collectionname'] = collectionname
        mappingData['studyid'] = studyid
        mappingData['clinicaltrialsubjectid'] = clinicaltrialsubjectid
        mappingData['imageid'] = imageid
        mappingData['fileid'] = fileid
        records.append(mappingData)

    args = parser.parse_args()
    main(args,records)
