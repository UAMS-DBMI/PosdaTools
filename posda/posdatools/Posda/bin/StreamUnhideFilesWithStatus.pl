#!/usr/bin/perl -w
use strict;
use Posda::DB::PosdaFilesQueries;
my $usage = "usage: StreamUnhideFilesWithStatus.pl <user> <reason>\n" .
  "receives list of file_digests, on STDIN:\n" .
  "<file_dig>\n"; 
if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print "$usage\n";
  exit;
}
unless($#ARGV == 1) { die $usage }
my $hide = PosdaDB::Queries->GetQueryInstance('UnHideFile');
my $ins_vc = PosdaDB::Queries->GetQueryInstance('InsertVisibilityChange');
my $get_old_vis = PosdaDB::Queries->GetQueryInstance('GetFileVisibilityByDigest');
line:
while(my $line = <STDIN>){
  chomp $line;
  my $file_dig = $line;
  my $old_visibility;
  my $file_id;
  $get_old_vis->RunQuery(sub {
    my($row) = @_;
    $file_id = $row->[0];
    $old_visibility = $row->[1];
  }, sub{}, $file_dig);
  unless(defined $file_id){
    print STDERR "File with digest $file_dig not found\n";
    next line;
  }
  $hide->RunQuery(sub {}, sub {}, $file_id);
  $ins_vc->RunQuery(sub {}, sub {},
    $file_id, $ARGV[0], $old_visibility, null, $ARGV[1]);
}
print STDERR "End of process loop in StreamUnhideFilesWithStatus.pl\n";
exit;
