-- Name: AddPidToSubprocessInvocation
-- Schema: posda_queries
-- Columns: []
-- Args: ['pid', 'subprocess_invocation_id']
-- Tags: ['NotInteractive', 'used_in_background_processing']
-- Description: Add a pid to a subprocess_invocation row
-- 
-- used in DbIf after subprocess invoked

update subprocess_invocation set
  process_pid = ?
where
  subprocess_invocation_id = ?
