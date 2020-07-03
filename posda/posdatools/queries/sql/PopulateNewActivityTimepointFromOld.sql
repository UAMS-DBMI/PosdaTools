-- Name: PopulateNewActivityTimepointFromOld
-- Schema: posda_files
-- Columns: []
-- Args: ['old_activity_timepoint_id', 'visual_review_instance_id', 'new_activity_timepoint_id']
-- Tags: ['visual_review']
-- Description:  Populate a new activity tp from an old activity tp, removing any sops that are reviewed bad
--

with tp_id as (
	select cast(? as integer)
), sops_in_timepoint as (
	select sop_instance_uid
	from activity_timepoint_file
	natural join file_sop_common
	where activity_timepoint_id = (select * from tp_id)
), bad_sops_in_vr as (
	select sop_instance_uid
	from image_equivalence_class
	natural join image_equivalence_class_input_image
	natural join file_sop_common
	where visual_review_instance_id = ?
	  and review_status = 'Bad'
), good_sops as (
	select sop_instance_uid
	from sops_in_timepoint
	except
	select sop_instance_uid
	from bad_sops_in_vr
), nondicom_files_in_tp as (
	select activity_timepoint_file.file_id
	from activity_timepoint_file
	natural left join dicom_file
	where activity_timepoint_id = (select * from tp_id)
	  and dicom_file.file_id is null
), new_timepoint_id as (
	select cast ( ? as integer )
)

insert into activity_timepoint_file
select (select * from new_timepoint_id) 
	as activity_timepoint_id, file_id
from file_sop_common
natural join activity_timepoint_file
natural join good_sops
where activity_timepoint_id = (select * from tp_id)
union
select (select * from new_timepoint_id) 
	as activity_timepoint_id, file_id
from nondicom_files_in_tp
