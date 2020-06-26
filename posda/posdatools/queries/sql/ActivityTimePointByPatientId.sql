-- Name: ActivityTimePointByPatientId
-- Schema: posda_files
-- Columns: ['activity_id', 'brief_description', 'activity_timepoint_id', 'num_files']
-- Args: ['patient_id']
-- Tags: []
-- Description:  Get Activity and timepoint by patient_id
--

select distinct activity_id, brief_description, activity_timepoint_id, count(distinct file_id) as num_files
from file_patient natural join activity_timepoint_file natural join activity_timepoint
  join activity using(activity_id)
where patient_id = ?
group by activity_id, brief_description, activity_timepoint_id
order by activity_id