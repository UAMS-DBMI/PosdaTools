#!/usr/bin/perl -w
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
my $xml_id_1 = "table_A-1";
my $fh;
my $struct_1; # Sop Class Registry

open $fh, "GetXmlById.pl \"$parsed_dir/$file_1\" \"$xml_id_1\" |" or
  die "can't open parsed xml structure";
eval { $struct_1 = fd_retrieve $fh };
if($@){ die "error in retrieve: $@" }
close $fh;
my $tab_1 = SemanticParse($struct_1);

my %SopCl;
RowsToDict(\%SopCl, $tab_1->{rows});
print "my \$SopCl = ";
Debug::GenPrint($dbg, \%SopCl, 1);
print ";\n";
sub RowsToDict{
  my($dict, $rows) = @_;
  for my $i (@$rows){
    my $sop_uid = $i->[0];
    my $desc = $i->[1];
    my $type = $i->[2];
    my $part = $i->[3];
    my $retired = 0;
    if($desc =~ /^(.*)\s*\(Retired\)\s*$/){
      $desc = $1;
      $retired = 1;
    }
    my $h = {
      sopcl_desc => $desc,
      type => $type,
    };
    if($retired) { $h->{retired} = 1 }
    if($part) { $h->{std_ref} = $part }
    $dict->{$sop_uid} = $h;
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
