#!/usr/bin/perl -w
use Posda::DB::PosdaFilesQueries;
use Debug;
my $dbg = sub {print @_ };
my $get_files = PosdaDB::Queries->GetQueryInstance(
  "FilesByModalityByCollectionSiteIntake");
my $usage = <<EOF;
CheckRtdoseLinkagesIntake.pl <collection> <site>
EOF
unless($#ARGV == 1){ die $usage }
my %Structs;
my %Doses;
my %Plans;
my %Pats;
$get_files->RunQuery(sub { 
  my($row) = @_;
  $Structs{$row->[3]} = {
    patient_id => $row->[0],
    modality => $row->[1],
    series_instance_uid => $row->[2],
    file => $row->[4],
  };
  $Structs{$row->[3]}->{file} =~ s/sdd1/intake1-data/;
  $Pats{$row->[0]}->{Structs}->{$row->[3]} = 1;
}, sub {}, "RTSTRUCT", $ARGV[0], $ARGV[1]);
$get_files->RunQuery(sub { 
  my($row) = @_;
  $Doses{$row->[3]} = {
    patient_id => $row->[0],
    modality => $row->[1],
    series_instance_uid => $row->[2],
    file => $row->[4],
  };
  $Doses{$row->[3]}->{file} =~ s/sdd1/intake1-data/;
  $Pats{$row->[0]}->{Doses}->{$row->[3]} = 1;
}, sub {}, "RTDOSE", $ARGV[0], $ARGV[1]);
$get_files->RunQuery(sub { 
  my($row) = @_;
  $Plans{$row->[3]} = {
    patient_id => $row->[0],
    modality => $row->[1],
    series_instance_uid => $row->[2],
    file => $row->[4],
  };
  $Plans{$row->[3]}->{file} =~ s/sdd1/intake1-data/;
  $Pats{$row->[0]}->{Plans}->{$row->[3]} = 1;
}, sub {}, "RTPLAN", $ARGV[0], $ARGV[1]);
#print "Patients: ";
#Debug::GenPrint($dbg, \%Pats, 1);
#print "\n";
my %UnlinkedPlans;
my %UnlinkedDoses;
for my $i (keys %Doses){
  my $file = $Doses{$i}->{file};
  my $cmd = "GetElementValue.pl $file '(300c,0002)[0](0008,1155)'";
  open FILE, "$cmd|";
  my $line = <FILE>;
  close FILE;
  chomp $line;
  unless(exists $Plans{$line}) {
    my $pat_id = $Doses{$i}->{patient_id};
    print "Dose ($i) not linked for patient $pat_id\n";
    print "\tlinked to $line\n";
    print "\tfile: $file\n";
    print "For patient_id $pat_id:\n";
    print "\tStructs:\n";
    for my $str (keys %{$Pats{$pat_id}->{Structs}}){
      print "\t\t$str\n";
    }
    print "\tDoses:\n";
    for my $str (keys %{$Pats{$pat_id}->{Doses}}){
      print "\t\t$str\n";
    }
    print "\tPlans:\n";
    for my $str (keys %{$Pats{$pat_id}->{Plans}}){
      print "\t\t$str\n";
    }
  }
}
for my $i (keys %Plans){
  my $file = $Plans{$i}->{file};
  my $cmd = "GetElementValue.pl $file '(300c,0060)[0](0008,1155)'";
  open FILE, "$cmd|";
  my $line = <FILE>;
  close FILE;
  chomp $line;
  unless(exists $Structs{$line}) {
    my $pat_id = $Plans{$i}->{patient_id};
    print "Plan ($i) not linked for patient $pat_id\n";
    print "\tlinked to $line\n";
    print "\tfile: $file\n";
    print "For patient_id $pat_id:\n";
    print "\tStructs:\n";
    for my $str (keys %{$Pats{$pat_id}->{Structs}}){
      print "\t\t$str\n";
    }
    print "\tDoses:\n";
    for my $str (keys %{$Pats{$pat_id}->{Doses}}){
      print "\t\t$str\n";
    }
    print "\tPlans:\n";
    for my $str (keys %{$Pats{$pat_id}->{Plans}}){
      print "\t\t$str\n";
    }
  }
}
