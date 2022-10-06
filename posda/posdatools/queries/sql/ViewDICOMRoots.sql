-- Name: ViewDICOMRoots
-- Schema: posda_queries
-- Columns: ['collection_name', 'collection_code', 'site_name', 'site_code', 'patient_id_prefix', 'body_part', 'access_type', 'baseline_date', 'date_shift', 'DicomRootPairID']
-- Args: []
-- Tags: ['dicom_roots']
-- Description: View the dicom_roots
--
--

select
    b.*,
    c.*,
    a.patient_id_prefix,
    a.body_part,
    a.access_type,
    a.baseline_date,
    a.date_shift,
    a.submission_id as DicomRootPairID
from
    submissions a
    natural join collection_codes b
    natural join site_codes c;
