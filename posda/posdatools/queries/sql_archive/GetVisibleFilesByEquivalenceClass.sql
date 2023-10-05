-- Name: GetVisibleFilesByEquivalenceClass
-- Schema: posda_files
-- Columns: ['file_id', 'visibility']
-- Args: ['image_equivalence_class_id']
-- Tags: ['signature', 'phi_review', 'visual_review', 'visual_review_new_workflow']
-- Description: Get a list of files which are hidden by series id and visual review id

select
  file_id, visibility
from ctp_file
where file_id in (
  select
    file_id
  from
    image_equivalence_class natural join image_equivalence_class_input_image
  where
    image_equivalence_class_id = ?
)