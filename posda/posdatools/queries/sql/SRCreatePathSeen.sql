-- Name: SRCreatePathSeen
-- Schema: posda_phi_simple
-- Columns: ['sr_path_seen_id']
-- Args: ['path_sig_pattern']
-- Tags: ['Structured Report']
-- Description: Creates a new entry in SR_path_seen
--

insert into
   sr_path_seen(path_sig_pattern)
   values(?) returning sr_path_seen_id;
