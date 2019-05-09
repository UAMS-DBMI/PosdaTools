-- Name: GetFileIdByDigest
-- Schema: posda_files
-- Columns: ['file_id']
-- Args: ['digest']
-- Tags: ['import_events', 'QIN-GBM-DSC-MRI-DRO/Barrow']
-- Description: Counts query by Collection, Site
-- 

select file_id from file where digest = ?