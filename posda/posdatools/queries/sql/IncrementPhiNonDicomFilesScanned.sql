-- Name: IncrementPhiNonDicomFilesScanned
-- Schema: posda_phi_simple
-- Columns: []
-- Args: ['phi_non_dicom_scan_instance_id']
-- Tags: ['used_in_simple_phi', 'NotInteractive', 'non_dicom_phi']
-- Description: Get value seen if exists

update phi_non_dicom_scan_instance
set pndsi_num_files_scanned = pndsi_num_files_scanned + 1
where phi_non_dicom_scan_instance_id = ?