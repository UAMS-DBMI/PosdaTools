-- Name: GetWinLev
-- Schema: posda_files
-- Columns: ['window_width', 'window_center', 'win_lev_desc', 'wl_index']
-- Args: ['file_id']
-- Tags: ['by_file_id', 'posda_files', 'window_level']
-- Description: Get a Window, Level(s) for a particular file 
-- 

select
  window_width, window_center, win_lev_desc, wl_index
from
  file_win_lev natural join window_level
where
  file_id = ?
order by wl_index desc;
