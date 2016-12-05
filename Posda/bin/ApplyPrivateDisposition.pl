#!/usr/bin/perl -w
use strict;
use Posda::DB::PosdaFilesQueries;
use Posda::Try;
use Digest::MD5;
use Posda::UUID;
use Time::Piece;
my $usage = <<EOF;
ApplyPrivateDisposition.pl <from_file> <to_file> <uid_root> <offset> <low_date> <high_date>
  Applies private tag disposition from knowledge base to <from_file>
  writes result into <to_file>
  UID's not hashed if they begin with <uid_root>
  date's not offset unless result of offset leaves date between <low_date> and <high_date>
EOF
unless($#ARGV == 5) { die $usage }
my $uid_root = $ARGV[2];
sub HashUID{
  my($uid) = @_;
  if($uid =~ /^$uid_root/){
    return $uid;
  }
  my $ctx = Digest::MD5->new;
  $ctx->add($uid);
  my $dig = $ctx->digest;
  my $new_uid = "$uid_root." . Posda::UUID::FromDigest($dig);
  $new_uid = substr($new_uid, 0, 64);
  return $new_uid;
}
my $offset = $ARGV[3];
my $low_date = $ARGV[4];
my $low_date_obj = Time::Piece->strptime($low_date, "%Y-%m-%d");
my $low_date_int = $low_date_obj->epoch;
my $high_date = $ARGV[5];
my $high_date_obj = Time::Piece->strptime($low_date, "%Y-%m-%d");
my $high_date_int = $high_date_obj->epoch;
sub ShiftIntegerDate{
  my($epoch) = @_;
  my $shifted = $epoch + $offset;
  if($shifted > $low_date_int && $shifted < $high_date_int){
    return $shifted;
  }
  return $epoch;
}
sub ShiftDate{
  my($date_string) = @_;
  if($date_string =~ /^(........)(.*)$/){
    my $old_date_string = $1;
    my $old_more = $2;
    my $date = Time::Piece->strptime($old_date_string, "%Y%m%d");
    my $epoch = $date->epoch;
    my $shifted_epoch = ShiftIntegerDate($epoch);
    if($epoch == $shifted_epoch) { return $date_string }
    my $new_date = Time::Piece->new($shifted_epoch);
    my $new_date_string = $new_date->strtftime("%Y%m%d");
    return $new_date_string . $old_more;
  } else {
    return $date_string;
  }
}
my $get_disp = PosdaDB::Queries->GetQueryInstance("GetElementByPrivateDisposition");
my %DeleteByElement;
my %DeleteByPattern;
my %OffsetDate;
my %OffsetInteger;
my %HashByElement;
my %HashByPattern;
$get_disp->RunQuery(sub {
  my($row) = @_;
  if($row->[0] =~ /\[/){
    $DeleteByPattern{$row->[0]} = 1;
  } else {
    $DeleteByElement{$row->[0]} = 1;
  }
}, sub {}, 'd');
$get_disp->RunQuery(sub {
  my($row) = @_;
  $OffsetDate{$row->[0]} = 1;
}, sub {}, 'o');
$get_disp->RunQuery(sub {
  my($row) = @_;
  $OffsetInteger{$row->[0]} = 1;
}, sub {}, 'oi');
$get_disp->RunQuery(sub {
  my($row) = @_;
  if($row->[0] =~ /\[/){
    $HashByPattern{$row->[0]} = 1;
  } else {
    $HashByElement{$row->[0]} = 1;
  }
}, sub {}, 'h');
my $try = Posda::Try->new($ARGV[0]);
unless(exists $try->{dataset}){ die "$ARGV[0] is not a DICOM file" }
my $ds = $try->{dataset};
print "Editing file $ARGV[0]\n";
for my $e (keys %DeleteByElement){
#  print "\tDeleting: $e\n";
  $ds->Delete($e);
}
for my $p (keys %DeleteByPattern){
  my $list = $ds->NewSearch($p);
  if(defined($list) && ref($list) eq "ARRAY" && $#{$list} >= 0){
    pat:
    for my $i (0 .. $#{$list}){
      unless(ref($i) eq "ARRAY") {
        print STDERR "not a list";
        next pat;
      }
      my $new_e = $p;
      for my $j (0 .. $#{$i}){
        $new_e =~ s/$i->{$j}/<$j>/;
      }
      print "Deleting $new_e\n";
      $ds->Delete($new_e);
    }
  }
}
for my $e (keys %HashByElement){
  my $u = $ds->Get($e);
  if(defined $u && $u ne "" && $u =~ /^[0-9\.]+$/){
    my $nu = HashUID($u);
    unless($nu eq $u){
      print "\tElement: $e\n";
      print "\t$u\n\t =>\n\t$nu\n";
      $ds->Insert($e, $nu);
    }
  }
}
for my $p (keys %HashByPattern){
  my $list = $ds->NewSearch($p);
  if(defined($list) && ref($list) eq "ARRAY" && $#{$list} >= 0){
    pat:
    for my $i (0 .. $#{$list}){
      unless(ref($i) eq "ARRAY") {
        print STDERR "not a list";
        next pat;
      }
      my $new_e = $p;
      for my $j (0 .. $#{$i}){
        my $new_e = $p;
        $p =~ s/$i->{$j}/<$j>/;
      }
      my $u = $ds->Get($new_e);
      if(defined $u && $u ne "" && $u =~ /^[0-9\.]+$/){
        my $nu = HashUID($u);
        unless($nu eq $u){
          print "\tElement: $new_e\n";
          print "\t$u\n\t =>\n\t$nu\n";
        $ds->Insert($new_e, $nu);
        }
      }
    }
  }
}
for my $e (keys %OffsetDate){
  my $date = $ds->Get($e);
  if(defined($date) && $date ne ""){
    my $new_date = ShiftDate($date);
    if($new_date ne $date){
      print "\tElement: $e\n";
      print "\t$date => $new_date\n";
      $ds->Insert($e, $new_date);
    }
  }
}
for my $e (keys %OffsetInteger){
  my $date = $ds->Get($e);
  if(defined($date) && $date ne ""){
    my $new_date = ShiftIntegerDate($date);
    if($new_date != $date){
      print "\tElement: $e\n";
      print "\t$date => $new_date\n";
      $ds->Insert($e, $new_date);
    }
  }
}
eval {
  $ds->WritePart10($ARGV[1], $try->{xfr_stx}, "POSDA", undef, undef);
};
if($@){
  print STDERR "Can't write $ARGV[1] ($@)\n";
  exit;
}
print "Wrote $ARGV[1]\n";
