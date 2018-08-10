-- Name: TotalsByDateRange
-- Schema: posda_files
-- Columns: ['project_name', 'site_name', 'num_subjects', 'num_studies', 'num_series', 'total_files']
-- Args: ['from', 'to']
-- Tags: ['AllCollections', 'DateRange', 'Kirk', 'Totals', 'count_queries', 'end_of_month']
-- Description: Get posda totals by date range
-- 
-- **WARNING:**  This query can run for a **LONG** time if you give it a large date range.
-- It is intended for short date ranges (i.e. "What came in last night?" or "What came in last month?")
-- 


select distinct
	project_name,
	site_name,

	count(distinct patient_id),
	count(distinct study_instance_uid),
	count(distinct series_instance_uid),
	count(distinct sop_instance_uid)
from
	import_event
	natural join file_import
	natural join ctp_file
	natural join file_study
	natural join file_series
	natural join file_sop_common
	natural join file_patient

where
	visibility is null
	and import_time between ? and ? 

group by
	project_name,
	site_name
