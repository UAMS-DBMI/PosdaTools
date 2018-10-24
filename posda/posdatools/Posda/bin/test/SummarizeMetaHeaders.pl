#!/usr/bin/perl -w
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use Cwd;
use strict;
use Posda::Dataset;
use Posda::Find;
use Debug;
my $dbg = sub {print @_};
Posda::Dataset::InitDD();
my $usage = sub {
        print "usage: $0 <source directory>\n";
        exit -1;
};
unless(
        $#ARGV >= 0
) {
        &$usage();
}
my $dir = $ARGV[0];
my $cwd = getcwd;
unless($dir =~ /^\//) { $dir = "$cwd/$dir" }
unless(-d $dir) { die "$dir is not a directory" }
my $list = Posda::Find::CollectMetaHeaders($dir);
my %Results;
for my $i (@$list){
  $Results{$i->{sop_class}}->{$i->{sop_inst}} = 1;
}
my $end_dir;
if($dir =~ /\/([^\/]+)$/){
  $end_dir = $1;
}
print "Directory: $end_dir\n";
for my $scl (keys %Results){
  my $count = keys %{$Results{$scl}};
  print "$scl: $count\n";
}
