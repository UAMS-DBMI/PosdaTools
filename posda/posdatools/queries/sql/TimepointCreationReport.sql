-- Name: TimepointCreationReport
-- Schema: posda_files
-- Columns: ['collection', 'site', 'patient', 'num_studies', 'num_series', 'num_sop_classes', 'num_modalities', 'num_sops', 'num_files']
-- Args: ['activity_timepoint_id']
-- Tags: ['activity_timepoints']
-- Description:  Get visible files in timepoint

select                                                                                                                                    
  project_name as collection, 
  site_name as site,
  patient_id as patient, 
  count(distinct study_instance_uid) as num_studies, 
  count(distinct series_instance_uid) as num_series,
  count(distinct dicom_file_type) as num_sop_classes, 
  count(distinct modality) as num_modalities,
  count(distinct sop_instance_uid) as num_sops,
  count(distinct file_id) as num_files
from
  file_series natural join file_study 
  natural join file_patient natural join dicom_file 
  natural join file_sop_common natural left join ctp_file 
where 
  visibility is null and 
  file_id in (
  select file_id 
  from activity_timepoint_file
  where activity_timepoint_id = ?
)group by collection, site, patient