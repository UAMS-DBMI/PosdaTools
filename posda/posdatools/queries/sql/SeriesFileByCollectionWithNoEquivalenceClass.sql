-- Name: SeriesFileByCollectionWithNoEquivalenceClass
-- Schema: posda_files
-- Columns: ['series_instance_uid']
-- Args: ['collection']
-- Tags: ['equivalence_classes']
-- Description: Construct list of series in a collection where no image_equivalence_class exists

select distinct
  series_instance_uid
from
  file_series s
where 
  file_id in (
    select distinct file_id
    from ctp_file
    where project_name = ?
  )
  and not exists (
    select 
      series_instance_uid
   from
      image_equivalence_class e
   where
      e.series_instance_uid = s.series_instance_uid
 )