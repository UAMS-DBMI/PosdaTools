#!/usr/bin/perl -w
use strict;
use Posda::DB::PosdaFilesQueries;
use Posda::BackgroundProcess;

my $usage = "usage: BackgroundHideFilesWithStatus.pl <?bkgrnd_id?> <notify> <reason>\n" .
  "receives list of file_ids on STDIN:\n" .
  "<file_id>"; 
if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print "$usage\n";
  exit;
}
unless($#ARGV == 2) { die $usage }
my @FileList;
my($invoc_id, $notify, $reason) = @ARGV;
while(my $line = <STDIN>){
  chomp $line;
  push @FileList, $line;
}
my $num_files = @FileList;
print "$num_files file to hide\n" .
  "notify: $notify\n";
print "going to background to hide files\n";
my $back = Posda::BackgroundProcess->new($invoc_id, $notify);
$back->Daemonize;
my $hide = PosdaDB::Queries->GetQueryInstance('HideFile');
my $ins_vc = PosdaDB::Queries->GetQueryInstance('InsertVisibilityChange');
for my $file_id (@FileList){
  $hide->RunQuery(sub {}, sub {}, $file_id);
  $ins_vc->RunQuery(sub {}, sub {},
    $file_id, $notify, '<undef>', 'hidden', $reason);
  $back->WriteToEmail( "Hid file $file_id and recorded visibility change\n");
}
$back->Finish;
