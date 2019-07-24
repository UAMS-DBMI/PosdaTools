-- Name: IncreaseButtonPopularity
-- Schema: posda_files
-- Columns: []
-- Args: ['processname']
-- Tags: ['NonInteractive']
-- Description: Add process name to the button popularity tracking table
-- 

insert into button_popularity (processname, created)
values (?, now())
