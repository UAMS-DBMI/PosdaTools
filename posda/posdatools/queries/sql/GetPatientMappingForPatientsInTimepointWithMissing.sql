-- Name: GetPatientMappingForPatientsInTimepointWithMissing
-- Schema: posda_files
-- Columns: ['from_patient_id', 'to_patient_id', 'to_patient_name', 'collection_name', 'site_name', 'batch_number', 'diagnosis_date', 'baseline_date', 'date_shift', 'uid_root', 'site_code', 'files_in_tp']
-- Args: ['activity_id']
-- Tags: ['adding_ctp', 'for_scripting', 'patient_mapping', 'activity_timepoint']
-- Description:  Get patient mappings for patients in timepoint
--

select 
  from_patient_id, to_patient_id, to_patient_name, collection_name, site_name, batch_number,
  diagnosis_date, baseline_date, date_shift, uid_root, site_code, count as files_in_tp
from (                                                                                                                                                                                                                                                                                          
  select 
    distinct project_name as collection_name, site_name, patient_id as to_patient_id, count(*)
  from
    file_patient natural join ctp_file
  where
     file_id in (                                                                                                                                                                                                                                                                                  
       select file_id 
       from activity_timepoint_file
       where activity_timepoint_id = (                                                                                                                                                                                                                                                                                                                                                                                          
         select max(activity_timepoint_id)
         from activity_timepoint where activity_id = ?
       )
    ) group by collection_name, site_name, patient_id
 ) as foo natural left join patient_mapping