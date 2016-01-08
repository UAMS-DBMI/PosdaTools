#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/include/Posda/Xml.pm,v $
#$Date: 2008/04/30 19:17:35 $
#$Revision: 1.4 $
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
package Posda::Xml;
use MIME::Base64;
sub Print{
  my($stream, $ds) = @_;
  my $ele_fun = sub {
    my($element, $grp, $ele, $depth) = @_;
    if($grp == 0xfffc){ return };
    if($element->{VR} eq "SQ"){
      print $stream "   " x $depth;
      print $stream sprintf "<sq%04x%04x>\n", $grp, $ele;
    } else {
      print $stream "   " x $depth;
      print $stream sprintf "<t%04x%04x grp=\"%04x\" ele=\"%04x\">\n", 
        $grp, $ele, $grp, $ele;
      PrintValue($stream, $element, $depth + 1);
      print $stream "   " x $depth;
      print $stream sprintf "</t%04x%04x>\n", $grp, $ele;
    }
  };
  my $ele_seq_end = sub {
    my($grp, $ele, $depth) = @_;
    print $stream "   " x $depth;
    print $stream sprintf "</sq%04x%04x>\n", $grp, $ele;
  };
  my $item_start_fun = sub {
    my($grp, $ele, $depth) = @_;
    print $stream "   " x $depth;
    print "<item>\n";
  };
  my $item_end_fun = sub {
    my($grp, $ele, $depth) = @_;
    print $stream "   " x $depth;
    print "</item>\n";
  };
  my $pvt_ele_fun = sub {
    my($element, $grp, $ele, $owner, $depth) = @_;
    print $stream "   " x $depth;
    print $stream sprintf "<private grp=\"%04x\" ele=\"%04x\" owner=\"%s\">\n",
      $grp, $ele, $owner;
    PrintValue($stream, $element, $depth + 1);
    print $stream "   " x $depth;
    print $stream "</private>\n";
  };
  print $stream "<dataset>\n";
  $ds->MapPvtForXml($ele_fun, $ele_seq_end, $item_start_fun, $item_end_fun, 
    $pvt_ele_fun, 1);
  print $stream "</dataset>\n";
}
sub PrintValue{
  my($stream, $element, $depth) = @_;
  unless(defined $element->{value}){
    return;
  }
  my @values;
  if(ref($element->{value}) eq "ARRAY"){
    @values = @{$element->{value}};
  } else {
    $values[0] = $element->{value};
  }
  my $vr = $element->{VR};
  my $type = $element->{type};
  for my $i (@values){
    print $stream "   " x $depth;
    print "<$vr>\n";
    PrintSingleValue($stream, $vr, $type, $i, $depth + 1);
    print $stream "   " x $depth;
    print "</$vr>\n";
  }
}
my $dispatch = {
  PN => sub {
    my($stream, $vr, $type, $value, $depth) = @_;
    my($family, $given, $middle, $prefix, $suffix) = split(/\^/, $value);
    if($family){
      print $stream "   " x $depth;
      print $stream "<family value=\"$family\">\n";
    }
    if($given){
      print $stream "   " x $depth;
      print $stream "<given value=\"$given\">\n";
    }
    if($middle){
      print $stream "   " x $depth;
      print $stream "<given value=\"$middle\">\n";
    }
    if($prefix){
      print $stream "   " x $depth;
      print $stream "<prefix value=\"$prefix\">\n";
    }
    if($suffix){
      print $stream "   " x $depth;
      print $stream "<suffix value=\"$suffix\">\n";
    }
  },
  DA => sub {
    my($stream, $vr, $type, $value, $depth) = @_;
    if($value =~ /^(\d\d\d\d)(\d\d)(\d\d)$/){
      my $y = $1;
      my $m = $2;
      my $d = $3;
      print $stream "   " x $depth;
      print $stream "$y-$m-$d\n";
    } else {
      print STDERR "Improperly formatted DICOM date: \"$value\"\n";
    }
  },
  TM => sub {
    my($stream, $vr, $type, $value, $depth) = @_;
    if($value =~ /^(\d\d)$/){
      my $hr = $1;
      print $stream "   " x $depth;
      print $stream sprintf "%02d\n", $hr;
    } elsif ($value =~ /^(\d\d)(\d\d)$/){
      my $hr = $1;
      my $min = $2;
      print $stream "   " x $depth;
      print $stream sprintf "%02d:%02d\n", $hr, $min;
    } elsif ($value =~ /^(\d\d)(\d\d)(\d\d)$/){
      my $hr = $1;
      my $min = $2;
      my $sec = $3;
      print $stream "   " x $depth;
      print $stream sprintf "%02d:%02d:%02d\n", $hr, $min, $sec;
    } elsif ($value =~ /^(\d\d)(\d\d)(\d\d)\.(\d*)/){
      my $hr = $1;
      my $min = $2;
      my $sec = $3;
      my $frac = $4;
      print $stream "   " x $depth;
      print $stream sprintf "%02d:%02d:%02d.%s\n", $hr, $min, $sec, $frac;
    } else {
      print STDERR "Improperly formatted DICOM TM: \"$value\"\n";
    }
  },
  DT => sub {
    my($stream, $vr, $type, $value, $depth) = @_;
    if($value =~ /^(\d\d\d\d)$/){
      my $yr = $1;
      print $stream "   " x $depth;
      print $stream sprintf "%04d\n", $yr;
    } elsif ($value =~ /^(\d\d\d\d)(\d\d)$/){
      my $yr = $1;
      my $mon = $2;
      print $stream "   " x $depth;
      print $stream sprintf "%04d-%02d\n", $yr, $mon;
    } elsif ($value =~ /^(\d\d\d\d)(\d\d)(\d\d)$/){
      my $yr = $1;
      my $mon = $2;
      my $day = $3;
      print $stream "   " x $depth;
      print $stream sprintf "%04d-%02d-%02d\n", $yr, $mon, $day;
    } elsif ($value =~ /^(\d\d\d\d)(\d\d)(\d\d)(\d\d)$/){
      my $yr = $1;
      my $mon = $2;
      my $day = $3;
      my $hr = $4;
      print $stream "   " x $depth;
      print $stream sprintf "%04d-%02d-%02dT%02\n", $yr, $mon, $day, $hr;
    } elsif ($value =~ /^(\d\d\d\d)(\d\d)(\d\d)(\d\d)(\d\d)$/){
      my $yr = $1;
      my $mon = $2;
      my $day = $3;
      my $hr = $4;
      my $min = $5;
      print $stream "   " x $depth;
      print $stream sprintf "%04d-%02d-%02dT%02\n", $yr, $mon, $day, $hr, $min;
    } elsif ($value =~ /^(\d\d\d\d)(\d\d)(\d\d)(\d\d)(\d\d)(\d\d)$/){
      my $yr = $1;
      my $mon = $2;
      my $day = $3;
      my $hr = $4;
      my $min = $5;
      my $sec = $6;
      print $stream "   " x $depth;
      print $stream sprintf "%04d-%02d-%02dT%02\n", 
        $yr, $mon, $day, $hr, $min, $sec;
    } elsif (
      $value =~ /^(\d\d\d\d)(\d\d)(\d\d)(\d\d)(\d\d)(\d\d)\.(\d*)$/
    ){
      my $yr = $1;
      my $mon = $2;
      my $day = $3;
      my $hr = $4;
      my $min = $5;
      my $sec = $6;
      my $frac = $7;
      print $stream "   " x $depth;
      print $stream sprintf "%04d-%02d-%02dT%02.%s\n", 
        $yr, $mon, $day, $hr, $min, $sec, $frac;
    } elsif (
      $value =~ 
        /^(\d\d\d\d)(\d\d)(\d\d)(\d\d)(\d\d)(\d\d)\.(\d*)([+-])(\d\d)(\d\d)$/
    ){
      my $yr = $1;
      my $mon = $2;
      my $day = $3;
      my $hr = $4;
      my $min = $5;
      my $sec = $6;
      my $frac = $7;
      my $op = $8;
      my $hoff = $9;
      my $moff = $10;
      print $stream "   " x $depth;
      print $stream sprintf "%04d-%02d-%02dT%02.%s%s%2d:%d2\n", 
        $yr, $mon, $day, $hr, $min, $sec, $frac, $op, $hoff, $moff;
    }
  }
};
sub PrintSingleValue{
  my($stream, $vr, $type, $value, $depth) = @_;
  unless(defined $type) { return };
  if(
    $type eq "text" || $type eq "ushort" ||
    $type eq "sshort"  || $type eq "ulong" ||
    $type eq "slong" || $type eq "float"
  ){
    if(exists $dispatch->{$vr}){
      &{$dispatch->{$vr}}($stream, $vr, $type, $value, $depth);
    } else {
      print $stream "   " x $depth;
      $value =~ s/</&lt;/g;
      $value =~ s/>/&gt;/g;
      print $stream "$value\n";
    }
  } else {
    print $stream MIME::Base64::encode($value, "\n");
  }
}
1;
