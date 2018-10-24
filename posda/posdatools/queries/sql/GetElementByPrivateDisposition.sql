-- Name: GetElementByPrivateDisposition
-- Schema: posda_phi
-- Columns: ['element_signature', 'disposition']
-- Args: ['private_disposition']
-- Tags: ['NotInteractive', 'ElementDisposition']
-- Description: Get List of Private Elements By Disposition

select
  element_signature, private_disposition as disposition
from
  element_signature
where
  is_private and private_disposition = ?
