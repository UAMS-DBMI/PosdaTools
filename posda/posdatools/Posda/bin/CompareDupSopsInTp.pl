#!/usr/bin/perl -w
use strict;
use File::Temp qw/ tempfile /;
use Posda::DB 'Query';
use Posda::BackgroundProcess;
use Posda::Try;
use Posda::DiffDicom;
use Digest::MD5;
use FileHandle;
use Storable qw( store retrieve fd_retrieve store_fd );


#use Debug;
#my $dbg = sub { print STDERR @_ };
#my $dbg = sub { print @_ };

my $usage = <<EOF;
Usage:
CompareDupSopsInTp.pl <?bkgrnd_id?> <activity_id> <activity_timepoint_id> <notify>
or
CompareDupSopsInTp.pl -h

Expects no lines no STDIN

This script uses the query "DupSopsSummaryTp" to get a list of all of the series 
in the timepoint which have duplicate SOPs (in the timepoint).

For each series, it will get a list by series of All SOPs which are duplicate, and
the number of duplicates for each SOP.  It will sort the file_id's for each SOP
by id, and will generate as set of <n-1> comparisons for <n> different file_id's for 
the SOP.

These differences will be stored in the dup_sops_comparison table.
At the end of execution, it will produce a report "DupSopDifferences".

This will report will contain at most (<n-1> * 2) columns, (i.e 2 columns for each
comparison generated for the SOP with the most duplicates). These columns will be
labeled "differences" and "difference_id".

Rows will be collapsed to avoid duplication.  There will be another column labled
"num_sops" to indicate how many SOP's generated each particular set of differences.
EOF

if($#ARGV == 0 && $ARGV[0] eq "-h") { print "$usage\n\n"; exit }
if($#ARGV != 3){ print "Wrong args: $usage\n"; die "$usage\n\n" }
my($invoc_id, $act_id, $act_tp_id, $notify) = @ARGV;

print "All processing in background\n";
my $back = 
  Posda::BackgroundProcess->new($invoc_id, $notify, $act_id);
$back->Daemonize;

$back->SetActivityStatus("Getting Series List");
my %Series;
Query('DupSopsSummaryInTp')->RunQuery(sub {
  my($row) = @_;
  my($series_id, $num_sops, $num_occ) = @$row;
  if(exists $Series{$series_id}){
  }
  $Series{$series_id} = 1;
}, sub {}, $act_tp_id);

my $total_series = keys %Series;
my %FileIdByDig;
my %Sops;
my $q = Query('GetDupSopsAndFileIdsBySeriesTp');
my $s_c; my $f_c;
for my $series(keys %Series){
  $s_c += 1;
  $q->RunQuery(sub{
    my($row) = @_;
    my($sop, $file) = @$row;
    $f_c += 1;
    unless(exists $Sops{$sop}) { $Sops{$sop} = [] }
    push @{$Sops{$sop}}, $file;
  }, sub {}, $act_tp_id, $series, $act_tp_id);
  $back->SetActivityStatus("Got $f_c sops for $s_c (of $total_series) series");
}
my $cur_sop_idx = 0;
my $q1 = Query("FilePathByFileId");
my $q_ins = Query("InsertDupSopsComparison");
my $sops_processed = 0;
my $cmps_processed = 0;
my @rpt_errors;
sop:
for my $sop (keys %Sops){
  $cur_sop_idx += 1;
  $sops_processed += 1;
  my $file_list = $Sops{$sop};
  my $num_cmps = (@$file_list) - 1;
  
  for my $cur_cmp_idx (1 .. $#{$file_list}){
    $cmps_processed += 1;
    my $from_file_id = $file_list->[$cur_cmp_idx - 1];
    my $to_file_id = $file_list->[$cur_cmp_idx];
    my $from_file_path;
    $q1->RunQuery(sub{
      my($row) = @_;
      $from_file_path = $row->[0];
    }, sub {}, $from_file_id);
    my $to_file_path;
    $q1->RunQuery(sub{
      my($row) = @_;
      $to_file_path = $row->[0];
    }, sub {}, $to_file_id);

    my $f_try = Posda::Try->new($from_file_path);
    unless(exists $f_try->{dataset}){
      my $msg = "from_file ($from_file_path) is not a dicom_file";
      push @rpt_errors, [$sop, $from_file_id, $msg];
      next sop;
    }
    my $t_try = Posda::Try->new($to_file_path);
    unless(exists $t_try->{dataset}){
      my $msg = "to file ($to_file_path) is not a dicom_file";
      push @rpt_errors, [$sop, $from_file_id, $msg];
      next sop;
    }
    my $fds = $f_try->{dataset};
    my $tds = $t_try->{dataset};
    my $l_rept_file_id;
    my $diff = Posda::DiffDicom->new($fds, $tds);
    $diff->Analyze;
    my($only_in_from, $only_in_to, $different) =
      $diff->SemiDiffReport;
    my $l_rept =
      $diff->LongReportFromSemiWithDates($only_in_from, $only_in_to, $different);
    unless(length($l_rept) <= 0){
      my $ctx1 = Digest::MD5->new;
      $ctx1->add($l_rept);
      my $l_rept_dig = $ctx1->hexdigest;
      if(exists $FileIdByDig{$l_rept_dig}){
        $l_rept_file_id = $FileIdByDig{$l_rept_dig};
      } else {
        my($fhl, $long_rept) = tempfile();
        $fhl->print($l_rept);
        my $cmd =
          "ImportSingleFileIntoPosdaAndReturnId.pl \"$long_rept\" " .
          "\"Difference report\"";
        my $result = `$cmd`;
        unlink $long_rept;
        if($result =~ /File id: (.*)/){
          $l_rept_file_id = $1;
          $FileIdByDig{$l_rept_dig} = $l_rept_file_id;
        } else {
          my $msg = "Couldn't import rept into posda";
          push @rpt_errors, [$sop, $from_file_id, $msg];
          next line;
        }
      }
    }
    $q_ins->RunQuery(sub{}, sub{},
      $invoc_id, $cur_sop_idx, $cur_cmp_idx, 
      $from_file_id, $to_file_id, $l_rept_file_id);
  }
  $back->SetActivityStatus("Processed $sops_processed sops, " .
    "$cmps_processed compares");
}
if($#rpt_errors >= 0){
  my $rpt_error = $back->CreateReport("ProcessingErrors");
  $rpt_error->print("sop,file,message\n");
  for my $err (@rpt_errors){
    $rpt_error->print("$err->[0],$err->[1],\"$err->[2]\"\r\n");
  }
}
$back->SetActivityStatus("Generating diff report");

my %Equiv;
my $last_sop_idx;
my $equiv_class;
Query('ForMakingDupSopsEquivalenceClasses')->RunQuery(sub{
  my($row) = @_;
  my($sop_index, $cmp_index, $long_report_file_id) = @$row;
  if(
    defined($last_sop_idx) &&
    $sop_index ne $last_sop_idx
  ){
    $Equiv{$equiv_class}->{$last_sop_idx} = 1;
    $last_sop_idx = $sop_index;
    $equiv_class = $long_report_file_id;
    return;
  }
  if(
    defined($last_sop_idx) &&
    $sop_index eq $last_sop_idx
  ){
    $equiv_class = $equiv_class . "::" . $long_report_file_id;
    return;
  }
  $last_sop_idx = $sop_index;
  $equiv_class = $long_report_file_id;
}, sub{}, $invoc_id);
$Equiv{$equiv_class}->{$last_sop_idx} = 1;

my $longest_equiv;
for my $i (keys %Equiv){
  my @foo = split(/::/, $i);
  my $num = @foo;
  unless(defined $longest_equiv) { $longest_equiv = $num }
  if($num > $longest_equiv) { $longest_equiv = $num }
}
my $add_equiv = Query('ForInsertingDupSopsEquivalenceClasses');
for my $e (keys %Equiv){
  for my $sop (keys %{$Equiv{$e}}){
    $add_equiv->RunQuery(sub{},sub{}, $e, $invoc_id, $sop);
  }
}

my $get_path = Query('GetFilePath');
my $rpt_diffs = $back->CreateReport("DifferenceReport");
my @EquivClasses = sort {
   keys %{$Equiv{$b}} <=> keys %{$Equiv{$a}} ||
   length($b) <=> length($a)
} keys %Equiv;
$rpt_diffs->print("num_sops,equiv_class");
for my $i (0 .. $longest_equiv){
  my $left = $i + 1;
  if($i < $longest_equiv){
    $rpt_diffs->print(",$left,diffs");
  } else {
    $rpt_diffs->print(",$left,");
    $rpt_diffs->print(",select\r\n");
  }
}
for my $eq (@EquivClasses){
  my $num_sops = keys %{$Equiv{$eq}};
  my @ids = split(/::/, $eq);
  $rpt_diffs->print("$num_sops,$eq");
  for my $i (0 .. $#ids){
    my $id = $ids[$i];
    $rpt_diffs->print(",");
    $rpt_diffs->print($i + 1);
    my $long_rept;
    $get_path->RunQuery(sub {
      my($row) = @_;
      my $file = $row->[0];
      $long_rept = `cat $file`;
      chomp $long_rept;
#      $long_rept = "$file";
    }, sub{}, $id);
    $long_rept = "Report id: $id\n\n" . $long_rept;
    $long_rept =~ s/"/""/g;
    $rpt_diffs->print(",\"$long_rept\"");
    if($i == $#ids){
      my $j = $i + 2;
      $rpt_diffs->print(",$j");
    }
  }
  $rpt_diffs->print("\r\n");
}
$back->Finish("Done");
