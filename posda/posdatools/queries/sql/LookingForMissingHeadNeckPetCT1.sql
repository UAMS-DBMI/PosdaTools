-- Name: LookingForMissingHeadNeckPetCT1
-- Schema: posda_files
-- Columns: ['patient_id', 'study_instance_uid', 'series_instance_uid', 'modality', 'num_files', 'first_load', 'last_load']
-- Args: []
-- Tags: ['meta', 'test', 'hello', 'bills_test', 'bills_ad_hoc_scripts', 'for_tracy']
-- Description: Add a filter to a tab

select 
  distinct patient_id, study_instance_uid, series_instance_uid, modality, 
  count(distinct file_id) as num_files, min(import_time) as first_load, max(import_time) as last_load
from
  file_patient natural join file_study 
  natural join file_series
  join file_import using(file_id)
  join import_event using(import_event_id)
where file_id in (      
  select
     distinct file_id
  from
    file_series join ctp_file using(file_id)
    join file_sop_common using(file_id) 
    join file_import using (file_id)
    join import_event using(import_event_id)
  where 
    project_name = 'Head-Neck-PET-CT' and import_time > '2018-04-01'
  )
group by patient_id, study_instance_uid, series_instance_uid, modality