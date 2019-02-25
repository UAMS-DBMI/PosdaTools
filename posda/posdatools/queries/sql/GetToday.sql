-- Name: GetToday
-- Schema: posda_files
-- Columns: ['today']
-- Args: []
-- Tags: ['downloads_by_date']
-- Description: Counts query by Collection, Site
-- 

select 
  date_trunc('day',now()) as today
 