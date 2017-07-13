-- Name: CreateElementSignature
-- Schema: posda_phi
-- Columns: []
-- Args: ['element_signature', 'vr', 'is_private']
-- Tags: ['UsedInPhiSeriesScan', 'NotInteractive']
-- Description: Create New Element Signature Id

insert into element_signature(element_signature, vr, is_private) 
values (?, ?, ?)
returning element_signature_id
