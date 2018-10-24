-- Name: GetDciodvfyErrorUnrecogPub
-- Schema: posda_phi_simple
-- Columns: ['id']
-- Args: ['error_tag']
-- Tags: ['NotInteractive', 'used_in_dciodvfy']
-- Description: Get an dciodvfy_errors row by error_tag where error_type = 'UnrecognizedPublicTag'

select
  dciodvfy_error_id as id
from 
  dciodvfy_error
where
  error_type = 'UnrecognizedPublicTag'
  and error_tag = ?
