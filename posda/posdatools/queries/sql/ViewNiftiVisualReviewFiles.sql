-- Name: ViewNiftiVisualReviewFiles
-- Schema: posda_files
-- Columns: ['nifti_review_file_id','review_status','nifti_visual_review_instance_id','nifti_file_name']
-- Args: ['nifti_visual_review_instance_id']
-- Tags: ['nifti','visual_review']
-- Description: View all visual review files for a nifti visual review instance
--

select 
  nvrf.nifti_file_id as nifti_review_file_id,
  nvrs.review_status, nvrf.nifti_visual_review_instance_id,
  nvrf.nifti_file_name
from 
  nifti_visual_review_files nvrf
left join 
  nifti_visual_review_status nvrs
on 
  nvrs.nifti_file_id = nvrf.nifti_file_id 
where 
  nvrf.nifti_visual_review_instance_id = ?
order by 
  nvrf.nifti_file_id
