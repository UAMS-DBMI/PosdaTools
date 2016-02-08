#!/usr/bin/perl -w
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
use Time::HiRes qw( gettimeofday tv_interval );
my $t0 = [gettimeofday];
my $elapsed;
my $dbg = sub { print STDERR @_ };
use Storable qw( store_fd fd_retrieve );
my $help = <<EOF;
Select Document List meant to run as sub-process
Receives parameters vi fd_retrieve from STDIN.
Writes results to STDOUT via store_fd.
Incoming datastucture:
\$in = {
  database_name => <name>,
  element_id => <element_id>,
};
Outgoing datastructure => {
  status => OK | ERROR,
  [error => "Error message",]
  element => {
    type => "element",
    name => <ele_name>,
    id => <ele_id>,
    attributes => {
      <key> => <value>,
      ...
    },
    content => [
      {
        type => "element" | "text",
        # if text 
        text => <text>,
        # else
        name => <ele_name>,
        id => <ele_id>,
        attributes => {
          <key> => <value>,
          ...
        },
        content => [
          ...
        ],
      },
      ...
  },
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
my $element = $params->{element_id};
my $el_q = $db->prepare(
  "select * from xml_element natural join xml_element_content " .
  "where xml_document_id = ?"
);
my $txt_q = $db->prepare(
  "select * from xml_text_field natural join xml_element_content " .
  "where xml_document_id = ?"
);
