-- Name: DuplicateCtpFile
-- Schema: posda_files
-- Columns: ['collection', 'site', 'dicom_file_type', 'num_files', 'first', 'last', 'num_imports', 'duration']
-- Args: []
-- Tags: ['AllCollections', 'queries']
-- Description: Get a list of available queries

select
  distinct project_name as collection,
  site_name as site,
  dicom_file_type,
  count(distinct file_id) as num_files,
  min(import_time) as first,
  max(import_time) as last,
  count(*) as num_imports,
  max(import_time) - min(import_time) as duration
from
   ctp_file natural join dicom_file natural join file_import natural join import_event
where file_id in (
  select file_id from (
    select distinct file_id, count(*) from dicom_file group by file_id 
  ) as foo where count > 1
) group by collection, site, dicom_file_type order by collection, site;