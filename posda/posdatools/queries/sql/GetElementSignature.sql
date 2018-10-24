-- Name: GetElementSignature
-- Schema: posda_phi
-- Columns: ['element_signature_id', 'element_signature', 'is_private', 'vr']
-- Args: ['element_signature', 'vr']
-- Tags: ['UsedInPhiSeriesScan', 'NotInteractive', 'ElementDisposition']
-- Description: Get Element Signature By Signature (pattern) and VR

select * from element_signature
  where element_signature = ? and vr = ?
