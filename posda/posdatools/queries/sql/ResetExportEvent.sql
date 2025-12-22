-- Name: ResetExportEvent
-- Schema: posda_files
-- Columns: ['export_event_id', 'non_success_count', 'updates_applied']
-- Args: ['export_event_id', 'expected_count']
-- Tags: []
-- Description: Reset an export event. expected_count must match the real count

-- select
WITH params AS (
  SELECT
    ?::bigint  AS export_event_id,
    ?::integer AS expected_count
),
non_success AS (
  SELECT
    COUNT(*) AS cnt
  FROM file_export fe
  JOIN params p ON fe.export_event_id = p.export_event_id
  WHERE fe.transfer_status IS DISTINCT FROM 'success'
),
reset_file_export AS (
  UPDATE file_export fe
  SET when_transferred = NULL,
      transfer_status  = NULL
  FROM params p, non_success ns
  WHERE fe.export_event_id = p.export_event_id
    AND fe.transfer_status IS DISTINCT FROM 'success'
    AND ns.cnt = p.expected_count
),
reset_export_event AS (
  UPDATE export_event ee
  SET request_pending = TRUE,
      start_time      = NULL,
      end_time        = NULL
  FROM params p, non_success ns
  WHERE ee.export_event_id = p.export_event_id
    AND ns.cnt = p.expected_count
)
SELECT
  p.export_event_id,
  ns.cnt AS non_success_count,
  (ns.cnt = p.expected_count) AS updates_applied
FROM params p
LEFT JOIN non_success ns ON true
