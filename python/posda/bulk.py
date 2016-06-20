import os
from os.path import join
from storable import retrieve, store

class BulkOperations(object):
  def __init__(self, root, collection, site, session, user, port):
    self.root = root
    self.collection = collection
    self.site = site
    self.session = session
    self.user = user
    self.port = port

    self.root_dir = join(root, collection, site)
    self._scan_for_subjects()


  def _scan_for_subjects(self):
    """Scan the root_dir to get a list of subjects"""
    subjects = []
    for i in os.scandir(self.root_dir):
      if i.is_dir():
        subjects.append(i)

    self.subjects = subjects


  def map_unlocked(self, callback, description):
    coll = self.collection
    site = self.site

    pinfo_files = [
      "dicom.pinfo",
      "send_hist.pinfo",
      "error.pinfo",
      "consistency.pinfo",
      "hierarchy.pinfo",
      "link_info.pinfo",
      "FileCollectionAnalysis.pinfo",
    ]

    for subj in self.subjects:
      rev_hist = retrieve(join(subj.path, 'rev_hist.pinfo'))
      current_rev = rev_hist['CurrentRev']
      info = {'CurrentRev': current_rev}

      old_info_dir = join(subj.path, 'revisions', current_rev)

      for f in pinfo_files:
        try:
          info[f] = retrieve(join(old_info_dir, f))
        except FileNotFoundError:
          pass

      f_list = info['dicom.pinfo']['FilesToDigest']
      yield (callback(coll, site, subj.name, f_list, info))


