-- Name: GetEndOfWeek
-- Schema: posda_files
-- Columns: ['end_week']
-- Args: ['from']
-- Tags: ['downloads_by_date']
-- Description: Counts query by Collection, Site
-- 

select 
  date_trunc('week', to_timestamp(?, 'yyyy-mm-dd') + interval '1 week') as end_week
 