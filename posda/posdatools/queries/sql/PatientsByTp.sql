-- Name: PatientsByTp
-- Schema: posda_queries
-- Columns: ['patient_id', 'series_instance_uid']
-- Args: ['activity_timepoint_id']
-- Tags: ['activity_timepoint_support']
-- Description: Get a list of patients, and their series in a timepoint

select distinct
    patient_id,
	series_instance_uid

from
    activity_timepoint_file
    natural join file_patient
	natural join file_series
where
    activity_timepoint_id = ?
