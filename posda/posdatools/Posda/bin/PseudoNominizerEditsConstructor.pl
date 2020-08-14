#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Digest::MD5;
use Posda::BackgroundProcess;
use Debug;
sub MakeDebugPrinter{
  my($hand) = @_;
  my $sub = sub {
    $hand->print(@_);
  };
  return $sub;
}
sub DebugPrintStruct{
  my($dbg, $caption, $struct) = @_;
  &{$dbg}("$caption: ");
  Debug::GenPrint($dbg, $struct, 1);
  &{$dbg}("\n");
};
my $usage = <<EOF;
PseudoNominizerEditsConstructor.pl <?bkgrnd_id?> <activity_id> <notify>

Expects the following list on <STDIN>
  <operation_scope>&<operation>&<tag>&<value1>&<value2>&<patient_id>&
    <series_instance_uid>&<series_instance_uid>&<sop_instance_uid>&<unmapped_uid>&<mapped_uid>

Uses query GetSopsInSeriesInTimepoint
EOF
if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print $usage;
  exit;
}
unless($#ARGV == 2){
  print "Invalid number of args\n$usage";
  exit;
}
my($invoc_id, $activity_id, $notify) = @ARGV;
my %UidMapping;
my ($current_patient, $current_study, $current_series, $current_sop);
my %sops;
my %patients;
my %studies;
my %series;
my %sops_seen;
my $getsops = Query('GetSopsInSeriesInTimepoint');
my $error_count = 0;
while(my $line = <STDIN>){
  chomp $line;
  my($op_scope, $op, $tag, $val1, $val2, $pat_id,
    $study_uid, $series_uid, $sop, $unmapped_uid, $mapped_uid) = split(/&/, $line);
  $op_scope = fix_parm($op_scope);
  $op = fix_parm($op);
  $tag = fix_parm($tag);
  $val1 = fix_parm($val1);
  $val2 = fix_parm($val2);
  $pat_id = fix_parm($pat_id);
  $study_uid = fix_parm($study_uid);
  $series_uid = fix_parm($series_uid);
  $sop = fix_parm($sop);
  $unmapped_uid = fix_parm($unmapped_uid);
  $mapped_uid = fix_parm($mapped_uid);
  if(
    defined($unmapped_uid) && $unmapped_uid &&
    defined($mapped_uid) && $mapped_uid
  ){
    $UidMapping{$unmapped_uid} = $mapped_uid;
  }
  ## todo: enhance error checking - unique hierarchy and correct ordering
  if(
    defined($pat_id) && defined($study_uid) && defined($series_uid) && defined($sop) &&
    $pat_id && $study_uid && $series_uid && $sop
  ){
    if(defined($pat_id) && $pat_id){
      $current_patient = $pat_id;
print "Current_patient: $current_patient\n";
    }
    if(defined($study_uid) && $study_uid){
      $current_study = $study_uid;
print "Current_study: $current_study\n";
      if(defined $studies{$current_study} && $studies{$current_study} ne $current_patient){
        print "Error: study ($current_study) belongs to two patients (" .
          "$current_patient and $studies{$current_study})\n";
        $error_count += 1;
      }
      $studies{$current_study} = $pat_id;
    }
    if(defined($series_uid) && $series_uid){
      $current_series = $series_uid;
print "Current series: $current_series\n";
      if(defined $series{$current_series} && $series{$current_series} ne $current_study){
        print "Error: series ($current_series) belongs to two studies (" .
          "$current_study and $series{$current_series})\n";
        $error_count += 1;
      }

      if(
        defined($patients{$current_patient}->{$current_study}->{$current_series})
      ){
        my $num_sops = keys %{$patients{$current_patient}->{$current_study}->{$current_series}};
        print "Series $current_series in hierarchy with $num_sops sops\n";
      } else {
        my $h = {};
        $getsops->RunQuery(sub{
          my($row) = @_;
          $h->{$row->[0]} = [];
        }, sub {}, $current_series, $activity_id);
        $patients{$current_patient}->{$current_study}->{$current_series} = $h;
        my $num_sops = keys %{$patients{$current_patient}->{$current_study}->{$current_series}};
        print "Created series $current_series in hierarchy with $num_sops sops\n";
      }
    }
    if(defined($sop) && $sop){
      $current_sop = $sop;
print "Current sop: $current_sop\n";
      if(exists $sops_seen{$current_sop}) {
        print "Error: series $current_sop defined twice\n";
        $error_count += 1;
      }
      $sops_seen{$current_sop} = 1;
      unless(
        defined (
          $patients{$current_patient}->{$current_study}->{$current_series}->{$current_sop}
        )
      ){
        print "Error: sop ($current_sop) not found in hierarchy\n";
        $error_count += 1;
      }
    }
  }
  ## odot: enhance error checking
  if(defined($op_scope) && $op_scope){ my $op_v = [$op, $tag, $val1, $val2];
    if($op_scope eq "Instance"){
      unless(defined($current_sop)){
        print "Error: no sop defined when operation_scope sop encountered\n";
        $error_count += 1;
      }
      unless(defined $patients{$current_patient}->{$current_study}->{$current_series}->{$current_sop}){
        print "Error: Instance $current_sop not defined in hierarchy\n";
        $error_count += 1;
      }
      my $sop_ptr = 
        $patients{$current_patient}->{$current_study}->{$current_series}->{$current_sop};
      push @{$sop_ptr}, $op_v;
    } elsif($op_scope eq "Series"){
      unless(
        defined($patients{$current_patient}->{$current_study}->{$current_series})
      ){
        print "Error: series $current_series not defined in hierarchy\n";
        $error_count += 1;
      }
      for my $sop (keys %{$patients{$current_patient}->{$current_study}->{$current_series}}){
        my $sop_ptr = 
          $patients{$current_patient}->{$current_study}->{$current_series}->{$sop};
        push @{$sop_ptr}, $op_v;
      }
    } elsif ($op_scope eq "Study"){
      unless(defined($patients{$current_patient}->{$current_study})){
        print "Error: study $current_study not defined in hierarchy\n";
        $error_count += 1;
        exit;
      }
      for my $study (keys %{$patients{$current_patient}}){
        for my $series (keys %{$patients{$current_patient}->{$study}}){
          for my $sop (keys %{$patients{$current_patient}->{$study}->{$series}}){
            my $sop_ptr = $patients{$current_patient}->{$study}->{$series}->{$sop};
            push @{$sop_ptr}, $op_v;
          }
        }
      }
    } elsif ($op_scope eq "Patient"){
      for my $study (keys %{$patients{$current_patient}}){
        for my $series(keys %{$patients{$current_patient}->{$study}}){
          for my $sop (keys %{$patients{$current_patient}->{$study}->{$series}}){
            my $sop_ptr = $patients{$current_patient}->{$study}->{$series}->{$sop};
            push @{$sop_ptr}, $op_v;
          }
        }
      }
    } elsif ($op_scope eq "Collection"){
      for my $pat (keys %patients){
        for my $study (keys %{$patients{$pat}}){
          for my $series(keys %{$patients{$pat}->{$study}}){
            for my $sop (keys %{$patients{$pat}->{$study}->{$series}}){
              my $sop_ptr = $patients{$pat}->{$study}->{$series}->{$sop};
              push @{$sop_ptr}, $op_v;
            }
          }
        }
      }
    } else {
      print "Unknown operation_scope ($op_scope)\n";
      exit;
    }
  }
}
print "Finished Building Structure\n";
print "Error count: $error_count\n";
#print "not entering background - just testing\n";
#exit;
print "Entering Background\n";
my $background = Posda::BackgroundProcess->new($invoc_id, $notify, $activity_id);
$background->Daemonize;
$background->WriteToEmail("Testing AnonymizerToEditor.pl\n");
my $rpt = $background->CreateReport("StructureDump");
my $dbg = MakeDebugPrinter($rpt);
my %EditsByDigest;
for my $p (keys %patients){
  for my $st (keys %{$patients{$p}}){
    for my $se (keys %{$patients{$p}->{$st}}){
      for my $sop (keys %{$patients{$p}->{$st}->{$se}}){
        my $edits = $patients{$p}->{$st}->{$se}->{$sop};
        my $dig = tree_digest($edits);
        $EditsByDigest{$dig}->{edits} = $edits;
        $EditsByDigest{$dig}->{sops}->{$sop} = 1;
      }
    }
  }
}
my @EditList;
for my $dig (keys %EditsByDigest){
  my $hash;
  $hash->{sops} = [keys %{$EditsByDigest{$dig}->{sops}}];
  for my $e (@{$EditsByDigest{$dig}->{edits}}){
    unless(exists $hash->{edits}->{$e->[0]}){
      $hash->{edits}->{$e->[0]} = [];
    }
    push @{$hash->{edits}->{$e->[0]}}, [$e->[1], $e->[2], $e->[3], $e->[4]];
  }
  push @EditList, $hash;
}
DebugPrintStruct($dbg, "EditsList", \@EditList);
my $uids_mapped = keys %UidMapping;
my $rpt1 = $background->CreateReport("PreliminaryEditSpreadsheet");
if($uids_mapped){
  $rpt1->print("\"unmapped_uid\",\"mapped_uid\",");
}
$rpt1->print("\"sop_instance_uid\",\"operation\",\"tag\",\"val1\"," .
  "\"val2\"\n");
my @unmapped_list = keys %UidMapping;
my $current_mapping_index = 0;
for my $edit (@EditList){
  my $sops = $edit->{sops};
  my $edits = $edit->{edits};
  for my $sop (@$sops){
    print_mapping($current_mapping_index, $rpt1);
    $current_mapping_index += 1;
    $rpt1->print("$sop,,,,,\n");
  }
  for my $ed(keys %$edits){
    for my $cmds (@{$edits->{$ed}}){
      print_mapping($current_mapping_index, $rpt1);
      $current_mapping_index += 1;
      for my $i (0 .. @$cmds){
        if($cmds->[$i] =~ /^<(.*)>$/) { $cmds->[$i] = $1 }
        if($cmds->[$i] =~ /^\s*<(.*)>$/) { $cmds->[$i] = $1 }
        $cmds->[$i] =~ s/\"/\"\"/g;
      }
      $rpt1->print(",$ed,\"<$cmds->[0]>\",\"<$cmds->[1]>\",\"<$cmds->[2]>\"\n");
    }
  }
}
while($current_mapping_index <= $#unmapped_list){
  print_mapping($current_mapping_index, $rpt1);
  $current_mapping_index += 1;
  $rpt1->print("\n");
}
$background->Finish;
exit;
sub print_mapping{
  my($index, $rpt) = @_;
  if($uids_mapped){
    if($index <= $#unmapped_list){
      my $unmapped = $unmapped_list[$index];
      my $mapped = $UidMapping{$unmapped};
      $rpt->print("$unmapped,$mapped,");
    } else {
      $rpt->print(",,");
    }
  }
}
sub fix_parm{
  my($parm) = @_;
  unless(defined $parm) { return undef };
  if($parm =~ /^'<(.*)>$/) { return $1 };
  if($parm =~ /^<(.*)>$/) { return $1 };
  return $parm;
}
sub tree_digest{
  my($struct, $ctx, $depth) = @_;
  unless(defined $ctx) {
    $ctx = Digest::MD5->new;
  }
  unless(defined $depth) {
    $depth = 0;
  }
  if(ref($struct) eq "ARRAY"){
    for my $i (@$struct) {
      tree_digest($i, $ctx, $depth + 1);
    }
  } elsif(ref($struct) eq ""){
    $ctx->add($struct);
  } else {
    die "tree_struct only works for ARRAY and scalar";
  }
  if($depth == 0){
    my $dig = $ctx->hexdigest;
    return $dig;
  }
}
