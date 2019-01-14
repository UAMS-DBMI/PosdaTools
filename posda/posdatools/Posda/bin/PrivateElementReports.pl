#!/usr/bin/perl -w
#
#Copyright 2013, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
use Posda::DB 'Query';
use Posda::DataDict;
use Posda::GetElementNameChain;
use Posda::BackgroundProcess;
my $dd = Posda::DataDict->new;
use Debug;
my $dbg = sub { print STDERR @_ };
my $usage = <<EOF;
Usage: 
  PrivateElementReports.pl <?bkgrnd_id?> <notify>
or
  PrivateElementReports.pl -h

First runs UpdatePrivateElementNames.pl to update
   name_chain, and
   is_private
in posda_phi_simple database table
   element_seen

Then generates some reports on private tags:
  Private Tags seen with non-canonical VR
  Private Tags Sigs with different dispositions due to VR
  Distinct values for Private tags with null disposition
  Distinct values for Private tags with disposition d
  Distinct values for Private tags with disposition k
  Distinct values for Private tags with disposition o
  Distinct values for Private tags with disposition oi
  Distinct values for Private tags with disposition h
  Distinct values for Private tags with disposition na
EOF

if($#ARGV >= 0 && ($ARGV[0] eq "-h")){
  print $usage;
  exit;
}
unless($#ARGV == 1) { die $usage }
my ($invoc_id, $notify) = @ARGV;
my $back = Posda::BackgroundProcess->new($invoc_id, $notify);
print "Going to background\n";
$back->Daemonize();
my $start_back1 = time;
my $all_seen = Query('AllSeenValuesByElementVr');

my %CanonicalVr;
my %ElementsInPosdaPhiSimple;
Query("GetPosdaPhiSimplePrivateElements")->RunQuery(sub {
  my($row) = @_;
  my($element_seen_id, $element_sig_pattern,
    $vr, $is_private, $private_disposition, $tag_name) =
    @$row;
  $ElementsInPosdaPhiSimple{$element_sig_pattern}->{$vr} = {
    is_private => $is_private,
    private_disposition => $private_disposition,
    name_chain => $tag_name,
    element_seen_id => $element_seen_id 
  };
},
sub {
});
my $num_eles = keys %ElementsInPosdaPhiSimple;
for my $sig (keys %ElementsInPosdaPhiSimple){
  for my $vr (keys %{$ElementsInPosdaPhiSimple{$sig}}){
    my($name_chain, $canon_vr) = Posda::GetElementNameChain::GetVrNameChain($sig);
    if($canon_vr =~ /:(..)$/){ $canon_vr = $1 }
    $CanonicalVr{$sig} = $canon_vr;
  }
}
my $gather_elapsed = time - $start_back1;
$back->WriteToEmail("$gather_elapsed seconds gathering basic info\n");
$back->WriteToEmail("$num_eles element_sig_patterns found\n");
my $start_non_canon = time;
##########################################################
# Private tags seen with non-canonical VR
my %tags_with_non_canon;
my $rpt = $back->CreateReport("Private Tags With Noncanonical Vr");
$rpt->print("element_sig_value,canon_vr,vrs_seen\r\n");
my %ElesWithNonCanonVr;
for my $ele(keys %ElementsInPosdaPhiSimple){
  my @vrs = keys %{$ElementsInPosdaPhiSimple{$ele}};
  my $num_vrs = @vrs;
#  $back->WriteToEmail("$ele has $num_vrs vrs\n");
  my $canon_vr = $CanonicalVr{$ele};
  if($#vrs > 0 || $canon_vr ne $vrs[0]){
    $tags_with_non_canon{$ele} = {
      canon => $canon_vr,
      vrs => \@vrs,
    };
  }
}
for my $tag (keys %tags_with_non_canon){
  my $ele = $tag;
  $ele =~ s/"/""/g;
  $rpt->print("\"$ele\",$tags_with_non_canon{$tag}->{canon},\"");
  my $vr_l = $tags_with_non_canon{$tag}->{vrs};
  for my $i (0 .. $#$vr_l){
    $rpt->print("$vr_l->[$i]");
    if($i == $#$vr_l){
      $rpt->print("\"\r\n");
    }else {
      $rpt->print(", ");
    }
  }
}
my $elapsed = time - $start_non_canon;
$back->WriteToEmail("$elapsed seconds to generate report\n");
##########################################################
# Private Tags Sigs with different dispositions due to VR
my %TagsByDispVr;
my %tag_name_by_tag;
for my $tag (keys %ElementsInPosdaPhiSimple){
  for my $vr (keys %{$ElementsInPosdaPhiSimple{$tag}}){
    my $tag_name = $ElementsInPosdaPhiSimple{$tag}->{$vr}->{name_chain};
    $tag_name_by_tag{$tag}->{$tag_name} = 1;
    my $info = $ElementsInPosdaPhiSimple{$tag}->{$vr};
    unless(defined $vr) { $vr = "<undef>" }
    my $disp = $info->{private_disposition};
    unless(defined $disp) { $disp = "<undef>" }
    if($vr eq "") { $vr = "<blank>" }
    $TagsByDispVr{$tag}->{$disp}->{$vr} = 1;
  }
}
my $rpt1 = $back->CreateReport("Private Tag Sigs with different dispositions due to VR");
$rpt1->print("tag,tag_name,vr_disp\r\n");
tag:
for my $tag (sort keys %TagsByDispVr){
  my $ele = $tag;
  $ele =~ s/"/""/g;
  my @disps = keys $TagsByDispVr{$tag};
  my $num_disps = @disps;
  if($num_disps < 2){ next tag }
  my $tag_name = [ keys %{$tag_name_by_tag{$tag}} ]->[0];
  $rpt1->print("\"$ele\",$tag_name,\"");
  my $str = "";
  for my $i (0 .. $#disps){
    my $disp = $disps[$i];
    my @vrs = keys %{$TagsByDispVr{$tag}->{$disp}};
    for my $j (0 .. $#vrs){
      my $vr = $vrs[$j];
      $str .= "$vr => $disp";
      if($j == $#vrs){
        if($i < $#disps){
          $str .= ", ";
        }
      } else {
        $str .= ", ";
      }
    }
  }
  $rpt1->print("$str\"\r\n");
}
$back->WriteToEmail("finished second report\n");
$back->Finish;

$back = Posda::BackgroundProcess->new($invoc_id, $notify);
$back->Daemonize;

my $start_value_gathering = time;
$back->WriteToEmail("In second process\n");
##########################################################
# Gather infomation on values seen for each tag
my $eles_gathered = 0;
my $report_inc = 10;
my $report_count = $report_inc;
my $get_v = Query("AllSeenValuesByElementVr");
for my $tag (keys %ElementsInPosdaPhiSimple){
  for my $vr (keys %{$ElementsInPosdaPhiSimple{$tag}}){
    my @first_ten;
    my @last_ten;
    my $more = 0;
    $get_v->RunQuery(sub {
      my($row) = @_;
      my $value = $row->[0];
      if($#first_ten < 9) {
        push @first_ten, $value;
        return;
      }
      push @last_ten, $value;
      if($#last_ten < 9){
        return;
      }
      $more = 1;
      shift(@last_ten);
    }, sub {}, $tag, $vr);
    if($more){ push @first_ten, "..." }
    for my $i (@last_ten){
      push(@first_ten, $i);
    }
    $ElementsInPosdaPhiSimple{$tag}->{$vr}->{values} =
       \@first_ten;
  }
  $eles_gathered += 1;
  $report_count -= 1;
  if($report_count <= 0){
    $report_count = $report_inc;
    my $elapsed = time - $start_value_gathering;
    print STDERR "#######################################\n";
    print STDERR "Values for $eles_gathered elements in $elapsed seconds\n";
    print STDERR "#######################################\n";
  }
}
$elapsed = time - $start_value_gathering;
$back->WriteToEmail("$elapsed seconds gather values for tags\n");
##########################################################
# Generate
#  Distinct values for Private tags with null disposition
#  Distinct values for Private tags with disposition d
#  Distinct values for Private tags with disposition k
#  Distinct values for Private tags with disposition o
#  Distinct values for Private tags with disposition oi
#  Distinct values for Private tags with disposition h
#  Distinct values for Private tags with disposition na
my $rpt3 = $back->CreateReport("Distinct values for Private " .
  "tags with null disposition");
$rpt3->print("Distinct values for Private " .
  "tags with null disposition\r\n");
$rpt3->print("id,tag,vr,tag_name,disp,values\r\n");

my $rpt4 = $back->CreateReport("Distinct values for Private " .
  "tags with disposition d");
$rpt4->print("Distinct values for Private " .
  "tags with disposition d\r\n");
$rpt4->print("id,tag,vr,tag_name,disp,values\r\n");

my $rpt5 = $back->CreateReport("Distinct values for Private " .
  "tags with disposition k");
$rpt5->print("Distinct values for Private " .
  "tags with disposition k\r\n");
$rpt5->print("id,tag,vr,tag_name,disp,values\r\n");

my $rpt6 = $back->CreateReport("Distinct values for Private " .
  "tags with disposition o");
$rpt6->print("Distinct values for Private " .
  "tags with disposition o\r\n");
$rpt6->print("id,tag,vr,tag_name,disp,values\r\n");

my $rpt7 = $back->CreateReport("Distinct values for Private " .
  "tags with disposition oi");
$rpt7->print("Distinct values for Private " .
  "tags with disposition oi\r\n");
$rpt7->print("id,tag,vr,tag_name,disp,values\r\n");

my $rpt8 = $back->CreateReport("Distinct values for Private " .
  "tags with disposition h");
$rpt8->print("Distinct values for Private " .
  "tags with disposition h\r\n");
$rpt8->print("id,tag,vr,tag_name,disp,values\r\n");

my $rpt9 = $back->CreateReport("Distinct values for Private " .
  "tags with disposition h");
$rpt9->print("Distinct values for Private " .
  "tags with disposition na\r\n");
$rpt9->print("id,tag,vr,tag_name,disp,values\r\n");

for my $ele (sort keys %ElementsInPosdaPhiSimple){
  my $tag = $ele;
  $tag =~ s/"/""/g;
  for my $vr (keys %{$ElementsInPosdaPhiSimple{$ele}}){
    my $info = $ElementsInPosdaPhiSimple{$ele}->{$vr};
    my $tag_name = $info->{name_chain};
    if(!defined $info->{private_disposition}){
      $rpt3->print("$info->{element_seen_id},\"$tag\",$vr," .
        "\"$tag_name\",<undef>,\"");
      my @values = @{$info->{values}};
      for my $i (0 .. $#values){
        my $v = $values[$i];
        $v =~ s/"/""/g;
        $rpt3->print($v);
        unless($i == $#values){ $rpt3->print("\n") }
      }
      $rpt3->print("\"\r\n");
    } elsif($info->{private_disposition} eq 'd'){
      $rpt4->print("$info->{element_seen_id},\"$tag\",$vr," .
        "\"$tag_name\",d,\"");
      my @values = @{$info->{values}};
      for my $i (0 .. $#values){
        my $v = $values[$i];
        $v =~ s/"/""/g;
        $rpt4->print($v);
        unless($i == $#values){ $rpt4->print("\n") }
      }
      $rpt4->print("\"\r\n");
    } elsif($info->{private_disposition} eq 'k'){
      $rpt5->print("$info->{element_seen_id},\"$tag\",$vr," .
        "\"$tag_name\",k,\"");
      my @values = @{$info->{values}};
      for my $i (0 .. $#values){
        my $v = $values[$i];
        $v =~ s/"/""/g;
        $rpt5->print($v);
        unless($i == $#values){ $rpt5->print("\n") }
      }
      $rpt5->print("\"\r\n");
    } elsif($info->{private_disposition} eq 'o'){
      $rpt6->print("$info->{element_seen_id},\"$tag\",$vr," .
        "\"$tag_name\",o,\"");
      my @values = @{$info->{values}};
      for my $i (0 .. $#values){
        my $v = $values[$i];
        $v =~ s/"/""/g;
        $rpt6->print($v);
        unless($i == $#values){ $rpt6->print("\n") }
      }
      $rpt6->print("\"\r\n");
    } elsif($info->{private_disposition} eq 'oi'){
      $rpt7->print("$info->{element_seen_id},\"$tag\",$vr," .
        "\"$tag_name\",oi,\"");
      my @values = @{$info->{values}};
      for my $i (0 .. $#values){
        my $v = $values[$i];
        $v =~ s/"/""/g;
        $rpt7->print($v);
        unless($i == $#values){ $rpt7->print("\n") }
      }
      $rpt7->print("\"\r\n");
    } elsif($info->{private_disposition} eq 'h'){
      $rpt8->print("$info->{element_seen_id},\"$tag\",$vr," .
        "\"$tag_name\",h,\"");
      my @values = @{$info->{values}};
      for my $i (0 .. $#values){
        my $v = $values[$i];
        $v =~ s/"/""/g;
        $rpt8->print($v);
        unless($i == $#values){ $rpt8->print("\n") }
      }
      $rpt8->print("\"\r\n");
    } elsif($info->{private_disposition} eq 'na'){
      $rpt9->print("$info->{element_seen_id},\"$tag\",$vr," .
        "\"$tag_name\",na,\"");
      my @values = @{$info->{values}};
      for my $i (0 .. $#values){
        my $v = $values[$i];
        $v =~ s/"/""/g;
        $rpt9->print($v);
        unless($i == $#values){ $rpt9->print("\n") }
      }
      $rpt9->print("\"\r\n");
    }
  }
}
##########################################################
$back->Finish;
