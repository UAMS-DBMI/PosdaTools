#!/usr/bin/perl -w
use strict;
use File::Temp qw/ tempfile /;
use Posda::DB::PosdaFilesQueries;
use Debug;
my $dbg = sub{print STDERR @_};
my $usage = <<EOF;
HideEarlySopDupsInSeries.pl <series_instance_uid> <user> <reason>
EOF
unless($#ARGV == 2 ){ die $usage }
my $query = PosdaDB::Queries->GetQueryInstance("DuplicateSopsInSeries");
my $get_file = PosdaDB::Queries->GetQueryInstance("FilePathByFileId");
my $series_inst = $ARGV[0];
my $user = $ARGV[1];
my $reason = $ARGV[2];
my %data;
$query->RunQuery(
  sub{
    my($row) = @_;
    my($sop_inst, $import_time, $file_id) = @$row;
    if(
      exists($data{$sop_inst}->{$file_id}) &&
      $data{$sop_inst}->{$file_id} le $import_time
    ){
      return;
    } else {
      $data{$sop_inst}->{$file_id} = $import_time;
    }
  },
  sub {
  },
  $series_inst
);
open CHILD, "|HideFilesWithStatus.pl $user \"$reason\"" or
  die "can't open sub_process";
for my $sop_inst(keys %data){
  print "For $sop_inst:\n";
  my @file_id_list = sort 
    { $data{$sop_inst}->{$a} cmp $data{$sop_inst}->{$b} } 
    keys %{$data{$sop_inst}};
  for my $f (0 .. $#file_id_list-1){
    print STDERR "Hide file_id: $file_id_list[$f]\n";
    print CHILD "$file_id_list[$f]&<undef>\n";
  }
  print STDERR "Leave file_id: $file_id_list[$#file_id_list]\n";
}
