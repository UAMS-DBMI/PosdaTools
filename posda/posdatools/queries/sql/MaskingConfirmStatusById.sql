-- Name: MaskingConfirmStatusById
-- Schema: posda_files
-- Columns: ['id', 'masking_status', 'dicom_file_type', 'num_created', 'num_ready','num_processing','num_complete','num_accepted','num_rejected','num_errored']
-- Args: ['visual_review_instance_id']
-- Tags: ['masking_review']
-- Description: Get details of a Masking Confirmation Review
-- 

select
id,
masking_status,
dicom_file_type,
count(distinct image_equivalence_class_id) as num_equiv,
sum(case when masking_status = 'created' then 1 else 0 end) as num_created,
sum(case when masking_status = 'ready-to-process' then 1 else 0 end) as num_ready,
sum(case when masking_status = 'in-process' then 1 else 0 end) as num_processing,
sum(case when masking_status = 'process-complete' then 1 else 0 end) as num_complete,
sum(case when masking_status = 'accepted' then 1 else 0 end) as num_accepted,
sum(case when masking_status = 'rejected' then 1 else 0 end) as num_rejected,
sum(case when masking_status = 'errored' then 1 else 0 end) as num_errored
from (
	select
		visual_review_instance_id as id,
		masking_status,
		image_equivalence_class_id,
		dicom_file_type,
		max(file_id) as file_id
	from
		image_equivalence_class 
		join image_equivalence_class_input_image using(image_equivalence_class_id)
		join masking using(image_equivalence_class_id)
		join dicom_file using(file_id)
	where
		visual_review_instance_id = ?
	group by
		id,
		masking_status,
		image_equivalence_class_id,
		dicom_file_type
	) masking_iecs
group by id, masking_status, dicom_file_type
