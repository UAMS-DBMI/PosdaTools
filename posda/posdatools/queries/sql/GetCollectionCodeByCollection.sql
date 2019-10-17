-- Name: GetCollectionCodeByCollection
-- Schema: posda_files
-- Columns: ['collection_code']
-- Args: ['collection_name']
-- Tags: ['for_scripting']
-- Description:  Retrive Collection Code from the collection_codes table, based on collection_name

select
  collection_code
from collection_codes
where collection_name = ?
  
