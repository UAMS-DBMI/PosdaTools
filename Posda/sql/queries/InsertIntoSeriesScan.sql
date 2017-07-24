-- Name: InsertIntoSeriesScan
-- Schema: posda_phi
-- Columns: []
-- Args: ['scan_id', 'equipment_signature_id', 'series_instance_uid', 'series_scanned_file']
-- Tags: ['UsedInPhiSeriesScan', 'NotInteractive']
-- Description: List of values seen in scan by VR (with count of elements)
-- 

insert into series_scan(
    scan_event_id, 
    equipment_signature_id, 
    series_instance_uid,
    series_scan_status, 
    series_scanned_file
) values (?, ?, ?, 'In Process', ?)
returning series_scan_id
