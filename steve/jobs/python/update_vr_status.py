#!/usr/bin/python3 -u
import requests
import logging

from posda.config import Config
import posda.logging.autoconfig


base_url = Config.get("internal-api-url")
my_vrs = []

r = requests.get(
    '{}/v1/vrstatus/find_vr_ready_to_begin_status_updates'.format(
        base_url
    )
)
resp = r.json()

logging.info("Found %s Visual Reviews ready to begin status updates", len(resp))

for vr in resp:
    vr_id = vr['visual_review_instance_id']
    logging.info("Processing VR %s...", vr_id)

    #get review summary for vr
    r = requests.get(
        "{}/v1/vrstatus/get_reviewed_percentage_for_vr/{}".format(
            base_url, vr_id
        )
    )
    resp2 = r.json()

    my_status = " "
    for entry in resp2:
        if entry['summary'] is not None:
            my_status += entry['summary'] + ' '


    if (my_status[:15] == " Reviewed 100% "):
        r = requests.get(
            "{}/v1/vrstatus/get_visible_bads_for_vr/{}".format(
                base_url, vr_id
            )
        )
        resp3 = r.json()
        for entry in resp3:
            my_status = entry['summary'] + ''

    if (my_status == "Reviewed 100% , 0 files need to be set to Bad and hidden to continue."):
        my_status = "Complete"

    #update activity_status for vr
    logging.info("Updating VR %s status to: %s", vr_id, my_status)
    r = requests.get(
        "{}/v1/vrstatus/update_activity_status/{}/{}".format(
            base_url, vr_id, my_status
        )
    )
    if (my_status == "Complete"):
        logging.info("Marking VR %s as complete.", vr_id)
        requests.get(
            "{}/v1/vrstatus/finish_activity_status/{}".format(
                base_url, vr_id
            )
        )
    resp4 = r.json()

logging.info("Complete")
