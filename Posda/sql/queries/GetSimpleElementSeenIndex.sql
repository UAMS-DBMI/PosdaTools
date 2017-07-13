-- Name: GetSimpleElementSeenIndex
-- Schema: posda_phi_simple
-- Columns: ['id']
-- Args: []
-- Tags: ['used_in_simple_phi', 'NotInteractive']
-- Description: Get index of newly created element_seen

select currval('element_seen_element_seen_id_seq') as id