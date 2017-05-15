#!/usr/bin/perl -w
use strict;
use Posda::DB::PosdaFilesQueries;
use File::Temp qw/ tempfile /;
my $usage = <<EOF;
MakeSelectedTagValueReport.pl <report_file_name> <notify_email>
or
MakeSelectedTagValueReport.pl -h

Generates a csv report file
Sends email when done
Expect input lines in following format:
<element_signature>&<vr>&<disposition>&<name_chain>&<num_phi_values>&<num_simple_phi_values>

Uses following queries:
  GetSimpleValuesByEleVr
  GetValuesByEleVr
EOF
unless($#ARGV == 1 ){ die $usage }
my %Data;
while(my $line = <STDIN>){
  chomp $line;
  my($sig, $vr, $disp, $name, $num_phi, $num_phi_simple) =
    split(/&/, $line);
  $Data{$sig}->{$vr} = {
    num_phi => $num_phi,
    num_simple => $num_phi_simple,
    disp => $disp,
    name => $name,
  };
}
my $num_sigs = keys %Data;
print "$num_sigs elements loaded\n";
my $report_file_name = $ARGV[0];
my $email = $ARGV[1];
fork and exit;
close STDOUT;
close STDIN;
print STDERR "In child\n";
open EMAIL, "|mail -s \"Posda Job Complete\" $email" or die 
  "can't open pipe ($!) to mail $email";
unless(open REPORT, ">$report_file_name"){
  print EMAIL "Can't open $report_file_name\n" .
    "giving up";
  die "Can't open $report_file_name";
}
print REPORT "\"element_signature\"," .
  "\"vr\",\"name\",\"disposition\",\"num_distinct\",\"values\"\r\n";
print STDERR "Opened children\n";
my @ElementList = sort keys %Data;
my $num_eles = @ElementList;
print EMAIL "$0 Running in background\n";
print EMAIL "$num_eles elements to process in child\n";
print STDERR "$num_eles elements to process in child\n";
my $get_phi = PosdaDB::Queries->GetQueryInstance("GetValuesByEleVr");
my $get_simp = PosdaDB::Queries->GetQueryInstance("GetSimpleValuesByEleVr");
print EMAIL "Starting report data\n";
Element:
for my $i (0 .. $#ElementList){
  my $sig = $ElementList[$i];
  my $psig = $sig;
  $psig =~ s/"/""/g;
  for my $vr (keys %{$Data{$sig}}){
    print EMAIL "Sig: $sig, vr: $vr - ";
    print REPORT "\"$psig\",$vr," .
      "\"$Data{$sig}->{$vr}->{disp}\"," .
      "\"$Data{$sig}->{$vr}->{name}\",";
    my %Values;
    $get_phi->RunQuery(sub {
        my($row) = @_;
        $Values{$row->[0]} = 1;
      },
      sub {},
      $sig, $vr
    );
    $get_simp->RunQuery(sub {
        my($row) = @_;
        $Values{$row->[0]} = 1;
      },
      sub {},
      $sig, $vr
    );
    my @values = sort(keys %Values);
    my $num_values = @values;
    print EMAIL "$num_values values\n";
    print REPORT "$num_values,\"";
    my @vprint;
    if($#values <= 9){
      for my $i (0 .. $#values){
        $vprint[$i] = $values[$i];
      }
    } else {
      for my $i (0 .. 4){
        $vprint[$i] = $values[$i];
      }
      $vprint[5] = "----";
      for my $i (0 .. 4){
        my $vi = $#values - $i;
        $vprint[6 + $i] = $values[$vi];
      }
    }
    for my $v (@vprint){
      my $vp = $v;
      $vp =~ s/"/""/g;
      print REPORT "$vp\r\n"
    }
    print REPORT "\"\r\n";
  }
}
close REPORT;
print EMAIL "Report written to $report_file_name\n";
close EMAIL;
