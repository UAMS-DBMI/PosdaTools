-- Name: GetBackgroundButtons
-- Schema: posda_queries
-- Columns: ['background_button_id', 'operation_name', 'object_class', 'button_text']
-- Args: []
-- Tags: ['NotInteractive', 'used_in_process_popup']
-- Description: N
-- o
-- n
-- e

select
    background_button_id,
    operation_name,
    object_class,
    button_text
from background_buttons

