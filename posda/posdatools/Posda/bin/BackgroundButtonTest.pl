#!/usr/bin/env perl

use Modern::Perl;
use Posda::BackgroundProcess;
use Posda::DownloadableDir;


say "Background Button Test v1.0\n\n";

say "This script does not read from stdin";

my ($invoc_id, $collection, $notify) = @ARGV;
my $background = Posda::BackgroundProcess->new($invoc_id, $notify);

my $lines = 0;
while (my $line = <STDIN>) {
  $background->LogInputLine($line);
  $lines++;
}
say "Read $lines lines from stdin, forking now...";

$background->Daemonize;
# don't write to stdout after this, or it will crash!

my $report = $background->CreateReport('main');
print $report "test print to report\n";

$background->WriteToEmail("Began BackgroundButtonTest.pl\n");

my $dl_dir = Posda::DownloadableDir::make("/mnt/main/test_set_for_va");
$background->WriteToEmail("Have some files: $dl_dir\n");

$background->Finish;
