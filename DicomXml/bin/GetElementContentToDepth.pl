#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/DicomXml/bin/GetElementContentToDepth.pl,v $
#$Date: 2014/05/08 19:26:52 $
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
  depth => <element_id>,
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
my $depth = $params->{depth};
$results->{element} = GetElementContent($element, $depth);
$results->{status} = "OK";
$elapsed = tv_interval($t0, [gettimeofday]);
print STDERR "$elapsed: Done fetching element content tree\n";
store_fd($results, \*STDOUT);
exit;
sub GetElementContent{
  my($element, $depth) = @_;
  my $q1 = $db->prepare(
    "select * from xml_text_field where xml_text_field_id = ?"
  );
$elapsed = tv_interval($t0, [gettimeofday]);
print STDERR "$elapsed: GetElementContent($element, $depth)\n";
  my $hash;
  my $result;
  my $q = $db->prepare(
    "select * from xml_element where xml_element_id = ?"
  );
  $q->execute($element);
  my $r = $q->fetchrow_hashref;
  $q->finish;
  $result->{type} = "element";
  $result->{name} = $r->{xml_element_name};
  $result->{id} = $r->{xml_element_id};
  $q = $db->prepare(
    "select * from xml_element_attribute where xml_element_id = ?"
  );
  $q->execute($element);
  while($r = $q->fetchrow_hashref){
    $result->{attributes}->{$r->{xml_attribute_key}} = 
      $r->{xml_attribute_value};
  }
$elapsed = tv_interval($t0, [gettimeofday]);
print STDERR "$elapsed: fetched attrs\n";
  if($depth <= 0){
    $result->{content} = "...";
    return $result;
  }
  my @content;
  $q = $db->prepare(
    "select * from xml_element_content where xml_containing_element_id = ?"
  );
  $q->execute($element);
  while(my $h = $q->fetchrow_hashref){
$elapsed = tv_interval($t0, [gettimeofday]);
print STDERR "$elapsed: row\n";
    if($h->{xml_element_content_is_element}){
      push(@content, GetElementContent($h->{xml_element_id}, $depth - 1));
    } else {
      print STDERR "text field id: $h->{xml_text_field_id}\n";
      $q1->execute($h->{xml_text_field_id});
      my $t = $q1->fetchrow_hashref;
      push(@content, {
        type => "text",
        text => $t->{xml_text_field_text},
        id => $t->{xml_text_field_id}
      });
$elapsed = tv_interval($t0, [gettimeofday]);
print STDERR "$elapsed: text\n";
      $q1->finish;
    }
  }
  $result->{content} = \@content;
  return $result;
}
