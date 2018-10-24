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
use Method::Signatures::Simple;

use Posda::DB::PosdaFilesQueries; # this actually imports PosdaDB::Queries
use Posda::Config 'Database';


func Query($query_name) {
  return PosdaDB::Queries->GetQueryInstance($query_name);
}

func QueryAsync($query_name) {
  return PosdaDB::Queries->GetQueryInstanceAsync($query_name);
}

func ResetDBHandles() {
  return PosdaDB::Queries->reset_db_handles();
}
func GetHandle($schema_name){
  return PosdaDB::Queries::_get_handle_main(Database($schema_name));
}
1;
