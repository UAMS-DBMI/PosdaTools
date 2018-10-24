#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Posda::BackgroundProcess;
my $usage = <<EOF;
BackgroundHideSeriesByCollection.pl <?bkgrnd_id?> <reason> <collection> <notify>

Expects the following list on <STDIN>
  <series_instance_uid>

Hiding is done by HideFilesWithStatus.pl
EOF
if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print $usage;
  exit;
}
unless($#ARGV == 3){
  print "Wrong number args ($#ARGV vs 2)\n";
  print $usage;
  exit;
}
my($invoc_id, $reason, $collection, $notify) = @ARGV;
my $background = Posda::BackgroundProcess->new($invoc_id, $notify);
my @series;
while(my $line = <STDIN>){
  chomp($line);
  push @series, $line
}
my $num_series = @series;
print "$num_series series to hide\n" .
  "Forking background process\n";
$background->Daemonize;
my $date = `date`;
chomp $date;
$background->WriteToEmail("$date\nHiding $num_series series\n" .
  "Collection: $collection\n" .
  "For: ($invoc_id) $reason\n\n");
#######################################################################
### Body of script
open SUBP, "|HideFilesWithStatus.pl $notify \"$reason\""
  or die "can't open subprocess ($!)";
my $get_files = Query('FilesIdsInSeriesWithVisibilityAndCollection');
for my $s (@series){
  my $num_files = 0;
  my $num_not_visible = 0;
  my $num_hidden = 0;
  my $num_visible_not_hidden = 0;
  $get_files->RunQuery(
    sub {
      my($row) = @_;
      my($file_id, $coll, $old_visibility) = @$row;
      $num_files += 1;
      if(defined $old_visibility){
        $num_not_visible += 1;
      } else {
        if($coll eq $collection){
          print SUBP "$file_id&<undef>\n";
          $num_hidden += 1;
        } else {
          $num_visible_not_hidden += 1;
        }
      }
    },
    sub {
    },
    $s
  );
  $background->WriteToEmail("For series $s:\n" .
    "\t num not visible: $num_not_visible\n" .
    "\t num hidden: $num_hidden\n" .
    "\t num not hidden (other collection): $num_visible_not_hidden\n");
}
close SUBP;
### Body of script
###################################################################
$background->Finish;
