-- Name: DatesOfUploadByCollectionSite
-- Schema: posda_files
-- Columns: ['date', 'num_uploads']
-- Args: ['collection', 'site']
-- Tags: ['receive_reports']
-- Description: Show me the dates with uploads for Collection from Site
-- 

select distinct date_trunc as date, count(*) as num_uploads from (
 select 
  date_trunc('day', import_time),
  file_id
from file_import natural join import_event
  natural join ctp_file
where project_name = ? and site_name = ? 
) as foo
group by date
order by date
