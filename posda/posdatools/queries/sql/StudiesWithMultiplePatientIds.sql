-- Name: StudiesWithMultiplePatientIds
-- Schema: posda_files
-- Columns: ['study_instance_uid', 'patient_id']
-- Args: ['collection']
-- Tags: ['by_study', 'consistency', 'study_consistency']
-- Description: Find Inconsistent Studies
-- 

select
  distinct study_instance_uid,
  patient_id
from
  file_study natural join file_patient natural join ctp_file                                                      
where study_instance_uid in (                                                                                                                                                        
  select distinct study_instance_uid from (                                                                                                                                                                                    
     select * from (
        select distinct study_instance_uid, count(*) from (
          select distinct study_instance_uid, patient_id
          from file_study natural join file_patient natural join ctp_file
          where project_name = ?
        ) as foo group by study_instance_uid
      ) as foo where count > 1
   ) as foo
)