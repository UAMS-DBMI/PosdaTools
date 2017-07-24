-- Name: ValuesWithVrTagAndCount
-- Schema: posda_phi
-- Columns: ['vr', 'value', 'element_signature', 'private_disposition', 'num_files']
-- Args: ['scan_id']
-- Tags: ['tag_usage', 'PrivateTagKb']
-- Description: List of values seen in scan by VR (with count of elements)
-- 

select
    distinct vr, value, element_signature, private_disposition, count(*)  as num_files
from
    scan_event natural join series_scan natural join seen_value
    natural join element_signature natural join scan_element
where
    scan_event_id = ?
group by value, element_signature, vr, private_disposition
