-- Name: BodyPartExamined
-- Schema: posda_files
-- Columns: ['patient_id', 'series_instance_uid', 'study_description', 'series_description', 'body_part_examined']
-- Args: ['activity_id']
-- Tags: ['consistency']
-- Description: Return all body_part_examined for a given activity
-- 

select * from (
with files_in_activity as (
select
	*
from
	activity_timepoint_file
where
	activity_timepoint_id = (
		select max(activity_timepoint_id)
		from activity_timepoint
		where activity_id = ?
	)
)

select distinct
	patient_id,
	series_instance_uid,
	study_description,
	series_description,
	body_part_examined
from files_in_activity
natural join file_patient
natural join file_series
natural join file_study
) foo
