-- Name: UpdCTQP
-- Schema: posda_files
-- Columns: []
-- Args: ['qualified', 'collection', 'site', 'patient_id']
-- Tags: ['activity_timepoint_support']
-- Description: Create An Activity Timepoint
-- 
-- 

update clinical_trial_qualified_patient_id
  set qualified = ?
where
  collection = ? and site = ? and patient_id = ?
 