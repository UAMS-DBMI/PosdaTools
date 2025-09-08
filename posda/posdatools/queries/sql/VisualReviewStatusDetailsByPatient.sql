-- Name: VisualReviewStatusDetailsByPatient
-- Schema: posda_files
-- Columns: ['patient_id', 'image_equivalence_class_id', 'series_instance_uid', 'processing_status', 'review_status', 'visibility', 'num_files']
-- Args: ['visual_review_instance_id', 'patient_id_like']
-- Tags: ['by_collection', 'find_series', 'compare_collection_site', 'search_series', 'edit_files', 'simple_phi', 'dciodvfy', 'ctp_details', 'select_for_phi', 'visual_review_new_workflow']
-- Description: Get details for a visual review and patient
-- 

select distinct
    patient_id,
    image_equivalence_class_id,
    series_instance_uid,
    processing_status,
    review_status,
    visibility,
    count(distinct file_id) as num_files
from
    image_equivalence_class
    natural join image_equivalence_class_input_image
    natural join dicom_file
    natural join ctp_file
	natural join file_patient
where
    visual_review_instance_id = ?
	and patient_id like ?
group by 1, 2, 3, 4, 5, 6
;
