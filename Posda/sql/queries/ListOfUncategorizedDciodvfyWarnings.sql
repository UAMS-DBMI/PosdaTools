-- Name: ListOfUncategorizedDciodvfyWarnings
-- Schema: posda_phi_simple
-- Columns: ['warning_text', 'num_occurances']
-- Args: []
-- Tags: ['tag_usage', 'dciodvfy']
-- Description: All dciodvfy uncategorized warnings in DB

select distinct warning_text, count(*)  as num_occurances from dciodvfy_warning
where
  warning_type = 'Uncategorized'
group by 
warning_text