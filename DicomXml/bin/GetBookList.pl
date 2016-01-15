#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/DicomXml/bin/GetBookList.pl,v $
#$Date: 2014/05/08 19:26:05 $
#$Revision: 1.1 $
#
#Copyright 2013, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
use DBI;
use Debug;
my $dbg = sub { print STDERR @_ };
use Storable qw( store_fd fd_retrieve );
my $help = <<EOF;
Select Document List meant to run as sub-process
Receives parameters vi fd_retrieve from STDIN.
Writes results to STDOUT via store_fd.
Incoming datastucture:
\$in = {
  database_name => <name>,
  book_only => 0 | 1,
};
Outgoing datastructure => {
  status => OK | ERROR,
  [error => "Error message",]
  [book_list => [ [<element_id>, <file_id>, <file_path>], ... ], ]
};

EOF
if($#ARGV >= 0){
  if($ARGV[0] eq "-h"){
    print STDERR $help;
    exit;
  }
  print STDERR $help;
  Error("Should not have a parameter (params received from STDIN)", $help);
}
my $results = {};
sub Error{
  my($message, $addl) = @_;
  $results->{Status} = "Error";
  $results->{message} = $message;
  if($addl){ $results->{additional_info} = $addl }
  store_fd($results, \*STDOUT);
  exit;
}
my $params;
eval { $params = fd_retrieve(\*STDIN) };
if($@){
  print STDERR
    "SubProcessRelinkStruct.pl: unable to fd_retrieve from STDIN ($@)\n";
  Error("unable to retrieve from STDIN", $@);
}
my $db = DBI->connect("dbi:Pg:dbname=$params->{database_name}", "", "");
unless($db) { Error("can't connect to $params->{database_name}") }
if($params->{book_only}){
  my $q = $db->prepare(
    "select * from\n" .
    "  xml_document_content natural join\n" .
    "  xml_document natural join xml_element\n" .
    "where xml_element_name = ?"
  ); 
  $q->execute("book");
  my @results;
  while (my $h = $q->fetchrow_hashref){
    push(@results,
      [$h->{xml_element_id}, $h->{xml_document_id}, $h->{xml_file}]);
  }
  $results->{status} = "OK";
  $results->{book_list} = \@results;
  store_fd($results, \*STDOUT);
} else {
  my $q = $db->prepare(
    "select * from\n" .
    "  xml_document_content natural join\n" .
    "  xml_document natural join xml_element\n"
  ); 
  $q->execute;
  my @results;
  while (my $h = $q->fetchrow_hashref){
    push(@results,
      [$h->{xml_element_id}, $h->{xml_document_id}, $h->{xml_file}]);
  }
  $results->{status} = "OK";
  $results->{book_list} = \@results;
  store_fd($results, \*STDOUT);
}
