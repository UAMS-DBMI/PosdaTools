#!/usr/bin/perl -w
use strict;
use File::Temp qw/ tempfile /;
use DBI;
my $dbh = DBI->connect("dbi:Pg:dbname=N_posda_files");
my $get_files = $dbh->prepare(
  "select distinct file_id, root_path || '/' || rel_path as path\n" .    
  "from file_storage_root natural join file_location\n" .
  "  natural join file_sop_common natural join ctp_file\n" .
  "where sop_instance_uid = ? and visibility is null\n" .
  "order by file_id"
);
my $usage = "CompareDupSopList.pl";
unless($#ARGV == -1 ){ die $usage }
my @SopList;
while(my $line = <STDIN>){
  chomp $line;
  push @SopList, $line;
}
print "\"Sop InstanceUID\"," .
  "\"Num\",\"File_Id From\",\"File_Id To\",\"Differences\"\r\n";
for my $i (0 .. $#SopList){
  my @files;
  $get_files->execute($SopList[$i]);
  while(my $h = $get_files->fetchrow_hashref){
    push @files, [$h->{file_id}, $h->{path}];
  }
  if($#files > 0){
    my $num_files = @files;
    for my $j (0 .. $#files-1){
      my $file_1 = $files[$j]->[1];
      my $file_id_1 = $files[$j]->[0];
      my $file_2 = $files[$j + 1]->[1];
      my $file_id_2 = $files[$j + 1]->[0];
      my $dump_1 = File::Temp::tempnam("/tmp", "one");
      my $dump_2 = File::Temp::tempnam("/tmp", "two");
      my $cmd1 = "DumpDicom.pl $file_1 > $dump_1";
      my $cmd2 = "DumpDicom.pl $file_2 > $dump_2";
      `$cmd1`;`$cmd2`;
      my $diff = "";
      open FILE, "diff $dump_1 $dump_2|";
      while(my $line = <FILE>){
        chomp $line;
        $line =~ s/"/""/g;
        $diff .= $line . "\r\n";
      }
      unlink $dump_1;
      unlink $dump_2;
      if($j == 0){
        print "\"$SopList[$i]\",$num_files,";
      } else {
        print ",,";
      }
      print "\"$file_id_1\",\"$file_id_2\",\"$diff\"\r\n";
    }
  }
}
