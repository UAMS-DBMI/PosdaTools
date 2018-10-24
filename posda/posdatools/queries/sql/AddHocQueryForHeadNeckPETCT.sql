-- Name: AddHocQueryForHeadNeckPETCT
-- Schema: posda_files
-- Columns: ['patient_id', 'study_uid', 'series_uid', 'num_files']
-- Args: []
-- Tags: ['meta', 'test', 'hello', 'bills_test']
-- Description: Add a filter to a tab

select
  distinct patient_id, study_instance_uid as study_uid, series_instance_uid as series_uid,
  count(distinct file_id) as num_files
from
  file_patient natural join file_study natural join file_series natural join ctp_file
where
  patient_id in
   ('HN-CHUM-050', 'HN-CHUM-052', 'HN-CHUM-054', 'HN-CHUM-056', 'HN-CHUM-030', 'HN-CHUM-034')
  and visibility is null
group by patient_id, study_uid, series_uid