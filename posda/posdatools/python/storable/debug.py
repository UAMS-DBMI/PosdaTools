DEBUG = 0

def debug(*args, **kwargs):
    if DEBUG:
        print("-- ", *args, **kwargs)
