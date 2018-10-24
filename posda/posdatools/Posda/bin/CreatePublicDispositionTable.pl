#!/usr/bin/perl -w
use strict;
use Posda::DB::PosdaFilesQueries;    
my $usage = <<EOF;
CreatePublicDispositionTable.pl <sop_class_uid> <description> <who>

  Expects rows on STDIN in following format:
  <Tag>^<VR>^<Disposition>^<NameChain>
EOF
unless($#ARGV == 2) {die $usage}
my $ctable = PosdaDB::Queries->GetQueryInstance("ClearPublicDispositions");
my $gsig = PosdaDB::Queries->GetQueryInstance("GetElementSignature");
my $ins = PosdaDB::Queries->GetQueryInstance("InsertPublicDisposition");
my $upd = PosdaDB::Queries->GetQueryInstance("UpdateElementDisposition");
my($sop_class_uid, $desc, $who, $why) = @ARGV;
$ctable->RunQuery(sub { }, sub { }, $sop_class_uid, $desc);
line:
while(my $line = <STDIN>){
  chomp $line;
  my($tag, $vr, $disp, $nc) = split (/\^/, $line);
  $tag =~ s/^-//;
  $tag =~ s/-$//;
  if($tag =~ /,"/) {
    print "Tag $tag is a private tag\n";
    next line;
  }
  my $id;
  $gsig->RunQuery(sub {
    my($row) = @_;
    $id = $row->[0];
  }, sub {}, $tag, $vr);
  unless(defined $id) { next line }
  $ins->RunQuery(sub {}, sub {}, $id, $sop_class_uid, $desc, $disp);
  $upd->RunQuery(sub {}, sub {}, 'p', $nc, $tag, $vr);
}
