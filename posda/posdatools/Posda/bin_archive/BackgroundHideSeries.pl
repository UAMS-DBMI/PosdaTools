#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Posda::BackgroundProcess;
my $usage = <<EOF;
BackgroundHideSeries.pl <?bkgrnd_id?> <reason> <notify>

Expects the following list on <STDIN>
  <series_instance_uid>

Hiding is done by HideFilesWithStatus.pl
EOF
if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print $usage;
  exit;
}
unless($#ARGV == 2){
  print "Wrong number args ($#ARGV vs 2)\n";
  print $usage;
  exit;
}
my($invoc_id, $reason, $notify) = @ARGV;
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
  "Reson: $reason\n");
#######################################################################
### Body of script
open SUBP, "|HideFilesWithStatus.pl $ARGV[1] \"$ARGV[2]\""
  or die "can't open subprocess ($!)";
my $get_files = Query('FilesIdsInSeriesWithVisibility');
for my $s (@series){
  my $num_files = 0;
  my $num_not_visible = 0;
  my $num_hidden = 0;
  $get_files->RunQuery(
    sub {
      my($row) = @_;
      my($file_id, $old_visibility) = @$row;
      $num_files += 1;
      if(defined $old_visibility){
        $num_not_visible += 1;
      } else {
        print SUBP "$file_id&<undef>\n";
        $num_hidden += 1;
      }
    },
    sub {
    },
    $s
  );
  $background->WritetoEmail("$num_hidden files hidden for series $s ($num_not_visible not visible)\n");
}
close SUBP;
### Body of script
###################################################################
$background->Finish;
