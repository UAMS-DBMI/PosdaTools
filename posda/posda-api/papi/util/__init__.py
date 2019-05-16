from sanic.response import json, text
from sanic.exceptions import NotFound
# import ujson


# Not sure what this method does, and it doesn't appear to be
# called any longer
def json_objects(objects):
    return json([o._asdict() for o in objects])

def json_records(objects):
    if objects is None:
        raise NotFound('not found')

    # use iter() to test if we have an iterable sequence
    # or just one instance
    try:
        iter_obj = iter(objects)
        return json([dict(o) for o in iter_obj])
    # ValueError is triggered if o cannot be
    # turned into a dict, which might happen if objects
    # is an iterable but isn't really a sequence
    # (happens with types that are 'magic' like NamedTuples)
    except:
        # print(dict(objects))
        return json(dict(objects))
        # d = dict(objects)
        # print(d)
        # j = ujson.dumps(d)
        # print(j)

        # return text(j)
