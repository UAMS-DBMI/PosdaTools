#!/usr/bin/perl -w
#
#Copyright 2013, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
use Posda::DB::PosdaFilesQueries;
use Posda::DataDict;
my $dd = Posda::DataDict->new;
use Debug;
my $dbg = sub { print STDERR @_ };
my $help = <<EOF;
Usage: 
  ReconcileTagNames.pl
or
  ReconcileTagNames.pl -h
EOF
die "Don't use this script\n";

if($#ARGV >= 0 && ($ARGV[0] eq "-h")){
  print $help;
  exit;
}

my $ptdh = PosdaDB::Queries->GetQueryInstance(
  "GetPrivateTagFeaturesBySignature");
sub get_private_info{ my($tag) = @_;
  my($name,$vr);
  $ptdh->RunQuery(
    sub {
      my($row) = @_;
      $name = $row->[0];
      $vr = $row->[1];
    }, sub {
    },
    $tag
  );
  unless(defined $name) { $name = "Unknown" }
  unless(defined $vr) { $vr = "UN" }
  return ($name, $vr);
}
my $tdh = PosdaDB::Queries->GetQueryInstance(
  "GetPublicTagNameAndVrBySignature");
sub get_public_info{
  my($tag) = @_;
  my($name, $vr);
  $tdh->RunQuery(
     sub{
       my($row) = @_;
       $name = $row->[0];
       $vr = $row->[1];
     },
     sub {
     },
     $tag
  );
  unless(defined $name) { 
    if($tag =~ /^\(([56].)..,([^\"]...)/){
      my $new_tag = "($1xx,$2)";
      $tdh->RunQuery(
         sub{
           my($row) = @_;
           $name = $row->[0];
           $vr = $row->[1];
         },
         sub {
         },
         $new_tag
      );
    }
    unless(defined $name){
      $name = "<undef>";
    }
  }
  unless(defined $vr) { $vr = "<undef>" }
  return ($name, $vr);
}
sub GetVrNameChain{
  my($sig) = @_;
  my @sig_comp = split /\[<\d+>\]/, $sig;
  my $final_vr = "";
  my $final_name = "";
  for my $i (0 .. $#sig_comp){
    my($dd_name, $dd_vr);
    my $si = $sig_comp[$i];
    my($name, $vr);
    if($si =~ /,\"/){
      ($name, $vr) = get_private_info($si);
    } else {
      ($name, $vr) = get_public_info($si);
    }
    $final_name .= $name;
    $final_vr .= $vr;
    unless($i == $#sig_comp){
      $final_name .= ":";
      $final_vr .= ":";
    }
  }
  return $final_name, $final_vr;
}
my %ElementsInPosdaPhi;
my $g_pphi_el_info = PosdaDB::Queries->GetQueryInstance(
  "GetPosdaPhiElementSigInfo");
$g_pphi_el_info->RunQuery(sub {
  my($row) = @_;
  $ElementsInPosdaPhi{$row->[0]}->{$row->[1]} = {
    is_private => $row->[2],
    private_disposition => $row->[3],
    name_chain => $row->[4],
  };
},
sub {
});
my %ElementsInPosdaPhiSimple;
my $g_pphisimp_el_info = PosdaDB::Queries->GetQueryInstance(
  "GetPosdaPhiSimpleElementSigInfo");
$g_pphisimp_el_info->RunQuery(sub {
  my($row) = @_;
  $ElementsInPosdaPhiSimple{$row->[0]}->{$row->[1]} = {
    is_private => $row->[2],
    private_disposition => $row->[3],
    name_chain => $row->[4],
  };
},
sub {
});
my %OnlyInPhi;
for my $sig (keys %ElementsInPosdaPhi){
  for my $vr (keys %{$ElementsInPosdaPhi{$sig}}){
    unless(exists $ElementsInPosdaPhiSimple{$sig}->{$vr}){
     $OnlyInPhi{$sig}->{$vr} = $ElementsInPosdaPhi{$sig}->{$vr};
    }
  }
}
my %OnlyInPhiSimple;
for my $sig (keys %ElementsInPosdaPhiSimple){
  for my $vr (keys %{$ElementsInPosdaPhiSimple{$sig}}){
    unless(exists $ElementsInPosdaPhi{$sig}->{$vr}){
     $OnlyInPhiSimple{$sig}->{$vr} = $ElementsInPosdaPhiSimple{$sig}->{$vr};
    }
  }
}
my $upd_phi_ele =  PosdaDB::Queries->GetQueryInstance(
  "UpdPosdaPhiEleName");
for my $sig (keys %ElementsInPosdaPhi){
  for my $vr (keys %{$ElementsInPosdaPhi{$sig}}){
    my($name, $vrc) = GetVrNameChain($sig);
    my $db_name = $ElementsInPosdaPhi{$sig}->{$vr}->{name_chain};
    unless(defined $db_name) {
      $db_name = $name;
      $upd_phi_ele->RunQuery(sub {}, sub {}, $name, $sig, $vr);
    }
    unless($name eq $db_name){
      print "$sig has mismatching name: $db_name vs $name\n";
    }
    my $final_vr = $vrc;
    if($vrc =~ /:(..)$/){
      $final_vr = $1;
    }
    unless($vr eq $final_vr){
      if(exists $ElementsInPosdaPhi{$sig}->{$final_vr}){
      } else {
        print "$sig has seen vr mismatch ($vr vs $final_vr)\n";
      }
    }
  }
}
my $upd_phi_simp_ele =  PosdaDB::Queries->GetQueryInstance(
  "UpdPosdaPhiSimpleEleName");
for my $sig (keys %ElementsInPosdaPhiSimple){
  my $is_private = "false";
  if($sig =~ /,\"/) { $is_private = "true" }
  for my $vr (keys %{$ElementsInPosdaPhiSimple{$sig}}){
    my($name, $vrc) = GetVrNameChain($sig);
    my $db_name = $ElementsInPosdaPhiSimple{$sig}->{$vr}->{name_chain};
    unless(defined $db_name){
      $db_name = $name;
      $upd_phi_simp_ele->RunQuery(
        sub {}, sub {}, $name, $is_private, $sig, $vr);
    }
    unless($name eq $db_name){
      print "$sig has mismatching simple name: $db_name vs $name\n";
    }
    my $final_vr = $vrc;
    if($vrc =~ /:(..)$/){
      $final_vr = $1;
    }
    unless($vr eq $final_vr){
      if(exists $ElementsInPosdaPhiSimple{$sig}->{$final_vr}){
      } else {
        print "$sig has simple seen vr mismatch ($vr vs $final_vr)\n";
      }
    }
  }
}
my $upd_phi_simp_disp =  PosdaDB::Queries->GetQueryInstance(
  "UpdPosdaPhiSimplePrivDisp");
for my $sig (keys %ElementsInPosdaPhiSimple){
  for my $vr (keys %{$ElementsInPosdaPhiSimple{$sig}}){
    if($ElementsInPosdaPhi{$sig}->{$vr}->{private_disposition}){
      $upd_phi_simp_disp->RunQuery(sub{}, sub{}, 
        $ElementsInPosdaPhi{$sig}->{$vr}->{private_disposition},
        $sig,
        $vr
      );
    }
  }
}
my $add_ele_phi_simp = PosdaDB::Queries->GetQueryInstance(
  "AddPhiSimpleElement");
for my $sig (keys %OnlyInPhi){
  for my $vr (keys %{$OnlyInPhi{$sig}}){
    print "Only in posda_phi (not posda_phi_simple): $sig, $vr\n";
    $add_ele_phi_simp->RunQuery(sub{},sub{},
      $sig,
      $vr,
      $OnlyInPhi{$sig}->{$vr}->{is_private},
      $OnlyInPhi{$sig}->{$vr}->{private_disposition},
      $OnlyInPhi{$sig}->{$vr}->{name_chain},
    );
  }
}
my $add_ele_phi = PosdaDB::Queries->GetQueryInstance(
  "AddPhiElement");
for my $sig (keys %OnlyInPhiSimple){
  for my $vr (keys %{$OnlyInPhiSimple{$sig}}){
    print "Only in posda_phi_simple (not posda_phi): $sig, $vr\n";
    $add_ele_phi->RunQuery(sub{},sub{},
      $sig,
      $vr,
      $OnlyInPhiSimple{$sig}->{$vr}->{is_private},
      $OnlyInPhiSimple{$sig}->{$vr}->{private_disposition},
      $OnlyInPhiSimple{$sig}->{$vr}->{name_chain},
    );
  }
}
