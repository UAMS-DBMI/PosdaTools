#!/usr/bin/perl -w
use strict;
use Posda::DB::PosdaFilesQueries;
use Posda::DB 'Query';
use Posda::Try;
use Digest::MD5;
use Posda::UUID;
use Time::Piece;
use Posda::NBIASubmit;

my $usage = <<EOF;
ApplyPrivateDispositionUnconditionalDate2.pl <backgrnd_id> <file_id> <from_file> <to_file> <uid_root> <offset> <batch>
  Applies private tag disposition from knowledge base to <from_file>
  writes result into <to_file>
  UID's not hashed if they begin with <uid_root>
  date's always offset
  Collection and Site are read from the file
  Site Code must be defined in site_codes
  Collection Code must be defined in collection_codes
  Once written, the NBIA Submissions API is called with the filename
EOF

unless($#ARGV == 6) { die $usage }
my ($subprocess_invocation_id, $file_id, $from_file, $to_file, $uid_root,
    $offset, $batch) = @ARGV;

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
# my $d = $from_file;
#my $frac = "";
#if($d =~ /^([\+\-]*\d+)(\.\d+)$/){
#  $d = $1;
#  $frac = $2;
#  if($d < 0){
#    $d -=  1;
#    $frac = 1 - $frac;
#    if($frac =~ /(\.\d+)$/){
#      $frac = $1;
#    } else {
#      $frac = "";
#    }
#  }
#}
#my $date = Time::Piece->new($d);
#my $val = $date->strftime("%Y%m%d%H%M%S");
#print "Date: $val$frac\n";

sub ShiftIntegerDate{
  my($epoch) = @_;
  my $shifted = $epoch + ($offset * 60 * 60 * 24);
  my $frac = "";
  if($shifted =~  /^([\+\-]*\d+)(\.\d+)$/){
    $shifted = $1;
    $frac = $2;
    if($shifted < 0){
      # $d -= 1;
      $frac = 1 - $frac;
      if($frac =~ /(\.\d+)$/){
        $frac = $1;
      } else {
        $frac = "";
      }
    }
  }
  return "$shifted$frac";
}
sub ShiftDate{
  my($date_string) = @_;

  # Sometimes the when we read the tag it is
  # returned as an array. I believe this is almost
  # always a mistake, and only the first value
  # in the array is valid, so only use it.
  if (ref($date_string) eq "ARRAY") {
    $date_string = shift @{$date_string};
  }

  if($date_string =~ /^(........)(.*)$/){
    my $old_date_string = $1;
    my $old_more = $2;
    my $date = Time::Piece->strptime($old_date_string, "%Y%m%d");
    my $epoch = $date->epoch;
    my $shifted_epoch = ShiftIntegerDate($epoch);
    if($epoch == $shifted_epoch) { return $date_string }
    my $new_date = Time::Piece->new($shifted_epoch);
    my $new_date_string = $new_date->strftime("%Y%m%d");
    return $new_date_string . $old_more;
  } else {
    return $date_string;
  }
}
my $get_disp = PosdaDB::Queries->GetQueryInstance("GetElementByPrivateDispositionSimple");
my %DeleteByElement;
my %DeleteByPattern;
my %OffsetDate;
my %OffsetDateByPattern;
my %OffsetInteger;
my %HashByElement;
my %HashByPattern;

# Delete Trial and Site name from Group 13
$DeleteByElement{'(0013,"CTP",11)'} = 1;
$DeleteByElement{'(0013,"CTP",12)'} = 1;

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
  my $tag = $row->[0];
  if($tag =~ /</){
    $OffsetDateByPattern{$tag} = 1;
  }else {
    $OffsetDate{$tag} = 1;
  }
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

my $try = Posda::Try->new($from_file);
unless(exists $try->{dataset}){ die "$from_file is not a DICOM file" }
my $ds = $try->{dataset};

# Get the Collection and Site from the file, for use in NBIASubmit later
my $collection_name = $ds->Get('(0013,"CTP",10)');
my $site_name = $ds->Get('(0013,"CTP",12)');

my $temp_results = Query('GetSiteCodeBySite')->FetchOneHash($site_name);
my $site_code = $temp_results->{site_code};

my $temp_results2 = Query('GetCollectionCodeByCollection')->FetchOneHash($collection_name);
my $collection_code = $temp_results2->{collection_code};

my $temp_results3 = Query('GetTPAURLBySubprocess')->FetchOneHash($subprocess_invocation_id);
my $tpa_url = $temp_results3->{third_party_analysis_url};

# NBIA's idea of a site_id is our site_code + collection_code
my $site_id = "$site_code$collection_code";



#print "Editing file $from_file\n";
for my $e (keys %DeleteByElement){
  #print "\tDeleting: $e\n";
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
    my $nu = HashUID($u);
    unless($nu eq $u){
      #print "\tElement: $e\n";
      #print "\t$u\n\t =>\n\t$nu\n";
      $ds->Insert($e, $nu);
    }
  }
}
for my $p (keys %HashByPattern){
#print STDERR "**********\nHash by Pattern\nelement: $p\n";
  my $list = $ds->NewSearch($p);
  if(defined($list) && ref($list) eq "ARRAY" && $#{$list} >= 0){
    pat:
    for my $i (0 .. $#{$list}){
      my $ps = $list->[$i];
      unless(ref($ps) eq "ARRAY") {
#        print STDERR "not a list\n";
        next pat;
      }
      my $new_e = $ds->DefaultSubstitute($p, $ps);
#      for my $j (0 .. $#{$i}){
#        my $new_e = $p;
#        $p =~ s/$i->{$j}/<$j>/;
#      }
      my $u = $ds->Get($new_e);
      if(defined $u && $u ne "" && $u =~ /^[0-9\.]+$/){
        my $nu = HashUID($u);
        unless($nu eq $u){
#          print STDERR "\tElement: $new_e\n";
#          print STDERR "\t$u\n\t =>\n\t$nu\n";
          $ds->Insert($new_e, $nu);
        }
      }
    }
  }
}
for my $e (keys %OffsetDate){
#print STDERR "**********\nOffsetDate\nelement: $e\n";
  my $date = $ds->Get($e);
  if(defined($date) && $date ne ""){
    my $new_date;
    eval {
      $new_date = ShiftDate($date);
    };
    if ($@) {
      die "%%%E Could not parse date '$date' in $e\n";
    }
    if($new_date ne $date){
      #print "\tElement: $e\n";
      #print "\t$date => $new_date\n";
      $ds->Insert($e, $new_date);
    }
  }
}
for my $e (keys %OffsetDateByPattern){
#print STDERR "**********\nOffsetDatePattern\nelement: $e\n";
  my $m = $ds->NewSearch($e);
  if(defined $m && ref($m) eq "ARRAY"){
    for my $p (@$m){
      my $tag = $ds->DefaultSubstitute($e, $p);
#      print STDERR "tag: $tag\n";
      my $date = $ds->Get($tag);
      if(defined($date) && $date ne ""){

        my $new_date;
        eval {
          $new_date = ShiftDate($date);
        };

        if ($@) {
          die "%%%E Could not parse date '$date' in $e\n";
        }

        if($new_date ne $date){
#          print STDERR "\tElement: $tag\n";
#          print STDERR "\t$date => $new_date\n";
          $ds->Insert($tag, $new_date);
        }
      }
    }
  }
}
for my $e (keys %OffsetInteger){
#print "OffsetInteger:\nelement: $e\n";
  my $date = $ds->Get($e);
#print "Date before: $date\n";
  if(defined($date) && $date ne "" && $date > 0){
    my $new_date = ShiftIntegerDate($date);
    if($new_date != $date){
      #print "\tElement: $e\n";
      #print "\t$date => $new_date\n";
      $ds->Insert($e, $new_date);
    }
  }
}
eval {
  $ds->WritePart10($to_file, $try->{xfr_stx}, "POSDA", undef, undef);
};
if($@){
  print STDERR "Can't write $to_file ($@)\n";
  exit;
}

Posda::NBIASubmit::AddToSubmitAndThumbQs(
  $subprocess_invocation_id,
  $file_id,
  $collection_name,
  $site_name,
  $site_id,
  $batch,
  $to_file,
  $tpa_url
);
