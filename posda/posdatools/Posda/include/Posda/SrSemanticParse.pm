#!/usr/bin/perl -w
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
use Posda::Parser;
use Posda::Dataset;
use Posda::Try;
use Debug;

package Posda::SrSemanticParse;

sub new{
  my($class, $infile) = @_;
  my($try)  = Posda::Try->new($infile);
  unless(exists $try->{dataset}) { die "$infile is not DICOM file" }
  my $this = {};
  $this->{ds} = $try->{dataset};
  my $sop_cl  = $this->{ds}->Get("(0008,0016)");
  unless(defined $sop_cl) { die "$infile is not a DICOM SOP instance" }
  my $dd = $Posda::Dataset::DD;
  my $sop_cl_name = $dd->GetSopClName($sop_cl);
  print "Sop Class: $sop_cl_name\n";
  unless($sop_cl_name =~ /SR Storage$/){
    die "Doesn't look like an SR type object";
  }
  $this->{container} = $this->{ds}->Get("(0040,a040)");
  unless($this->{container} eq "CONTAINER"){
    die "So sorry, I only know how to Semanticaly Parse SR's with Value type of CONTAINER\n" .
        "This one has a value type of \"$this->{container}\"\n";
  }
  bless $this, $class;
  my $doc_type = $this->GetCodedValue("(0040,a043)");
  print "Document type: $doc_type\n";
  $this->{content} = $this->ParseContainer("(0040,a730)");
  return $this;
}

sub PrintContent{
  my($this, $printer) = @_;
  $this->RecurPrintContent($printer, $this->{content}, 0);
}

sub RecurPrintContent{
  my($this, $printer, $content, $indent) = @_;
  if(ref($content) eq "ARRAY"){
    for my $i (@$content){
      $this->RecurPrintContent($printer, $i, $indent);
    }
  } elsif(ref($content) eq "HASH"){
    my $line;
    if($content->{rel_type} eq "HAS ACQ CONTEXT"){
      $line .= "(Acq context) ";
    } elsif($content->{rel_type} eq "HAS CONCEPT MOD"){
      $line .= "(modifier) ";
    } elsif($content->{rel_type} eq "HAS OBS CONTEXT"){
      $line .= "(observation) ";
    } elsif($content->{rel_type} eq "HAS PROPERTIES"){
      $line .= "(property) ";
    } elsif($content->{rel_type} eq "INFERRED FROM"){
      $line .= "(inference) ";
    } elsif($content->{rel_type} eq "SELECTED FROM"){
      $line .= "(selection) ";
    } elsif($content->{rel_type} eq "CONTAINS"){
      $line .= "(content) ";
    }
    if(exists $content->{name}){
      $line .= "$content->{name}:";
      if(exists $content->{value}){
        $line .= " $content->{value}";
      } elsif($content->{rel_type} eq "CONTAINS" && $content->{val_type} eq "IMAGE"){
        $line .= " $content->{image_ref}";
      }
    } elsif (exists $content->{image_ref}){
      $line .= "$content->{image_ref}:";
      if(exists $content->{value}){
        $line .= " $content->{value}";
      }
    }
    &{$printer}("  " x $indent . "$line\n");
    if(defined $content->{content}){
      for my $i (0 .. $#{$content->{content}}){
        $this->RecurPrintContent($printer, $content->{content}->[$i], $indent+1);
      }
    }
  } else {
    &{$printer}("  " x $indent . "couldn't parse $content->{path}\n");
  }
}

sub DumpContent{
  my($this, $printer) = @_;
  &{$printer}("Content: ");
  Debug::GenPrint($printer, $this->{content}, 1);
  &{$printer}("\n");
}

sub ParseContainer{
  my($this, $tag, $path) = @_;
  my $ds = $this->{ds};
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
      $item_st->{path} = $item;
      my $concept_name_tag = "$item(0040,a043)";
      my $concept_name = $this->GetCodedValue($concept_name_tag);
my $has_concept_name = "no";
if(defined $concept_name) { $has_concept_name = "yes" }
my $ctnt = $ds->Get("$item(0040,a730)");
my $has_content = "no";
if(defined $ctnt){$has_content = "yes"};
my $has_image_ref = "no";
my $img_ref = $ds->Get("$item(0008,1199)");
if(defined $img_ref){ $has_image_ref = "yes" }
#print "$rel_type\n";
#print "Val type: $val_type, Rel type: $rel_type, " .
#  "has_concept_name: $has_concept_name, has_content: $has_content, has_image_ref: $has_image_ref\n";
      if(defined $concept_name){
        $item_st->{name} = $concept_name;
      }
      if(defined $img_ref){
        $item_st->{image_ref} = $this->GetImageReference("$item(0008,1199)");
        $item_st->{final_tag} = '(0008,1199)[0](0008,1150)';
      }
      $item_st->{val_type} = $val_type;
      $item_st->{rel_type} = $rel_type;
      if($val_type eq "CODE"){
        my $concept_code = $this->GetCodedValue("$item(0040,a168)");
        if(defined($concept_name)){
          $item_st->{value} = $concept_code;
          $item_st->{final_tag} = '(0040,a168)[0](0008,0104)';
        } else {
          $item_st->{value} = "Error: val_type = code, but no Coded Value Found";
        }

      } elsif($val_type eq "DATE"){
        $item_st->{value} = $ds->Get("$item(0040,a121)");
        $item_st->{final_tag} = '(0040,a121)';
      } elsif($val_type eq "DATETIME"){
        $item_st->{value} = $ds->Get("$item(0040,a120)");
        $item_st->{final_tag} = '(0040,a120)';
      } elsif($val_type eq "TEXT"){
        $item_st->{value} = $ds->Get("$item(0040,a160)");
        $item_st->{final_tag} = '(0040,a160)';
      } elsif($val_type eq "UIDREF"){
        $item_st->{value} = $ds->Get("$item(0040,a124)");
        $item_st->{final_tag} = '(0040,a124)';
      } elsif($val_type eq "NUM"){
        $item_st->{value} = $this->GetMeasuredValueSequence("$item(0040,a300)[0]");
        $item_st->{final_tag} = '(0040,a300)[0](0040,a30a)';
      } elsif($val_type eq "PNAME"){
        $item_st->{value} = $ds->Get("$item(0040,a123)");
        $item_st->{final_tag} = '(0040,a123)';
      }
      my $root_path;
      if(defined $path){
        $root_path = $path . "::";
      } else {
        $root_path = "";
      }

      if(exists $item_st->{name}) { $item_st->{semantic_path} = $root_path . $item_st->{name}
      } elsif (exists $item_st->{image_ref}) { $item_st->{semantic_path} = $root_path . "IMAGE"
      } else { $item_st->{semantic_path} = $root_path . "<none>" }
      my $content = $this->ParseContainer("$item(0040,a730)", $item_st->{semantic_path});
      if(defined $content){
        $item_st->{content} = $content;
      }
      push @Content, $item_st;
    }
  }
  if($#Content >= 0){ return \@Content }
  return undef;
};
sub GetMeasuredValueSequence{
  my($this, $tag) = @_;
  my $ds = $this->{ds};
  my $value = $ds->Get("$tag(0040,a30a)");
  my $code = $this->GetCodedValue("$tag(0040,08ea)");
  if(ref($value) eq "ARRAY"){ $value = $value->[0] }
  return "$value $code";
}
sub GetCodedValue{
  my($this, $tag) = @_;
  my $ds = $this->{ds};
  my $c_value = $ds->Get($tag . "[0](0008,0100)");
  my $c_scheme = $ds->Get($tag . "[0](0008,0102)");
  my $c_desc = $ds->Get($tag . "[0](0008,0104)");
  my $c_vers = $ds->Get($tag . "[0](0008,0103)");
  if(defined($c_value) && defined($c_scheme)){
    if (defined $c_vers) {
      return "$c_desc ($c_value of $c_scheme ($c_vers))";
    }
    return "$c_desc ($c_value of $c_scheme)";
  } else {
    return undef;
  }
}
sub GetImageReference{
  my($this, $tag) = @_;
  my $ds = $this->{ds};
  my $sop = $ds->Get($tag . "[0](0008,1155)");
  my $sop_class = $ds->Get($tag . "[0](0008,1150)");
  my $frame_no = $ds->Get($tag . "[0](0008,1160)");
  if(ref($frame_no) eq "ARRAY"){ $frame_no = $frame_no->[0] }
  if(defined($sop) && defined($sop_class)){
    my $dd = $Posda::Dataset::DD;
    my $sop_desc = $dd->GetSopClName($sop_class);
    $sop_desc .= " $sop";
    if(defined $frame_no) { $sop_desc .= " frame $frame_no" }
    return $sop_desc;
  } else {
    return undef;
  }
}
1;
