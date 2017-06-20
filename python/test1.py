#!/usr/bin/env python3.6

from posda.main import printe
from posda.queries import Query

import time

MYPID=7 # TODO: fix this

def main():

    get_import = Query("GetPosdaFilesImportControl")
    go_in_service = Query("GoInServicePosdaImport")
    quit_q = Query("RelinquishControlPosdaImport")

    while True:
        # get current status
        for import_control in get_import.run(): pass

        if import_control.status == "waiting to go inservice":
            go_in_service.execute(MYPID)
            continue

        if import_control.status == "service process running":
            if import_control.processor_pid != MYPID:
                printe("Some other process controlling import")
                return

            if import_control.pending_change_request == "shutdown":
                quit_q.execute()
                printe("Relinquished control of posda_import")
                return

            printe("Doing actual work (well, pretending)")

        else:
            printe(f"unknown state ({import_control.status}) for posda_import")

def do_actual_work(import_control):
    if True: # remain_count == 0
        printe(f"Sleeping {import_control.idle_seconds} seconds")
        time.sleep(import_control.idle_seconds)

if __name__ == "__main__":
    main()
