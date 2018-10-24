#!/usr/bin/python3.6 -u

import os
import sys
import time

from posda.main import printe

parent_pid = os.getpid()

print("Starting up.. verifying inputs and stuff, about to fork..")


sys.stdin.close()
sys.stdout.close()
# if we don't close stderr the parent is not released???
# sys.stderr.close()

child_pid = os.fork()

if child_pid != 0:
    printe(f"I am the parent! my pid is: {parent_pid}, and my child's pid is: {child_pid}")
    os._exit(1)
    # sys.exit(1)

mypid = os.getpid()

printe(f"I am the child! My pid is: {mypid}, my parent's pid is {parent_pid}")
time.sleep(5)
printe("Slept for 5 seconds! wee")

