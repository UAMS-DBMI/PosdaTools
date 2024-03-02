-- Name: PathologyViewEdits
-- Schema: posda_files
-- Columns: ['file_id', 'edit_type', 'edit_details','status']
-- Args: ['activity_id']
-- Tags: ['pathology']
-- Description: View the pathology edits queued for this activity.
--

--
select
	file_id,
	edit_type,
	edit_details,
	status
from pathology_edit_queue p
natural join file f
natural join activity_timepoint_file atf
where atf.activity_timepoint_id in (
    select
        max(activity_timepoint_id) as activity_timepoint_id
    from
        activity_timepoint
    where
        activity_id = $1 and status = 'waiting'
  );
