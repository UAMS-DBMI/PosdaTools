-- Name: MaskingReviewStatusById
-- Schema: posda_files
-- Columns: ['id', 'processing_status', 'review_status', 'dicom_file_type', 'num_equiv']
-- Args: ['id']
-- Tags: ['masking_review']
-- Description: Get details of a Masking Review
-- 

select
id,
masking_status,
dicom_file_type,
count(distinct image_equivalence_class_id) as num_equiv
from (
	select
		visual_review_instance_id as id,
		masking_status,
		image_equivalence_class_id,
		max(file_id) as file_id
	from
		image_equivalence_class 
		join image_equivalence_class_input_image using(image_equivalence_class_id)
		join masking using(image_equivalence_class_id)
	where
		visual_review_instance_id = ?
	group by
		id,
		masking_status,
		image_equivalence_class_id			
	) masking_iecs
join dicom_file using(file_id)
group by id, masking_status, dicom_file_type
