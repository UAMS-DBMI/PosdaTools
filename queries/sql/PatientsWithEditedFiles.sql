-- Name: PatientsWithEditedFiles
-- Schema: posda_files
-- Columns: ['collection', 'site', 'patient_id', 'num_sops', 'num_files']
-- Args: []
-- Tags: ['adding_ctp', 'for_scripting', 'patient_queries']
-- Description: Get a list of to files from the dicom_edit_compare table for a particular edit instance, with file_id and visibility
-- 
-- NB: Normally there should be no file_id (i.e. file has not been imported)

select
  distinct project_name as collection,
  site_name as site,
  patient_id,
  count(distinct sop_instance_uid) as num_sops,
  count(distinct file_id) as num_files
from
  ctp_file natural join
  file_patient natural join
  file_sop_common
where file_id in (
  select 
    distinct file_id 
  from 
    file f natural join dicom_edit_compare dec
  where
    f.digest = dec.to_file_digest and subprocess_invocation_id in (
      select distinct subprocess_invocation_id
      from dicom_edit_compare_disposition
      where current_disposition like 'Import Complete%'
    )
)
group by collection, site, patient_id
order by collection, site, patient_id