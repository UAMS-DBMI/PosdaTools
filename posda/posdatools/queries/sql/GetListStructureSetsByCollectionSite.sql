-- Name: GetListStructureSetsByCollectionSite
-- Schema: posda_files
-- Columns: ['project_name', 'patient_id', 'site_name', 'sop_instance_uid']
-- Args: ['collection', 'site']
-- Tags: ['Structure Sets', 'sops', 'LinkageChecks']
-- Description: Get Structure Set List
-- 
-- 

select 
  distinct project_name, site_name, patient_id, sop_instance_uid
from
  file_sop_common natural join ctp_file natural join dicom_file natural join file_patient
where
  dicom_file_type = 'RT Structure Set Storage'
  and project_name = ? and site_name = ?
order by project_name, site_name, patient_id