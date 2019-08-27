-- Name: PatientsInCurrentActivityTimepointByActivityIdWithMinStudyDate
-- Schema: posda_files
-- Columns: ['patient_id', 'min_study_date']
-- Args: ['activity_id']
-- Tags: ['activity_timepoint']
-- Description: Get list of patients by activity_timepoint_id
--

select distinct patient_id, min(study_date) as min_study_date
from file_patient natural join file_study natural left join ctp_file
where file_id in (
  select file_id from activity_timepoint_file
  where  activity_timepoint_id in (
     select max(activity_timepoint_id)
     from activity_timepoint
     where activity_id = ?
  )
)
group by patient_id