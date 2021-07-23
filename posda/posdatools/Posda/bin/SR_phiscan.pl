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
use Posda::DB::PosdaFilesQueries;
use Posda::Dataset;
use Dispatch::EventHandler;
use Dispatch::LineReader;
use Posda::DB 'Query';


my $usage = <<EOF;
SR_phiScan.pl  <description>
  description - description of scan
Expects a list of <files> on STDIN
EOF
# unless($#ARGV == 1){
#   die "$usage\n";
# }
my( $desc) = @ARGV;


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



my %Files;
while(my $line = <STDIN>){
  chomp $line;
  if($line =~ /^([\d\.]+)\s*,\s*(.*)\s*$/){  ##FIX
    my $s = $1; my $sig = $2;
    $Files{$s} = $sig;
  } else {
    print STDERR "Can't process line: $line\n";
  }
}

my $num_files = keys %Files;
print "Received list of $num_files to scan\n";
close STDOUT;
close STDIN;
fork and exit;
print STDERR "Survived fork with $num_files to process\n";

my $create_scan = PosdaDB::Queries->GetQueryInstance("SR_CreateScanEvent");
# my $get_scan_id = PosdaDB::Queries->GetQueryInstance("SR_GetScanEventEventId");
# my $finish_scan = PosdaDB::Queries->GetQueryInstance("SR_UpdateFilesFinished");

#$create_scan->RunQuery(sub {}, sub {}, $desc, $num_files);

my $scan_id;
$get_scan_id->RunQuery(sub{
    my($row) = @_;
    $scan_id = $row->[0];
  }, sub {});
unless(defined $scan_id) { die "Can't get scan_id" }
my $num_scanned = 0;



#####

$max_len1 = 64;
$max_len2 = 300;

Posda::Dataset::InitDD();
my $dd = $Posda::Dataset::DD;

for my $files (keys %Files){
		my $ParsedSR = Posda::SrSemanticParse->new($infile);
		my %Paths;
		my $content = $ParsedSR->{content};
		GetPaths $content;
		for my $path(sort keys %Paths){
			for my $v (sort keys %{$Paths{$path}}){
				$path =~ s/\s\([^)]+\)//g;
				$v =~ s/\s\([^)]+\)//g;
				print "$path|$v\n";
				#DB here
			}
	}
}
$finish_scan->RunQuery(sub{}, sub{}, $scan_id);


}
