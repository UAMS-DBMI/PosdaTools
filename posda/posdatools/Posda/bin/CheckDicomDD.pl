#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Posda::BackgroundProcess;
my $usage = <<EOF;
CheckDicomDD.pl <?bkgrnd_id?> <activity_id> <notify>
  <activity_id>> - activity
  <notify> - user to notify

Expects the following list on <STDIN>
<Tag>|<Name>|<Keyword>|<VR>|<VM>|<Ret>

This table can be copied from "Table 6-1. Registry of DICOM Data Elements" in
part 6 of the DICOM standard.

It compares the values in this table to the contents of the dicom_elements
table in the dicom_dd database and produces reports.

Uses named query "LookUpTagEle"
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
  push @NewDD, [$tag, $name, $keyword, $vr, $vm, $ret];
}
my $num_tags = @NewDD;
print "Going to background to process $num_tags tags\n";
my $back = Posda::BackgroundProcess->new($invoc_id, $notify, $activity_id);
$back->Daemonize;
$back->SetActivityStatus("StartingScanOfDD");
my $q = Query('LookUpTagEle');
my $start = time;
my $processed_rows = 0;
my @good_rows;
my @missing_rows;
my @changed_rows;
my @newly_retired;
for my $r (@NewDD){
  my($new_ele, $new_name, $new_key, $new_vr, $new_vm, $ret_com) = @$r;
  my($old_ele, $old_name, $old_key, $old_vr, $old_vm, $ret, $comment);
  my $new_row;
  $q->RunQuery(sub{
    my($row) = @_;
    $old_ele = $row->[0];
    $old_name = $row->[1];
    $old_key = $row->[2];
    $old_vr = $row->[3];
    $old_vm = $row->[4];
    $ret = $row->[5];
    $comment = $row->[6];
    $new_row = $row;
  }, sub{}, $new_ele);
  if(defined $old_ele) {
    if(
      $new_name eq $old_name &&
      $new_key eq $old_key &&
      $new_vr eq $old_vr &&
      $new_vm eq $old_vm
    ){
      push(@good_rows, $new_row);
    } else {
      push @changed_rows, [$new_row, $r];
    }
    if((!$ret) && ($ret_com =~ /RET/)){
      push @newly_retired, [$new_row, $r];
    }
  } else {
    push @missing_rows, $r;
  }
  $processed_rows += 1;
  my $num_good = @good_rows;
  my $num_missing = @missing_rows;
  my $num_changed = @changed_rows;
  my $num_newly_retired = @newly_retired;
 
  $back->SetActivityStatus("Processed $processed_rows, " .
    "good: $num_good, " .
    "missing: $num_missing, " .
    "changed: $num_changed, " .
    "newly_retired: $num_newly_retired"
  );
}
my $num_good = @good_rows;
my $num_missing = @missing_rows;
my $num_changed = @changed_rows;
my $num_newly_retired = @newly_retired;
$back->WriteToEmail("Processed $processed_rows, " .
  "good: $num_good, " .
  "missing: $num_missing, " .
  "changed: $num_changed, " .
  "newly_retired: $num_newly_retired\n"
);
if($num_good > 0){
  $back->SetActivityStatus("Preparing good report\n");
  my $g_rpt = $back->CreateReport("Good Rows");
  $g_rpt->print("Tag,Name,Keyword,VR,VM,Retired,Comment\n");
  for my $i (@good_rows){
    for my $j (0 .. $#{$i}){
      my $v = $i->[$j];
      $v =~ s/""/"/g;
      $g_rpt->print("\"$v\"");
      if($j == $#{$i}){$g_rpt->print("\n")}
      else {$g_rpt->print(",")}
    }
  }
}
if($num_missing > 0){
  $back->SetActivityStatus("Preparing missing report\n");
  my $m_rpt = $back->CreateReport("Missing Rows");
  $m_rpt->print("Tag,Name,Keyword,VR,VM,Retired,Comment\n");
  for my $i (@missing_rows){
    for my $j (0 .. $#{$i}){
      my $v = $i->[$j];
      $v =~ s/""/"/g;
      $m_rpt->print("\"$v\"");
      if($j == $#{$i}){$m_rpt->print("\n")}
      else {$m_rpt->print(",")}
    }
  }
}
if($num_changed > 0){
  $back->SetActivityStatus("Preparing changed report\n");
  my $c_rpt = $back->CreateReport("Changed Rows");
  $c_rpt->print("Tag,Name,Keyword,VR,VM,Retired,Comment,Changes\n");
  for my $i (@changed_rows){
    my($or, $nr) = @$i;
    for my $j (0 .. 6){
      my $v = $or->[$j];
      $v =~ s/"/""/g;
      $c_rpt->print("\"$v\",");
    }
    my @head = ("Tag", "Name", "Keyword", "VR", "VM");
    my $message = "";
    for my $j (1 .. 4){
      if($nr->[$j] ne $or->[$j]){
        my $mess = "$head[$j]: \"$or->[$j]\" => \"$nr->[$j]\"; ";
        $message .= $mess;
      }
    }
    $message =~ s/"/""/g;
    $c_rpt->print("$message\n");
  }
}
if($num_newly_retired > 0){
  $back->SetActivityStatus("Preparing newly retired report\n");
  my $r_rpt = $back->CreateReport("Newly Retired Rows");
  $r_rpt->print("Tag,Name,Keyword,VR,VM,Retired,Comment,NewComment\n");
  for my $i (@newly_retired){
    my($or, $nr) = @$i;
    for my $j (0 .. 6){
      my $v = $or->[$j];
      $v =~ s/"/""/g;
      $r_rpt->print("\"$v\",");
    }
    $r_rpt->print("$nr->[5]\n");
  }
}

my $elapsed = time - $start;
$back->Finish("Processed: $processed_rows in $elapsed seconds");
