-- Name: GetPhiNonDicomScanId
-- Schema: posda_phi_simple
-- Columns: ['id']
-- Args: []
-- Tags: ['used_in_simple_phi', 'NotInteractive', 'non_dicom_phi']
-- Description: Get value seen if exists

select
  currval('phi_non_dicom_scan_instance_phi_non_dicom_scan_instance_id_seq') as id