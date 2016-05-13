import sys
import json

def get_parameters():
    test = sys.stdin.read()
    return json.loads(test)
