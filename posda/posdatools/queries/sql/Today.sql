-- Name: Today
-- Schema: posda_files
-- Columns: ['today', 'tomorrow']
-- Args: []
-- Tags: ['date_range']
-- Description: Get today and tomorrow dates for date range queries
-- 

select date_trunc('day', now()) as today, 
  date_trunc('day', now() + cast('1 days' as interval)) as tomorrow