#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/bin/test/GetDataDictFromXml.pl,v $
#$Date: 2014/07/10 16:40:44 $
#$Revision: 1.1 $
#
#Copyright 2014, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
use Storable qw( fd_retrieve );
use Debug;
my $dbg = sub {print @_};
my $parsed_dir = "/Users/bbennett/FileDistApp/ParsedDicom";
my $file_1 = "part06/part06.xml.perl";
my $xml_id_1 = "table_6-1";
my $xml_id_2 = "table_7-1";
my $xml_id_3 = "table_8-1";
my $file_2 = "part07/part07.xml.perl";
my $xml_id_4 = "table_E.1-1";
my $xml_id_5 = "table_E.2-1";
my $fh;
my $struct_1; # data dictionary
my $struct_2; # file meta elements (group 2)
my $struct_3; # directory structuring elements (group 4)
my $struct_4; # command elements (group 0)
my $struct_5; # retired command elements (also group 0)

open $fh, "GetXmlById.pl \"$parsed_dir/$file_1\" \"$xml_id_1\" |" or
  die "can't open parsed xml structure";
eval { $struct_1 = fd_retrieve $fh };
if($@){ die "error in retrieve: $@" }
close $fh;
my $tab_1 = SemanticParse($struct_1);

open $fh, "GetXmlById.pl \"$parsed_dir/$file_1\" \"$xml_id_2\" |" or
  die "can't open parsed xml structure";
eval { $struct_2 = fd_retrieve $fh };
if($@){ die "error in retrieve: $@" }
close $fh;
my $tab_2 = SemanticParse($struct_2);

open $fh, "GetXmlById.pl \"$parsed_dir/$file_1\" \"$xml_id_3\" |" or
  die "can't open parsed xml structure";
eval { $struct_3 = fd_retrieve $fh };
if($@){ die "error in retrieve: $@" }
close $fh;
my $tab_3 = SemanticParse($struct_3);

open $fh, "GetXmlById.pl \"$parsed_dir/$file_2\" \"$xml_id_4\" |" or
  die "can't open parsed xml structure";
eval { $struct_4 = fd_retrieve $fh };
if($@){ die "error in retrieve: $@" }
close $fh;
my $tab_4 = SemanticParse($struct_4);

open $fh, "GetXmlById.pl \"$parsed_dir/$file_2\" \"$xml_id_5\" |" or
  die "can't open parsed xml structure";
eval { $struct_5 = fd_retrieve $fh };
if($@){ die "error in retrieve: $@" }
close $fh;
my $tab_5 = SemanticParse($struct_5);

my %Dict;
RowsToDict(\%Dict, $tab_1->{rows}, "shows_ret");
RowsToDict(\%Dict, $tab_2->{rows}, "shows_ret");
RowsToDict(\%Dict, $tab_3->{rows}, "shows_ret");
RowsToDict(\%Dict, $tab_4->{rows}, "description");
RowsToDict(\%Dict, $tab_5->{rows}, "is_ret");
print "\$Dict = ";
Debug::GenPrint($dbg, \%Dict, 1);
print ";\n";
exit;
#for my $i (@{$tab->{rows}}){
#  print $i->[0];
#  for my $j (1, 3, 4, 5){
#    my $f = $i->[$j];
#    $f =~ s/\s*$//;
#    print "|$f"
#  }
#  print "\n";
#}
sub RowsToDict{
  my($dict, $rows, $ret_control) = @_;
  for my $i (@$rows){
    my $sig = $i->[0];
    unless($sig =~ /^\((....),(....)\)$/){
      next;
    }
    my $g_hex = $1;
    my $e_hex = $2;
    unless($g_hex =~ /^[0-9a-fA-F]+$/) {
      next;
    }
    unless($e_hex =~ /^[0-9a-fA-F]+$/) {
      next;
    }
    my $g = hex($g_hex);
    my $e = hex($e_hex);
    $g_hex =~ tr/A-F/a-f/;
    $e_hex =~ tr/A-F/a-f/;
    my $name = $i->[1];
    my $kw = $i->[2];
    my $vr = $i->[3];
    if($vr =~ /or/){ $vr = "OT" }
    my $vm = $i->[4];
    my $h = {
      VM => $vm,
      VR => $vr,
      ele => $e_hex,
      group => $g_hex,
      Name => $name,
      KeyWord => $kw,
    };
    if($ret_control eq 'description'){
      $h->{description} = $i->[5];
    } elsif($ret_control eq 'is_ret'){
      $h->{RET} = 1;
    } elsif($ret_control eq 'shows_ret'){
      if($i->[5]){
        if($i->[5] eq 'RET'){
          $h->{RET} = 1;
        } else {
          $h->{comment} = $i->[5];
        }
      }
    }
    $dict->{$g}->{$e} = $h;
  }
}
sub SemanticParse{
  my($struct) = @_;
    if($struct->{el} eq "table"){
    my $result = {
      rows => [],
    };
    item:
    for my $i (0 .. $#{$struct->{content}}){
      my $c = $struct->{content}->[$i];
      unless(ref($c)){ next item }
      if($c->{el} eq "caption") {
        $result->{caption} = GetText($c);
      } elsif(
#        $c->{el} eq "thead" ||
        $c->{el} eq "tbody"
      ) {
        sub_item:
        for my $j (@{$c->{content}}){
          unless(ref($j)) { next sub_item }
          my $row = SemanticParse($j);
          push @{$result->{rows}}, $row;
        }
      }
    }
    return $result;
  } elsif($struct->{el} eq "tr"){
    my @result;
    tr_item:
    for my $i (@{$struct->{content}}){
      unless(ref($i)) { next tr_item }
      if($i->{el} eq "td" || $i->{el} eq "th"){
        my $txt = SemanticParse($i);
        push(@result, $txt);
      }
    }
    return \@result;
  } elsif(
    $struct->{el} eq "td" ||
    $struct->{el} eq "th"
  ){
    my $txt = GetText($struct);
    $txt =~ s/^\s*//g;
    $txt =~ s/\s*$//g;
    utf8::decode($txt);
    $txt =~ s/\N{ZERO WIDTH SPACE}//g;
    utf8::encode($txt);
    return $txt;
  }
}
sub GetText{
  my($xml) = @_;
  my $ref_desc = ref($xml);
  unless($ref_desc){ return $xml }
  if($ref_desc){
    my $text = "";
    for my $i (@{$xml->{content}}){
      $text .= GetText($i);
    }
    return $text;
  }
  die "malformed xml: ($xml)";
}
