#!/usr/bin/perl -w
use strict;
use File::Temp qw/ tempfile /;
use Posda::DB::PosdaFilesQueries;
use Posda::Try;
use Posda::DiffDicom;
use Posda::Dataset;
use Digest::MD5;

my $usage = <<EOF;
StreamingNonDicomEditCompare.pl <subprocess_invocation_id>
or
StreamingNonDicomEditCompare.pl -h

Populates non_dicom_edit_compare table
Expect input lines in following format:
<file_id>|<from_file>|<to_file>
EOF

$|=1;

if($#ARGV == 0 && $ARGV[0] eq "-h" ){ die $usage }
unless($#ARGV == 0 ){ die $usage }

my ($invoc_id) = @ARGV;

my $ins = PosdaDB::Queries->GetQueryInstance(
  "InsertIntoNonDicomEditCompareFixed");
my %FileIdByDig;
line:
while(my $line = <STDIN>){
  chomp $line;
#print STDERR "Received Compare Instructions: $line\n";
  my($file_id, $from_file, $to_file) =
    split(/\|/, $line);
  my $fh;
  #my $cmd = "diff \"$from_file\" \"$to_file\"";
  #open $fh, "-|", "$cmd" or die;
  #my $rept = slurp($fh);
  my $rept = "No diffs being done right now.";
  if(length($rept) <= 0){
    print "Failed: $file_id|no lines in rept\n";
    next line;
  }
  my $ctx1 = Digest::MD5->new;
  open my $fh1, "<$from_file";
  $ctx1->addfile($fh1);
  my $f_dig = $ctx1->hexdigest;
  close($fh1);
  my $ctx2 = Digest::MD5->new;
  open my $fh2, "<$to_file";
  $ctx2->addfile($fh2);
  my $t_dig = $ctx2->hexdigest;
  close($fh2);
  my $ctx3 = Digest::MD5->new;
  $ctx3->add($rept);
  my $rept_dig = $ctx3->hexdigest;
  my $rept_file_id;
  if(exists $FileIdByDig{$rept_dig}){
    $rept_file_id = $FileIdByDig{$rept_dig};
  } else {
    my($fhs, $rept_path) = tempfile();
    $fhs->print($rept);
    my $cmd = 
      "ImportSingleFileIntoPosdaAndReturnId.pl \"$rept_path\" " .
      "\"Difference report\"";
    my $result = `$cmd`;
    if($result =~ /File id: (.*)/){
      $rept_file_id = $1;
      $FileIdByDig{$rept_dig} = $rept_file_id;
    } else {
      print "Failed: $file_id|Couldn't import rept into posda\n";
      next line;
    }
  }
  $ins->RunQuery(sub{}, sub{},
    $invoc_id, $f_dig, $t_dig, $rept_file_id, $to_file);
  print "Completed: $file_id|$from_file|$to_file|$rept_file_id\n";
}
sub slurp {
  my $fh = shift;
  local $/ = undef;
  my $cont = <$fh>;
  close $fh;
  return $cont;
}
