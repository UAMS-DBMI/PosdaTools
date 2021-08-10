#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Posda::BackgroundProcess;
my $usage = <<EOF;
CopySeriesFromPublic.pl <?bkgrnd_id?> <activity_id> <notify>
  <activity_id> - activity
  <notify> - user to notify

Expects the following list on <STDIN>
  <series_instance_uid>

Uses named query "PublicFilesInSeries"
EOF
if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print $usage;
  exit;
}
unless($#ARGV == 2){
  my $n_args = @ARGV;
  my $mess = "Wrong number of args ($n_args vs 4). Usage:\n$usage\n";
  print $mess;
}
my($invoc_id, $activity_id, $notify) = @ARGV;
my @Series;
while(my $line = <STDIN>){
  chomp $line;
  push @Series, $line;
}
my $num_series = @Series;
print "Going to background to process $num_series series\n";

my $back = Posda::BackgroundProcess->new($invoc_id, $notify, $activity_id);
$back->Daemonize;
my $q = Query("PublicFilesInSeries");
my $start = time;
my $i = 0;
my $import_comment = "\"Copy from public $invoc_id\"";
open IMPORT, "|ImportMultiplePermanentFilesIntoPosda.pl $import_comment"
 or die "Can't open subprocess ($!)";
$back->WriteToEmail("Import Comment: $import_comment\n");
for my $series (@Series){
  $i += 1;
  my $msg1 = "$i of $num_series series";
  my $j = 0;
  $q->RunQuery(sub{
    my($row) = @_;
    my $path = $row->[0];
    if($path =~ /^\/usr\/local\/apps\/ncia\/CTP-server\/CTP(.*)$/){
      $path = "/nas/public$1";
    }
    $j += 1;
    print IMPORT "$path\n";
    $back->SetActivityStatus("Queued $j\'th file of series $msg1");
  }, sub {}, $series);
}
$back->SetActivityStatus("Waiting for imports to clear");
close IMPORT;
my $elapsed = time - $start;
$back->Finish("Processed $num_series series in $elapsed seconds");;
