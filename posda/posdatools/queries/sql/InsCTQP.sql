-- Name: InsCTQP
-- Schema: posda_files
-- Columns: []
-- Args: ['collection', 'site', 'patient_id', 'qualified']
-- Tags: ['activity_timepoint_support']
-- Description: Create An Activity Timepoint
-- 
-- 

insert into clinical_trial_qualified_patient_id(
  collection, site, patient_id, qualified
) values (
  ?, ?, ?, ?
)
