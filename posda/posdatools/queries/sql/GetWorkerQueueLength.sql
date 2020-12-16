-- Name: GetWorkerQueueLength
-- Schema: posda_files
-- Columns: ['qlength']
-- Args: []
-- Tags: []
-- Description: check length of work queue
--

select count(*) as qlength from work where status != 'finished' and failed = false
