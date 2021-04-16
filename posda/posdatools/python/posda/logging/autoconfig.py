"""
This module, when imported, will automatically configure logging
with the default configuration below.
"""
import logging

def default_config():
    """Setup sane default logging settings"""

    format = '[%(levelname).4s|%(asctime)s|%(module)-15.15s] %(message)s'

    logging.basicConfig(level=logging.INFO,
                        format=format,
                        datefmt='%Y-%m-%d/%H:%M:%S')


default_config()
