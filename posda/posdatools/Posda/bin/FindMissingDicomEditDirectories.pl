#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
my $q = Query("GetEditStatus");
$q->RunQuery(sub{
  my($row) = @_;
  my($id, $start_creation_time,
    $duration, $to_edit, $changed,
    $not_changed, $disposition,
    $dest_dir) = @$row;
  unless(-d $row){
    print "$id|$disposition|$dest_dir\n";
  }
}, sub {});
