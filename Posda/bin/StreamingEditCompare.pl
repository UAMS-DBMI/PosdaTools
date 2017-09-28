#!/usr/bin/perl -w
use strict;
use File::Temp qw/ tempfile /;
use Posda::DB::PosdaFilesQueries;
use Posda::Try;
use Posda::DiffDicom;
use Posda::Dataset;
use Digest::MD5;

my $usage = <<EOF;
StreamingEditCompare.pl <subprocess_invocation_id>
or
StreamingEditCompare.pl -h

Populates dicom_edit_compare table
Expect input lines in following format:
<sop_instance_uid>|<from_file>|<to_file>
EOF

$|=1;

if($#ARGV == 0 && $ARGV[0] eq "-h" ){ die $usage }
unless($#ARGV == 0 ){ die $usage }

my ($invoc_id) = @ARGV;

my $ins = PosdaDB::Queries->GetQueryInstance(
  "InsertIntoDicomEditCompareFixed");
my %FileIdByDig;
line:
while(my $line = <STDIN>){
  chomp $line;
#print STDERR "Received Compare Instructions: $line\n";
  my($sop_inst, $from_file, $to_file) =
    split(/\|/, $line);
  my $f_try = Posda::Try->new($from_file);
  unless(exists $f_try->{dataset}){
    print "Failed: $sop_inst|$from_file is not a dicom file\n";
    next line;
  }
  my $t_try = Posda::Try->new($to_file);
  unless(exists $t_try->{dataset}){
    print "Failed: $sop_inst|$to_file is not a dicom file\n";
    next line;
  }
  my $fds = $f_try->{dataset};
  my $tds = $t_try->{dataset};
  my $f_dig = $f_try->{digest};
  my $t_dig = $t_try->{digest};
  my $diff = Posda::DiffDicom->new($fds, $tds);
  my($s_rept, $l_rept) = $diff->DiffReport;
  my $ctx = Digest::MD5->new;
  $ctx->add($s_rept);
  my $s_rept_dig = $ctx->hexdigest;
  my $ctx1 = Digest::MD5->new;
  $ctx->add($l_rept);
  my $l_rept_dig = $ctx->hexdigest;
  my($s_rept_file_id, $l_rept_file_id);
  if(exists $FileIdByDig{$s_rept_dig}){
    $s_rept_file_id = $FileIdByDig{$s_rept_dig};
  } else {
    my($fhs, $short_rept) = tempfile();
    $fhs->print($s_rept);
    my $cmd = 
      "ImportSingleFileIntoPosdaAndReturnId.pl \"$short_rept\" " .
      "\"Difference report\"";
    my $result = `$cmd`;
    if($result =~ /File id: (.*)/){
      $s_rept_file_id = $1;
      $FileIdByDig{$s_rept_dig} = $s_rept_file_id;
    } else {
      print "Failed: $sop_inst|Couldn't import short_rept into posda\n";
      next line;
    }
  }
  if(exists $FileIdByDig{$l_rept_dig}){
    $l_rept_file_id = $FileIdByDig{$l_rept_dig};
  } else {
    my($fhl, $long_rept) = tempfile();
    $fhl->print($l_rept);
    my $cmd = 
      "ImportSingleFileIntoPosdaAndReturnId.pl \"$long_rept\" " .
      "\"Difference report\"";
    my $result = `$cmd`;
    if($result =~ /File id: (.*)/){
      $l_rept_file_id = $1;
      $FileIdByDig{$l_rept_dig} = $l_rept_file_id;
    } else {
      print "Failed: $sop_inst|Couldn't import long_rept into posda\n";
      next line;
    }
  }
  $ins->RunQuery(sub{}, sub{},
    $invoc_id, $f_dig, $t_dig, $s_rept_file_id, $l_rept_file_id, $to_file);
  print "Completed: $sop_inst|$from_file|" .
    "$to_file|$s_rept_file_id|$l_rept_file_id\n";
}
