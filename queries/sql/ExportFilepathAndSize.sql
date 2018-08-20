-- Name: ExportFilepathAndSize
-- Schema: posda_files
-- Columns: ['file_name', 'size']
-- Args: ['collection', 'site']
-- Tags: ['Universal']
-- Description: Creates an export list for importing with python_import_csv_filelist.py

select root_path || '/' || rel_path as file_name, size from file natural join file_location natural join file_storage_root natural join ctp_file where project_name = ? and site_name = ?