-- Name: CreateDciodvfyWarning
-- Schema: posda_phi_simple
-- Columns: []
-- Args: ['warning_type', 'warning_tag', 'warning_desc', 'warning_iod', 'warning_comment', 'warning_value', 'warning_reason', 'warning_index', 'warning_text']
-- Tags: ['NotInteractive', 'used_in_dciodvfy']
-- Description: Create a dciodvfy_warnings row

insert into dciodvfy_warning(
  warning_type,
  warning_tag,
  warning_desc,
  warning_iod,
  warning_comment,
  warning_value,
  warning_reason,
  warning_index,
  warning_text
) values (
  ?, ?, ?, ?,
  ?, ?, ?, ?,
  ?
)