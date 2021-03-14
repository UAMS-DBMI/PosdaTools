-- Name: CreateNewWorkWithPriority
-- Schema: posda_files
-- Columns: ['work_id']
-- Args: ['subprocess_invocation_id', 'input_file_id', 'background_queue_name']
-- Tags: []
-- Description:  Create row in worker table for this subprocess id, with background_queue_name
-- 

insert into work (
  subprocess_invocation_id, input_file_id, background_queue_name
 ) values (?,?,?) returning work_id