import sys
import os

def close_file_descriptors():
  import resource
  maxfd = resource.getrlimit(resource.RLIMIT_NOFILE)[1]
  if (maxfd == resource.RLIM_INFINITY):
      maxfd = 1024

  for fd in range(0, maxfd):
      if fd == sys.stderr.fileno(): # do not close stderr
        continue
      try:
          os.close(fd)
      except OSError:
          pass

def daemonize():
    return fork_and_exit()

def fork_and_exit():
    parent_pid = os.getpid()

    child_pid = os.fork()

    if child_pid != 0:
        # this is the parent, so exit
        # print("parent exiting now")
        os._exit(1)

    os.setsid() # begin new session/process group
    child_pid = os.getpid() # get the actual child_pid

    close_file_descriptors()

    return (parent_pid, child_pid)
