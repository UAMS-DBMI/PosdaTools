#!/usr/bin/perl -w 
#$Source: /home/bbennett/pass/archive/Posda/bin/SeriesElements.pl,v $
#$Date: 2014/11/14 21:21:32 $
#$Revision: 1.1 $
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
use Cwd;
use Posda::Try;
use Posda::Dataset;
use Posda::ValidationRules;

my $usage = "Usage: $0 <file>\n";
unless ($#ARGV == 0) {die $usage;}

my $dir = getcwd;
my $infile = $ARGV[0];
unless($infile =~ /^\//) {
	$infile = "$dir/$infile";
}
my $try = Posda::Try->new($infile);
unless(exists $try->{dataset}) { die "$infile is not a DICOM file" }
for my $desc (@Posda::ValidationRules::consistent_series){
  my $name = $desc->{name};
  my $ele = $desc->{ele};
  my $value = $try->{dataset}->Get($ele);
  unless(defined $value) { $value = "&lt;Not present&gt;" }
  if(ref($value) eq "ARRAY") { $value = join("\\", @$value) }
  my $enc_v = $value;
  $enc_v =~ s/([\n\|])/"%" . unpack("H2", $1)/eg;
  if($enc_v eq ""){ $enc_v = "&lt;Present but null&gt;" }
  print "$name|$ele|$enc_v\n";
}
