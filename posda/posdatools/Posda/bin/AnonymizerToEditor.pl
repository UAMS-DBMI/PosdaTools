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
AnonymizerToEditor.pl <id> <notify>
  id - id of row in subprocess_invocation table created for the
    invocation of the script
  writes result into <to_dir>
  UID's not hashed if they begin with <uid_root>
  date's always offset with offset (days)
  email sent to <notify>

Expects the following list on <STDIN>
  <operation_scope>&<operation>&<tag>&<value1>&<value2>&<patient_id>&
    <series_instance_uid>&<series_instance_uid>&<unmapped_uid>&<mapped_uid>
EOF
if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print $usage;
  exit;
}
unless($#ARGV == 1){
  print "Invalid number of args\n$usage";
  exit;
}
my($invoc_id, $notify) = @ARGV;
my %UidMapping;
my ($current_patient, $current_study, $current_series);
my %series;
my %studies;
my %patients;
while(my $line = <STDIN>){
  chomp $line;
  my($op_scope, $op, $tag, $val1, $val2, $pat_id,
    $study_uid, $series_uid, $unmapped_uid, $mapped_uid) = split(/&/, $line);
  $op_scope = fix_parm($op_scope);
  $op = fix_parm($op);
  $tag = fix_parm($tag);
  $val1 = fix_parm($val1);
  $val2 = fix_parm($val2);
  $pat_id = fix_parm($pat_id);
  $study_uid = fix_parm($study_uid);
  $series_uid = fix_parm($series_uid);
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
    defined($pat_id) && defined($study_uid) && defined($series_uid) &&
    $pat_id && $study_uid && $series_uid
  ){
    if(defined($pat_id) && $pat_id){
      $current_patient = $pat_id;
    }
    if(defined($study_uid) && $study_uid){
      $current_study = $study_uid;
      $patients{$current_patient}->{$current_study} = 1;
    }
    if(defined($series_uid) && $series_uid){
      $current_series = $series_uid;
      $studies{$current_study}->{$current_series} = 1;
      if(exists $series{$current_series}) {
        print "Error: series $current_series defined twice\n";
        exit;
      }
      $series{$current_series}->{series_uid} = $current_series;
    }
  }
  ## odot: enhance error checking
  if(defined($op_scope) && $op_scope){
    if($op_scope eq "Series"){
      unless(defined($current_series) && exists($series{$current_series})){
        print "Error: no series defined when operation_scope series " .
          "encountered\n";
        exit;
      }
      my $series_ptr = $series{$current_series};
      unless(exists $series_ptr->{edits}){
        $series_ptr->{edits} = [];
      }
      push @{$series_ptr->{edits}}, [$op, $tag, $val1, $val2];
    } elsif ($op_scope eq "Study"){
      for my $series (keys %{$studies{$current_study}}){
        my $series_ptr = $series{$series};
        unless(exists $series_ptr->{edits}){
          $series_ptr->{edits} = [];
        }
        push @{$series_ptr->{edits}}, [$op, $tag, $val1, $val2];
      }
    } elsif ($op_scope eq "Patient"){
      for my $study (keys %{$patients{$current_patient}}){
        for my $series(keys %{$studies{$study}}){
          my $series_ptr = $series{$series};
          unless(exists $series_ptr->{edits}){
            $series_ptr->{edits} = [];
          }
          push @{$series_ptr->{edits}}, [$op, $tag, $val1, $val2];
        }
      }
    } elsif ($op_scope eq "Collection"){
      for my $pat (keys %patients){
        for my $study (keys %{$patients{$pat}}){
          for my $series(keys %{$studies{$study}}){
            my $series_ptr = $series{$series};
            unless(exists $series_ptr->{edits}){
              $series_ptr->{edits} = [];
            }
            push @{$series_ptr->{edits}}, [$op, $tag, $val1, $val2];
          }
        }
      }
    } else {
      print "Unknown operation_scope ($op_scope)\n";
      exit;
    }
  }
}
print "Finished Building Structure\nEntering Background\n";
unless(defined $notify){
  print "But notify is not defined\n";
  die "Notify undefined";
}
my $background = Posda::BackgroundProcess->new($invoc_id, $notify);
$background->ForkAndExit;
$background->WriteToEmail("Testing AnonymizerToEditor.pl\n");
my $rpt = $background->CreateReport("StructureDump");
my $dbg = MakeDebugPrinter($rpt);
my %EditsByDigest;
for my $s (keys %series){
  my $edits = $series{$s}->{edits};
  my $dig = tree_digest($edits);
  $EditsByDigest{$dig}->{edits} = $edits;
  $EditsByDigest{$dig}->{series}->{$s} = 1;
}
my @EditList;
for my $dig (keys %EditsByDigest){
  my $hash;
  $hash->{series} = [keys %{$EditsByDigest{$dig}->{series}}];
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
$rpt1->print("\"series_instance_uid\",\"operation\",\"tag\",\"value1\"," .
  "\"value2\"\n");
my @unmapped_list = keys %UidMapping;
my $current_mapping_index = 0;
for my $edit (@EditList){
  my $series = $edit->{series};
  my $edits = $edit->{edits};
  for my $ser (@$series){
    print_mapping($current_mapping_index, $rpt1);
    $current_mapping_index += 1;
    $rpt1->print("$ser,,,,,\n");
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
      return;
    }
  }
  print ",,";
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
