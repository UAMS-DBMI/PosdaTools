-- Name: AdHocStonyBrookQueryNumOfPatientsWithMultipleActivities
-- Schema: posda_files
-- Columns: ['num_activities', 'num_patients']
-- Args: []
-- Tags: []
-- Description: Find patients in multiple StonyBrook activities
-- 

select distinct num_activities, count(*) as num_patients from (
select distinct patient_id, count(*) as num_activities from
(select 
distinct patient_id, activity_id
from activity_timepoint_file natural join file_patient natural join activity_timepoint
where activity_id in (470,471,471,473,474,475,476)
order by patient_id, activity_id) as foo group by patient_id
order by num_activities desc
)as foo group by num_activities