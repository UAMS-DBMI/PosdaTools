-- Name: ListOfPrivateElementsValues
-- Schema: posda_phi
-- Columns: ['value']
-- Args: ['element_signature_id']
-- Tags: ['ElementDisposition']
-- Description: Get List of Values for Private Element based on element_signature_id

select
  distinct value
from
  scan_element natural join seen_value
where
  element_signature_id = ?
order by value
