-- Name: VisualReviewStatusById
-- Schema: posda_files
-- Columns: ['id', 'processing_status', 'review_status', 'dicom_file_type', 'num_equiv']
-- Args: ['id']
-- Tags: ['by_collection', 'find_series', 'compare_collection_site', 'search_series', 'edit_files', 'simple_phi', 'dciodvfy', 'ctp_details', 'select_for_phi', 'visual_review_reports', 'visual_review_new_workflow']
-- Description: Get details of a Visual Review
-- 

select
	id,
	processing_status,
	review_status,
	dicom_file_type,
	count(distinct image_equivalence_class_id) as num_equiv
from 
	(
		/*
			Get all IECs in the Visual Review, and get only
			one file_id from the input_image set for each IEC.
			IECs will already contain only input images of the
			same type, so this saves us significant time later
			when joining agianst dicom_file.
		*/
		select
			image_equivalence_class_id,
			max(file_id) as file_id,
			visual_review_instance_id as id,
			processing_status,
			review_status
		from
			image_equivalence_class 
			natural join image_equivalence_class_input_image 
		where
			visual_review_instance_id = ?
		group by
			image_equivalence_class_id,
			id,
			processing_status,
			review_status
	) one_image_from_each_iec
	natural join dicom_file
	natural join ctp_file

group by
	1, 2, 3, 4
