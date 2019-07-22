-- Name: GetSiteCodeBySite
-- Schema: posda_files
-- Columns: ['site_code']
-- Args: ['site_name']
-- Tags: ['for_scripting']
-- Description: Retrive Site Code from the site_codes table, based on site_name

select
  site_code
from site_codes
where site_name = ?
  
