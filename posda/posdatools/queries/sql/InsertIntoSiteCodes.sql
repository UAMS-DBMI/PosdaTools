-- Name: InsertIntoSiteCodes
-- Schema: posda_files
-- Columns: []
-- Args: ['site_name', 'site_code']
-- Tags: ['adding_ctp', 'mapping_tables', 'for_scripting', 'patient_mapping']
-- Description: Make an entry into the site_codes table

insert into site_codes(site_name, site_code)
values (?, ?)