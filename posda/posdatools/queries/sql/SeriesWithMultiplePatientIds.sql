-- Name: SeriesWithMultiplePatientIds
-- Schema: posda_files
-- Columns: ['series_instance_uid', 'patient_id']
-- Args: ['collection']
-- Tags: ['by_study', 'consistency', 'series_consistency']
-- Description: Find Inconsistent Studies
-- 

select
  distinct series_instance_uid,
  patient_id
from
  file_series natural join file_patient natural join ctp_file                                                      
where series_instance_uid in (                                                                                                                                                        
  select distinct series_instance_uid from (                                                                                                                                                                                    
     select * from (
        select distinct series_instance_uid, count(*) from (
          select distinct series_instance_uid, patient_id
          from file_series natural join file_patient natural join ctp_file
          where project_name = ?
        ) as foo group by series_instance_uid
      ) as foo where count > 1
   ) as foo
)