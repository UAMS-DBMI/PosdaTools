-- Name: GetPatientMappingDupes
-- Schema: posda_files
-- Columns: ['from_patient_id', 'to_patient_id', 'to_patient_name', 'collection_name', 'site_name', 'batch_number', 'uid_root', 'diagnosis_date', 'baseline_date', 'date_shift', 'computed_shift']
-- Args: []
-- Tags: ['patient_mapping']
-- Description: Retrieve duplicate entries from patient_mapping table
--

select
  from_patient_id,
  to_patient_id,
  to_patient_name,
  collection_name,
  site_name,
  batch_number,
  uid_root,
  diagnosis_date,
  baseline_date,
  date_shift
from
  patient_mapping pm
  left join
  (select from_patient_id, count(from_patient_id) as c from patient_mapping pm2 group by from_patient_id) subq
  on pm.from_patient_id  = subq.from_patient_id
where subq.c > 1;
