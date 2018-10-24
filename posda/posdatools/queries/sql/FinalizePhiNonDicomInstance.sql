-- Name: FinalizePhiNonDicomInstance
-- Schema: posda_phi_simple
-- Columns: []
-- Args: ['phi_non_dicom_scan_instance_id']
-- Tags: ['used_in_simple_phi', 'NotInteractive', 'non_dicom_phi']
-- Description: Get value seen if exists

update phi_non_dicom_scan_instance
set pndsi_end_time = now()
where phi_non_dicom_scan_instance_id = ?