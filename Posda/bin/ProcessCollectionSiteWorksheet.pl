#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';

my $usage = <<EOF;
ProcessCollectionSiteWorksheet.pl <invoc_id>
or
ProcessCollectionSiteWorksheet.pl.pl -h

This script, although a "background script" merely executes in the
foreground and returns its results via STDOUT

It expects lines in the following format on STDIN:
<site_code>&<collection_code>&<site_id>&<site_name>&<collection_name>

It checks that "site_id" is "\${site_code}\${collection_code}\" and
prints an error if not.

It checks site_codes and collection_codes for internal consistency,
reports errors and keeps first spec of code.

Then it checks resulting specs against database, reports errors and
ignore offending specs.

Then it insert new specs into database.

It uses the following queries:
  GetCollectionCodes
  GetSiteCodes
  InsertIntoCollectionCodes
  InsertIntoSiteCodes

EOF
$| = 1;
if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print "$usage\n";
  exit;
}

unless($#ARGV == 0){
  die "$usage\n";
}

my ($invoc_id) = @ARGV;
my %CollectionCodesInDb;
my %CollectionNamesInDb;
my %SiteCodesInDb;
my %SiteNamesInDb;
my %CollectionCodesNotInDb;
my %CollectionNamesNotInDb;
my %SiteCodesNotInDb;
my %SiteNamesNotInDb;
my $get_collections = Query("GetCollectionCodes");
my $get_sites = Query("GetSiteCodes");
$get_collections->RunQuery(sub{
  my($row) = @_;
  my($collection_name, $collection_code) = @$row;
  $CollectionCodesInDb{$collection_code} = $collection_name;
  $CollectionNamesInDb{$collection_name} = $collection_code;
}, sub {});
$get_sites->RunQuery(sub{
  my($row) = @_;
  my($site_name, $site_code) = @$row;
  $SiteCodesInDb{$site_code} = $site_name;
  $SiteNamesInDb{$site_name} = $site_code;
}, sub {});
my @errors;
my $line_no = 0;
line:
while(my $line = <STDIN>){
  $line_no += 1;
  chomp $line;
  my($site_code, $collection_code, $site_id, $site_name, $collection_name) =
    split /&/, $line;
  my $correct_site_id = "${site_code}${collection_code}";
  ## bad site code check
  unless($site_id eq $correct_site_id){
    push(@errors, "Error: site_id ($site_id) vs ($correct_site_id), line $line_no");
    next line;
  }
  ## check conflicts with db
  if(
    exists($SiteCodesInDb{$site_code}) &&
    $SiteCodesInDb{$site_code} ne $site_name
  ){
    push(@errors, "Error: site_code ($site_code) has site ($site_name) vs " .
      "db ($SiteCodesInDb{$site_code}), line $line_no");
    next line;
  }
  if(
    exists($SiteNamesInDb{$site_name}) &&
    $SiteNamesInDb{$site_name} ne $site_code
  ){
    push(@errors, "Error: site_name ($site_name) has site_code ($site_code) vs " .
      "db ($SiteNamesInDb{$site_name}), line $line_no");
    next line;
  }
  if(
    exists($CollectionCodesInDb{$collection_code}) &&
    $CollectionCodesInDb{$collection_code} ne $collection_name
  ){
    push(@errors, "Error: collection_code ($collection_code) has collection ($collection_name) vs " .
      "db ($CollectionCodesInDb{$collection_code}), line $line_no");
    next line;
  }
  if(
    exists($CollectionNamesInDb{$collection_name}) &&
    $CollectionNamesInDb{$collection_name} ne $collection_code
  ){
    push(@errors, "Error: collection_name ($collection_name) has collection_code ($collection_code) vs " .
      "db ($CollectionNamesInDb{$collection_name}), line $line_no");
    next line;
  }
  if(
    exists($CollectionCodesInDb{$collection_code}) &&
    $CollectionCodesInDb{$collection_code} ne $collection_name
  ){
    push(@errors, "Error: collection_code ($collection_code) has collection ($collection_name) vs " .
      "db ($CollectionCodesInDb{$collection_code}), line $line_no");
    next line;
  }
  if(
    exists($CollectionNamesInDb{$collection_name}) &&
    $CollectionNamesInDb{$collection_name} ne $collection_code
  ){
    push(@errors, "Error: collection_name ($collection_name) has collection_code ($collection_code) vs " .
      "db ($CollectionNamesInDb{$collection_name}), line $line_no");
    next line;
  }
  ## no conflicts with db
  unless(exists $SiteCodesInDb{$site_code}){
    if(exists $SiteCodesNotInDb{$site_code}){
      ## check conflicts with prior site_code specs
      unless($SiteCodesNotInDb{$site_code} eq $site_name){
        push @errors, "Error: site_code ($site_code) has conflicting site_name ($site_name vs " .
          "$SiteCodesNotInDb{$site_code}), line $line_no";
      }
    } else {
      $SiteCodesNotInDb{$site_code} = $site_name;
    }
  }
  unless(exists $CollectionCodesInDb{$collection_code}){
    if(exists $CollectionCodesNotInDb{$collection_code}){
      ## check conflicts with prior collection_code specs
      unless($CollectionCodesNotInDb{$collection_code} eq $collection_name){
        push @errors, "Error: collection_code ($collection_code) has conflicting collection_name ($collection_name vs " .
          "$CollectionCodesNotInDb{$collection_code}), line $line_no";
      }
    } else {
      $CollectionCodesNotInDb{$collection_code} = $collection_name;
    }
  }
}
my $num_coll_codes = keys %CollectionCodesNotInDb;
my $num_site_codes = keys %SiteCodesNotInDb;
my $num_errors = @errors;
if($num_errors > 0) {
  print "$num_errors errors found:\n";
  for my $err (@errors){
    print "$err\n";
  }
  print "\n\n";
}
print "$num_coll_codes new collection codes to insert\n";
print "$num_site_codes new site codes to insert\n";
my $ins_site_codes = Query("InsertIntoSiteCodes");
my $ins_coll_codes = Query("InsertIntoCollectionCodes");
for my $site_code (keys %SiteCodesNotInDb){
  $ins_site_codes->RunQuery(sub {}, sub {},
    $SiteCodesNotInDb{$site_code}, $site_code);
}
for my $collection_code (keys %CollectionCodesNotInDb){
  $ins_coll_codes->RunQuery(sub {}, sub {},
    $CollectionCodesNotInDb{$collection_code}, $collection_code);
}
print "Insertions done\n";
