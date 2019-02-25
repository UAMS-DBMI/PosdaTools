#!/usr/bin/perl -w
use strict;
use Storable qw(fd_retrieve);
use Posda::DB 'Query';
use File::Slurp;
use Debug;
my $dbg = sub {print @_ };
my $get_man = Query("ManifestsByFileId");
my $ins_man = Query("InsertManifestRow");
Query("AllManifests")->RunQuery(sub{
  my($row) = @_;
  my($file_id, $import_time, $size, $path, $alt_path) = @$row;
  my @manifest_in_db;
  $get_man->RunQuery(sub{
    my($row) = @_;
    push @manifest_in_db, $row;
  }, sub {}, $file_id);
  open MANIFEST, "cat $path|FixStupidCtpCsvFiles.pl|CsvStreamToPerlStruct.pl|"
  or die "Can't get manifest: $path";
  my $frozen = read_file(\*MANIFEST);
  my $text;
  if($frozen =~ /^pst0(.*)$/s){
    $text = $1;
  } else {
    $text = $frozen;
  }
  my $struct = &Storable::thaw($text);
  unless($struct->{status} eq "OK") {
    print STDERR "Manifest ($path) didn't parse\n";
    return;
  }
  if(@manifest_in_db > 0){
    unless($#{$struct->{rows}} == @manifest_in_db){
      print STDERR "manifest ($path) doesn't match db\n";
    } else {
      print STDERR "manifest ($path) matches db\n";
    }
    return;
  }
  if($#{$struct->{rows}} == 0){
    print STDERR "manifest ($path) matches db (zero length)\n";
    return;
  }
  print STDERR "Entering manifest ($path) into DB\n";
  for my $i (1 .. $#{$struct->{rows}}){
    my $r = $struct->{rows}->[$i];
    my($coll, $site, $pat_id, $sty_date, $series_inst,
      $sty_desc, $ser_desc, $modality, $num_files, $foo) = @$r;
    $ins_man->RunQuery(sub{},sub{},
       $file_id, $i, $coll, $site,
       $pat_id, $sty_date, $series_inst,
       $sty_desc, $ser_desc, $modality, $num_files);
  }
}, sub {});
