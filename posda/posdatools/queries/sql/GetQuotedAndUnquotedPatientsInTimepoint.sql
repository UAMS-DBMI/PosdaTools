-- Name: GetQuotedAndUnquotedPatientsInTimepoint
-- Schema: posda_files
-- Columns: ['quoted_patient_id', 'patient_id']
-- Args: ['activity_timepoint_id']
-- Tags: ['adding_ctp', 'for_scripting', 'patient_mapping']
-- Description: Retrieve entries from patient_mapping table

select distinct '<' || patient_id || '>' as quoted_patient_id, patient_id from file_patient natural join activity_timepoint_file where activity_timepoint_id = ? order by quoted_patient_id
  