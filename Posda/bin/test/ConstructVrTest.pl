#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/bin/test/ConstructVrTest.pl,v $
#$Date: 2008/10/16 16:08:31 $
#$Revision: 1.2 $
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
use Posda::Dataset;
my $file_name = $ARGV[0];
my $BO = $ARGV[1];
unless(defined($BO) && ($BO eq "BE" || $BO eq "LE")){
  $BO = "LE";
}
my %values;
my %pvt_values;
line:
while (my $line = <STDIN>){
  chomp $line;
  if($line =~ /^#/) { next }
  my @fields = split(/\|/, $line);
  my $vr = $fields[0];
  $vr =~ s/^\s*//;
  $vr =~ s/\s*$//;
  if($vr eq "PVT"){
    my $grp = $fields[1];
    my $owner = $fields[2];
    my $ele = $fields[3];
    my $value = $fields[5];
    $pvt_values{$grp}->{$owner}->{$ele} = $value;
    next line;
  }
  my $vm = $fields[1];
  $vm =~ s/^\s*//;
  $vm =~ s/\s*$//;
  my $sig = $fields[3];
  $sig =~ s/^\s*//;
  $sig =~ s/\s*$//;
  my $count = $fields[4];
  my $here_file = 0;
  if(defined $fields[5] &&$fields[5] eq "<<EOF"){
    $here_file = 1;
  }
  if($vm eq "1"){
    unless($count == 1){ die "$sig has vm of 1 and count of $count" }
    my $value;
    if($here_file){
      $value = ReadHereFile();
    } else {
      if($vr eq 'AT'){
        unless($fields[5] =~ /^\((....),(....)\)$/){
          die "improperly formatted AT: $value";
        }
        my $grp = $1;
        my $ele = $2;
        my $hex_num = "$grp$ele";
        $value = hex($hex_num);
      } elsif($vr eq "OB" || $vr eq "OW"){
        if(defined $value){
          $value = hex($fields[5]);
        }
      } else {
        $value = $fields[5];
      }
    }
    $values{$sig} = $value;
  } else {
    my @value_a;
    for my $i (0 .. $count - 1){
      my $value;
      if(defined($fields[5]) && $fields[5] eq "<<EOF"){
        $value = ReadHereFile();
      } else {
        $value = $fields[5+$i];
      }
      if($vr eq 'AT'){
        unless($value =~ /^\((....),(....)\)$/){
          die "improperly formatted AT: $value";
        }
        my $grp = $1;
        my $ele = $2;
        my $hex_num = "$grp$ele";
        $value_a[$i] = hex($hex_num);
      } elsif($vr eq "OB" || $vr eq "OW"){
        $value_a[$i] = hex($value);
      } else {
        $value_a[$i] = $value;
      }
    }
    if($vr eq 'OB'){
      my $packed = pack("C*", @value_a);
      $values{$sig} = $packed;
    } elsif ($vr eq 'OW'){
      my $packed;
      if($BO eq "LE"){
        $packed = pack("v*", @value_a);
      } else {
        $packed = pack("n*", @value_a);
      }
      $values{$sig} = $packed;
    } elsif ($vr eq 'OF'){
      my $packed;
      if($BO eq "LE"){
        $packed = pack("V*", unpack( "L*", pack("f*", @value_a)));
      } else {
        $packed = pack("N*", unpack( "L*", pack("f*", @value_a)));
      }
      $values{$sig} = $packed;
    } else {
      for my $i (0 .. $#value_a){
        my $key = $sig . "[$i]";
        $values{$key} = $value_a[$i];
      }
    }
  }
}
Posda::Dataset::InitDD();
my $ds = Posda::Dataset->new_blank();
for my $key (keys %values){
#  print "$key: \"$values{$key}\"\n";
  $ds->InsertElementBySig($key, $values{$key});
}
for my $grp (keys %pvt_values){
  my $start_owner = 0x10;
  for my $owner (keys %{$pvt_values{$grp}}){
    for my $ele (keys %{$pvt_values{$grp}->{$owner}}){
      my $value = $pvt_values{$grp}->{$owner}->{$ele};
      my $sig = sprintf("(%04x,\"%s\",%02x)", $grp, $owner, $ele);
      $ds->Insert($sig, $value);
    }
  }
  $start_owner += 1;
}
$ds->InsertElementBySig("(0008,0016)", "1.2.3.456");
$ds->InsertElementBySig("(0008,0018)", "1.2.3.456.789");
print "File name: $file_name\n";
if($BO eq "LE"){
  $ds->WritePart10($file_name, 
    "1.2.840.10008.1.2.1", "DICOM_TEST", undef, undef);
} else {
  $ds->WritePart10($file_name, 
    "1.2.840.10008.1.2.2", "DICOM_TEST", undef, undef);
}

sub ReadHereFile{
  my @lines;
  while(my $string = <STDIN>){
    chomp $string;
    if($string eq "EOF"){
      return join "\n", @lines;
    }
    push @lines, $string;
  } 
  die "Here not terminated";
}
