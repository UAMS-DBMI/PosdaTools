-- Name: GetEquipmentSignatureId
-- Schema: posda_phi
-- Columns: ['id']
-- Args: []
-- Tags: ['NotInteractive', 'UsedInPhiSeriesScan']
-- Description: Get current value of EquipmentSignatureId Sequence
-- 

select currval('equipment_signature_equipment_signature_id_seq') as id