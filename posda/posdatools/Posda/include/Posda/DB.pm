package Posda::DB;
# 
# This package defines a new interface to the old PosdaDB::PosdaFilesQueries
#
# Eventually it will completely replace the other package.
#
#

require Exporter;
@ISA = 'Exporter';
@EXPORT_OK = ('Query', 'QueryAsync', 'ResetDBHandles', 'GetHandle');

use Modern::Perl '2010';

use Posda::DB::PosdaFilesQueries; # this actually imports PosdaDB::Queries
use Posda::Config 'Database';


sub Query {
  my ($query_name) = @_;
  return PosdaDB::Queries->GetQueryInstance($query_name);
}

sub QueryAsync {
  my ($query_name) = @_;
  return PosdaDB::Queries->GetQueryInstanceAsync($query_name);
}

sub ResetDBHandles {
  return PosdaDB::Queries->reset_db_handles();
}
sub GetHandle {
  my ($schema_name) = @_;
  return PosdaDB::Queries::_get_handle_main(Database($schema_name));
}
1;
