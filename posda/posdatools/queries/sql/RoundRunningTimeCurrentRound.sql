-- Name: RoundRunningTimeCurrentRound
-- Schema: posda_backlog
-- Columns: ['running_time']
-- Args: []
-- Tags: ['NotInteractive', 'Backlog', 'Backlog Monitor', 'backlog_status']
-- Description: Summary of round by id

select now() - round_start as running_time from round where round_id in (
select round_id from round where round_end is null and round_start is not null)