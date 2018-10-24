-- Name: GetSeenValueId
-- Schema: posda_phi
-- Columns: ['id']
-- Args: []
-- Tags: ['UsedInPhiSeriesScan', 'NotInteractive']
-- Description: Get current value of seen_value_id sequence

select currval('seen_value_seen_value_id_seq') as id