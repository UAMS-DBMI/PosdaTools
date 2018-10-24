-- Name: RecordPatientStatusChange
-- Schema: posda_files
-- Columns: None
-- Args: ['patient_id', 'who', 'why', 'old_status', 'new_status']
-- Tags: ['NotInteractive', 'PatientStatus', 'Update']
-- Description: Record a change to Patient Import Status
-- For use in scripts
-- Not really intended for interactive use
-- 

insert into patient_import_status_change(
  patient_id, when_pat_stat_changed,
  pat_stat_change_who, pat_stat_change_why,
  old_pat_status, new_pat_status
) values (
  ?, now(),
  ?, ?,
  ?, ?
)
