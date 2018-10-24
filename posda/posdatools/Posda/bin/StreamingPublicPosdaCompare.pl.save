#!/usr/bin/perl -w
use strict;
use File::Temp qw/ tempfile /;
use Posda::DB::PosdaFilesQueries;
use Posda::Try;
use Posda::DiffDicom;
use Posda::Dataset;
use Digest::MD5;

my $usage = <<EOF;
StreamingPublicPosdaCompare.pl <id>
or
StreamingPublicPosdaCompare.pl -h

Expect input lines in following format:
<sop_instance_uid>|<from_file>|<to_file>|<from_file_id_in_posda>

Consumes all of its input, then uses Posda::DiffDicom
to compare files.  It eliminates all differences which involve
group 0013 elements.

At the end, it produces on STDOUT a list of reports, with a count of
the number of files which produced each diff report.
EOF

$|=1;

if($#ARGV == 0 && $ARGV[0] eq "-h" ){ die $usage }
unless($#ARGV == 0 ){ die $usage }

my $invoc_id = $ARGV[0];
my $ins = PosdaDB::Queries->GetQueryInstance(
  "InsertIntoPosdaPublicCompare");

my @SopsToCompare;
line:
while(my $line = <STDIN>){
  chomp $line;
  if($line eq "Prepare Report"){ last line }
  my($sop_inst, $from_file, $to_file, $id) =
    split(/\|/, $line);
  push @SopsToCompare, [$sop_inst, $from_file, $to_file, $id];
}
my $num_compares = @SopsToCompare;
my $start_time = time;
my %Reports;
my %Errors;
my %FileIdByDig;
my $num_sops = @SopsToCompare;
my $sops_done = 0;
my $status_interval = 3600;
my $last_time = time;
print "StreamingPublicPosdaCompare.pl: Starting Comparison\n";
comparison:
for my $comparison(@SopsToCompare){
  my $sop = $comparison->[0];
  my $from_file = $comparison->[1];
  my $to_file = $comparison->[2];
  my $posda_file_id = $comparison->[3];
  my $f_try = Posda::Try->new($from_file);
  unless(exists $f_try->{dataset}){
    print "Error: not a dicom file:sop=$sop;from_file=$from_file;from_file_id=$posda_file_id\n";
    $sops_done += 1;
    next comparison;
  }
  my $t_try = Posda::Try->new($to_file);
  unless(exists $t_try->{dataset}){
    print "Error: not a dicom file:sop=$sop;to_file=$to_file";
    $sops_done += 1;
    next comparison;
  }
  my $fds = $f_try->{dataset};
  my $tds = $t_try->{dataset};
  my $f_dig = $f_try->{digest};
  my $t_dig = $t_try->{digest};
  my $differ = Posda::DiffDicom->new($fds, $tds);
  $differ->Analyze;
  my($OnlyInFrom, $OnlyInTo, $Different) = $differ->SemiDiffReport;
  for my $tag (keys %$OnlyInFrom){
    if($tag =~ /^\(0013/) { delete $OnlyInFrom->{$tag} }
    if($tag =~ /^\(....,\"/) { delete $OnlyInFrom->{$tag} }
  }
  for my $tag (keys %$OnlyInTo){
    if($tag =~ /^\(0013/) { delete $OnlyInTo->{$tag} }
  }
  for my $tag (keys %$Different){
    if($tag =~ /^\(0013/) { delete $Different->{$tag} }
    if($tag =~ /^\(....,\"/) { delete $Different->{$tag} }
  }
  my($short_rpt, $long_rpt) = $differ->ReportFromSemi($OnlyInFrom,
    $OnlyInTo, $Different);
  if($short_rpt eq "") { $short_rpt = "no differences\n" }
  if($long_rpt eq "") { $long_rpt = "no differences\n" }
  my $ctx = Digest::MD5->new;
  $ctx->add($short_rpt);
  my $s_rept_dig = $ctx->hexdigest;
  my $ctx1 = Digest::MD5->new;
  $ctx1->add($long_rpt);
  my $l_rept_dig = $ctx1->hexdigest;
  ##### Put the reports in Posda
  my($s_rept_file_id, $l_rept_file_id);
  if(exists $FileIdByDig{$s_rept_dig}){
    $s_rept_file_id = $FileIdByDig{$s_rept_dig};
  } else {
    my($fhs, $short_rept) = tempfile();
    $fhs->print($short_rpt);
    $fhs->close;
    my $cmd =
      "ImportSingleFileIntoPosdaAndReturnId.pl \"$short_rept\" " .
      "\"Difference report\"";
    my $result = `$cmd`;
    if($result =~ /File id: (.*)/){
      $s_rept_file_id = $1;
      $FileIdByDig{$s_rept_dig} = $s_rept_file_id;
    } else {
      print "Error: Couldn't import short_rept into posda:sop=$sop\n";
      next comparison;
    }
  }
  if(exists $FileIdByDig{$l_rept_dig}){
    $l_rept_file_id = $FileIdByDig{$l_rept_dig};
  } else {
    my($fhl, $long_rept) = tempfile();
    $fhl->print($long_rpt);
    $fhl->close;
    my $cmd =
      "ImportSingleFileIntoPosdaAndReturnId.pl \"$long_rept\" " .
      "\"Difference report\"";
    my $result = `$cmd`;
    if($result =~ /File id: (.*)/){
      $l_rept_file_id = $1;
      $FileIdByDig{$l_rept_dig} = $l_rept_file_id;
    } else {
      print "Error: Couldn't import long_rept into posda:sop=$sop\n";
      next comparison;
    }
  }
  ##### Reports are put in Posda
  $ins->RunQuery(sub{}, sub{},
    $invoc_id, $sop, $posda_file_id, 
    $s_rept_file_id, $l_rept_file_id, $to_file);

  $Reports{$s_rept_dig}->{$l_rept_dig}->{$sop} = 1;
  $sops_done += 1;
  ### Print a progress report periodically while we are running:
  my $elapsed = time - $last_time;
  if($elapsed >= $status_interval){
    $last_time = time;
    my $total_elapsed = time - $start_time;
    my $num_reports = keys %FileIdByDig;
    my $num_short = keys %Reports;
    my $max_len = 0;
    my $longest;
    my $total_len = 0;
    for my $dig (keys %FileIdByDig){
      my $len = length($FileIdByDig{$dig});
      if($len > $max_len) {
         $max_len = $len;
         $longest = $dig;
      }
      $total_len += $len;
    }
    my $avg_rept_len = 0;
    if($num_reports > 0){
      $avg_rept_len = $total_len / $num_reports;
    }
    my $rpt =  "#########################\n" .
          "StreamingPublicPosdaCompare.pl (progress):\n" .
          "After $total_elapsed seconds,\n" .
          "\tfiles processed:      $sops_done\n" .
          "\ttotal reports:        $num_reports\n" .
          "\tnum short rpts:       $num_short\n" .
          "\tlongest report:       $max_len\n" .
          "\ttotal report length:  $total_len\n" .
          "\tavg report length:    $avg_rept_len\n";
    print $rpt;
    print STDERR $rpt;
  }
}
my $total_elapsed = time - $start_time;
my $num_reports = keys %FileIdByDig;
my $num_short = keys %Reports;
my $max_len = 0;
my $total_len = 0;
my $longest;
for my $dig (keys %FileIdByDig){
  my $len = length($FileIdByDig{$dig});
  if($len > $max_len) {
    $max_len = $len;
    $longest = $dig;
  }
  $total_len += $len;
}
my $avg_rept_len = 0;
if($num_reports > 0){
  $avg_rept_len = $total_len / $num_reports;
}
# Print a summary report
my $rpt =  "#########################\n" .
      "StreamingPublicPosdaCompare.pl (final):\n" .
      "After $total_elapsed seconds,\n" .
      "\tfiles processed:      $sops_done\n" .
      "\ttotal reports:        $num_reports\n" .
      "\tnum short rpts:       $num_short\n" .
      "\tlongest report:       $max_len\n" .
      "\ttotal report length:  $total_len\n" .
      "\tavg report length:    $avg_rept_len\n";
print $rpt;
print STDERR $rpt;
print "End of Report\n";
