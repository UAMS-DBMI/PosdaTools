#!/usr/bin/perl -w
use strict;
use JSON;
use Debug;
my $dbg = sub { print @_ };
sub slurp {
    my $file = shift;
    open my $fh, '<', $file or die $!;
    local $/ = undef;
    my $cont = <$fh>;
    close $fh;
    return $cont;
}
my $usage = <<EOF;
PhiScanJson.pl <file>
PhiScanJson.pl -h

Reads a json file and produces a set of path: values for all
the paths with values

EOF
if($#ARGV != 0 || $ARGV[0] eq "-h"){ die $usage }

my $file = $ARGV[0];
my $foo = slurp($file);
my $struct = decode_json $foo;
#print "Struct: ";
#Debug::GenPrint($dbg, $struct, 1);
#print "\n";
my $path = "";
PrintValues($struct, "");
sub PrintValues{
  my($struct, $path) = @_;
  if(ref($struct) eq "HASH"){
    for my $k (sort keys %{$struct}){
      PrintValues($struct->{$k}, "$path" . "{$k}");
    }
  } elsif (ref($struct) eq "ARRAY"){
    for my $i (0 .. @{$struct}){
      PrintValues($struct->[$i], "$path" . "[$i]");
    }
  } else {
    if(defined $struct && $struct){
      if($struct =~ /\n/){
        my @foo = split /\n/, $struct;
        for my $f (@foo){
          if($f){
            print "$path|$f\n";
          }
        }
      } else {
        print "$path|$struct\n";
      }
    }
  }
}

