#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
use Posda::Dataset;
package Posda::DiffDicom;
{
  package Packer;
  sub new {
    my($class) = @_;
    my $this = {
      string => "",
    };
    return bless $this, $class;
  }
  sub print {
    my $this = shift;
    for my $i (@_){
      $this->{string} .= $i;
    }
  }
  sub get_str{
    my($this) = @_;
    return $this->{string};
  }
}
sub new{
  my($class, $from, $to) = @_;
  my $this = {
    from_ds =>$from,
    to_ds =>$to,
  };
  return bless $this, $class;
}
sub Analyze{
  my($this) = @_;
  $this->{FromEles} = {};
  $this->{ToEles} = {};
  $this->{OnlyInFrom} = {};
  $this->{OnlyInTo} = {};
  $this->{InBoth} = {};
  $this->{DifferentValues} = {};
  $this->{from_ds}->MapPvt(sub {
    my($ele, $sig) = @_;
    $this->{FromEles}->{$sig} = $ele;
  });
  $this->{to_ds}->MapPvt(sub {
    my($ele, $sig) = @_;
    $this->{ToEles}->{$sig} = $ele;
  });
  Element:
  for my $el (keys %{$this->{FromEles}}){
    unless(exists $this->{ToEles}->{$el}){
      $this->{OnlyInFrom}->{$el} = $this->{FromEles}->{$el};
      next Element;
    }
    $this->{InBoth}->{$el}->{From} = $this->{FromEles}->{$el};
  }
  for my $el (keys %{$this->{ToEles}}){
    unless(exists $this->{FromEles}->{$el}){
      $this->{OnlyInTo}->{$el} = $this->{ToEles}->{$el};
    }
  }
  for my $el (keys %{$this->{InBoth}}){
    my $from_v = $this->RenderValue($this->{FromEles}->{$el});
    my $to_v = $this->RenderValue($this->{ToEles}->{$el});
    unless($from_v eq $to_v){
      $this->{DifferentValues}->{$el}->{from} = $from_v;
      $this->{DifferentValues}->{$el}->{to} = $to_v;
    }
  }
  for my $sig (keys %{$this->{OnlyInFrom}}){
    my($pat, $indices) = Posda::Dataset->MakeMatchPat($sig);
    $this->{OnlyInFromPat}->{$pat} = 1;
  }
  for my $sig (keys %{$this->{OnlyInTo}}){
    my($pat, $indices) = Posda::Dataset->MakeMatchPat($sig);
    $this->{OnlyInToPat}->{$pat} = 1;
  }
  for my $sig (keys %{$this->{DifferentValues}}){
    my($pat, $indices) = Posda::Dataset->MakeMatchPat($sig);
    $this->{DifferentValuesPat}->{$pat} = 1;
  }
}
sub RenderValue{
  my($this, $ele) = @_;
  my $pr = Packer->new;
  Posda::Dataset::DumpEle($pr, $ele, 64);
  my $text = $pr->get_str;
  return $text;
}
sub SemiDiffReport{
  my($this) = @_;
  my %OnlyInFrom;
  my %OnlyInTo;
  my %DifferentValues;
  for my $el (keys %{$this->{OnlyInFrom}}){
    $OnlyInFrom{$el} = $this->{OnlyInFrom}->{$el};
  }
  for my $el (keys %{$this->{OnlyInTo}}){
    $OnlyInTo{$el} = $this->{OnlyInTo}->{$el};
  }
  for my $el (keys %{$this->{DifferentValues}}){
    $DifferentValues{$el} = $this->{DifferentValues}->{$el};
  }
  return(\%OnlyInFrom, \%OnlyInTo, \%DifferentValues);
}
sub ReportFromSemi{
  my($this, $OnlyInFrom, $OnlyInTo, $DifferentValues) = @_;
  my($short_rpt, $long_rpt) = ("","");
  my $num_only_in_from = keys %$OnlyInFrom;
  if($num_only_in_from > 0){
    $short_rpt .= "Only in from file:\r\n";
    $long_rpt .= "Only in from file:\r\n";
    my %SeenPatterns;
    for my $el (sort keys %$OnlyInFrom){
      my $tag_pat = $this->MakePattern($el);
      unless(exists $SeenPatterns{$tag_pat}){
        $SeenPatterns{$tag_pat} = 1;
        $short_rpt .= "\t$el\r\n";
        if($this->IsUid($el)){
          $long_rpt .= "\t$tag_pat: <uid>\r\n";
        } elsif($this->IsDate($el)){
          $long_rpt .= "\t$tag_pat: <date>\r\n";
        } else {
          my $v = $this->RenderValue($OnlyInFrom->{$el});
          $long_rpt .= "\t$tag_pat : $v\r\n";
        }
      }
    }
  }
  my $num_only_in_to = keys %$OnlyInTo;
  if($num_only_in_to > 0){
    $short_rpt .= "Only in to file:\r\n";
    $long_rpt .= "Only in to file:\r\n";
    my %SeenPatterns;
    for my $el (sort keys %$OnlyInTo){
      my $tag_pat = $this->MakePattern($el);
      unless(exists $SeenPatterns{$tag_pat}){
        $SeenPatterns{$tag_pat} = 1;
        $short_rpt .= "\t$tag_pat\r\n";
        if($this->IsUid($el)){
          $long_rpt .= "\t$tag_pat: <uid>\r\n";
        } elsif($this->IsDate($el)){
          $long_rpt .= "\t$tag_pat: <date>\r\n";
        } else {
          my $v = $this->RenderValue($OnlyInTo->{$el});
          $long_rpt .= "\t$tag_pat: $v\r\n";
        }
      }
    }
  }
  my $num_diffs = keys %$DifferentValues;
  if($num_diffs > 0){
    $short_rpt .= "Elements changed:\r\n";
    $long_rpt .= "Elements changed:\r\n";
    my %SeenPatterns;
    for my $el (sort keys %$DifferentValues){
      my $tag_pat = $this->MakePattern($el);
      unless(exists $SeenPatterns{$tag_pat}){
        $SeenPatterns{$tag_pat} = 1;
        $short_rpt .= "\t$tag_pat: \r\n";
        if($this->IsUid($el)){
          $long_rpt .= "\t$tag_pat: <changed uid>\r\n";
        } elsif($this->IsDate($el)){
          $long_rpt .= "\t$tag_pat: <changed date>\r\n";
        } else {
          $long_rpt .= "\t$tag_pat: $DifferentValues->{$el}->{from} " .
            "=> $DifferentValues->{$el}->{to}\r\n";
        }
      }
    }
  }
  return($short_rpt, $long_rpt);
}
sub LongReportFromSemiWithDates{
  my($this, $OnlyInFrom, $OnlyInTo, $DifferentValues, $show_uid_diffs) = @_;
  my $long_rpt = "";
  my $num_only_in_from = keys %$OnlyInFrom;
  if($num_only_in_from > 0){
    $long_rpt .= "Only in from file:\r\n";
    my %SeenPatterns;
    for my $el (sort keys %$OnlyInFrom){
      my $tag_pat = $this->MakePattern($el);
      unless(exists $SeenPatterns{$tag_pat}){
        my $v = $this->RenderValue($OnlyInFrom->{$el});
        $long_rpt .= "\t$tag_pat : $v\r\n";
      }
    }
  }
  my $num_only_in_to = keys %$OnlyInTo;
  if($num_only_in_to > 0){
    $long_rpt .= "Only in to file:\r\n";
    my %SeenPatterns;
    for my $el (sort keys %$OnlyInTo){
      my $tag_pat = $this->MakePattern($el);
      unless(exists $SeenPatterns{$tag_pat}){
        $SeenPatterns{$tag_pat} = 1;
        my $v = $this->RenderValue($OnlyInTo->{$el});
        $long_rpt .= "\t$tag_pat: $v\r\n";
      }
    }
  }
  my $num_diffs = keys %$DifferentValues;
  if($num_diffs > 0){
    $long_rpt .= "Elements changed:\r\n";
    my %SeenPatterns;
    for my $el (sort keys %$DifferentValues){
      my $tag_pat = $this->MakePattern($el);
      unless(exists $SeenPatterns{$tag_pat}){
        $SeenPatterns{$tag_pat} = 1;
        if($show_uid_diffs){
          $long_rpt .= "\t$tag_pat: $DifferentValues->{$el}->{from} " .
            "=> $DifferentValues->{$el}->{to}\r\n";
        } else {
          if($this->IsUid($el)){
            $long_rpt .= "\t$tag_pat: <uid>\r\n";
          } else {
            $long_rpt .= "\t$tag_pat: $DifferentValues->{$el}->{from} " .
              "=> $DifferentValues->{$el}->{to}\r\n";
          }
        }
      }
    }
  }
  return $long_rpt;
}
sub IsUid{
  my($this, $el) = @_;
  my $ele_desc = Posda::DataDict::get_ele_by_sig($Posda::Dataset::DD, $el);
  if($ele_desc->{VR} eq "UI") {return 1};
  return 0;
}
sub IsDate{
  my($this, $el) = @_;
  my $ele_desc = Posda::DataDict::get_ele_by_sig($Posda::Dataset::DD, $el);
  if($ele_desc->{VR} eq "DA") {return 1};
  if($ele_desc->{VR} eq "DT") {return 1};
  return 0;
}
sub MakePattern{
  my($this, $tag) = @_;
  my($pat, $indices) = Posda::Dataset->MakeMatchPat($tag);
  return $pat;
}
sub DiffReport{
  my($this) = @_;
  my $short_rpt = "";
  my $long_rpt = "";
  $this->Analyze;
  my $num_only_in_from = keys %{$this->{OnlyInFrom}};
  if($num_only_in_from > 0){
    $short_rpt .= "Only in from file:\n";
    $long_rpt .= "Only in from file:\n";
    for my $el (sort keys %{$this->{OnlyInFrom}}){
      $short_rpt .= "\t$el\n";
      my $v = $this->RenderValue($this->{OnlyInFrom}->{$el});
      $long_rpt .= "\t$el : $v\n";
    }
  }
  my $num_only_in_to = keys %{$this->{OnlyInTo}};
  if($num_only_in_to > 0){
    $short_rpt .= "Only in to file:\n";
    $long_rpt .= "Only in to file:\n";
    for my $el (sort keys %{$this->{OnlyInTo}}){
      $short_rpt .= "\t$el\n";
      my $v = $this->RenderValue($this->{OnlyInTo}->{$el});
      $long_rpt .= "\t$el : $v\n";
    }
  }
  my $num_diffs = keys %{$this->{DifferentValues}};
  if($num_diffs > 0){
    $short_rpt .= "Elements changed:\n";
    $long_rpt .= "Elements changed:\n";
    for my $el (sort keys %{$this->{DifferentValues}}){
      $short_rpt .= "\t$el\n";
      $long_rpt .= "\t$el: $this->{DifferentValues}->{$el}->{from} " .
        "=> $this->{DifferentValues}->{$el}->{to}\n";
    }
  }
  return($short_rpt, $long_rpt);
}
sub CondensedDiffReport{
  my($this) = @_;
  my $short_rpt = "";
  $this->Analyze;
  my $num_only_in_from = keys %{$this->{OnlyInFromPat}};
  if($num_only_in_from > 0){
    $short_rpt .= "Only in from file:\n";
    for my $el (sort keys %{$this->{OnlyInFromPat}}){
      $short_rpt .= "\t$el\n";
    }
  }
  my $num_only_in_to = keys %{$this->{OnlyInToPat}};
  if($num_only_in_to > 0){
    $short_rpt .= "Only in to file:\n";
    for my $el (sort keys %{$this->{OnlyInToPat}}){
      $short_rpt .= "\t$el\n";
    }
  }
  my $num_diffs = keys %{$this->{DifferentValuesPat}};
  if($num_diffs > 0){
    $short_rpt .= "Elements changed:\n";
    for my $el (sort keys %{$this->{DifferentValuesPat}}){
      $short_rpt .= "\t$el\n";
    }
  }
  my $long_rpt = "";
  $num_only_in_from = keys %{$this->{OnlyInFrom}};
  if($num_only_in_from > 0){
    $long_rpt .= "Only in from file:\n";
    for my $el (sort keys %{$this->{OnlyInFrom}}){
      $long_rpt .= "\t$el\n";
    }
  }
  $num_only_in_to = keys %{$this->{OnlyInTo}};
  if($num_only_in_to > 0){
    $long_rpt .= "Only in to file:\n";
    for my $el (sort keys %{$this->{OnlyInTo}}){
      $long_rpt .= "\t$el\n";
    }
  }
  $num_diffs = keys %{$this->{DifferentValues}};
  if($num_diffs > 0){
    $long_rpt .= "Elements changed:\n";
    for my $el (sort keys %{$this->{DifferentValues}}){
      $long_rpt .= "\t$el\n";
    }
  }
  return($short_rpt, $long_rpt);
}
1;
