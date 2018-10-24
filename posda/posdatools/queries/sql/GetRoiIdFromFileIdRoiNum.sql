-- Name: GetRoiIdFromFileIdRoiNum
-- Schema: posda_files
-- Columns: ['roi_id']
-- Args: ['file_id', 'roi_num']
-- Tags: ['NotInteractive', 'used_in_processing_structure_set_linkages']
-- Description: Get the file_storage root for newly created files

select
  roi_id
from
  roi natural join structure_set natural join file_structure_set
where 
  file_id =? and roi_num = ?