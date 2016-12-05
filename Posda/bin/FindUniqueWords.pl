#!/usr/bin/perl -w
#
#Copyright 2013, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
use Posda::Try;
use File::Temp qw/ tempfile /;
my $file = $ARGV[0];
sub UncompressGeProtocolDataBlock{
  my($v) = @_;
  my($fh, $fname) = tempfile();
  print $fh $v;
  close $fh;
  my $zip_name = File::Temp::tempnam("/tmp", "foo");
  my $length = length $v;
  my $new_len = $length - 4;
  if($new_len <= 0) { return undef }
  my $cmd1 = "tail -${new_len}c $fname >$zip_name";
  `$cmd1`;
  my $unzip_name = File::Temp::tempnam("/tmp", "bar");
  my $cmd2 = "gzip -dc < $zip_name >$unzip_name";
  `$cmd2`;
  my $cmd3 = "cat $unzip_name";
  my $new_v = `$cmd3`;
  return $new_v;
}
sub MakeEleFun{
  my($file, $values) = @_;
  my $sub = sub {
    my($ele, $n_sig) = @_;
    if($n_sig =~ /\(7fe0,0010\)$/) {
       $values->{"not scanning pixel data"}->{$n_sig}->{$ele->{VR}} = 1;
       return;
    }
#    unless($ele->{type} eq "text" || $ele->{type} eq "raw") {
#      $values->{"not scanning $ele->{type}"}->{$n_sig}->{$ele->{VR}} = 1;
#      return;
#    }
    my @values;
    if(ref($ele->{value}) eq ""){
      push(@values, $ele->{value});
    } else {
      for my $v (@{$ele->{value}}) {
        push(@values, $v);
      }
    }
    my $nvalues = @values;
    if($ele->{VR} eq "DS" && $nvalues > 100){ @values = ($values[0]); }
    my $num_text_values = 0;
    value:
    for my $v (@values){
      if(ref($v) eq "Posda::Dataset"){
        $values->{"Posda::Dataset"}->{$n_sig}->{$ele->{VR}} = 1;
        $num_text_values += 1;
        next value;
      }
      unless(defined $v) {
        $values->{"<undef>"}->{$n_sig}->{$ele->{VR}} = 1;
        $num_text_values += 1;
        next value;
      }
      if($v eq "") { 
        $values->{"<empty>"}->{$n_sig}->{$ele->{VR}} = 1;
        $num_text_values += 1;
        next value;
      }
      if($n_sig eq '(0025,"GEMS_SERS_01",1b)'){
        $v = UncompressGeProtocolDataBlock($v);
      }
      unless($v =~ /^[[:print:][:cntrl:]]+$/){ next value }
#      if($v =~ /^[0-9\.\+\-Ee ]+$/) { next value }
      if($v =~ /\n/){
        my @values = split(/[\n,']/, $v);
        value1:
        for my $i (@values){
          $i =~ tr/\000-\037/ /;
          $i =~ s/\s*$//g;
          $i =~ s/^\s*//g;
          $i =~ s/\|/ /g;
          if ($i eq "") { next value1 }
          if($i =~ /[^[:print:]]/){
            my @foo = split(/[^[:print:]]+/, $i);
            foo:
            for my $j (@foo){
              $i =~ tr/\000-\037/ /;
              $i =~ s/\s*$//g;
              $i =~ s/^\s*//g;
              if($j eq "") { next foo }
              $values->{$j}->{$n_sig}->{$ele->{VR}} = 1;
              $num_text_values += 1;
            }
          } else {
            $values->{$i}->{$n_sig}->{$ele->{VR}} = 1;
            $num_text_values += 1;
          }
        }
      } elsif(length($v) > 64) {
        my @values = split(/[\s,]+/, $v);
        value2:
        for my $i (@values){
          if(length($i) > 64){
            my $remain = $i;
            value3:
            while($remain =~ /^(.....................)(.*)$/){
              my $j = $1;
              $remain = $2;
              $j =~ tr/\000-\037/ /;
              $j =~ s/\|/ /g;
              $j =~ s/\s*$//g;
              $j =~ s/^\s*//g;
              if($j eq "" ) { next value3 }
              $values->{$j}->{$n_sig}->{$ele->{VR}} = 1;
              $num_text_values += 1;
            }
            if($remain){
              my $j = $remain;
              $j =~ tr/\000-\037/ /;
              $j =~ s/\|/ /g;
              $j =~ s/\s*$//g;
              $j =~ s/^\s*//g;
              unless($j eq "" ) {
                $values->{$j}->{$n_sig}->{$ele->{VR}} = 1;
                $num_text_values += 1;
              }
            }
          } else {
            $i =~ tr/\000-\037/ /;
            $i =~ s/\|/ /g;
            $i =~ s/\s*$//g;
            $i =~ s/^\s*//g;
            if($i eq "" ) { next value2 }
            $values->{$i}->{$n_sig}->{$ele->{VR}} = 1;
            $num_text_values += 1;
          }
        }
      } else {
        $v =~ tr/\000-\037/ /;
        $v =~ s/\|/ /g;
        $v =~ s/\s*$//g;
        $v =~ s/^\s*//g;
        if($v eq "") { next value }
        $values->{$v}->{$n_sig}->{$ele->{VR}} = 1;
        $num_text_values += 1;
      }
    }
    if($num_text_values == 0){
      $values->{"no text value found"}->{$n_sig}->{$ele->{VR}} = 1;
    }
  };
  return $sub;
}
my %Values;
my $try = Posda::Try->new($file);
unless(exists $try->{dataset}) { die "$file isn't a DICOM file" }
$try->{dataset}->MapPvt(MakeEleFun($file, \%Values));
for my $v (sort {$a cmp $b} keys %Values){
  for my $sig (sort {$a cmp $b} keys %{$Values{$v}}){
    my $type;
    for my $vr (keys %{$Values{$v}->{$sig}}){
      my $enc_v = $v;
      $enc_v =~ s/(\n)/"%" . unpack("H2", $1)/eg;
      print "$enc_v|$sig|$vr\n";
    }
  }
}
