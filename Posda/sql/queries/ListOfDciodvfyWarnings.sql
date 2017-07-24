-- Name: ListOfDciodvfyWarnings
-- Schema: posda_phi_simple
-- Columns: ['warning_type', 'warning_tag', 'warning_desc', 'warning_iod', 'warning_comment', 'warning_value', 'warning_reason', 'warning_index']
-- Args: []
-- Tags: ['tag_usage', 'dciodvfy']
-- Description: All dciodvfy warnings in DB

select distinct warning_type, warning_tag, warning_desc, warning_iod, warning_comment, warning_value, warning_reason, warning_index
 from dciodvfy_warning
order by warning_type, warning_tag, warning_desc, warning_iod, warning_comment, warning_value, warning_reason, warning_index