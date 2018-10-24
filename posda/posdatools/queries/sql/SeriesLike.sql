-- Name: SeriesLike
-- Schema: posda_files
-- Columns: ['collection', 'site', 'pat_id', 'series_instance_uid', 'series_description', 'count']
-- Args: ['collection', 'site', 'description_matching']
-- Tags: ['find_series', 'pattern', 'posda_files']
-- Description: Select series not matching pattern
-- 

select
   distinct collection, site, pat_id,
   series_instance_uid, series_description, count(*)
from (
  select
   distinct
     project_name as collection, site_name as site,
     file_id, series_instance_uid, patient_id as pat_id,
     series_description
  from
     ctp_file natural join file_series natural join file_patient
  where
     project_name = ? and site_name = ? and 
     series_description like ?
) as foo
group by collection, site, pat_id, series_instance_uid, series_description
order by collection, site, pat_id
