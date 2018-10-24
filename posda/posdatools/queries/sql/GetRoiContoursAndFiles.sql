-- Name: GetRoiContoursAndFiles
-- Schema: posda_files
-- Columns: ['file_path', 'roi_id', 'roi_contour_id', 'roi_num', 'contour_num', 'geometric_type', 'number_of_points']
-- Args: ['file_id']
-- Tags: ['Structure Sets', 'sops', 'LinkageChecks']
-- Description: Get Structure Set Volume
-- 
-- 

select distinct root_path || '/' || rel_path as file_path, roi_id, roi_contour_id, roi_num, contour_num, geometric_type, number_of_points 
from roi_contour natural join roi natural join structure_set natural join file_structure_set natural join file_storage_root natural join file_location
where file_id = ?