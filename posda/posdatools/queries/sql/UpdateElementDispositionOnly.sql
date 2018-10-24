-- Name: UpdateElementDispositionOnly
-- Schema: posda_phi
-- Columns: []
-- Args: ['private_disposition', 'element_signature', 'vr']
-- Tags: ['NotInteractive', 'Update', 'ElementDisposition']
-- Description: Update Element Disposition
-- For use in scripts
-- Not really intended for interactive use
-- 

update element_signature set 
  private_disposition = ?
where
  element_signature = ? and
  vr = ?
