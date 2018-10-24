#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Posda::BackgroundProcess;
use Debug;
my $dbg = sub { print @_ };


my $usage = <<EOF;
Usage:
MakeDownloadableDirectory.pl <?bkgrnd_id?> <sub_dir> <notify>
  or
MakeDownloadableDirectory.pl -h

Expects lines on STDIN:
<collection>&<patient_id>&<study_instance_uid>&<series_instance_uid>

EOF

if($#ARGV == 0 && $ARGV[0] eq "-h"){ print $usage; exit }

unless($#ARGV == 2) { print $usage; exit }

my($invoc_id, $sub_dir, $notify) = @ARGV;
my $start = time;

my %Hierarchy;
my %Patients;
my %Studies;
my %Series;
my %Files;
my $get_files = Query('FilesInSeries');
while(my $line = <STDIN>){
  chomp $line;
  my($coll, $pat, $study, $series) = split(/&/, $line);
  $Patients{$pat} = 1;
  $Series{$series} = 1;
  $Studies{$study} = 1;
  $get_files->RunQuery(sub {
    my($row) = @_;
    my $path = $row->[0];
    $Hierarchy{$coll}->{$pat}->{$study}->{$series}->{$path} = 1;
    $Files{$path} = 1;
  }, sub {}, $series);
}
my $num_patients = keys %Patients;
my $num_studies = keys %Studies;
my $num_series = keys %Series;
my $num_files = keys %Files;
print "Patients: $num_patients\n";
print "Series: $num_series\n";
print "Files: $num_files\n";
my $dir = "/nas/public/posda/cache/linked_for_download/$sub_dir";
if(-d $dir) {
  print "Error: $dir already exists\n";
  exit;
}
unless(mkdir($dir) == 1) {
  print "Error ($!): couldn't mkdir $dir\n";
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
    for my $study(keys %{$Hierarchy{$coll}->{$pat}}){
      unless(-d "$dir/$coll/$pat/$study"){
        if(mkdir("$dir/$coll/$pat/$study") == 1){
          print "Created dir: $dir/$coll/$pat/$study\n";
        } else {
          print "Error ($!) : Couldn't create directory: $dir/$coll/$pat/$study\n";
          $errors += 1;
        }
      }
      for my $series(keys %{$Hierarchy{$coll}->{$pat}->{$study}}){
        unless(-d "$dir/$coll/$pat/$study/$series"){
          if(mkdir("$dir/$coll/$pat/$study/$series") == 1){
            print "Created dir: $dir/$coll/$pat/$study/$series\n";
          } else {
            print "Error ($!) : Couldn't create directory: $dir/$coll/$pat/$study/$series\n";
            $errors += 1;
          }
        }
        for my $file (keys %{$Hierarchy{$coll}->{$pat}->{$study}->{$series}}){
          unless(-f $file){
            print "Error: $file doesn't exist\n";
            $errors += 1;
          }
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
print "Going to background to link files  after $forground_time seconds\n";
my $background = Posda::BackgroundProcess->new($invoc_id, $notify);
$background->Daemonize;
my $start_creation = time;
### Linking Directories Here
my $file_seq = 0;
for my $coll (keys %Hierarchy){
  for my $pat (keys %{$Hierarchy{$coll}}){
    for my $study (keys %{$Hierarchy{$coll}->{$pat}}){
      for my $series (keys %{$Hierarchy{$coll}->{$pat}->{$study}}){
        for my $file (keys %{$Hierarchy{$coll}->{$pat}->{$study}->{$series}}){
          my $new_file = "$dir/$coll/$pat/$study/$series/$file_seq.dcm";
          $file_seq += 1;
          #$background->WriteToEmail("symlink $file, $new_file\n");
          symlink $file, $new_file;
        }
      }
    }
  }
}
###
my $link_time = time - $start_creation;
$background->WriteToEmail("Linked $num_files files in $link_time seconds.\n");
$background->Finish;
