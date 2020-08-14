#!/usr/bin/perl -w
use strict;
use Posda::BackgroundProcess;
use Posda::DB qw( Query );
my $usage = <<EOF;
/CollectAllUidsFromFileList.pl <?bkgrnd_id?> <activity_id> <notify>
  <activity_id>> - activity
  <notify> - user to notify

Expects the following list on <STDIN>
  <file_id>

Constructs a spreadsheet with with every "UID looking" value in 
any tag in the collection of files.
this spreadsheet has the following columns:
  <tag>
  <description>
  <uid>
  <note>

It also constructs spreadsheet which summarizes all of the warnings
produced by the parser when parsing these files.
This spreadsheet has the following columns:
  <warning message>
  <list of file_ids>

Invokes ListOfUidsInFile.pl as subprocess for each file to scan the files.

Uses query FilePathByFileId to get file_path

EOF
if($#ARGV == 0 && $ARGV[0] eq "-h"){
  print $usage;
  exit;
}
unless($#ARGV == 2){
  my $n_args = @ARGV;
  my $mess = "Wrong number of args ($n_args vs 3). Usage:\n$usage\n";
  print $mess;
  die "######################## subprocess failed to start:\n" .
      "$mess\n" .
      "#####################################################\n";
}
my($invoc_id, $activity_id, $notify) = @ARGV;
my @FileIds;
while(my $line = <STDIN>){
  chomp $line;
  $line =~ s/^\s*//;
  $line =~ s/\s*$//;
  push @FileIds, $line;
}
my $num_files = @FileIds;
print "Going to background to process $num_files files\n";

my $back = Posda::BackgroundProcess->new($invoc_id, $notify, $activity_id);
$back->Daemonize;
my %UidReport;
my %ErrorReport;
$back->WriteToEmail("CollectAllUidsFromFileList.pl starting to process $num_files files\n");
my $start = time;
my $q = Query('FilePathByFileId');
my $i = 0;
for my $file_id (@FileIds){
  $i += 1;
  my $path;
  $q->RunQuery(sub{
    my($row) = @_;
    $path = $row->[0];
  }, sub{}, $file_id);
  my $num_uids = keys %UidReport;
  my $num_errs = keys %ErrorReport;
  $back->SetActivityStatus("Scanning $i of $num_files files.  Uids: $num_uids, Errs: $num_errs");
  my $command = "ListOfUidsInFile.pl \"$path\"";
  open SUB, "$command|" or die "Can't open subcommand ($!)";
  my $line_no = 0;
  while(my $line = <SUB>){
    chomp $line;
    $line_no += 1;
    #$back->SetActivityStatus("$line_no of file $file_id");
    if($line =~ /^Potential/){
      my($type, $name, $tag, $uid) = split(/\|/, $line);
      $UidReport{$uid}->{$tag} = $name;
    } elsif ($line =~ /^Parse/){
      my($type, $error) = split(/\|/, $line);
      $ErrorReport{$error}->{$file_id} = 1;
    } else {
      $back->WriteToEmail("line not understood: \"$line\"\n");
    }
  }
}
$back->SetActivityStatus("Creating UID report");
my $uid_rep = $back->CreateReport("UidReport");
$uid_rep->print("tag,description,uid,note\n");
for my $uid(keys %UidReport){
  my $note = "";
  my @tags = keys %{$UidReport{$uid}};
  if(@tags >1){
    $note = "multiple tags";
  }
  my $tag = $tags[0];
  my $name = $UidReport{$uid}->{$tag};
  my $stag = $tag;
  $stag =~ s/"/""/g;
  $uid_rep->print("\"<$stag>\",$name,<$uid>,$note\n");
}
$back->SetActivityStatus("Creating Error report");
my $err_rep = $back->CreateReport("ErrorReport");
$err_rep->print("warning_message,List of file_ids\n");
for my $error (keys %ErrorReport){
  my @f_ids = keys %{$ErrorReport{$error}};
  $error =~ s/"/""/g;
  $err_rep->print("\"$error\",");
  my $list = "";
  for my $i (0 .. $#f_ids){
    $list .= $f_ids[$i];
    unless($i == $#f_ids) { $list .= " "}
  }
  $err_rep->print("\"$list\"\n");
}
my $elapsed = time - $start;
$back->Finish("Processed $num_files files in $elapsed seconds");;
