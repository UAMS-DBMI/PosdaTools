-- Name: UpdateElementDisposition
-- Schema: posda_phi
-- Columns: []
-- Args: ['private_disposition', 'name_chain', 'element_signature', 'vr']
-- Tags: ['NotInteractive', 'Update', 'ElementDisposition']
-- Description: Update Element Disposition
-- For use in scripts
-- Not really intended for interactive use
-- 

update element_signature set 
  private_disposition = ?,
  name_chain = ?
where
  element_signature = ? and
  vr = ?
