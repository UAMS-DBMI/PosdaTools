-- Name: PatientStatusCounts
-- Schema: posda_files
-- Columns: ['collection', 'status', 'num_patients']
-- Args: []
-- Tags: ['FindSubjects', 'PatientStatus']
-- Description: Find All Subjects which have at least one visible file
-- 

select
  distinct project_name as collection, patient_import_status as status,
  count(distinct patient_id) as num_patients
from
  patient_import_status natural join file_patient natural join ctp_file
group by collection, status
order by collection, status
