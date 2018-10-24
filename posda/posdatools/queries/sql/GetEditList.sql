-- Name: GetEditList
-- Schema: posda_files
-- Columns: ['dicom_edit_event_id', 'from_dicom_file', 'to_dicom_file', 'edit_desc_file', 'when_done', 'performing_user']
-- Args: []
-- Tags: ['ImageEdit']
-- Description: Get list of dicom_edit_event

select * from dicom_edit_event