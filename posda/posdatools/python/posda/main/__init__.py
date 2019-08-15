import sys
import json
import os
import subprocess

from ..util import md5sum
from ..util import printe
from .file import insert_file

def get_parameters():
    test = sys.stdin.read()
    return json.loads(test)


def get_stdin_input():
    lines = []
    for row in sys.stdin:
        lines.append(row.strip())

    return lines

#TODO: move these classes somwehre else.. maybe posda.compat? 
#       they aren't going to be used much, if at all..
class DicomFile:

    def __init__(self, filename):
        self.filename = filename
        self.__parse(filename)

    def __getitem__(self, index):
        if isinstance(index, str):
            # does it look like a tag?
            if index.startswith("(") and index.endswith(")") and "," in index:
                return self.get_by_tag(index)
            else:
                return self.get_by_name(index)
        elif isinstance(index, tuple):
            a, b = index
            tag = "({0:04x},{1:04x})".format(a, b)
            return self.get_by_tag(tag)
        else:
            raise RuntimeError("Not sure how to locate tag using a " + 
                               str(type(index)))


    def get_by_tag(self, tag):
        return DicomTag(self.by_tag[tag])

    def get_by_name(self, name):
        return DicomTag(self.by_desc[name])

    def __parse(self, filename):

        self.stat = os.stat(filename)
        self.md5sum = md5sum(filename)

        proc = subprocess.run(['./dicom_dump.sh', filename],
                              stdout=subprocess.PIPE)

        lines = proc.stdout.decode().split('\n')

        by_tag = {}
        by_desc = {}
        for line in lines:
            try:
                tag, vr, desc, *rest = line.split(':')
            except:
                continue

            value = ':'.join(rest)

            t = (tag, vr, desc, value)

            by_tag[tag] = t
            by_desc[desc] = t

        self.by_tag = by_tag
        self.by_desc = by_desc


class DicomTag:
    def __init__(self, init_tuple):
        self.tag_name, self.vr, self.name, self._value = init_tuple
        self._init_value()

    def _init_value(self):
        v = self._value
        # TODO: this is hacky, for now assume anything surrounded in
        # quotes is a string and drop the quotes
        # THIS WILL BREAK if a value legitiamtely has quotes around it!
        if v.startswith('"') and v.endswith('"'):
            v = v[1:-1]

        if "\\" in v:
            v = v.split("\\")
        self.value = v

    def __repr__(self):
        return f"<DicomTag: {self.name} = {self.value}>"

    def __str__(self):
        return str(self.value)

    def __unicode__(self):
        return self.__str__()
