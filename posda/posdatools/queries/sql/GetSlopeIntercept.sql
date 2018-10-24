-- Name: GetSlopeIntercept
-- Schema: posda_files
-- Columns: ['slope', 'intercept', 'si_units']
-- Args: ['file_id']
-- Tags: ['by_file_id', 'posda_files', 'slope_intercept']
-- Description: Get a Slope, Intercept for a particular file 
-- 

select
  slope, intercept, si_units
from
  file_slope_intercept natural join slope_intercept
where
  file_id = ?
