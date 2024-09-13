-- Name: NiftiFilePathsFromActivity
-- Schema: posda_files
-- Columns: ['file_id','root_path','rel_path']
-- Args: ['activity_id']
-- Tags: []
-- Description: View filepaths for the nifti files in the latest Actitivy TP for the specified activity id
--
--

select
  atf.file_id,
  fsr.root_path,
  fl.rel_path,
  fi.file_name
from
  activity_timepoint_file atf
  natural join file f
  natural join file_nifti fn
  natural join file_location fl
  natural join file_storage_root fsr
  left join file_import fi
    on atf.file_id = fi.file_id
    and fi.import_event_id = (
      select max(import_event_id)
      from file_import fi_sub
      where fi_sub.file_id = atf.file_id)
where
  atf.activity_timepoint_id = (select max(activity_timepoint_id) as activity_timepoint_id from activity_timepoint where activity_id = ?);
