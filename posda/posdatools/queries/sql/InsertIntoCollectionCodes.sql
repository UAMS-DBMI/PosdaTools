-- Name: InsertIntoCollectionCodes
-- Schema: posda_files
-- Columns: []
-- Args: ['collection_name', 'collection_code']
-- Tags: ['adding_ctp', 'mapping_tables', 'for_scripting', 'patient_mapping']
-- Description:  Make an entry into the collection_codes table


insert into collection_codes(collection_name, collection_code)
values (?, ?)