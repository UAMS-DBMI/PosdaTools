#!/usr/bin/perl -w
use strict;
use Posda::DB::PosdaFilesQueries;
my $usage = "usage: HideFileWithStatus.pl <file_id> <old_visibility> <user> <reason>\n";
unless($#ARGV == 3) { die $usage }
my $file_id = $ARGV[0];
my $old_visibility = $ARGV[1];
if($old_visibility eq "<undef>") { $old_visibility = undef }
my $user = $ARGV[2];
my $reason = $ARGV[3];
my $hide = PosdaDB::Queries->GetQueryInstance('HideFile');
my $ins_vc = PosdaDB::Queries->GetQueryInstance('InsertVisibilityChange');
$hide->RunQuery(sub {}, sub {}, $file_id);
$ins_vc->RunQuery(sub {}, sub {},
  $file_id, $user, $old_visibility, 'hidden', $reason);
