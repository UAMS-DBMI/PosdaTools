-- Name: GetDupContourCounts
-- Schema: posda_files
-- Columns: ['file_id', 'num_dup_contours']
-- Args: []
-- Tags: ['Structure Sets', 'sops', 'LinkageChecks', 'dup_contours']
-- Description: Get list of plan which reference unknown SOPs
-- 
-- 

select 
  distinct file_id, count(*) as num_dup_contours
from
  file_roi_image_linkage 
where 
  contour_digest in (
  select contour_digest
  from (
    select 
      distinct contour_digest, count(*)
    from
      file_roi_image_linkage group by contour_digest
  ) as foo
  where count > 1
) group by file_id order by num_dup_contours desc