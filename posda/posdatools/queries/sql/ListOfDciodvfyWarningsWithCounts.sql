-- Name: ListOfDciodvfyWarningsWithCounts
-- Schema: posda_phi_simple
-- Columns: ['warning_type', 'warning_tag', 'warning_desc', 'warning_iod', 'warning_comment', 'warning_value', 'warning_reason', 'warning_index', 'num_scan_units']
-- Args: []
-- Tags: ['tag_usage', 'dciodvfy']
-- Description: All dciodvfy warnings in DB

select distinct warning_type, warning_tag, warning_desc, warning_iod, warning_comment, warning_value, warning_reason, warning_index, count(distinct dciodvfy_unit_scan_id)  as num_scan_units from dciodvfy_warning
natural join dciodvfy_unit_scan_error group by 
warning_type, warning_tag, warning_desc, warning_iod, warning_comment, warning_value, warning_reason, warning_index
order by warning_type, warning_tag, warning_desc, warning_iod, warning_comment, warning_value, warning_reason, warning_index