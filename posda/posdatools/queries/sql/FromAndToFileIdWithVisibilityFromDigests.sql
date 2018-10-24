-- Name: FromAndToFileIdWithVisibilityFromDigests
-- Schema: posda_files
-- Columns: ['from_file_id', 'to_file_id', 'from_visibility', 'to_visibility']
-- Args: ['from_digest_1', 'to_digest_1', 'from_digest_2', 'to_digest_2']
-- Tags: ['meta', 'test', 'hello', 'bills_test', 'hide_events']
-- Description: Add a filter to a tab

select 
(select file_id from file where digest = ?) as from_file_id,
(select file_id from file where digest = ?) as to_file_id,
(select visibility as from_file_visibility from ctp_file natural join file where digest = ?) as from_visibility,
(select visibility as from_file_visibility from ctp_file natural join file where digest = ?) as to_visibility