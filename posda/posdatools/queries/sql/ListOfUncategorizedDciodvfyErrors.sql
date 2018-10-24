-- Name: ListOfUncategorizedDciodvfyErrors
-- Schema: posda_phi_simple
-- Columns: ['error_text', 'num_occurances']
-- Args: []
-- Tags: ['tag_usage', 'dciodvfy']
-- Description: All dciodvfy uncategorized warnings in DB

select distinct error_text, count(*)  as num_occurances from dciodvfy_error
where
  error_type = 'Uncategorized'
group by 
error_text