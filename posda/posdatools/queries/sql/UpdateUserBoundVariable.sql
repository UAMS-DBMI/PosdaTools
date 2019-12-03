-- Name: UpdateUserBoundVariable
-- Schema: posda_queries
-- Columns: []
-- Args: ['value', 'user', 'variable_name']
-- Tags: ['AllCollections', 'queries', 'activity_support', 'variabler_binding']
-- Description: Update the value of a bound variable
--


update user_variable_binding set
  bound_value = ?
where
  binding_user = ?
  and bound_variable_name = ?
 