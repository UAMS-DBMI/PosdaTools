#!/usr/bin/perl -w
use strict;
use Posda::Try;
use Posda::DB qw( Query );
my $usage = <<EOF;
usage:
GetRoiNames.pl <file_id>
or
GetRoiNames.pl -h

 <file_id> should be the file id of an RTSTRUCT

Produces lines on STDOUT in the following format:
<roi_num>:<roi_name>

Produces no output if not an RTSTRUCT, etc.

EOF
unless($#ARGV == 0) { die $usage }
if($ARGV[0] eq "-h"){
  print $usage;
  exit;
}
my $file_path;
Query("GetFilePath")->RunQuery(sub{
 my($row) = @_;
 $file_path = $row->[0];
},sub{}, $ARGV[0]);
my $try = Posda::Try->new($file_path);
unless(defined($try) && defined($try->{dataset})){
  die "file_id $ARGV[0] isn't a dicom_file";
}
my $ds = $try->{dataset};
my $m = $ds->Search("(3006,0020)[<0>](3006,0022)");
for my $r (@$m){
  my $numtag = "(3006,0020)[$r->[0]](3006,0022)";
  my $nametag = "(3006,0020)[$r->[0]](3006,0026)";
  my $name = $ds->Get($nametag);
  my $num = $ds->Get($numtag);
  print "$num:$name\n";
}
