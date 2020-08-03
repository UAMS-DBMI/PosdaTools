-- Name: ForMakingPatientConversion
-- Schema: posda_files
-- Columns: ['from', 'to']
-- Args: []
-- Tags: ['DateRange', 'Kirk', 'Totals', 'count_queries', 'end_of_month']
-- Description:  Get posda totals by date range
-- 
-- **WARNING:**  This query can run for a **LONG** time if you give it a large date range.
-- It is intended for short date ranges (i.e. "What came in last night?" or "What came in last month?")
-- (Ignore this line, it is a test!)
--

select '<'||patient_id||'>' as from, '<COVID-19-AR-'||patient_id||'>' as to from(
select distinct patient_id from activity_timepoint_file natural join file_patient where
activity_timepoint_id = 1810) as foo