-- Name: GetElementSignatureId
-- Schema: posda_phi
-- Columns: ['id']
-- Args: []
-- Tags: ['NotInteractive', 'UsedInPhiSeriesScan', 'ElementDisposition']
-- Description: Get current value of ElementSignatureId Sequence
-- 

select currval('element_signature_element_signature_id_seq') as id