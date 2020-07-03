-- Name: VerifyAllSopsInTpAreInVR
-- Schema: posda_files
-- Columns: ['sop_instance_uid']
-- Args: ['activity_id', 'visual_review_instance_id']
-- Tags: ['visual_review']
-- Description:  Get all sops in the timpoint that are missing from the visual review
-- 

select * from (
with tp_id as (
	select max(activity_timepoint_id)
	from activity_timepoint
	where activity_id = ?
), sops_in_timepoint as (
	select sop_instance_uid
	from activity_timepoint_file
	natural join file_sop_common
	where activity_timepoint_id = (select * from tp_id)
), sops_in_vr as (
	select sop_instance_uid
	from image_equivalence_class
	natural join image_equivalence_class_input_image
	natural join file_sop_common
	where visual_review_instance_id = ?
)
select *
from sops_in_timepoint
except
select *
from sops_in_vr
) foo
