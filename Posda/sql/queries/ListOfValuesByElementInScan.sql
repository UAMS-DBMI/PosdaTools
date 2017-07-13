-- Name: ListOfValuesByElementInScan
-- Schema: posda_phi
-- Columns: ['element_signature', 'value']
-- Args: ['element_signature', 'scan_id']
-- Tags: ['ElementDisposition']
-- Description: Get List of Values for Private Element based on element_signature_id

select element_signature, value                  
from element_signature natural join scan_element natural join seen_value natural join series_scan natural join scan_event where element_signature = ? and scan_event_id = ?;