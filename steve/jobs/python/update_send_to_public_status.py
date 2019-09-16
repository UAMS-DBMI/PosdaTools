#!/usr/bin/python3 -u
import requests

my_subprocesses = []

r = requests.get('http://web/papi/v1/send_to_public_status/find_send_ready_to_begin_status_updates')
resp = r.json()


for record in resp:
    #get review summary for record
    r = requests.get("http://web/papi/v1/send_to_public_status/get_success_percentage_for_send/{}".format(record['subprocess_invocation_id']))
    resp2 = r.json()

    my_status = " "
    for entry in resp2:
        if entry['summary'] is not None:
            my_status += entry['summary'] + ' '

    #find percentages and see if they add to 100
    index1 = (my_status.strip()).find(' ')
    index2 = (my_status.strip()).find('%')
    index3 = (my_status.strip()).rfind(' ')
    index4 = (my_status.strip()).rfind('%')

    numOne = int( (my_status.strip())[index1:index2])
    numTwo = int( (my_status.strip())[index3:index4])


    if (numOne + numTwo == 100):
        my_status = "Complete"

    #update activity_status for record
    r = requests.get("http://web/papi/v1/send_to_public_status/update_activity_status/{}/{}".format(record['subprocess_invocation_id'],my_status))
    if (my_status == "Complete"):
        requests.get("http://web/papi/v1/send_to_public_status/finish_activity_status/{}".format(record['subprocess_invocation_id']))
    resp4 = r.json()
