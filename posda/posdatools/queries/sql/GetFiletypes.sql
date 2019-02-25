-- Name: GetFiletypes
-- Schema: posda_files
-- Columns: ['file_type', 'num_files']
-- Args: []
-- Tags: ['downloads_by_date']
-- Description: Counts query by Collection, Site
-- 

select distinct file_type, count(*) as num_files from file group by file_type
 