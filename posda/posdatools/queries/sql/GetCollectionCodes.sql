-- Name: GetCollectionCodes
-- Schema: posda_files
-- Columns: ['collection_name', 'collection_code']
-- Args: []
-- Tags: ['adding_ctp', 'for_scripting']
-- Description: Retrieve entries from patient_mapping table

select
 collection_name, collection_code
from
  collection_codes
  