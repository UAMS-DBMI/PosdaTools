-- Name: ExportFilepathAndSize
-- Schema: posda_files
-- Columns: ['root_path', 'rel_path', 'size', 'digest']
-- Args: ['collection', 'site']
-- Tags: ['Universal']
-- Description: Creates an export list for importing with python_import_csv_filelist.py

select 
  root_path,
  rel_path,
  size,
  digest 
from file 
  natural join file_location 
  natural join file_storage_root 
  natural join ctp_file 
where project_name = ? 
  and site_name = ?