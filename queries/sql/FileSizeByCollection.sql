-- Name: FileSizeByCollection
-- Schema: posda_files
-- Columns: ['collection', 'total_disc_used']
-- Args: []
-- Tags: ['AllCollections', 'queries']
-- Description: Get a list of available queries

select project_name as collection,sum(size) as total_disc_used from file natural join ctp_file group by project_name order by total_disc_used desc