-- Name: GetFileIdVisibilityByImageEquivalenceClass
-- Schema: posda_files
-- Columns: ['file_id', 'visibility']
-- Args: ['image_equivalence_class_id']
-- Tags: ['ImageEdit', 'edit_files']
-- Description: Get File id and visibility for all files in a series

select 
  distinct file_id, visibility
from
  image_equivalence_class natural join image_equivalence_class_input_image natural join ctp_file
where image_equivalence_class_id = ?