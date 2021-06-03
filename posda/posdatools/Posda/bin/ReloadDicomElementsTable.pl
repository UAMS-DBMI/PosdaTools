#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Posda::BackgroundProcess;
my $usage = <<EOF;
ReloadDicomElementsTable.pl <?bkgrnd_id?> <activity_id> <notify>
  <activity_id>> - activity
  <notify> - user to notify

Expects the following list on <STDIN>
<Tag>|<Name>|<Keyword>|<VR>|<VM>|<Ret>

This table can be copied from "Table 6-1. Registry of DICOM Data Elements" in
part 6 of the DICOM standard.

It compares the values in this table to the contents of the dicom_elements
table in the dicom_dd database and produces reports.

Uses named queries "DeleteDicomElementTable", and "InsertInitialDicomDD"
EOF
if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print $usage;
  exit;
}
unless($#ARGV == 2){
  my $n_args = @ARGV;
  my $mess = "Wrong number of args ($n_args vs 3). Usage:\n$usage\n";
  print $mess;
  die "######################## subprocess failed to start:\n" .
      "$mess\n" .
      "#####################################################\n";
}
my($invoc_id, $activity_id, $notify) = @ARGV;
my @NewDD;
while(my $line = <STDIN>){
  chomp $line;
  my($tag, $name, $keyword, $vr, $vm, $ret) = split(/\|/, $line);
  $tag =~ s/^\s*//;
  $tag =~ s/\s*$//;
  $tag =~ tr/A-F/a-f/;
  $name =~ s/^\s*//;
  $name =~ s/\s*$//;
  $keyword =~ s/^\s*//;
  $keyword =~ s/\s*$//;
  $vr =~ s/^\s*//;
  $vr =~ s/\s*$//;
  $vm =~ s/^\s*//;
  $vm =~ s/\s*$//;
  $ret =~ s/^\s*//;
  $ret =~ s/\s*$//;
  my $is_retired = 0;
  if($ret =~ /RET/){
   $is_retired = 1;
   $ret = "";
  }
  push @NewDD, [$tag, $name, $keyword, $vr, $vm, $is_retired, $ret];
}
my $num_tags = @NewDD;
print "Going to background to process $num_tags tags\n";
my $back = Posda::BackgroundProcess->new($invoc_id, $notify, $activity_id);
$back->Daemonize;
$back->SetActivityStatus("DeletingFromDicomDD");
Query('DeleteDicomElementTable')->RunQuery(sub{}, sub{});
my $q = Query('InsertInitialDicomDD');
my $start = time;
$back->SetActivityStatus("InsertingNewElements");
for my $r (@NewDD){
  my($new_ele, $new_name, $new_key, $new_vr, $new_vm, $ret, $comment) = @$r;
  $q->RunQuery(sub{ }, sub{}, 
    $new_ele, $new_name, $new_key, $new_vr, $new_vm, $ret, $comment
  );
}

my $elapsed = time - $start;
$back->WriteToEmail("Processed: $num_tags in $elapsed seconds\n");
$back->Finish("Processed: $num_tags in $elapsed seconds");
