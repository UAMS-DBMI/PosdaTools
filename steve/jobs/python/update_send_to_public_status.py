#!/usr/bin/python3 -u
import requests

my_subprocesses = []

r = requests.get('http://web/papi/v1/vrstatus/find_vr_ready_to_begin_status_updates')
resp = r.json()


for record in resp:
    #get review summary for vr
    r = requests.get("http://web/papi/v1/vrstatus/get_success_percentage_for_send/{}".format(record['subprocess_invocation_id']))
    resp2 = r.json()

    my_status = " "
    for entry in resp2:
        my_status += entry['summary'] + ' '

    if (my_status == " false 0% true 100% " or " true 100% false 0% "):
        my_status = "Complete"

    #update activity_status for vr
    r = requests.get("http://web/papi/v1/vrstatus/update_activity_status/{}/{}".format(vr['subprocess_invocation_id'],my_status))
    if (my_status == "Complete"):
        requests.get("http://web/papi/v1/vrstatus/finish_activity_status/{}".format(vr['subprocess_invocation_id']))
    resp4 = r.json()
