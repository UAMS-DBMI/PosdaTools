-- Name: GetModuleToTableArgs
-- Schema: posda_queries
-- Columns: ['tag_cannonical_name', 'tag', 'posda_table_name', 'column_name', 'preparation_description']
-- Args: ['table_name']
-- Tags: ['bills_test', 'posda_db_populate']
-- Description: Add a filter to a tab

select *
from 
  dicom_tag_parm_column_table natural left join tag_preparation
where posda_table_name = ?