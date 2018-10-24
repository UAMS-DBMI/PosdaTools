#!/usr/bin/perl -w
use strict;
use Storable;
my $usage = <<EOF;
usage: GetRevisionCreationInfo.pl <full_path_to_creation.pinfo>
EOF
unless($#ARGV == 0){
  die $usage;
}
unless(-f $ARGV[0]) { die $usage }
my $info = Storable::retrieve($ARGV[0]);
my $files_copied = 0;
my $files_edited = 0;
unless(exists $info->{operation}) { die "no operation in $ARGV[0]" }
my $operation = $info->{operation};
my $sub_operation;
if($operation eq "ExtractAndAnalyze"){
  for my $st (keys %{$info->{desc}->{studies}}){
    my $sth = $info->{desc}->{studies}->{$st};
    for my $se (keys %{$sth->{series}}){
      my $serh = $sth->{series}->{$se};
      for my $fi (keys %{$serh->{files}}){
        my $fih = $serh->{files}->{$fi};
        $files_copied += 1;
      }
    }
  }
}elsif($operation eq "EditAndAnalyze"){
  $files_copied = keys %{$info->{files_to_link}};
  if(exists $info->{FileEdits}){
    $sub_operation = "FileEdits";
    $files_edited = keys %{$info->{FileEdits}};
  } elsif(exists $info->{RelinkSS}){
    $sub_operation = "RelinkSS";
    $files_edited = keys %{$info->{RelinkSS}};
  }
}
print "Operation: $operation\n";
if($sub_operation){
  print "SubOperation: $sub_operation\n";
}
print "Copied: $files_copied\n";
print "Edited: $files_edited\n";
