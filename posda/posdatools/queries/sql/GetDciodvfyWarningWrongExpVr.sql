-- Name: GetDciodvfyWarningWrongExpVr
-- Schema: posda_phi_simple
-- Columns: ['id']
-- Args: ['warning_tag', 'warning_desc', 'warning_comment', 'warning_value', 'warning_reason']
-- Tags: ['NotInteractive', 'used_in_dciodvfy']
-- Description: Get an dciodvfy_warnings row by warning_text (if present)

select
  dciodvfy_warning_id as id
from 
  dciodvfy_warning
where
  warning_type = 'WrongExplicitVr'
  and warning_tag = ?
  and warning_desc = ?
  and warning_comment = ?
  and warning_value = ?
  and warning_reason = ?
 