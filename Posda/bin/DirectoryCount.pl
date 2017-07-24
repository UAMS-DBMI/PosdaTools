#!/usr/bin/perl -w
use strict;
my $usage = <<EOF;
DirectoryCount.pl <dir>
EOF
unless ($#ARGV == 0) { die $usage }
if ($#ARGV == 0 && $ARGV[0] eq "-h") { die $usage }
my $dir = $ARGV[0];
my %Patients;
unless(-d $dir) { die "$dir is not a directory" }
opendir PATIENTDIR, $dir or die "Can't opendir $dir";
pat:
while(my $pat = readdir PATIENTDIR){
  if($pat =~ /^\./) { next pat }
  unless(-d "$dir/$pat"){
    print STDERR "$dir/$pat is not a directory\n";
    next pat;
  }
  opendir STUDYDIR, "$dir/$pat" or die "Can't opendir $dir/$pat";
  study_l:
  while(my $study = readdir STUDYDIR){
    if($study =~ /^\./) { next study_l }
    unless(-d "$dir/$pat/$study"){
      print STDERR "$dir/$pat/$study is not a directory\n";
      next study;
    }
    opendir SERIESDIR, "$dir/$pat/$study" or
      die "Can't opendir $dir/$pat/$study";
    series:
    while(my $series = readdir SERIESDIR){
      if($series =~ /^\./) { next series }
      unless(-d "$dir/$pat/$study/$series"){
        print STDERR "$dir/$pat/$study/$series is not a directory\n";
        next series;
      }
      opendir DICOMFILES, "$dir/$pat/$study/$series" or
        die "Can't open $dir/$pat/$study/$series";
      my $files = 0;
      file:
      while(my $file = readdir DICOMFILES){
        if($file =~ /^\./) { next file }
        unless(-f "$dir/$pat/$study/$series/$file"){
          print STDERR "$dir/$pat/$study/$series/$file is not a file\n";
          next file;
        }
        unless($file =~ /\.dcm$/){
          print STDERR "$file doesn't end in '.dcm'\n";
          next file;
        }
        $files += 1;
      }
      closedir DICOMFILES;
      $Patients{$pat}->{$study}->{$series} = $files;
    }
    closedir SERIESDIR;
  }
  closedir STUDYDIR;
}
closedir PATIENTDIR;
print "Patient,Study,Series,NumFiles\n";
for my $pat (sort keys %Patients){
  for my $study (sort keys %{$Patients{$pat}}){
    for my $series (sort keys %{$Patients{$pat}->{$study}}){
      print "$pat,$study,$series,$Patients{$pat}->{$study}->{$series}\n";
    }
  }
}
