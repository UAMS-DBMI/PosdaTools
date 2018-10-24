-- Name: GetFileCountByLikeLoadPath
-- Schema: posda_files
-- Columns: ['import_event_id', 'num_files']
-- Args: ['like_rel_path']
-- Tags: ['radcomp']
-- Description: Add a filter to a tab

select distinct import_event_id, count(distinct file_id)  as num_files from file_import where rel_path like ? group by import_event_id;