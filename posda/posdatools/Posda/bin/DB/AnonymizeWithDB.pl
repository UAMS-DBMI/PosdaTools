#!/usr/bin/perl -w
#
#Copyright 2010, Bill Bennett
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
use DBI;

my %file_digests;
my @file_list;
Posda::Dataset::InitDD();

unless($#ARGV == 3){ die "usage: $0 <db> <map> <input_dir> <output_dir>" }
my $db = DBI->connect("dbi:Pg:dbname=$ARGV[0]", "", "");
my $anon = Posda::Anonymizer->new_from_file($ARGV[1]);
my $input_dir = $ARGV[2];
my $output_dir = $ARGV[3];
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
  $anon->db_pass_one($db, $ds);
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
    ["Posda Anonymizer", "AnonymizeSearch.pl", "AnonymizeWithDB.pl"]);
  my $sop_inst = $ds->ExtractElementBySig("(0008,0018)");
  my $modality = $ds->ExtractElementBySig("(0008,0060)");
  my $dest_file = "$output_dir/${modality}_$sop_inst.dcm";
  print "Converted:\n\t$f_name\n";
  $ds->WritePart10($dest_file, $xfr_stx, "POSDA_ANON", undef, undef);
  print "to\n\t$dest_file\n";
}
