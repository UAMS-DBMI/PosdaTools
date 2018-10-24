#!/usr/bin/perl -w
#
use strict;
use Posda::Find;
use Posda::SimplerDicomAnalysis;
use Posda::Try;
use Storable;
die "This uses obsolete cache logic -- don't use until updated!!!!";
my $source_dir = $ARGV[0];
my $dest_dir = $ARGV[1];
my $cache_dir = $ARGV[2];
unless(-d $source_dir) { die "No source dir: $source_dir" }
unless(-d $dest_dir) { die "No dest dir: $dest_dir" }
unless(-d $cache_dir) { die "No cache dir: $cache_dir" }
my %Bom;
my $file_handler = sub {
  my($try) = @_;
  unless(exists $try->{dataset}) {return}
  unless($try->{dataset}->Get('(0008,0016)')) {return}
  my $file = $try->{filename};
  my $digest = $try->{digest};
  my $collection = $try->{dataset}->Get('(0013,"CTP",11)');
  my $site = $try->{dataset}->Get('(0013,"CTP",12)');
  my $subj = $try->{dataset}->Get('(0010,0020)');
  print "###############\n";
  print "File: $file\n";
  print "Collection: $collection, Site: $site Subj: $subj\n";
  unless($file =~ /\/([^\/]+)$/) {
    print STDERR "can't extract file name from $file\n";
    return;
  }
  my $fn = $1;
  unless(-d "$dest_dir/$collection"){
    unless(mkdir "$dest_dir/$collection"){
      print STDERR "Can't mkdir $dest_dir/$collection\n";
      return;
    }
  }
  unless(-d "$dest_dir/$collection/$site"){
    unless(mkdir "$dest_dir/$collection/$site"){
      print STDERR "Can't mkdir $dest_dir/$collection/$site\n";
      return;
    }
  }
  unless(-d "$dest_dir/$collection/$site/$subj"){
    unless(mkdir "$dest_dir/$collection/$site/$subj"){
      print STDERR "Can't mkdir $dest_dir/$collection/$site/$subj\n";
      return;
    }
  }
  unless(-d "$dest_dir/$collection/$site/$subj/files"){
    unless(mkdir "$dest_dir/$collection/$site/$subj/files"){
      print STDERR "Can't mkdir $dest_dir/$collection/$site/$subj/files\n";
      return;
    }
  }
  if(-f "$dest_dir/$collection/$site/$subj/bom.pinfo"){
    unless(exists $Bom{$collection}->{$site}->{$subj}){
      $Bom{$collection}->{$site}->{$subj} = 
        Storable::retrieve "$dest_dir/$collection/$site/$subj/bom.pinfo";
    }
  }
  unless(exists $Bom{$collection}->{$site}->{$subj}){
    $Bom{$collection}->{$site}->{$subj} = {};
  }
  my $Index = $Bom{$collection}->{$site}->{$subj};
  my $analysis = Posda::SimplerDicomAnalysis::Analyze($try, $file);
  $analysis->{file} = $file;
  $analysis->{parse_errors} = $try->{parser_warnings},
  $analysis->{xfr_stx} = $try->{xfr_stx};
  $analysis->{digest} = $try->{digest};
  $analysis->{dataset_digest} = $try->{dataset_digest};
  $analysis->{TypeOfResult} = "DicomAnalysis";
  $analysis->{dataset_start_offset} = $try->{dataset_start_offset};
  if($try->{has_meta_header}){
    $analysis->{has_meta_header} = 1;
    $analysis->{meta_header} = $try->{meta_header};
  }
  unless($try->{digest} =~ /^(.)(.).*/){
    die "Bad Digest";
  }
  my $first_dir = "$cache_dir/$1";
  my $second_dir = "$cache_dir/$1/$2";
  unless(-d $first_dir) {
    unless(mkdir $first_dir) { die "Can't mkdir $first_dir ($!)" }
  }
  unless(-d $second_dir) {
    unless(mkdir $second_dir) { die "Can't mkdir $second_dir ($!)" }
  }
  my $cache_file = "$second_dir/$try->{digest}.dcminfo";
  unless(-f $cache_file) {
    Storable::store($analysis, $cache_file);
  }
  $Index->{FilesByDigest}->{$try->{digest}} = $analysis;
  $Index->{FilesToDigest}->{$file} = $digest;
  my $dest_file = "$dest_dir/$collection/$site/$subj/files/$fn";
  if(-f $dest_file) {
    print STDERR "dest file already exists:\n\t$dest_file\n";
  } else {
    unless(link $file, $dest_file){
      print STDERR "Couldn't link\n\t$dest_file\nto\n\t$file\n";
      return;
    }
  }
};
print STDERR "Finding\n";
Posda::Find::DicomOnly($source_dir, $file_handler);
print STDERR "Find Complete\n";
for my $collection (keys %Bom){
  for my $site (keys %{$Bom{$collection}}){
    for my $subj (keys %{$Bom{$collection}->{$site}}){
      my $index_file = "$dest_dir/$collection/$site/$subj/bom.pinfo";
print STDERR "Storing index: $index_file\n";
      Storable::store($Bom{$collection}->{$site}->{$subj}, $index_file);
    }
  }
}
