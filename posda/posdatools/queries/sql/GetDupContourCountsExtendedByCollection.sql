-- Name: GetDupContourCountsExtendedByCollection
-- Schema: posda_files
-- Columns: ['collection', 'site', 'patient_id', 'file_id', 'num_dup_contours']
-- Args: ['collection']
-- Tags: ['Structure Sets', 'sops', 'LinkageChecks', 'dup_contours']
-- Description: Get list of plan which reference unknown SOPs
-- 
-- 

select
  project_name as collection,
  site_name as site,
  patient_id,
  file_id,
  num_dup_contours
from (
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
  ) group by file_id 
) foo join ctp_file using (file_id) join file_patient using(file_id)
where project_name = ? and visibility is null
order by num_dup_contours desc