-- Name: HideSeriesNotLikeWithModality
-- Schema: posda_files
-- Columns: None
-- Args: ['modality', 'collection', 'site', 'description_not_matching']
-- Tags: ['Update', 'posda_files']
-- Description: Hide series not matching pattern by modality
-- 

update ctp_file set visibility = 'hidden'
where file_id in (
  select
    file_id
  from
    file_series
  where
    series_instance_uid in (
      select
         distinct series_instance_uid
      from (
        select
         distinct
           file_id, series_instance_uid, series_description
        from
           ctp_file natural join file_series
        where
           modality = ? and project_name = ? and site_name = ?and 
           series_description not like ?
      ) as foo
    )
  )
