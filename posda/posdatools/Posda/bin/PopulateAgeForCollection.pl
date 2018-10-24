#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Posda::Try;
use Posda::DB::NewModules;

my $usage = <<EOF;

PopulateAgeForCollection.pl <collection>
or
PopulateAgeForCollection.pl -h

Get a list of files with null patient_age for
a collection, and then read each file, update
patient_age in patient table.  If the file
does not contain patient_age, set patient_age
to a blank string (not null).

EOF
unless($#ARGV == 0) { die $usage };
if($ARGV[0] eq "-h"){ print $usage; exit }
my $collection = $ARGV[0];
my $get_file_list = Query("NullPatientAgeByCollection");
my $add_age = Query("AddPatientAge");
my $start = time;
my $counter = 1000;
my $num_files;
$get_file_list->RunQuery(sub {
  my($row) = @_;
  my $file_id = $row->[0];
  my $file = $row->[1];
  my $try = Posda::Try->new($file);
  unless(defined $try->{dataset}){ die "$file didn't parse as DICOM" }
  my $ds = $try->{dataset};
  my $age = $ds->Get("(0010,1010)");
  unless(defined $age) { $age = "" };
  $add_age->RunQuery(sub {}, sub {}, $age, $file_id);
#print "Id: $file_id, age: $age, file: $file\n";
  $num_files += 1;
  $counter -= 1;
  if($counter < 0){
    my $now = time;
    my $elapsed = $now - $start;
    print "$num_files files after $elapsed seconds\n";
    $counter = 1000;
  }
}, sub {}, $collection);
my $total_elapsed = time - $start;
print "total of $num_files in $total_elapsed seconds\n";
