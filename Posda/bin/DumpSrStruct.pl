#!/usr/bin/perl -w 
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
use Cwd;
use Posda::Parser;
use Posda::Dataset;
use Posda::Try;
use Debug;
my $dbg = sub {print @_ };

my $usage = "Usage: $0 <file> [<len>] [<len>]";
unless ($#ARGV >= 0) {die $usage;}

my $dir = getcwd;
my $infile = $ARGV[0];
unless($infile =~ /^\//) {
	$infile = "$dir/$infile";
}
my $max_len1 = $ARGV[1];
my $max_len2 = $ARGV[2];
unless(defined $max_len1) {$max_len1 = 64}
unless(defined $max_len2) {$max_len2 = 300}

Posda::Dataset::InitDD();
my $dd = $Posda::Dataset::DD;

my($try)  = Posda::Try->new($infile);
unless(exists $try->{dataset}) { die "$infile is not DICOM file" }
my $ds = $try->{dataset};
my($sop_cl) = $ds->Get("(0008,0016)");
unless(defined $sop_cl) { die "$infile is not a DICOM SOP instance" }
my $sop_cl_name = $dd->GetSopClName($sop_cl);
print "Sop Class: $sop_cl_name\n";
unless($sop_cl_name =~ /SR Storage$/){
  die "Doesn't look like an SR type object";
}
my $container = $ds->Get("(0040,a040)");
unless($container eq "CONTAINER"){
  die "So sorry, I only know how to dump SR objects with Value type of CONTAINER\n" .
      "This one has a value type of \"$container\"\n";
}
my $doc_type = GetCodedValue($ds, "(0040,a043)");
print "Document type: $doc_type\n";
my $content = ParseContainer($ds, "(0040,a730)");
print "Content: ";
Debug::GenPrint($dbg, $content, 1);
print "\n";
#PrintContent($content, 1);
sub PrintContent{
  my($content, $indent) = @_;
  if(ref($content) eq "ARRAY"){
    for my $i (@$content){
      PrintContent($i, $indent);
    }
  } elsif(ref($content) eq "HASH"){
    for my $k (keys %$content){
      if($k eq "concept_mod"){
        PrintContent($content->{$k}, $indent);
      } elsif (ref($content->{$k})){
        print "  " x $indent . "$k:\n";
        PrintContent($content->{$k}, $indent + 1);
      } elsif(defined($content->{$k})) {
        print "  " x $indent . "$k: $content->{$k}\n";
      } else {
      }
    }
  } else {
    print "  " x $indent . "$content\n";
  }
}
sub ParseContainer{
  my($ds, $tag) = @_;
  my $subs = $ds->Search(${tag} . "[<0>](0040,a010)");
  my @Content;
  if(defined($subs) && ref($subs) eq "ARRAY" && $#$subs >= 0){
    for my $i (@$subs){
      my $item = $tag . "[$i->[0]]";
      my $rel_tag = "$item(0040,a010)";
      my $val_tag = "$item(0040,a040)";
      my $rel_type = $ds->Get($rel_tag);
      my $val_type = $ds->Get($val_tag);
      my $item_st = {};
      my $concept_name_tag = "$item(0040,a043)";
      my $concept_name = GetCodedValue($ds, $concept_name_tag);
      if($val_type eq "CODE"){
        my $concept_code = GetCodedValue($ds, $tag . "[$i->[0]](0040,a168)");
        if(defined($concept_name)){
          $item_st->{$concept_name} = $concept_code;
        }
        if($rel_type eq "HAS CONCEPT MOD"){
          my $concept_mod = ParseContainer($ds, "$item(0040,a730)");
          if(defined $concept_mod){
            $item_st->{concept_mod} = $concept_mod;
          }
        }
      } elsif($val_type eq "CONTAINER"){
        my $content = ParseContainer($ds, "$item(0040,a730)");
        $item_st->{$concept_name} = $content;
      } elsif($val_type eq "DATE"){
        my $concept_name_tag = "$item(0040,a043)";
        my $concept_name = GetCodedValue($ds, $concept_name_tag);
        my $concept = $ds->Get("$item(0040,a121)");
        if(defined($concept_name)){
          $item_st->{$concept_name} = $concept;
        }
      } elsif($val_type eq "DATETIME"){
        my $concept_name_tag = "$item(0040,a043)";
        my $concept_name = GetCodedValue($ds, $concept_name_tag);
        my $concept = $ds->Get("$item(0040,a120)");
        if(defined($concept_name)){
          $item_st->{$concept_name} = $concept;
        }
      } elsif($val_type eq "TEXT"){
        my $concept_name_tag = "$item(0040,a043)";
        my $concept_name = GetCodedValue($ds, $concept_name_tag);
        my $concept = $ds->Get("$item(0040,a160)");
        if(defined($concept_name)){
          $item_st->{$concept_name} = $concept;
        }
      } elsif($val_type eq "UIDREF"){
        my $concept_name_tag = "$item(0040,a043)";
        my $concept_name = GetCodedValue($ds, $concept_name_tag);
        my $concept = $ds->Get("$item(0040,a124)");
        if(defined($concept_name)){
          $item_st->{$concept_name} = $concept;
        }
      } elsif($val_type eq "IMAGE" || $val_type eq "COMPOSITE"){
        my $sop_class = $ds->Get("$item(0008,1199)[0](0008,1150)");
        my $sop_inst = $ds->Get("$item(0008,1199)[0](0008,1155)");
        my $segment = $ds->Get("$item(0008,1199)[0](0062,000b)");
        if(ref($segment) eq "ARRAY"  && $#{$segment} == 0){
          $segment = $segment->[0];
        }
        my $concept_name_tag = "$item(0040,a043)";
        my $concept_name = GetCodedValue($ds, $concept_name_tag);
        my $content = ParseContainer($ds, "$item(0040,a730)");
        my $image_name = "$val_type";
        if(defined($sop_class) && defined($sop_inst)){
          $image_name .= " ($sop_inst, $sop_class)";
        }
        if(defined $segment){
          $image_name .= " segment [$segment]";
        }
        if(defined $concept_name){
          if(defined $content){
            $item_st->{$concept_name} = [
              $image_name,
              $content
            ];
          } else {
            $item_st->{$concept_name} = $image_name;
          }
        } else {
          if(defined $content){
            $item_st->{$image_name} = $content;
          } else {
            $item_st = $image_name;
          }
        }
      } elsif($val_type eq "NUM"){
        my $concept_name_tag = "$item(0040,a043)";
        my $concept_name = GetCodedValue($ds, $concept_name_tag);
        my $content = GetMeasuredValueSequence($ds, "$item(0040,a300)[0]"); 
        $item_st->{$concept_name} = $content;
      } elsif($val_type eq "PNAME"){
        if($rel_type eq "HAS OBS CONTEXT"){
          my $concept_name_tag = "$item(0040,a043)";
          my $concept_name = GetCodedValue($ds, $concept_name_tag);
        }
        if(defined($concept_name)){
          my $concept = $ds->Get("$item(0040,a123)");
          $item_st->{$concept_name} = $concept;
        } else {
        }
      } else {
        $item_st->{rel_type}  = $rel_type;
        $item_st->{val_type}  = $val_type;
        my $content = ParseContainer($ds, "$item(0040,a730)");
        if(defined $content){
          $item_st->{content} = $content;
        }
      }
      push @Content, $item_st;
    }
  }
  if($#Content >= 0){ return \@Content }
  return undef;
};
sub GetMeasuredValueSequence{
  my($ds, $tag) = @_;
  my $value = $ds->Get("$tag(0040,a30a)");
  my $code = GetCodedValue($ds, "$tag(0040,08ea)");
  return ({units => $code, value => $value});
}
sub GetCodedValue{
  my($ds, $tag) = @_;
  my $c_value = $ds->Get($tag . "[0](0008,0100)");
  my $c_scheme = $ds->Get($tag . "[0](0008,0102)");
  my $c_desc = $ds->Get($tag . "[0](0008,0104)");
  if(defined $c_desc){
    return "$c_desc ($c_value of $c_scheme)";
  }
  return undef;
}
