-- Name: DatesOfUpload
-- Schema: posda_files
-- Columns: ['collection', 'site', 'date', 'num_uploads']
-- Args: []
-- Tags: ['receive_reports']
-- Description: Show me the dates with uploads for Collection from Site
-- 

select 
  distinct project_name as collection, site_name as site,
  date_trunc as date, count(*) as num_uploads from (
   select 
    project_name,
    site_name,
    date_trunc('day', import_time),
    file_id
  from file_import natural join import_event
    natural join ctp_file 
) as foo
group by project_name, site_name, date
order by date, project_name, site_name