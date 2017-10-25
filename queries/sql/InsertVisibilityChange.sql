-- Name: InsertVisibilityChange
-- Schema: posda_files
-- Columns: []
-- Args: ['file_id', 'user_name', 'prior_visibility', 'new_visibility', 'reason']
-- Tags: ['ImageEdit', 'NotInteractive']
-- Description: Insert Image Visibility Change
-- 
-- 

insert into file_visibility_change(
  file_id, user_name, time_of_change,
  prior_visibility, new_visibility, reason_for
)values(
  ?, ?, now(),
  ?, ?, ?
)
