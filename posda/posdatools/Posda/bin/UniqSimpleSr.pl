#!/usr/bin/perl -w
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
use Cwd;
use Posda::SrSemanticParse;

my $usage = "Usage: $0 <file>";
unless ($#ARGV >= 0) {die $usage;}


my $dir = getcwd;
my $infile = $ARGV[0];
unless($infile =~ /^\//) {
	$infile = "$dir/$infile";
}
my $max_len1 = $ARGV[1];
my $max_len2 = $ARGV[2];
unless(defined $max_len1) {$max_len1 = 64}
unless(defined $max_len2) {$max_len2 = 300}

Posda::Dataset::InitDD();
my $dd = $Posda::Dataset::DD;

my $ParsedSR = Posda::SrSemanticParse->new($infile);

my %Paths;
sub GetPaths{
  my($content) = @_;
  for my $i (@{$content}){
    if(exists $i->{value}){

      $Paths{$i->{semantic_path}}->{$i->{value}} = 1;
    } elsif(exists $i->{image_ref}){
      $Paths{$i->{semantic_path}}->{$i->{image_ref}} = 1;
    } else {
      $Paths{$i->{semantic_path}}->{"<none>"} = 1;
    }
    if(exists $i->{content}){
      GetPaths($i->{content});
    }
  }
}
my $content = $ParsedSR->{content};
GetPaths $content;
for my $path(sort keys %Paths){
  for my $v (sort keys %{$Paths{$path}}){
    #print "$path|$v\n";
    #if($path =~ /^(.*) \(.*\)$/){ $path = $1 }
    $path =~ s/\s\([^)]+\)//g;
    $v =~ s/\s\([^)]+\)//g;
    print "$path|$v\n";


  }
}
