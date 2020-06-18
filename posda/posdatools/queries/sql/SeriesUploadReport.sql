-- Name: SeriesUploadReport
-- Schema: posda_files
-- Columns: ['sop_instance_uid', 'file_id', 'import_event_id', 'import_type', 'import_comment', 'import_time', 'visibility']
-- Args: ['series_instance_uid']
-- Tags: ['sop_import_history']
-- Description: Report of uploads of SOP
--

select
  distinct sop_instance_uid, file_id, import_event_id, import_type, 
  import_comment, import_time, COALESCE(visibility, 'visible') as visibility
from
  file_sop_common natural join
  activity_timepoint_file natural join
  activity_timepoint natural join 
  file_import natural join 
  import_event natural join
  ctp_file
where sop_instance_uid in (
  select distinct sop_instance_uid 
  from file_sop_common natural join file_series 
  where series_instance_uid = ?
)
