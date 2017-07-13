-- Name: GetSsReferencingKnownImages
-- Schema: posda_files
-- Columns: ['collection', 'site', 'patient_id', 'file_id']
-- Args: []
-- Tags: ['Structure Sets', 'sops', 'LinkageChecks', 'struct_linkages']
-- Description: Get list of plan which reference unknown SOPs
-- 
-- 

select
  project_name as collection,
  site_name as site,
  patient_id, file_id
from
  ctp_file natural join file_patient
where file_id in (
  select
    distinct ss_file_id as file_id 
  from (
    select
      sop_instance_uid, ss_file_id 
    from (
      select 
        distinct
           linked_sop_instance_uid as sop_instance_uid,
           file_id as ss_file_id
      from
        file_roi_image_linkage
    ) foo left join file_sop_common using(sop_instance_uid)
    join ctp_file using(file_id)
  where
    visibility is null
  ) as foo
)
order by collection, site, patient_id, file_id
