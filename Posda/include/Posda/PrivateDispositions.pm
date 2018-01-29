#!/usr/bin/perl -w
use strict;
use Posda::DB::PosdaFilesQueries;
use Digest::MD5;
use Posda::UUID;
use Time::Piece;
package Posda::PrivateDispositions;

my $get_disp = PosdaDB::Queries->GetQueryInstance("GetElementByPrivateDispositionSimple");
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

sub new{
  my($class, $uid_root, $shift, $low_date, $high_date) = @_;
  my $this = {
    uid_root => $uid_root,
    shift => $shift,
    low_date => $low_date,
    high_date => $high_date,
  };
  if(defined($this->{low_date}) && defined($this->{high_date})){
    my $low_date_obj = Time::Piece->strptime($low_date, "%Y%m%d");
    $this->{low_date_int} = $low_date_obj->epoch;
    my $high_date_obj = Time::Piece->strptime($high_date, "%Y%m%d");
    $this->{high_date_int} = $high_date_obj->epoch;
  }
  return bless $this, $class;
}
sub HashUID{
  my($this, $uid) = @_;
  if($uid =~ /^$this->{uid_root}/){
    return $uid;
  }
  my $ctx = Digest::MD5->new;
  $ctx->add($uid);
  my $dig = $ctx->digest;
  my $new_uid = "$this->{uid_root}." . Posda::UUID::FromDigest($dig);
  $new_uid = substr($new_uid, 0, 64);
  return $new_uid;
}
sub ShiftIntegerDate{
  my($this, $epoch) = @_;
  my $shifted = $epoch + ($this->{shift} * 60 * 60 * 24);
  if(defined($this->{low_date}) && defined($this->{high_date})){
    if($shifted > $this->{low_date_int} && $shifted < $this->{high_date_int}){
      #print "Returning shifted\n";
      return $shifted;
    }
    return $epoch;
  }
  #print "Returning unshifted\n\tbefore: $epoch, after: $shifted\n" .
  #  "\tLow: $this->{low_date_int}, high: $this->{high_date_int}\n";
  return $shifted;
}
sub ShiftDate{
  my($this, $date_string) = @_;
  unless(defined $date_string) { return $date_string }
  if($date_string eq "" ) { return $date_string }
  if($date_string =~ /^(........)(.*)$/){
    my $old_date_string = $1;
    my $old_more = $2;
    if($old_date_string == 0) { return $date_string }
    $old_date_string =~ /^(....)(..)(..)$/;
    my $yr = $1; my $m = $2, my $day = $3;
    unless($m > 0 && $m <13) { return $date_string }
    unless($day > 0 && $m <32) { return $date_string }
    #print STDERR "$old_date_string\n";
    my $date = Time::Piece->strptime($old_date_string, "%Y%m%d");
    my $epoch = $date->epoch;
    my $shifted_epoch = $this->ShiftIntegerDate($epoch);
    if($epoch == $shifted_epoch) { return $date_string }
    my $new_date = Time::Piece->new($shifted_epoch);
    my $new_date_string = $new_date->strftime("%Y%m%d");
    return $new_date_string . $old_more;
  } else {
    return $date_string;
  }
}
#########
sub Apply{
  my($this, $ds) = @_;
  for my $e (keys %DeleteByElement){
  #  print "\tDeleting: $e\n";
    $ds->Delete($e);
  }
  for my $p (keys %DeleteByPattern){
    my $list = $ds->NewSearch($p);
    if(defined($list) && ref($list) eq "ARRAY" && $#{$list} >= 0){
      my @terms = split(/\[<\d+>\]/, $p);
      #print "Pattern: $p\n";
      #print "Terms:\n";
      #for my $i (@terms) { print "\t$i\n" }
      pat:
      for my $in (0 .. $#{$list}){
        my $new_e = "";
        my $i_list = $list->[$in];
        #print "Match:\n";
  #      for my $i (@$i_list){
  #        print "\t$i\n";
  #      }
        unless($#terms == $#{$i_list} + 1) {
          my $ill = $#{$i_list};
          my $terml = $#terms;
  #        print "Error i_list = $ill, terms = $terml\n";
        }
        for my $t (0 .. $#terms){
          $new_e = $new_e . $terms[$t];
          unless($t == $#terms){
            $new_e = $new_e . "[$i_list->[$t]]";
          }
        }
  #      print "Deleting $new_e\n";
        $ds->Delete($new_e);
      }
    }
  }
  for my $e (keys %HashByElement){
    my $u = $ds->Get($e);
    if(defined $u && $u ne "" && $u =~ /^[0-9\.]+$/){
      my $nu = $this->HashUID($u);
      unless($nu eq $u){
        #print "\tElement: $e\n";
        #print "\t$u\n\t =>\n\t$nu\n";
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
          my $nu = $this->HashUID($u);
          unless($nu eq $u){
            #print "\tElement: $new_e\n";
            #print "\t$u\n\t =>\n\t$nu\n";
            $ds->Insert($new_e, $nu);
          }
        }
      }
    }
  }
  for my $e (keys %OffsetDate){
    my $date = $ds->Get($e);
    if(defined($date) && $date ne ""){
      my $new_date = $this->ShiftDate($date);
      if($new_date ne $date){
        #print "\tElement: $e\n";
        #print "\t$date => $new_date\n";
        $ds->Insert($e, $new_date);
      }
    }
  }
  for my $e (keys %OffsetInteger){
  #print "element: $e\n";
    my $date = $ds->Get($e);
  #print "Date before: $date\n";
    if(defined($date) && $date ne ""){
      my $new_date = $this->ShiftIntegerDate($date);
      if($new_date != $date){
        #print "\tElement: $e\n";
        #print "\t$date => $new_date\n";
        $ds->Insert($e, $new_date);
      }
    }
  }
}
1;
