-- Name: SeriesByMatchingImportEvents
-- Schema: posda_files
-- Columns: ['series_instance_uid']
-- Args: ['import_comment_like', 'import_type_like']
-- Tags: ['import_events']
-- Description: Get a list of series in all matching import events
-- 

select distinct series_instance_uid from
  file_series natural join file_import 
where import_event_id in (
  select
    import_event_id
  from 
    import_event natural join file_import
  where
    import_comment like ? and import_type like ?
)
