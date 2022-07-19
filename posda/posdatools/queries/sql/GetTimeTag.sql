-- Name: GetTimeTag
-- Schema: posda_files
-- Columns: ['time_tag']
-- Args: []
-- Tags: ['downloads_by_date']
-- Description: Get a time_tag
-- 

select 
  now() as time_tag
 