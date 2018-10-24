-- Name: GetDciodvfyWarningUnrecognizedDT
-- Schema: posda_phi_simple
-- Columns: ['id']
-- Args: ['warning_tag', 'warning_value', 'warning_index']
-- Tags: ['NotInteractive', 'used_in_dciodvfy']
-- Description: Get dciodvfy_warning row where subtype = UnrecognizedDefinedTerm

select
  dciodvfy_warning_id as id
from 
  dciodvfy_warning
where
  warning_type = 'UnrecognizedDefinedTerm'
  and warning_tag = ?
  and warning_value = ?
  and warning_index = ?
