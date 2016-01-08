#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/bin/Anonymize.pl,v $
#$Date: 2009/04/16 15:31:53 $
#$Revision: 1.10 $
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#

use strict;
use Posda::Anonymizer;
use Posda::Dataset;
use Digest::MD5;
use File::Find;

my %file_digests;
my @file_list;
Posda::Dataset::InitDD();
sub MakePath{
  my($root, $path) = @_;
  my $full_path = $root;
  for my $i (@$path){
    $full_path = "$full_path/$i";
    unless(-d $full_path){
      `mkdir \"$full_path\"`;
    }
    unless(-d $full_path){
      die "unable to make path $full_path";
    }
  }
}

unless($#ARGV == 2){ die "usage: $0 <map> <input_dir> <output_dir>" }
my $anon = Posda::Anonymizer->new_from_file($ARGV[0]);
my $input_dir = $ARGV[1];
my $output_dir = $ARGV[2];
opendir DIR, $output_dir;
dir:
while(my $file = readdir(DIR)){
  if($file eq ".") { next dir }
  if($file eq "..") { next dir }
  die "$output_dir is not empty (and I'm afraid to 'rm -rf $output_dir/*'";
}
closedir DIR;


my $pass_one_wanted = sub{
  my $f_name = $File::Find::name;
  if(-d $f_name){return}
  unless(-r $f_name){return}
  open FILE, "<$f_name";
  my $ctx = Digest::MD5->new();
  $ctx->addfile(*FILE);
  my $digest = $ctx->hexdigest;
  close FILE;
  if(exists $file_digests{$digest}){ return }
  $file_digests{$digest} = $f_name;
  my($df, $ds, $size, $xfr_stx, $errors) = Posda::Dataset::Try($f_name);
  unless(defined $ds){return}
  my $SopClassUID = $ds->ExtractElementBySig("(0008,0016)");
  unless(defined $SopClassUID){return}
  push(@file_list, $f_name);
  $anon->pass_one($ds);
};
find({wanted => $pass_one_wanted, follow => 1}, $input_dir);

my $none_seq = 1;
for my $f_name (@file_list){
  my($df, $ds, $size, $xfr_stx, $errors) = Posda::Dataset::Try($f_name);
  unless(defined $ds){ die "$f_name only parsed once" }
  $anon->Deletes($ds);
  $anon->pass_two($ds);
  $anon->Overrides($ds);
  $anon->TextSubstitutions($ds);
  $ds->InsertElementBySig("(0012,0062)", "YES");
  $ds->InsertElementBySig("(0012,0063)", 
    ["Posda Anonymizer", "AnonymizeSearch.pl", "Anonymize.pl"]);
  my $sop_inst = $ds->ExtractElementBySig("(0008,0018)");
  my $modality = $ds->ExtractElementBySig("(0008,0060)");
  my $dest_file = "$output_dir/${modality}_$sop_inst.dcm";
  print "Converted:\n\t$f_name\n";
  $ds->WritePart10($dest_file, $xfr_stx, "POSDA_ANON", undef, undef);
  print "to\n\t$dest_file\n";
}
