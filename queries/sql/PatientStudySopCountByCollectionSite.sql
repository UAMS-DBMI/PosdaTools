-- Name: PatientStudySopCountByCollectionSite
-- Schema: posda_files
-- Columns: ['patient_id', 'study_instance_uid', 'num_sops']
-- Args: ['collection', 'site']
-- Tags: ['counts', 'for_bill_counts']
-- Description: For every patient in collection site, get a list of studies with a count of distinct SOPs in each study

select 
  distinct patient_id, study_instance_uid, 
  count(distinct sop_instance_uid) as num_sops
from 
  ctp_file natural join 
  file_sop_common natural join
  file_patient natural join 
  file_study
where
  project_name = ? and site_name = ? and visibility is null
group by patient_id, study_instance_uid
order by patient_id