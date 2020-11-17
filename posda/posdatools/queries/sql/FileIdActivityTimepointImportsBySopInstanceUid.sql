-- Name: FileIdActivityTimepointImportsBySopInstanceUid
-- Schema: posda_files
-- Columns: ['file_id', 'visibility', 'activity_id', 'activity_timepoint_id', 'import_event_id', 'import_time', 'import_comment']
-- Args: ['sop_instance_uid']
-- Tags: ['sops']
-- Description: Get FileIds and history data for a SOP
-- 

select 
  file_id, visibility, activity_id, activity_timepoint_id,
  import_event_id, import_time, import_comment 
from
  file_import natural left join ctp_file natural left join
  import_event natural left join activity_timepoint_file natural left join activity_timepoint  
where file_id in (select file_id from file_sop_common where sop_instance_uid = ?)
order by activity_id, activity_timepoint_id, import_event_id;