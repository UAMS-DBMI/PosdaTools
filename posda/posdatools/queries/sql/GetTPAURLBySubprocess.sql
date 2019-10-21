-- Name: GetTPAURLBySubprocess
-- Schema: posda_files
-- Columns: ['third_party_analysis_url']
-- Args: ['subprocess_invocation_id']
-- Tags: ['for_scripting']
-- Description: Get the Third Party Analysis URL associated with an Activity, 
-- given a subprocess_invocation_id

select third_party_analysis_url
from activity_task_status
natural join activity
where subprocess_invocation_id = ?
