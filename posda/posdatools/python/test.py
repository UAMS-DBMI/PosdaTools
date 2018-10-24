import posda.fork
from posda.main import printe

parent_pid, my_pid = posda.fork.daemonize()
printe(f"This is the child, all is well! It looks like my parent's pid was: {parent_pid}, mine is {my_pid}")
