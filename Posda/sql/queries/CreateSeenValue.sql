-- Name: CreateSeenValue
-- Schema: posda_phi
-- Columns: []
-- Args: ['value']
-- Tags: ['UsedInPhiSeriesScan', 'NotInteractive']
-- Description: Create New Seen Value

insert into seen_value(value)values(?)
returning seen_value_id
