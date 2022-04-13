#!/usr/bin/perl -w 
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use Cwd;
use Posda::NewTry;
use Debug;
my $dbg = sub {print @_ };
my $usage = "Usage: $0 <file>";
unless ($#ARGV == 0) {die $usage;}

my $dir = getcwd;
my $infile = $ARGV[0];
unless($infile =~ /^\//) {
	$infile = "$dir/$infile";
}

Posda::Dataset::InitDD();
my $dd = $Posda::Dataset::DD;

my $try  = Posda::NewTry->new($infile);
my $max_len1 = 64;
my $max_len2 = 300;

if($try->{dataset}){
    print "Part10 Metaheader:";
    print "\n";
    my $mh = $try->{metaheader}->{metaheader};
    for my $key (sort keys %$mh){
      if($key eq "(0002,0000)") { next }
      if($key eq "(0002,0001)") { next }
      my $value = $mh->{$key};
      print "$key: \"$value\"";
      if(exists $dd->{SopCl}->{$value}){
        print " ($dd->{SopCl}->{$value}->{sopcl_desc})";
      } elsif (exists $dd->{XferSyntax}->{$value}){
        print " ($dd->{XferSyntax}->{$value}->{name})";
      }
      print "\n";
    }
  print "Dataset:\n";
  $try->{dataset}->DumpStyle0(\*STDOUT, $max_len1, $max_len2);
  if(
    exists($try->{parser_warnings}) &&
    ref($try->{parser_warnings}) eq "ARRAY" &&
    $#{$try->{parser_warnings}} >= 0
  ){
    print "Warnings encountered in parsing:\n";
    for my $e (@{$try->{parser_warnings}}){
      print "$e\n";
    }
  }
} else {
  print "Try: ";
  Debug::GenPrint($dbg, $try, 1, 3);
  print "\n";
}
