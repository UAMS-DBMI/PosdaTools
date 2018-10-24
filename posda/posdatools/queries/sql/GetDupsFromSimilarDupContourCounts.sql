-- Name: GetDupsFromSimilarDupContourCounts
-- Schema: posda_files
-- Columns: ['roi_id', 'count']
-- Args: ['num_dup_contours']
-- Tags: ['Structure Sets', 'sops', 'LinkageChecks', 'dup_contours']
-- Description: Get list of plan which reference unknown SOPs
-- 
-- 

select distinct roi_id, count(*) from file_roi_image_linkage where
contour_digest in (select contour_digest from (select
  distinct contour_digest, count(*) from
(select
  distinct
  project_name as collection,
  site_name as site,
  patient_id,
  series_instance_uid,
  sop_class_uid,
  file_id,
  contour_digest
from
   ctp_file
   natural join file_patient
   natural join file_series
   natural join file_sop_common
  natural join file_roi_image_linkage
where file_id in (
  select distinct file_id from (
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
  ) as foo
  where num_dup_contours = ?
)
) as foo
group by contour_digest)
as foo where count > 1)
group by roi_id order by count desc
