#!/usr/bin/perl
#$Source: /home/bbennett/pass/archive/DicomXml/bin/DumpExpandedIodModule.pl,v $
#$Date: 2014/08/15 20:44:51 $
#$Revision: 1.1 $
#
#Copyright 2014, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
use Storable qw( fd_retrieve retrieve store_fd);
use Cwd;
use Debug;
my $dbg = sub { print STDERR @_ };
my $c_dbg = sub { print @_ };
unless($#ARGV == 0) {
  die "usage: DumpExpandedModuleTable.pl <parsed_iod_table>";
}
my $tab = retrieve($ARGV[0]);
for my $tag (sort keys %{$tab->{tags}}){
  if(ref($tab->{tags}->{$tag}) eq "HASH"){
    PrintTag($tag, $tab->{tags}->{$tag});
  } elsif(ref($tab->{tags}->{$tag}) eq "ARRAY"){
    for my $t (@{$tab->{tags}->{$tag}}){ PrintTag($tag, $t) }
  }
}
print "Errors:\n";
for my $e (@{$tab->{errors}}){
  print "$e\n";
}
sub PrintTag{
  my($tag, $info) = @_;
  my $entity = $info->{entity};
  my $module = $info->{module};
  my $req = $info->{req};
  my $usage = $info->{usage};
  my $macro = "";
  if(exists $info->{mod_tables}){
    for my $i (0 .. $#{$info->{mod_tables}}){
      $macro .= $info->{mod_tables}->[$i];
      unless($i == $#{$info->{mod_tables}}){ $macro .= ":" }
    }
  }
  print "$tag|$entity|$module|$macro|$usage|$req|$info->{name}\n";
}
