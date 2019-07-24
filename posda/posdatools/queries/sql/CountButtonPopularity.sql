-- Name: CountButtonPopularity
-- Schema: posda_files
-- Columns: ['pop']
-- Args: ['processname']
-- Tags: ['NonInteractive']
-- Description: Retrieve button popularity tracking table
-- 

select count(processname) as pop
from button_popularity
where processname = ?
