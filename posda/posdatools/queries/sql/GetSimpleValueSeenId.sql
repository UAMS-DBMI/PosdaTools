-- Name: GetSimpleValueSeenId
-- Schema: posda_phi_simple
-- Columns: ['id']
-- Args: []
-- Tags: ['used_in_simple_phi', 'NotInteractive']
-- Description: Get index of newly created value_seen

select currval('value_seen_value_seen_id_seq') as id