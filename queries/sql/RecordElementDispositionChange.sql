-- Name: RecordElementDispositionChange
-- Schema: posda_phi
-- Columns: []
-- Args: ['element_signature_id', 'who_changed_sig', 'why_sig_changed', 'old_disposition', 'new_disposition', 'old_name_chain', 'new_name_chain']
-- Tags: ['NotInteractive', 'Update', 'ElementDisposition']
-- Description: Record a change to Element Disposition
-- For use in scripts
-- Not really intended for interactive use
-- 

insert into element_signature_change(
  element_signature_id, when_sig_changed,
  who_changed_sig, why_sig_changed,
  old_disposition, new_disposition,
  old_name_chain, new_name_chain
) values (
  ?, now(),
  ?, ?,
  ?, ?,
  ?, ?
)
