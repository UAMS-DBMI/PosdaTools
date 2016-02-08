#!/usr/bin/perl -w
#
use strict;
use Storable qw( store_fd );
use Digest::MD5;
my $usage = <<EOF;
ConsolidatePhiScans.pl <bom> <results>
  <bom>     is full path to file where bill of materials stored
  <results> is full path to file where results of consolidated
            phi report is stored
reads a line at a time from STDIN where each line is the full path
to a phi_file to be consolidated.

Writes "OK" to STDOUT when done.
EOF
unless($#ARGV == 1){ die $usage }
my $bom = $ARGV[0];
my $report = $ARGV[1];
my %phi_files;
subject:
while(my $line = <STDIN>){
  chomp $line;
  unless(-f $line){
    print STDERR "file $line not found\n";
    next;
  }
  my $ctx = Digest::MD5->new;
  open DIG, "<$line";
  $ctx->addfile(*DIG);
  my $dig = $ctx->hexdigest;
  close DIG;
  $phi_files{$line} = $dig;
}
open BOM, ">$bom";
my %ConsolidatedReport;
for my $f (keys %phi_files){
  my $digest = $phi_files{$f};
  print BOM "$digest|$f\n";
  my $rpt = Storable::retrieve($f);
  for my $vr (keys %{$rpt->{results}}){
    for my $value (keys %{$rpt->{results}->{$vr}}){
      for my $tag (keys %{$rpt->{results}->{$vr}->{$value}}){
        for my $file (keys %{$rpt->{results}->{$vr}->{$value}->{$tag}}){
          $ConsolidatedReport{$value}->{$tag}->{vr} = $vr;
          $ConsolidatedReport{$value}->{$tag}->{files}->{$file} = 1;
        }
      }
    }
  }
}
close BOM;
Storable::store \%ConsolidatedReport, $report;
