-- Name: GetLoadWeeks
-- Schema: posda_files
-- Columns: ['load_week']
-- Args: []
-- Tags: ['downloads_by_date']
-- Description: Counts query by Collection, Site
-- 

select distinct load_week from (select distinct file_id, date_trunc('week', min(import_time)) as load_week from file_import natural join import_event group by file_id) as foo order by load_week;