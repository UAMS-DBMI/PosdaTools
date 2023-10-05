-- Name: HideFileWithNoCtp
-- Schema: posda_files
-- Columns: []
-- Args: ['file_id']
-- Tags: ['ImageEdit', 'NotInteractive']
-- Description: Hide a file which currently has no ctp_file row
-- 
-- Insert a ctp_file row with:
-- project_name = 'UNKNOWN'
-- site_name = 'UNKNOWN'
-- visibility = 'hidden'
-- 

insert into ctp_file(file_id, project_name, trial_name, site_name, visibility)
values(?, 'UNKNOWN', 'UNKNOWN', 'UNKNOWN', 'hidden')