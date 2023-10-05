-- Name: SsWithClosedContoursWithNoLinkage
-- Schema: posda_files
-- Columns: ['collection', 'site', 'patient_id', 'file_id', 'series_instance_uid']
-- Args: ['collection']
-- Tags: ['Structure Sets', 'sops', 'LinkageChecks', 'struct_linkages']
-- Description: Get list of plan which reference unknown SOPs
-- 
-- 

select 
  distinct project_name as collection,
  site_name as site, patient_id, series_instance_uid, file_id
from ctp_file natural join file_patient natural join file_series 
where project_name = ?
  and file_id in (
  select distinct file_id from file_structure_set where structure_set_id in (
    select distinct structure_set_id from roi where roi_id in (
      select distinct roi_id from roi_contour where roi_contour_id in (
        select distinct roi_id from roi r where exists (
          select * from roi_contour c where r.roi_id = c.roi_id and geometric_type = 'CLOSED_PLANAR') 
          and roi_id in (     
            select distinct roi_id from roi r where not exists (
              select * from file_roi_image_linkage l where l.roi_id = r.roi_id
            )
         )
       )
     )
   )
)