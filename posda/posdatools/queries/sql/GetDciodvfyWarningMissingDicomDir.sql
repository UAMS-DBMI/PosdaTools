-- Name: GetDciodvfyWarningMissingDicomDir
-- Schema: posda_phi_simple
-- Columns: ['id']
-- Args: ['warning_tag']
-- Tags: ['NotInteractive', 'used_in_dciodvfy']
-- Description: Get an dciodvfy_warnings row by warning_text (if present)

select
  dciodvfy_warning_id as id
from 
  dciodvfy_warning
where
  warning_type = 'MissingForDicomDir'
  and warning_tag = ?
 