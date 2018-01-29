#!/usr/bin/perl -w
use strict;
use File::Temp qw/ tempfile /;
use Posda::DB 'Query';
use Posda::Try;

my $usage = <<EOF;
StreamingMoveFromPublicToPosda.pl <copy_from_public_id>
or
StreamingMoveFromPublicToPosda.pl -h

Reads file from Public, adds site_name and moves to Posda.
Updates corresponding row in corresponding file_copy_from_public table

Expect input lines in following format (relationships between files
is the responsibility of parent process):
<collection>&<site_in_public>&<sop_instance_uid>&<file_path_in_public>

Uses scripts:
  ImportSingleFileIntoPosdaAndReturnId.pl
EOF

$|=1;

if($#ARGV == 0 && $ARGV[0] eq "-h" ){ die $usage }
unless($#ARGV == 0 ){ die $usage }

my ($copy_from_public_id) = @ARGV;

my $record_ins = Query("AddInsertedToFileCopyFromPublic");
line:
while(my $line = <STDIN>){
  chomp $line;
  my($coll, $site, $sop_instance_uid, $path_in_public) = split /&/, $line;
  my $try = Posda::Try->new($path_in_public);
  unless(exists $try->{dataset}) {
    print STDERR "Error: $path_in_public didn't parse as DICOM\n";
    next line;
  }
  my($fh, $fname) = tempfile();
  $try->{dataset}->Insert('(0013,"CTP",12)', $site);
  $try->{dataset}->Insert('(0013,"CTP",11)', $coll);
  $try->{dataset}->WritePart10Fh($fh, $try->{xfr_stx}, "POSDA");
  close $fh;
  my $cmd = "ImportSingleFileIntoPosdaAndReturnId.pl \"$fname\" " .
    "\"copy_from_public: $copy_from_public_id\"";
  open CMD, "$cmd|";
  my $id;
  while(my $line = <CMD>){
    if($line =~ /^Error: (.*)$/){
      print STDERR "Error importing file into Posda: $1\n";
    } elsif($line =~ /^File id: (.*)$/){
      $id = $1;
    }
  }
  unless(defined $id){
    print STDERR "Couldn't import $fname ($sop_instance_uid) into Posda\n";
    #unlink $fname;
    next line;
  }
  unlink $fname;
  $record_ins->RunQuery(sub {}, sub {}, $id, $copy_from_public_id, 
    $sop_instance_uid);
}
