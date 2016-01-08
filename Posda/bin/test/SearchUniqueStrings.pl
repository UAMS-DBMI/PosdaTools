#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/bin/test/SearchUniqueStrings.pl,v $
#$Date: 2014/05/13 20:17:48 $
#$Revision: 1.2 $
#
#Copyright 2013, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
use Posda::Find;
use Posda::Try;
use Storable;
my $dir = $ARGV[0];
my $db_file = $ARGV[1];
sub MakeEleFun{
  my($file, $values) = @_;
  my $sub = sub {
    my($ele, $n_sig) = @_;
    if($ele eq "(7fe0,0010)") { return }
    unless($ele->{type} eq "text" || $ele->{type} eq "raw") { return }
    my @values;
    if(ref($ele->{value}) eq ""){
      push(@values, $ele->{value});
    } else {
      for my $v (@{$ele->{value}}) {
        push(@values, $v);
      }
    }
    value:
    for my $v (@values){
      unless(defined $v) { next value }
      $v =~ s/\0+$//g;
      $v =~ s/\s*$//g;
      $v =~ s/^\s*//g;
      unless($v =~ /^[[:print:]]+$/){ next value }
      if($v =~ /^[0-9\.\+\-Ee ]+$/) { next value }
      $values->{$v}->{$file}->{$n_sig} = 1;
    }
  };
  return $sub;
}
my %Values;
my $string_finder = sub {
  my($try) = @_;
  my $file = $try->{filename};
  my $ds = $try->{dataset};
  $ds->MapPvt(MakeEleFun($file, \%Values));
};
Posda::Find::DicomOnly($dir, $string_finder);
store \%Values, $db_file;
#for my $u (sort keys %Values){
#  print "----\"$u\"\n";
#}
