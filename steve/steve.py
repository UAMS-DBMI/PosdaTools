#!/usr/bin/python3 -u
import os
import time
import datetime
from datetime import timedelta
from posda.database import Database

class Job():
    def __init__(self,name,schedule,db,instructions):
        self.name =  name.strip()
        self.schedule = schedule.strip()
        self.db = db.strip()
        self.instructions = instructions.strip()
        self.set_next_time()

    def time_check(self):
        return datetime.datetime.now() > self.nextTime

    def set_next_time(self):
        self.nextTime = datetime.datetime.now() + timedelta(minutes=(int(schedule)))
        #print("next time is " + str(self.nextTime))
        return

    def walk_briskly(self):

        print(" " + self.name + " job running at " + str(datetime.datetime.now()) )

        with Database(self.db) as conn:
            cur = conn.cursor()
            cur.execute(self.instructions)

        self.set_next_time()
        return


myjobs = []
try:
    with os.scandir('/steve/jobs') as dir:
        for entry in dir:
            if entry.is_file():
                if entry.name[:1] != '.': #don't import . files
                    with open(entry.path) as file:
                        name = file.readline()
                        schedule = file.readline()
                        db = file.readline()
                        instructions = file.read()
                    myjobs.append(Job(name,schedule,db,instructions))
            elif entry.is_dir(follow_symlinks=False):
                self.read_file_structure(entry)
except Exception as e:
    print("Error: {0}".format(e))

print("Steve, the job runner")

while True:
    time.sleep(60)
    #print("checking")
    for job in myjobs:
        if job.time_check():
            job.walk_briskly()
