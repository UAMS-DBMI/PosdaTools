#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Posda::BackgroundProcess;
use Debug;
my $dbg = sub { print @_ };

my $usage = <<EOF;
Usage:
LinkPublicCollection.pl <?bkgrnd_id?> <directory> <notify>
  or
LinkPublicCollection.pl -h

Expects lines on STDIN:
<collection>&<patient_id>&<series_instance_uid>&<dicom_file_uri>

EOF

if($#ARGV == 0 && $ARGV[0] eq "-h"){ print $usage; exit }

unless($#ARGV == 2) { print $usage; exit }

my($invoc_id, $dir, $notify) = @ARGV;
my $start = time;

my %Hierarchy;
my %Patients;
my %Series;
my %Files;
while(my $line = <STDIN>){
  chomp $line;
  my($coll, $pat, $series, $file) = split(/&/, $line);
  unless($file =~ /(storage.*)$/){
    print "Rejecting file: $file\n";
    next;
  }
  my $xlated = "/nas/public/$1";
  $Patients{$pat} = 1;
  $Series{$series} = 1;
  $Files{$file} = 1;
  $Hierarchy{$coll}->{$pat}->{$series}->{$xlated} = 1;
}
my $num_patients = keys %Patients;
my $num_series = keys %Series;
my $num_files = keys %Files;
print "Patients: $num_patients\n";
print "Series: $num_series\n";
print "Files: $num_files\n";
unless(-d $dir) {
  print "Error: $dir is not a directory\n";
  exit;
}
my $errors = 0;
for my $coll (keys %Hierarchy){
  unless(-d "$dir/$coll"){
    if(mkdir("$dir/$coll") == 1){
      print "Created dir: $dir/$coll\n";
    } else {
      print "Error ($!) : Couldn't create directory: $dir/$coll\n";
      $errors += 1;
    }
  }
  for my $pat(keys %{$Hierarchy{$coll}}){
    unless(-d "$dir/$coll/$pat"){
      if(mkdir("$dir/$coll/$pat") == 1){
        print "Created dir: $dir/$coll/$pat\n";
      } else {
        print "Error ($!) : Couldn't create directory: $dir/$coll/$pat\n";
        $errors += 1;
      }
    }
    for my $series(keys %{$Hierarchy{$coll}->{$pat}}){
      unless(-d "$dir/$coll/$pat/$series"){
        if(mkdir("$dir/$coll/$pat/$series") == 1){
          print "Created dir: $dir/$coll/$pat/$series\n";
        } else {
          print "Error ($!) : Couldn't create directory: $dir/$coll/$pat/$series\n";
          $errors += 1;
        }
      }
      for my $file (keys %{$Hierarchy{$coll}->{$pat}->{$series}}){
        unless(-f $file){
          print "Error: $file doesn't exist\n";
        }
      }
    }
  }
}
if($errors > 0){
  print "Not linking file due to error\n";
  exit;
}
#############################
# This is code which sets up the Background Process and Starts it
my $forground_time = time - $start;
print "Going to background to create timepoint  after $forground_time seconds\n";
my $background = Posda::BackgroundProcess->new($invoc_id, $notify);
$background->Daemonize;
my $start_creation = time;
### Linking Directories Here
my $file_seq = 0;
for my $coll (keys %Hierarchy){
  for my $pat (keys %{$Hierarchy{$coll}}){
    for my $series (keys %{$Hierarchy{$coll}->{$pat}}){
      for my $file (keys %{$Hierarchy{$coll}->{$pat}->{$series}}){
        my $new_file = "$dir/$coll/$pat/$series/$file_seq";
        $file_seq += 1;
        symlink $file, $new_file;
      }
    }
  }  
}
###
my $link_time = time - $start_creation;
$background->WriteToEmail("Linked $num_files files in $link_time seconds.\n");
$background->Finish;
