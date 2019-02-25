-- Name: GetThisWeeksRange
-- Schema: posda_files
-- Columns: ['start_week', 'end_week', 'end_partial_week', 'today']
-- Args: []
-- Tags: ['downloads_by_date']
-- Description: Counts query by Collection, Site
-- 

select 
  date_trunc('week', now()) as start_week,
  date_trunc('week', now() + interval '7 days') as end_week,
  date_trunc('day', now() + interval '1 day') as end_partial_week,
  date_trunc('day', now()) as today
