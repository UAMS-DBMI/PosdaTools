#!/usr/bin/perl -w
use strict;
use Posda::DB "Query";
use Posda::DataDict;
use Posda::BackgroundProcess;
use Debug;
my $dbg = sub {print @_};

my $dd = Posda::DataDict->new();
my $OldPosdaPrivDd = $dd->{PvtDict};
my $PosdaPrivKb;

my $usage = <<EOF;
CompareNewPrivateTagDbToOld.pl <?bkgrnd_id?> <activity_id> <notify>
EOF

if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print "$usage\n";
  exit;
}
unless($#ARGV == 2){
  die $usage;
}
my($invoc_id, $activity_id, $notify) = @ARGV;
print "Going to background\n";
my $back = Posda::BackgroundProcess->new($invoc_id, $notify, $activity_id);
$back->Daemonize;

Query("GetPrivateKb")->RunQuery(sub {
  my($row) = @_;
  my($sig, $owned_by, $grp,
    $ele, $vr, $vm, $name) = @$row;
  $PosdaPrivKb->{$owned_by}->{$grp}->{$ele} = {
     VR => $vr,
     VM => $vm,
     Name => $name,
     ele => sprintf("%02x", $ele),
     group => sprintf("%04x", $grp)
  };
}, sub{});
  
sub BuildBySig{
  my($by_sig, $source, $name) = @_;
  for my $own (keys %$source){
    for my $grp (keys %{$source->{$own}}){
      for my $ele (keys %{$source->{$own}->{$grp}}){
        my $sig = sprintf("(%04x,\"%s\",%02x)", $grp, $own, $ele);
        $by_sig->{$sig} = $source->{$own}->{$grp}->{$ele};
      }
    }
  }
}
sub CompareNewToOld{
  my($new, $old) = @_;
  my %keys_in_new;
  for my $i (keys %$new){
    $keys_in_new{$i} = 1;
  }
  my %keys_in_old;
  for my $i (keys %$old){
    $keys_in_old{$i} = 1;
  }
  my $num_new_keys = keys %keys_in_new;
  my $num_old_keys = keys %keys_in_old;
  if($num_old_keys != $num_new_keys) {
    return 0;
  }
  for my $i (keys %keys_in_old){
    unless(exists $keys_in_new{$i}){
      return 0;
    }
    unless($old->{$i} eq $new->{$i}){
      return 0;
    }
  }
  return 1;
}
my $OldBySig = {};
my $NewBySig = {};
my $DiffNewOld = {};
my $SameNewOld = {};
BuildBySig($OldBySig, $OldPosdaPrivDd, "Old");
BuildBySig($NewBySig, $PosdaPrivKb, "New");

my $OnlyInOld = {};
for my $i (sort keys %$OldBySig){
  if(exists $NewBySig->{$i}){
    if(
      CompareNewToOld($NewBySig->{$i}, $OldBySig->{$i})
    ){
      $SameNewOld->{$i} = $NewBySig->{$i};
    } else {
      $DiffNewOld->{$i}->{new} = $NewBySig->{$i};
      $DiffNewOld->{$i}->{old} = $OldBySig->{$i};
    }
  } else {
    $OnlyInOld->{$i} = $OldBySig->{$i};
  }
}

my $OnlyInNew = {};
for my $i (keys %$NewBySig){
  unless(exists $OldBySig->{$i}){
    $OnlyInNew->{$i} = $NewBySig->{$i};
  }
}

my $num_diffs = keys %$DiffNewOld;
my $num_only_in_old = keys %$OnlyInOld;
my $num_only_in_new = keys %$OnlyInNew;
my $num_same_in_both = keys %$SameNewOld;
$back->WriteToEmail("$num_diffs are in both old and new, but different\n");
$back->WriteToEmail( "$num_only_in_old are only in old\n");
$back->WriteToEmail( "$num_only_in_new are only in new\n");
$back->WriteToEmail( "$num_same_in_both are in both old and new and identical\n");

if($num_diffs > 0){
  my $rpt1 = $back->CreateReport("Different In Posda DataDict and Private Tag KB");
  $rpt1->print("signature,differences\n");
  for my $i (sort keys %$DiffNewOld){
    my $sig = $i;
    $sig =~ s/"/""/g;
    $rpt1->print("\"$sig\",");
    my $diffs = "";
    for my $j (sort keys %{$DiffNewOld->{$i}->{old}}){
      if($DiffNewOld->{$i}->{new}->{$j} ne $DiffNewOld->{$i}->{old}->{$j}){
        $diffs .=  "$j: \"$DiffNewOld->{$i}->{old}->{$j}\" => " .
          "\"$DiffNewOld->{$i}->{new}->{$j}\";";
      }
    }
    $diffs =~ s/"/""/g;
    $rpt1->print("\"$diffs\"\n");
  }
}

if($num_only_in_old > 0){
  my $rpt2 = $back->CreateReport("In Posda DataDict and not in Private Tag KB");
  $rpt2->print("signature,VR, VM, Name\n");
  for my $i (sort keys %$OnlyInOld){
    my $sig = $i;
    $sig =~ s/"/""/g;
    $rpt2->print("\"$sig\",");
    $rpt2->print("$OnlyInOld->{$i}->{VR},$OnlyInOld->{$i}->{VM},\"$OnlyInOld->{$i}->{Name}\"\n");
  }
}
if($num_only_in_new > 0){
  my $rpt3 = $back->CreateReport("In Private Tag Kb and not in Posda DataDict");
  $rpt3->print("signature,VR, VM, Name\n");
  for my $i (sort keys %$OnlyInNew){
    my $sig = $i;
    $sig =~ s/"/""/g;
    $rpt3->print("\"$sig\",");
    $rpt3->print("$OnlyInNew->{$i}->{VR},$OnlyInNew->{$i}->{VM},\"$OnlyInNew->{$i}->{Name}\"\n");
  }
}
if($num_same_in_both > 0){
  my $rpt4 = $back->CreateReport("In both Private Tag Kb and Posda DataDict");
  $rpt4->print("signature,VR, VM, Name\n");
  for my $i (sort keys %$SameNewOld){
    my $sig = $i;
    $sig =~ s/"/""/g;
    $rpt4->print("\"$sig\",");
    $rpt4->print("$SameNewOld->{$i}->{VR},$SameNewOld->{$i}->{VM},\"$SameNewOld->{$i}->{Name}\"\n");
  }
}
$back->Finish("Done");
