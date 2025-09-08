#!/usr/bin/env python3
import subprocess
import sys
import logging
import os
from pygelf import GelfUdpHandler

# Read configuration from environment
gelf_host = os.getenv("GELF_HOST", "localhost")
gelf_port = int(os.getenv("GELF_PORT", "12201"))
gelf_tag = os.getenv("GELF_TAG", "gelf_wrapper")

# Set up GELF logging
logger = logging.getLogger()
logger.setLevel(logging.INFO)

# Add custom tag as an extra field (GELF supports additional fields prefixed with underscore)
handler = GelfUdpHandler(
    host=gelf_host,
    port=gelf_port,
    include_extra_fields=True,
    static_fields={"_tag": gelf_tag}
)
logger.addHandler(handler)

# Run the wrapped command
cmd = sys.argv[1:]
proc = subprocess.Popen(cmd, stdout=subprocess.PIPE, stderr=subprocess.STDOUT, text=True)

for line in proc.stdout:
    sline = line.rstrip()
    print(sline) # also print to stdout
    logger.info(sline)

proc.wait()
sys.exit(proc.returncode)
