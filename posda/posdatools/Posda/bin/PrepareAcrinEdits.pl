#!/usr/bin/perl -w
use strict;
use Posda::BackgroundProcess;
use Posda::DB 'Query';

my $usage = <<EOF;
Usage:
PrepareAcrinEdits.pl <bkgrnd_id> <notify>
or
PrepareAcrinEdits.pl -h

Expects lines of the form:
<ele_pattern>&<value>&<series_instance_uid>

Produces a new spreadsheet to edit the changes into the files.
Format:
<pat>|<study_uid>|<series_uid>|<sop_uid>|<file_id>|<element>|<value>|<op>|<arg1>|<arg2>
EOF
if($#ARGV == 0 && $ARGV[0] eq "-h") { print "$usage\n\n"; exit }
if($#ARGV != 1){
  my $num_args = $#ARGV;
  print "Wrong args: ($num_args vs 1)\n$usage\n";
  exit;
}
my($invoc_id, $notify) = @ARGV;


my @LinesToProcess;
while(my $line = <STDIN>){
  chomp $line;
  my($ele_pat, $value, $series_instance_uid) =
    split /&/, $line;
  if($ele_pat =~ /^-(.*)-$/){$ele_pat = $1}
  if($ele_pat =~ /^<(.*)>$/){$ele_pat = $1}
  push(@LinesToProcess, [$ele_pat, $value, $series_instance_uid]);
}
my $get_files = Query("DistinctVisibleSopsAndFilesInSeriesWithPatAndStudy");
my @FilesToProcess;
for my $line (@LinesToProcess){
  my($ele_pat, $value, $series_instance_uid) = @$line;
  my %sops;
  $get_files->RunQuery(sub {
    my($row) = @_;
    my($pat_id, $study_uid, $series_uid, $sop_instance_uid, $file_id) =
      @$row;
    push @FilesToProcess, [
      $pat_id, $study_uid, $series_uid, $sop_instance_uid, $file_id, 
      $ele_pat
    ];
  }, sub {}, $series_instance_uid);
}

my $num_files = @FilesToProcess;
print "Found list of $num_files files to prepare edits for\n" .
  "Forking background process\n";
my $background = Posda::BackgroundProcess->new($invoc_id, $notify);

$background->Daemonize;

my $tt = `date`;
chomp $tt;
print STDERR "Starting File Analysis at $tt\n";
$background->WriteToEmail("$tt: Starting processing on $num_files files\n" .
  "Description: Generating edits for ACRIN-FLT-Breast\n");
my $get_path = Query("GetFilePath");
my %PatientsToEdit;
my $current_pat = "none";
my $num_pats = 0;
my $num_files_p = 0;
my $start_analysis_time = time;
my $start_pat_time = $start_analysis_time;
file:
for my $file (@FilesToProcess){
  my($pat_id, $study_uid, $series_uid, $sop_instance_uid, $file_id,
    $ele_pat) = @$file;
  if($current_pat ne $pat_id){
    if($num_pats > 0){
      my $elapsed = time - $start_analysis_time;
      my $pat_elapsed = time - $start_pat_time;
      print STDERR "processed $num_files_p for pat $current_pat" .
        " in $pat_elapsed seconds\n";
      $num_files_p = 0;
      print STDERR "$num_pats patient changes " .
        "processed after $elapsed seconds\n"
    }
    $num_pats += 1;
    $current_pat = $pat_id;
    $start_pat_time = time;
  }
  $num_files_p += 1;
  my $path;
  $get_path->RunQuery(sub {
    my($row) = @_;
    $path = $row->[0];
  }, sub {}, $file_id);
  unless(defined($path) && -f $path){
    $background->WriteToEmail("Couldn't find path to file: $file_id\n");
    next file;
  }
  my $actual_value;
  if($ele_pat =~ /\[/){  #  pattern to match
    my %tag_values;
    my $cmd = "GetElementValuesByPat.pl \"$path\" \"$ele_pat\" 2>/dev/null";
    open CMD, "$cmd|";
    my $state = "search";
    my $tag;
    my $value;
    while(my $line = <CMD>){
      if($state eq "search"){
        if($line =~ /^###>tag: (.*)$/){
          $tag = $1;
          $value = "";
          $state = "lines";
        }
      } elsif($state eq "lines"){
        if($line =~ /^<###$/){
          chop $value;
          $tag_values{$tag} = $value;
          $state = "search";
          $tag = undef;
          $value = undef;
        } else {
          $value .= $line;
        }
      } else {
        $background->WriteToEmail("Invalid state ($state) for file: $file_id");
        next file;
      }
    }
    for my $tag (keys %tag_values){
      my $value = $tag_values{$tag};
      $PatientsToEdit{$pat_id}->{$study_uid}->{$series_uid}->{$sop_instance_uid}
        ->{$file_id}->{$tag} = $value;
    }
  } else {               #  just an element
    my $cmd = "GetElementValue.pl \"$path\" \"$ele_pat\" 2>/dev/null";
    my $value = `$cmd`;
    $PatientsToEdit{$pat_id}->{$study_uid}->{$series_uid}->{$sop_instance_uid}
      ->{$file_id}->{$ele_pat} = $value;
  }
}
$tt = `date`;
chomp $tt;
print STDERR "Finished File Analysis at $tt\n";
$background->WriteToEmail("Finished File Analysis at: $tt\n");
$background->WriteToEmail("Starting Report Rendering\n");
my $start_report_time = time;
my $num_patients = keys %PatientsToEdit;
my $num_patients_done = 0;
for my $patient (keys %PatientsToEdit){
  print STDERR "Starting patient $patient\n";
  my $start_patient_time = time;
  my $rpt_hand = $background->CreateReport("EditsForPatient_$patient");
  $rpt_hand->print("\"pat\",\"study_uid\",\"series_uid\",\"sop_uid\"" .
    ",\"file_id\",\"element\",\"value\",\"op\",\"arg1\",\"arg2\"\r\n");
  for my $study(keys %{$PatientsToEdit{$patient}}){
    my $pat_hash = $PatientsToEdit{$patient};
    for my $study(keys %$pat_hash){
      my $study_hash = $pat_hash->{$study};
      for my $series(keys %$study_hash){
        my $series_hash = $study_hash->{$series};
        for my $sop(keys %$series_hash){
          my $sop_hash = $series_hash->{$sop};
          for my $file(keys %$sop_hash){
            my $file_hash = $sop_hash->{$file};
            for my $ele(keys %$file_hash){
              my $value = $file_hash->{$ele};
                $ele =~ s/\"/\"\"/g;
                $value =~ s/\"/\"\"/g;
                $rpt_hand->print("\"$patient\",\"$study\"," .
                  "\"$series\",\"$sop\"" .
                  ",\"$file\",\"$ele\",\"$value\",,,\r\n");
            }
          }
        }
      }
    }
  }
  my $elapsed = time - $start_patient_time;
  print STDERR "did report for $patient in $elapsed seconds\n";
  close $rpt_hand;
  $num_patients_done += 1;
  my $total_elapsed = time - $start_report_time;
  print STDERR "Done $num_patients_done patients of $num_patients " .
    "after $total_elapsed\n";
}
$tt = `date`;
chomp $tt;
$background->WriteToEmail("Ending at: $tt\n");
$background->Finish;
