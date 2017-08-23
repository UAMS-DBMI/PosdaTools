package Posda::DB::Queries;
# 
# This package defines a new interface to the old PosdaDB::PosdaFilesQueries
#
# Eventually it may completely replace the other package.
#
#

require Exporter;
@ISA = 'Exporter';
@EXPORT_OK = ('Query');

use Modern::Perl '2010';
use Method::Signatures::Simple;

use Posda::DB::PosdaFilesQueries; # this actually imports PosdaDB::Queries


func Query($query_name) {
  return PosdaDB::Queries->GetQueryInstance($query_name);
}

func QueryAsync($query_name) {
  return PosdaDB::Queries->GetQueryInstanceAsync($query_name);
}

1;
