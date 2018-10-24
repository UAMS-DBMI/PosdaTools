-- Name: GetSeenValue
-- Schema: posda_phi
-- Columns: ['seen_value_id', 'value']
-- Args: ['value']
-- Tags: ['UsedInPhiSeriesScan', 'NotInteractive']
-- Description: Get Seen Value Id

select * from seen_value where value = ?
