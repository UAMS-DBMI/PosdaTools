-- Name: FileSizeByPublic
-- Schema: public
-- Columns: ['collection', 'total_disc_used']
-- Args: []
-- Tags: ['AllCollections', 'queries']
-- Description: Get a list of available queries

select distinct project as collection, sum(dicom_size) as total_disc_used from general_image group by project order by total_disc_used desc