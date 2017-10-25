-- Name: GetPublicFeaturesBySignature
-- Schema: dicom_dd
-- Columns: ['name', 'vr']
-- Args: ['element_signature']
-- Tags: ['UsedInPhiSeriesScan', 'NotInteractive', 'ElementDisposition']
-- Description: Get Element Signature By Signature (pattern) and VR

select
  name, vr
from dicom_element
where tag = ?