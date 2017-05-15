#!/usr/bin/perl -w
use strict;
use Posda::DB::PosdaFilesQueries;
my $ins = PosdaDB::Queries->GetQueryInstance('InsertInitialDicomDD');
my $usage = <<EOF;
ParseDicomDD.pl <csv file>
EOF
if($ARGV[0] eq "-h") { die $usage }
unless(-f $ARGV[0]) { die $usage }
open FILE, "<$ARGV[0]";
while (my $line = <FILE>){
  chomp $line;
  $line =~ s/\r$//;
  my($tag, $remain);
  if($line =~ /^\"(\(....,....\))\",(.*)$/){
    $tag = $1; $remain = $2;
    $tag =~ tr/A-F/a-f/;
    my($name, $keyword, $vr, $vm, $foo) =
      split(/,/, $remain);
    $keyword =~ s/ //g;
    my $is_ret = 'false';
    my $comment = "";
    if($foo =~ /RET/){ $is_ret = 'true' } else{
      $comment = $foo;
    }
    print "$tag|$name|$keyword|$vr|$vm|$is_ret|$comment\n";
    $ins->RunQuery(sub {}, sub {},
    $tag, $name, $keyword, $vr, $vm, $is_ret, $comment);
  }
}
