#!/usr/bin/perl -w
use strict;
use Posda::Inbox;
use Posda::DB 'Query';
use Posda::BackgroundProcess;
my $usage = <<EOF;
FileAndDismissNotification.pl <?bkgrnd_id> <activity_id> <description> <notify>

expects a list of <inbox_content_id> on STDIN

EOF

if($#ARGV == 0 && $ARGV[0] eq '-h'){
  print $usage; exit;
}
unless($#ARGV == 3){
  print $usage; die $usage;
}
my($invoc_id, $activity_id, $description, $notify) = @ARGV;
my %inbox_content_ids;
while(my $line = <STDIN>){
  chomp ($line);
  $inbox_content_ids{$line} = 1;  
}
my $bkgrnd = Posda::BackgroundProcess->new($invoc_id, $notify);
my $num_notifications = keys %inbox_content_ids;
print "$num_notifications inbox_content_items to file and dismiss\n";
print "Entering background\n" .
  "Description: $description\n" .
  "activity_id: $activity_id\n" .
  "notify: $notify\n";
$bkgrnd->Daemonize;
$bkgrnd->WriteToEmail(
  "Entering background\n" .
  "Description: $description\n" .
  "activity_id: $activity_id\n" .
  "notify: $notify\n");

my $ins = Query('InsertActivityInboxContent');
my $dismiss = Query('DismissInboxContentItem');
for my $inbox_content_id (keys %inbox_content_ids){
  $ins->RunQuery(sub{}, sub {}, $activity_id, $inbox_content_id);
  $dismiss->RunQuery(sub{}, sub{}, $inbox_content_id);
}
