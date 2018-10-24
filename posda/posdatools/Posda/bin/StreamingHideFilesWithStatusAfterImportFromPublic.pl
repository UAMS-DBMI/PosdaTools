#!/usr/bin/perl -w
use strict;
use Posda::DB::PosdaFilesQueries;
use Posda::DB 'Query';
my $usage = <<EOF;
usage: HideFilesWithStatusAfterImportFromPublic.pl  <user> <copy_id>
Expects lines in the following formatn on STDIN:

<file_id>&<sop_instance_uid>&<old_visibility>

EOF
if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print "$usage\n";
  exit;
}
unless($#ARGV == 1) { die $usage }
my($user, $copy_id) = @ARGV;
my $hide = Query('HideFile');
my $ins_vc = Query('InsertVisibilityChange');
#my $ins_rc = Query('AddReplacedToFileCopyFromPublic');
line:
while(my $line = <STDIN>){
  chomp $line;
  my($file_id, $sop_instance_uid, $old_visibility) = split /&/, $line;
  $hide->RunQuery(sub {}, sub {}, $file_id);
  $ins_vc->RunQuery(sub {}, sub {},
    $file_id, $user, $old_visibility, 'hidden', 
    "Copy From Public: $copy_id");
#  $ins_rc->RunQuery(sub{}, sub{}, $file_id, $copy_id, $sop_instance_uid);
}
