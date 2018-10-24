import sys
import subprocess

def lines(command):
    """Return a generator that yields lines (as strings) from command"""

    sub = subprocess.Popen(command, 
                           stdin=subprocess.PIPE, 
                           stdout=subprocess.PIPE,
                           stderr=sys.stderr)

    while True:
        line = sub.stdout.readline().strip().decode()
        yield line
        if len(line) == 0 and sub.poll() != None:
            raise StopIteration()
