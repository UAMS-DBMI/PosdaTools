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
}
sub RenderValue{
  my($this, $ele) = @_;
  my $pr = Packer->new;
  Posda::Dataset::DumpEle($pr, $ele, 64);
  my $text = $pr->get_str;
  return $text;
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
1;
