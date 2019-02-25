-- Name: ProjectCompletion
-- Schema: posda_phi_simple
-- Columns: ['projected_completion']
-- Args: ['start_time', 'num_done_1', 'num_to_do', 'num_done_2']
-- Tags: ['bills_test']
-- Description: Status of PHI scans
-- 

select
  ((now() - ?) / ?) * (cast(? as float) - cast(? as float)) + now() as projected_completion