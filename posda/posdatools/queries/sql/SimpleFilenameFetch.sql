-- Name: SimpleFilenameFetch
-- Schema: posda_files
-- Columns: ['file_name']
-- Args: ['file_id']
-- Tags: []
-- Description: get filename for a file_id
-- 

 select
        file_name
    from
        file_import
    where
        file_id = ?