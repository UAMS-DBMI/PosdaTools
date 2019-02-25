-- Name: GetWeeksRangeByDate
-- Schema: posda_files
-- Columns: ['start_week', 'end_week', 'end_partial_week']
-- Args: ['from']
-- Tags: ['downloads_by_date']
-- Description: Counts query by Collection, Site
-- 

select 
  date_trunc('week', foo) as start_week,
  date_trunc('week', foo + interval '7 days') as end_week,
  date_trunc('day', foo + interval '1 day') as end_partial_week
where foo in (
  select to_timestamp(?, 'yyyy-mm-dd') as foo
)