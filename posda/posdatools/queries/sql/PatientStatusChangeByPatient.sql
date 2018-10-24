-- Name: PatientStatusChangeByPatient
-- Schema: posda_files
-- Columns: ['patient_id', 'from', 'to', 'by', 'why', 'when']
-- Args: ['patient_id']
-- Tags: ['PatientStatus']
-- Description: Get History of Patient Status Changes by Patient Id
-- 

select
  patient_id, old_pat_status as from,
  new_pat_status as to, pat_stat_change_who as by,
  pat_stat_change_why as why,
  when_pat_stat_changed as when
from patient_import_status_change
where patient_id = ?
order by when
