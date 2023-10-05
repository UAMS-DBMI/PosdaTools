-- Name: AAA_import_test_query1
-- Schema: posda_files
-- Columns: ['file_id']
-- Args: []
-- Tags: ['AllCollections', 'DateRange', 'Kirk', 'Totals', 'count_queries', 'end_of_month']
-- Description: Get posda totals by date range
-- 
-- **WARNING:**  This query can run for a **LONG** time if you give it a large date range.
-- It is intended for short date ranges (i.e. "What came in last night?" or "What came in last month?")
-- (Ignore this line, it is a test!)
-- 

select '2492183' as file_id
union
select '4372774' as file_id
