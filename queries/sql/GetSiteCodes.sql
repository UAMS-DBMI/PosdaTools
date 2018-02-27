-- Name: GetSiteCodes
-- Schema: posda_files
-- Columns: ['site_name', 'site_code']
-- Args: []
-- Tags: ['adding_ctp', 'for_scripting']
-- Description: Retrieve entries from patient_mapping table

select
  site_name, site_code
from
  site_codes
  