-- Name: DuplicatesOfSopsInTp
-- Schema: posda_files
-- Columns: ['file_id']
-- Args: ['activity_timepoint_id', 'activity_timepoint_id_again']
-- Tags: ['duplicate SOPS', 'activity_timepoint']
-- Description: Get all files which are duplicate sops of files in a timepoint, but not in the timepoint and are visibile

select
  file_id
from
  file_sop_common fsc natural left join ctp_file
  where 
  not exists (
    select file_id
    from activity_timepoint_file atf
    where
      atf.file_id = fsc.file_id and
      activity_timepoint_id = ?
  )
  and sop_instance_uid in (
    select
      distinct sop_instance_uid
    from
      file_sop_common natural join activity_timepoint_file
    where activity_timepoint_id = ?
  )