-- Name: GetStartOfWeek
-- Schema: posda_files
-- Columns: ['start_week']
-- Args: ['from']
-- Tags: ['downloads_by_date']
-- Description: Counts query by Collection, Site
-- 

select 
  date_trunc('week', to_timestamp(?, 'yyyy-mm-dd')) as start_week
 