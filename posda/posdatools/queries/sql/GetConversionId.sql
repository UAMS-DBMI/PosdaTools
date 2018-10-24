-- Name: GetConversionId
-- Schema: posda_files
-- Columns: ['id']
-- Args: []
-- Tags: ['radcomp']
-- Description: Add a filter to a tab

select currval('conversion_event_conversion_event_id_seq') as id