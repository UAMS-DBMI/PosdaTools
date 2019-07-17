#!/usr/bin/python3 -u
import requests

my_vrs = []

r = requests.get('http://web/papi/v1/vrstatus/find_vr_ready_to_begin_status_updates')
resp = r.json()


for vr in resp:
    #get review summary for vr
    r = requests.get("http://web/papi/v1/vrstatus/get_reviewed_percentage_for_vr/{}".format(vr['visual_review_instance_id']))
    resp2 = r.json()

    my_status = " "
    for entry in resp2:
        my_status += entry['summary'] + ' '


    if (my_status[:15] == " Reviewed 100% "):
        r = requests.get("http://web/papi/v1/vrstatus/get_visible_bads_for_vr/{}".format(vr['visual_review_instance_id']))
        resp3 = r.json()
        for entry in resp3:
            my_status = entry['summary'] + ''

    if (my_status == "Reviewed 100% , 0 files need to be set to Bad and hidden to continue."):
        my_status = "Complete"

    #update activity_status for vr
    r = requests.get("http://web/papi/v1/vrstatus/update_activity_status/{}/{}".format(vr['visual_review_instance_id'],my_status))
    if (my_status == "Complete"):
        requests.get("http://web/papi/v1/vrstatus/finish_activity_status/{}".format(vr['visual_review_instance_id']))
    resp4 = r.json()
