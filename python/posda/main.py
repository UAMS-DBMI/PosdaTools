import sys
import json

def get_parameters():
    test = sys.stdin.read()
    return json.loads(test)

def printe(*args, **kwargs):
    """Print to standard error"""
    print(*args, **kwargs, file=sys.stderr)

