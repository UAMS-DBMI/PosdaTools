-- Name: GetPublicTagNameAndVrBySignature
-- Schema: dicom_dd
-- Columns: ['name', 'vr']
-- Args: ['tag']
-- Tags: ['DispositionReport', 'NotInteractive', 'used_in_reconcile_tag_names']
-- Description: Get the relevant features of a private tag by signature
-- Used in DispositionReport.pl - not for interactive use
-- 

select
  name,
  vr
from dicom_element
where tag = ?
