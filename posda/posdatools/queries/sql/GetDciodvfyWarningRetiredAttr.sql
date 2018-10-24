-- Name: GetDciodvfyWarningRetiredAttr
-- Schema: posda_phi_simple
-- Columns: ['id']
-- Args: ['warning_tag', 'warning_desc']
-- Tags: ['NotInteractive', 'used_in_dciodvfy']
-- Description: Get dciodvfy_warnings row where warning_type = GetDciodvfyWarningRetiredAttr

select
  dciodvfy_warning_id as id
from 
  dciodvfy_warning
where
  warning_type = 'RetiredAttribute'
  and warning_tag = ?
  and warning_desc = ?