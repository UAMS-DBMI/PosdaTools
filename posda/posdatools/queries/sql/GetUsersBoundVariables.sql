-- Name: GetUsersBoundVariables
-- Schema: posda_queries
-- Columns: ['user', 'variable', 'binding']
-- Args: ['user']
-- Tags: ['AllCollections', 'queries', 'activity_support', 'variabler_binding']
-- Description: Get list of variables with bindings for a user

select
  binding_user as user,
  bound_variable_name as variable,
  bound_value as  value
from
  user_variable_binding
where
  binding_user = ?

