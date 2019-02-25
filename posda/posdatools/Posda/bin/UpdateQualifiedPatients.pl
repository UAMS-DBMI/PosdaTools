#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Posda::BackgroundProcess;

my $usage = <<EOF;
UpdateQualifiedPatients.pl <?bkgrnd_id?> <notify>
or
UpdateQualifiedPatients.pl -h

Expects input lines in following format:
<collection>&<site>&<patient_id>&<qualified>

where <qualified> is "TRUE", "FALSE", or "<undef>"

inserts or updates clinical_trial_qualified_patient_id

EOF
if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print $usage; exit;
}
unless($#ARGV == 1 ){ die $usage }

my($invoc_id, $notify) = @ARGV;

my $Errors = 0;
my %Data;
while(my $line = <STDIN>){
  chomp $line;
  my($collection, $site, $pat_id, $qualified) =
    split(/&/, $line);
  unless(
    $qualified eq "TRUE" || $qualified eq "FALSE" ||
    $qualified eq "<undef>"
  ){
    print "Error: qualified cannot have value $qualified\n";
    $Errors += 1;
  }
  $Data{$collection}->{$site}->{$pat_id} = $qualified;
}
if($Errors > 0){
  print "Aborting because of errors\n";
  exit;
}
my %Table;
Query("GetCTQP")->RunQuery(sub{
  my($row) = @_;
  my($coll, $site, $pat_id, $qualified) = @$row;
  if($qualified) {$qualified = "TRUE"}
  elsif(!defined $qualified) {$qualified = "<undef>"}
  else {$qualified = "FALSE"}
  $Table{$coll}->{$site}->{$pat_id} = $qualified;
},sub{}); my %Changed; my %New;
my $num_changed = 0;
my $num_new = 0;
my $num_matching = 0;
my $num_same = 0;
for my $coll(keys %Data){
  for my $site (keys %{$Data{$coll}}){
    for my $pat (keys %{$Data{$coll}->{$site}}){
      unless(exists $Table{$coll}->{$site}->{$pat}){
        $New{$coll}->{$site}->{$pat} = 
          $Data{$coll}->{$site}->{$pat};
        $num_new += 1;
        next;
      }
      unless(
       $Data{$coll}->{$site}->{$pat} eq
       $Table{$coll}->{$site}->{$pat}
      ){
        $Changed{$coll}->{$site}->{$pat} = 
          $Data{$coll}->{$site}->{$pat};
        $num_changed += 1;
        next;
      }
      $num_same += 1;
    }
  }
}
my $num_unreferenced = 0;
for my $coll (keys %Table){
  for my $site (keys %{$Table{$coll}}){
    for my $pat (keys %{$Table{$coll}->{$site}}){
      unless(exists $Data{$coll}->{$site}->{$pat}){
        $num_unreferenced += 1;
      }
    }
  }
}
print "$num_new rows to be created\n";
print "$num_changed existing rows to be updated\n";
print "$num_same existing rows specified not to changed\n";
print "$num_unreferenced existing rows not mentioned\n";

my $back = Posda::BackgroundProcess->new($invoc_id, $notify);
$back->Daemonize;
$back->WriteToEmail("Updating clinical_trial_qualified_patient_id table:\n" .
  "   $num_new rows to be created\n" .
  "   $num_changed existing rows to be updated\n" .
  "   $num_same existing rows specified not to changed\n" .
  "   $num_unreferenced existing rows not mentioned\n"); 
my $ins = Query("InsCTQP");
my $upd = Query("UpdCTQP");
for my $coll (keys %Changed){
  for my $site(keys %{$Changed{$coll}}){
    for my $pat(keys %{$Changed{$coll}->{$site}}){
      my $qual = $Changed{$coll}->{$site}->{$pat};
      if($qual eq "<undef>") {$qual = undef};
      $upd->RunQuery(sub{}, sub{}, $qual, $coll, $site, $pat);
    }
  }
}
for my $coll (keys %New){
  for my $site(keys %{$New{$coll}}){
    for my $pat(keys %{$New{$coll}->{$site}}){
      my $qual = $New{$coll}->{$site}->{$pat};
      if($qual eq "<undef>") {$qual = undef};
print STDERR "$coll, $site, $pat, $qual\n";
      $ins->RunQuery(sub{}, sub{}, $coll, $site, $pat, $qual);
    }
  }
}
$back->Finish;
