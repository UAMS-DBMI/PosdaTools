#!/usr/bin/perl -w
use strict;
use Posda::DB::PosdaFilesQueries;
use Posda::BackgroundProcess;

my $usage = "usage: BackgroundUnhideFilesWithStatus.pl <?bkgrnd_id?> <notify> <reason>\n" .
  "receives list of file_ids, and old_visibility on STDIN:\n" .
  "<file_id>&<old_visibility>"; 
if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print "$usage\n";
  exit;
}
unless($#ARGV == 2) { die $usage }
my @FileList;
my($invoc_id, $notify, $reason) = @ARGV;
while(my $line = <STDIN>){
  chomp $line;
  my($file_id, $old_visibility) = split /&/, $line;
  push @FileList, [$file_id, $old_visibility];
}
my $num_files = @FileList;
print "$num_files file to unhide\n" .
  "notify: $notify\n" .
  "reason: $reason\n";;
print "going to background to unhide files\n";
my $back = Posda::BackgroundProcess->new($invoc_id, $notify);
$back->Daemonize;
my $unhide = PosdaDB::Queries->GetQueryInstance('UnHideFile');
my $ins_vc = PosdaDB::Queries->GetQueryInstance('InsertVisibilityChange');
for my $i (@FileList){
  my($file_id, $old_visibility) = @$i;
  if($old_visibility eq ""){ $old_visibility = undef }
  if($old_visibility eq "<undef>"){ $old_visibility = undef }
  $unhide->RunQuery(sub {}, sub {}, $file_id);
  $ins_vc->RunQuery(sub {}, sub {},
    $file_id, $notify, $old_visibility, '<undef>', $reason);
  $back->WriteToEmail( "Unhid file $file_id and recorded visibility change\n");
}
$back->Finish;
