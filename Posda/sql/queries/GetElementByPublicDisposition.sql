-- Name: GetElementByPublicDisposition
-- Schema: posda_phi
-- Columns: ['element_signature', 'disposition']
-- Args: ['sop_class_uid', 'name', 'disposition']
-- Tags: ['NotInteractive', 'ElementDisposition']
-- Description: Get List of Public Elements By Disposition, Sop Class, and name

select
  element_signature, disposition
from
  element_signature natural join public_disposition
where
  sop_class_uid = ? and name = ? and
  not is_private and disposition = ?
