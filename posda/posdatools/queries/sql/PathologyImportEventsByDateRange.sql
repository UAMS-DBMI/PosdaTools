-- Name: PathologyImportEventsByDateRange
-- Schema: posda_files
-- Columns: ['import_event_id', 'import_time', 'import_type', 'import_comment', 'num_files']
-- Args: ['from', 'to']
-- Tags: []
-- Description: Get Pathology ImportEvents By Date Range
--

select distinct
    import_event_id,
    import_time,
    import_type,
    import_comment,
    count(distinct file_id) as num_files
from
    import_event
    natural join file_import
where
    import_time > ? and import_time < ?
    and import_origin = 'web'
group by
    1, 2, 3, 4
