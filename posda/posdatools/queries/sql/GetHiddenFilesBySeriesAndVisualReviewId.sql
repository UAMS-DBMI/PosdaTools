-- Name: GetHiddenFilesBySeriesAndVisualReviewId
-- Schema: posda_files
-- Columns: ['file_id']
-- Args: ['visual_review_instance_id', 'series_instance_uid']
-- Tags: ['signature', 'phi_review', 'visual_review_new_workflow']
-- Description: Get a list of files which are hidden by series id and visual review id

select
  file_id
from ctp_file
where visibility is not null and file_id in (
  select
    file_id
  from
    image_equivalence_class natural join image_equivalence_class_input_image
  where
    visual_review_instance_id = ? and series_instance_uid = ?
)