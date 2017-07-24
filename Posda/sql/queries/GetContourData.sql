-- Name: GetContourData
-- Schema: posda_files
-- Columns: ['contour_data']
-- Args: ['roi_contour_id']
-- Tags: ['Structure Sets', 'sops', 'LinkageChecks']
-- Description: Get Contour Data by roi_contour_id
-- 

select
  contour_data
from
  roi_contour
where roi_contour_id = ?