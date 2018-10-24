-- Name: GetNonDicomPathSeenId
-- Schema: posda_phi_simple
-- Columns: ['id']
-- Args: []
-- Tags: ['used_in_simple_phi', 'NotInteractive', 'non_dicom_phi']
-- Description: Get value seen if exists

select
  currval('non_dicom_file_scan_non_dicom_file_scan_id_seq') as id