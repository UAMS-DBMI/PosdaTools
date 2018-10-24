#!/usr/bin/perl -w
use strict;
use File::Temp qw/ tempfile /;
use Posda::DB::PosdaFilesQueries;
use Debug;
my $dbg = sub{print STDERR @_};
my $usage = "CompareDupSopSeriesList.pl";
unless($#ARGV == -1 ){ die $usage }
my $query = PosdaDB::Queries->GetQueryInstance("DuplicateSopsInSeries");
my $get_file = PosdaDB::Queries->GetQueryInstance("FilePathByFileId");
unless($#ARGV == -1 ){ die $usage }
my @SeriesList;
while(my $line = <STDIN>){
  chomp $line;
  push @SeriesList, $line;
}
print "\"Series Instance UID\",\"Sop Instance UID\"," .
  "\"File_Id From\",\"First Loaded\"," .
  "\"File_Id To\",\"First Loaded\",\"Differences\"\r\n";
for my $i (0 .. $#SeriesList){
  my $series_inst = $SeriesList[$i];
  my %data;
  $query->RunQuery(
    sub{
      my($row) = @_;
      my($sop_inst, $import_time, $file_id) = @$row;
      if(
        exists($data{$sop_inst}->{$file_id}) &&
        $data{$sop_inst}->{$file_id} le $import_time
      ){
        return;
      } else {
        $data{$sop_inst}->{$file_id} = $import_time;
      }
    },
    sub {
    },
    $series_inst
  );
  my $sop_inst = [keys %data]->[0];
  my @file_id_list = sort 
    { $data{$sop_inst}->{$a} cmp $data{$sop_inst}->{$b} } 
    keys %{$data{$sop_inst}};
  for my $f (0 .. $#file_id_list-1){
    my $t = $f + 1;
    my $file_id_f = $file_id_list[$f];
    my $file_it_f = $data{$sop_inst}->{$file_id_f};
    my $file_path_f;
    $get_file->RunQuery(sub {
        my($row) = @_;
        $file_path_f = $row->[0];
      },
      sub {}, $file_id_f);
    my $file_id_t = $file_id_list[$t];
    my $file_it_t = $data{$sop_inst}->{$file_id_t};
    my $file_path_t;
    $get_file->RunQuery(sub {
        my($row) = @_;
        $file_path_t = $row->[0];
      },
      sub {}, $file_id_t);
    my $dump_1 = File::Temp::tempnam("/tmp", "one");
    my $dump_2 = File::Temp::tempnam("/tmp", "two");
    my $cmd1 = "DumpDicom.pl $file_path_f > $dump_1";
    my $cmd2 = "DumpDicom.pl $file_path_t > $dump_2";
print STDERR "cmd1: $cmd1\n";
print STDERR "cmd2: $cmd2\n";
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
    if($f == 0){
      print "\"$series_inst\",$sop_inst,";
    } else {
      print ",,";
    }
    print "\"$file_id_f\",\"$file_it_f\"," .
     "\"$file_id_t\",\"$file_it_t\"," .
     "\"$diff\"\r\n";
  }
}
