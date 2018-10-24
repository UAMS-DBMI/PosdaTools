-- Name: GetMatchingRootID
-- Schema: posda_files
-- Columns: ['file_storage_root_id']
-- Args: ['root_path']
-- Tags: ['Universal']
-- Description: Checks for the local environment's ID for a certain root path. Used by python_import_csv_filelist.py to insert file info into local development environments for files physically stored and referenced in internal posda production. 
-- 
-- (import list will have the root path for a file in prod, this will find the local id for that path)

select file_storage_root_id from file_storage_root where root_path = ?