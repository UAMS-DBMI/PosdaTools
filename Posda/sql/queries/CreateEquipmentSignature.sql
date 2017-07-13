-- Name: CreateEquipmentSignature
-- Schema: posda_phi
-- Columns: []
-- Args: ['equipment_signature']
-- Tags: ['UsedInPhiSeriesScan', 'NotInteractive']
-- Description: Create New Equipment Signature Id

insert into equipment_signature(equipment_signature)values(?)
returning equipment_signature_id
