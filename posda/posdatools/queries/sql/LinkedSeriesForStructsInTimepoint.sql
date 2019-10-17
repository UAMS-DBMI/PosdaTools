-- Name: LinkedSeriesForStructsInTimepoint
-- Schema: posda_files
-- Columns: ['series_instance_uid', 'num_files']
-- Args: ['activity_timepoint_id']
-- Tags: ['activity_timepoint']
-- Description: Get Series Linked to RTSTRUCTs in timepoint


select distinct series_instance_uid, count(distinct file_id) as num_files 
from file_sop_common natural join file_series natural join ctp_file
where sop_instance_uid in (                                                                                                                                          
  select distinct sop_instance as sop_instance_uid 
  from contour_image where roi_contour_id in (
    select roi_contour_id from roi natural join roi_contour
    where structure_set_id in (
      select structure_set_id from file_structure_set natural join file_series natural join activity_timepoint_file
      where activity_timepoint_id = ?
    )
  )
)
 group by series_instance_uid;