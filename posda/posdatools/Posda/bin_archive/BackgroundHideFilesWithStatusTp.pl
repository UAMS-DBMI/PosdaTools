#!/usr/bin/perl -w
use strict;
use Posda::DB::PosdaFilesQueries;
use Posda::BackgroundProcess;

my $usage = "usage: BackgroundHideFilesWithStatusTp.pl <?bkgrnd_id?> <activity_id> <comment> <notify>\n" .
  "receives list of file_ids on STDIN:\n" .
  "<file_id>&<visiblity>"; 
if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print "$usage\n";
  exit;
}
unless($#ARGV == 3) { die $usage }
my($invoc_id, $act_id, $comment, $notify) = @_;
my @FileList;
while(my $line = <STDIN>){
  chomp $line;
  my($file_id, $old_visibility) = split /&/, $line;
  push @FileList, [$file_id, $old_visibility];
}
my $num_files = @FileList;
print "$num_files file to hide\n" .
  "notify: $notify\n";
print "going to background to hide files\n";
my $back = Posda::BackgroundProcess->new($invoc_id, $notify, $act_id);
$back->Daemonize;
my $get_ctp = PosdaDB::Queries->GetQueryInstance("GetCtpFileRow");
my $hide = PosdaDB::Queries->GetQueryInstance('HideFile');
my $hide_no_ctp = PosdaDB::Queries->GetQueryInstance('HideFileWithNoCtp');
my $ins_vc = PosdaDB::Queries->GetQueryInstance('InsertVisibilityChange');
my $files_processed = 0;
for my $i (@FileList){
  $files_processed += 1;
  $back->SetActivityStatus("Hiding $files_processed of $num_files");
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
  $back->WriteToEmail("Hid file $file_id and recorded visibility change\n");
}



$back->Finish("Done - hid $num_files files");
