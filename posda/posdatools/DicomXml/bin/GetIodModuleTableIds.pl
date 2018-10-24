#!/usr/bin/perl
#
#Copyright 2014, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
use XML::Parser;
use Storable qw( retrieve store_fd);
use Cwd;
unless($#ARGV == 0) {
  die "usage: GetIodModuleTableIds.pl <parsed_xml_file>";
}
my $doc = retrieve($ARGV[0]);
for my $id (keys %{$doc->{index}}){
  if($doc->{index}->{$id}->{el} eq "table") {
    my $caption = GetCaption($doc->{index}->{$id}->{content});
    unless($caption =~ /IOD Modules$/){ next }
    print "$id: $caption";
    print "\n";
  }
}
sub GetCaption{
  my($c) = @_;
  my $cap;
  for my $i (@$c) {
    unless(ref($i) eq "HASH" && $i->{el} eq "caption"){ next }
    $cap = $i->{content}->[0];
  }
  return $cap;
}
