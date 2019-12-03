#!/usr/bin/perl -w
use strict;
use Posda::DB::PosdaFilesQueries;
my $usage = "usage: HideFilesWithStatusIrrespectiveOfCtp.pl <user> <reason>\n" .
  "receives list of file_ids, and old_visibility on STDIN:\n" .
  "<file_id>&<old_visibility>"; 
if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print "$usage\n";
  exit;
}
unless($#ARGV == 1) { die $usage }
my @FileList;
while(my $line = <STDIN>){
  chomp $line;
  my($file_id, $old_visibility) = split /&/, $line;
  push @FileList, [$file_id, $old_visibility];
}
my $get_ctp = PosdaDB::Queries->GetQueryInstance("GetCtpFileRow");
my $hide = PosdaDB::Queries->GetQueryInstance('HideFile');
my $hide_no_ctp = PosdaDB::Queries->GetQueryInstance('HideFileWithNoCtp');
my $ins_vc = PosdaDB::Queries->GetQueryInstance('InsertVisibilityChange');
for my $i (@FileList){
  my($file_id, $old_visibility) = @$i;
  if($old_visibility eq ""){ $old_visibility = undef }
  if($old_visibility eq "<undef>"){ $old_visibility = undef }
  my $has_ctp = 0;;
  $get_ctp->RunQuery(sub{
    my($row) = @_;
    $has_ctp = 1;
  }, sub {}, $file_id);
  if($has_ctp){
    $hide->RunQuery(sub {}, sub {}, $file_id);
  } else {
    $hide_no_ctp->RunQuery(sub {}, sub {}, $file_id);
  }
  $ins_vc->RunQuery(sub {}, sub {},
    $file_id, $ARGV[0], $old_visibility, 'hidden', $ARGV[1]);
  print STDERR "Hide file $file_id and recorded visibility change\n";
}
