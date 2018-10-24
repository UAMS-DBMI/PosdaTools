-- Name: RecordFileConversion
-- Schema: posda_files
-- Columns: []
-- Args: ['from_file_id', 'to_file_id', 'conversion_event_id']
-- Tags: ['radcomp']
-- Description: Add a filter to a tab

insert into non_dicom_conversion(from_file_id, to_file_id, conversion_event_id)
values(?, ?, ?)