-- Name: CreateNewWork
-- Schema: posda_files
-- Columns: ['work_id']
-- Args: ['subprocess_invocation_id', 'input_file_id']
-- Tags: []
-- Description: Create row in worker table for this subprocess id
--

insert into work (subprocess_invocation_id, input_file_id ) values (?,?) returning work_id