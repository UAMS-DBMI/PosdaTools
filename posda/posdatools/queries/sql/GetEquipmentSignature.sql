-- Name: GetEquipmentSignature
-- Schema: posda_phi
-- Columns: ['equipment_signature_id', 'equipment_signature']
-- Args: ['equipment_signature']
-- Tags: ['UsedInPhiSeriesScan', 'NotInteractive']
-- Description: Get Equipment Signature Id

select * from equipment_signature where equipment_signature = ?
