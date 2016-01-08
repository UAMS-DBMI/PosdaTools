#!/usr/bin/perl -w
use strict;
#$Source: /home/bbennett/pass/archive/Posda/bin/CacheFileInfo.pl,v $
#$Date: 2015/06/21 19:29:53 $
#$Revision: 1.4 $
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
#
#  Parse a file into cache
#
#
use Cwd;
use Digest::MD5;
use Storable qw( store retrieve store_fd fd_retrieve );
my $usage = <<EOF;
Usage:
CacheFileInfo.pl <file> <cache_dir> <1|2>

<file> is the file to be analyzed
<cache_dir> is the root of the directory where the analysis is to be cached
<1> indicates a directory stucture of:
   <root>/a/s/asdfasdfasddasdf....dcminfo
<2> indicates a directory structure of:
   <root>/as/df/asdfasdfasddasdf....dcminfo
Given an md5 digest of asdfasdfasddasdf... for the file

Produces on STDOUT:
Cache file: <full path to cache file>
or
Error: <error text>
EOF
unless($#ARGV == 2){
  die $usage;
}
my($file, $dir, $opt) = @ARGV;
my $curdir = getcwd;
unless($file =~ /^\//) {
        $file = "$curdir/$file";
}
unless($dir =~ /^\//) {
        $dir = "$curdir/$dir";
}
unless(-f $file) { die "$file is not a file" }
unless(-d $dir) { die "$dir is not a directory" }
my $ctx = Digest::MD5->new;
open FILE, "<$file" or die "can't open $file for reading\n";
$ctx->addfile(*FILE);
my $digest = $ctx->hexdigest;
close FILE;
my($one, $two);
if($opt == 2){ ($one, $two) = $digest =~ /^(..)(..)/ }
elsif($opt == 1){ ($one, $two) = $digest =~ /^(.)(.)/ }
else { die $usage }
my $cache_dir = "$dir/$one/$two";
my $cache_file = "$cache_dir/$digest.dcminfo";
if(-f $cache_file) {
  print "Cache file: $cache_file\n";
  exit;
}
unless(-d "$dir/$one") {
  unless(mkdir "$dir/$one") {
    print "Error: can't mkdir $dir/$one\n";
    die "can't mkdir $dir/$one";
  }
}
unless(-d "$dir/$one/$two") {
  unless(mkdir "$dir/$one/$two") {
    print "Error: can't mkdir $dir/$one/$two\n";
    die "can't mkdir $dir/$one/$two";
  }
}
my $sub_prog = ( -x "/usr/bin/speedy" ) ? 
  "DicomInfoAnalyzer.pl" : "SpeedyDIcomInfoAnalyzer.pl";
my $fh;
unless(open $fh, "-|", "$sub_prog $file"){
 print "Error: can't open subprogram\n";
 die "Can't open subprogram";
}
my $analysis = fd_retrieve($fh);
close $fh;
unless($analysis->{digest} eq $digest) {
  print "Error: DICOM caching race: returned digest($analysis->{digest}) " .
    "doesn't match that requested($digest)\n";
  die "DICOM caching race: returned digest($analysis->{digest}) " .
    "doesn't match that requested($digest)";
}
if(-f $cache_file){
  print "Cache file: $cache_file\n";
  die "DICOM caching race: cache file ($cache_file) already exists  " .
    "for $file\n";
}
store $analysis, $cache_file;
print "Cache file: $cache_file\n";
