-- Name: GetElementByPrivateDispositionSimple
-- Schema: posda_phi_simple
-- Columns: ['element_signature', 'disposition']
-- Args: ['private_disposition']
-- Tags: ['NotInteractive', 'ElementDisposition']
-- Description: Get List of Private Elements By Disposition

select
  element_sig_pattern as element_signature, private_disposition as disposition
from
  element_seen
where
  is_private and private_disposition = ?
