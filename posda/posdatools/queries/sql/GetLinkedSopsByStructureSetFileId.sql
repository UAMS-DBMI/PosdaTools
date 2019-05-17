-- Name: GetLinkedSopsByStructureSetFileId
-- Schema: posda_files
-- Columns: ['sop_instance']
-- Args: ['file_id']
-- Tags: ['Structure Sets', 'sops', 'LinkageChecks']
-- Description: Get List of SOP's linked in SS
-- 
-- 

select
  distinct sop_instance
from contour_image natural join  file_structure_set natural join roi natural join roi_contour
where file_id = ?