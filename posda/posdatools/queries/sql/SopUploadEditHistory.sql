-- Name: SopUploadEditHistory
-- Schema: posda_files
-- Columns: ['import_event_id', 'import_type', 'import_comment', 'import_time', 'visibility', 'time_of_change', 'prior_visibility', 'new_visibility', 'reason_for']
-- Args: ['sop_instance_uid']
-- Tags: ['Sop investigation']
-- Description: Show the upload/edit history for a particular SOP
--

select
  import_event_id, import_type, import_comment,
  import_time, visibility, time_of_change, prior_visibility, new_visibility, user_name, reason_for
from
  import_event natural join file_import natural left join ctp_file  natural left join file_visibility_change
where file_id  in (select distinct file_id from file_sop_common where sop_instance_uid = ?)
order by import_time