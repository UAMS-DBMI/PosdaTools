#!/usr/bin/perl -w
use strict;
use Posda::Dataset;
use Debug;
my $dbg = sub { print @_ };

Posda::Dataset::InitDD();


unless($#ARGV == 0) { die "usage: $0 <file>\n" }
my $file = $ARGV[0];
my %ele_map;
unless(-r $file && -f $file){ die "Can't read $file" }
my ($df, $ds, $size, $xfr_stx, $errors) = Posda::Dataset::Try($file);
unless($ds) { 
  die "$file is not a DICOM file";
}
ele_sig:
$ds->MapPvt(sub {
    my($ele, $sig) = @_;
    my @values;
    my $ele_info = $Posda::Dataset::DD->get_ele_by_sig($sig);
    
    if(defined($ele->{value}) && ref($ele->{value}) eq "ARRAY"){
      @values = @{$ele->{value}};
      for my $i (0 .. $#values){
        my $value = $values[$i];
        if($value =~ /\.\d+\./ && length($value) <= 128){
          print "Potential_UID|$ele_info->{Name}|$sig" . "[$i]|$value|\n";
        }
      }
    } elsif(defined($ele->{value})){
      my $value = $ele->{value};
      if($value =~ /\.\d+\./ && length($value) <= 128){
        print "Potential_UID|$ele_info->{Name}|$sig|$value|\n";
      }
    }
#    if(length($ele->{value}) < 100){ print "value: \"$ele->{value}\"\n" }
#    print "EleSig: $sig\n";
#    my $test_sig;
#    my $ele_info = $Posda::Dataset::DD->get_ele_by_sig($sig);
#    print "ele_info: ";
#    Debug::GenPrint($dbg, $ele_info, 1);
#    print "\n";
});
for my $i (@$errors){
  print "Parse_error|$i\n";
}
