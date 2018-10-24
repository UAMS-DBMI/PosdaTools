-- Name: GetCountSsVolumeByPatientId
-- Schema: posda_files
-- Columns: ['sop_instance_uid', 'num_links']
-- Args: ['patient_id']
-- Tags: ['Structure Sets', 'sops', 'LinkageChecks']
-- Description: Get Structure Set Volume
-- 
-- 

select
  distinct sop_instance_uid, count(distinct sop_instance_link) as num_links 
from (
  select 
    sop_instance_uid, for_uid, study_instance_uid, series_instance_uid,
    sop_class as sop_class_uid, sop_instance as sop_instance_link
  from
    ss_for natural join ss_volume natural join
    file_structure_set join file_sop_common using (file_id)
  where structure_set_id in (
    select 
      structure_set_id 
    from
      file_structure_set fs, file_sop_common sc
    where
      sc.file_id = fs.file_id and sop_instance_uid in (
         select distinct sop_instance_uid 
         from file_sop_common natural join file_patient
         where patient_id = ?
     )
  )
) as foo 
group by sop_instance_uid