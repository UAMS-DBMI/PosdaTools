-- Name: GetDciodvfyWarningQuestionable
-- Schema: posda_phi_simple
-- Columns: ['id']
-- Args: ['warning_reason', 'warning_tag', 'warning_index']
-- Tags: ['NotInteractive', 'used_in_dciodvfy']
-- Description: Get an dciodvfy_warnings row by warning_text (if present)

select
  dciodvfy_warning_id as id
from 
  dciodvfy_warning
where
  warning_type = 'QuestionableValue'
  and warning_reason = ?
  and warning_tag = ?
  and warning_index = ?
 