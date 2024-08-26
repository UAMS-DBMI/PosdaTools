-- Name: MaskingReview
-- Schema: posda_files
-- Columns: ['image_equivalence_class_id', 'masking_status', 'visual_review_instance_id', 'dicom_file_type', 'num_files']
-- Args: ['visual_review_instance_id']
-- Tags: ['masking_review']
-- Description: Get details of a Masking Visual Review
-- 

select
        image_equivalence_class_id,
        masking_status,
        visual_review_instance_id,
        dicom_file_type,
        count(file_id) as num_files
from masking
natural join image_equivalence_class
natural join image_equivalence_class_input_image
left join dicom_file using(file_id)
where visual_review_instance_id = ?
and masking_status = 'process-complete'
group by 1, 2, 3, 4
