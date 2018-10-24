-- Name: GetBackgroundButtonsByTag
-- Schema: posda_queries
-- Columns: ['background_button_id', 'operation_name', 'object_class', 'button_text']
-- Args: ['tags']
-- Tags: ['NotInteractive', 'used_in_process_popup']
-- Description: 

select
    background_button_id,
    operation_name,
    object_class,
    button_text
from background_buttons
where tags && ?

