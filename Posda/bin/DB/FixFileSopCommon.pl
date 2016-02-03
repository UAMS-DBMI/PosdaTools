#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/bin/DB/FixFileSopCommon.pl,v $ #$Date: 2016/01/26 19:37:14 $
#$Revision: 1.1 $
#
use strict;
use DBI;
use Posda::Try;
my $dbh = DBI->connect("DBI:Pg:database=$ARGV[0]", "", "");
my $q = <<EOF;
select root_path || '/' || rel_path as path from file_storage_root natural join file_location
where file_id = ?
EOF
my $qh = $dbh->prepare($q);
my $qh1 = $dbh->prepare("select count(*) from file_sop_common where file_id = ?");
while(my $line = <STDIN>){
  chomp $line;
  unless($line =~ /^[\d]+$/) {
    print STDERR "Bad file id: $line\n";
    next;
  }
  my @rows;
  $qh->execute($line);
  while(my $h = $qh->fetchrow_hashref){
    push @rows, $h;
  }
  if($#rows < 0){
    print STDERR "No file row for file_id: $line\n";
    next;
  }
  unless($#rows == 0){
    print STDERR "Multiple file rows for file_id: $line\n";
    next;
  }
  my $file_path = $rows[0]->{path};
  $qh1->execute($line);
  my @fsc_rows;
  while(my $h = $qh1->fetchrow_hashref){
    push(@fsc_rows, $h);
  }
  if($#fsc_rows > 0 || $#fsc_rows < 0){
    print STDERR "??????? file_id: $line\n";
    next;
  }
  my $num_rows = $fsc_rows[0]->{count};
  if($num_rows > 1){
    print STDERR "Multiple file_sop_common rows for file_id: $line\n";
    next;
  }
  if($num_rows == 1){
    print STDERR "One file_sop_common row for file_id: $line\n";
    next;
  }
  my $try = Posda::Try->new($file_path);
  unless(exists $try->{dataset}) {
    print STDERR "file: $file_path has no dataset\n";
    next;
  }
  my $ds = $try->{dataset};
  my $sop_inst = $ds->Get("(0008,0018)");
  unless(defined $sop_inst) {
    print STDERR "file: $file_path has no sop_instance_uid\n";
    next;
  }
  my $sop_class = $ds->Get("(0008,0016)");
  unless(defined $sop_class) {
    print STDERR "file: $file_path has no sop_class_uid\n";
    next;
  }
  Import($dbh, $ds, $line, $sop_class);
}
sub Import{
  my($db, $ds, $id, $sop_class) = @_;
  my $sop_common_parms = {
    spec_char_set => "(0008,0005)",
    sop_class => "(0008,0016)",
    sop_instance => "(0008,0018)",
    creation_date => "(0008,0012)",
    creation_time => "(0008,0013)",
    creator_uid => "(0008,0014)",
    related_general_sop_class => "(0008,001a)",
    orig_spec_sop_class => "(0008,001b)",
    offset_from_utc => "(0008,0201)",
    instance_number => "(0020,0013)",
    instance_status => "(0100,0410)",
    auth_date_time => "(0100,0420)",
    auth_comment => "(0100,0424)",
    auth_cert_num => "(0100,0426)",
  };
  my $ins_sop_common = $db->prepare(
    "insert into file_sop_common\n" .
    "  (file_id, sop_class_uid, sop_instance_uid,\n" .
    "   specific_character_set, creation_date, creation_time,\n" .
    "   creator_uid, related_general_sop_class, " .
    "      original_specialized_sop_class,\n" .
    "   offset_from_utc, instance_number, instance_status,\n" .
    "   auth_date_time, auth_comment, auth_cert_num)\n" .
    "values\n" .
    "  (?, ?, ?,\n" .
    "   ?, ?, ?,\n" .
    "   ?, ?, ?,\n" .
    "   ?, ?, ?,\n" .
    "   ?, ?, ?)"
  );
  my %parms;
  my @errors;

  for my $i (keys %$sop_common_parms){
    my $value = $ds->Get($sop_common_parms->{$i});
    $parms{$i} = $value;
  }
  if(ref($parms{spec_char_set}) eq "ARRAY"){
    $parms{spec_char_set} = join("\\", @{$parms{spec_char_set}});
  }
  if(
    defined($parms{creation_time}) && 
    $parms{creation_time} =~ /^(\d\d)(\d\d)(\d\d)$/
  ){
    $parms{creation_time} = "$1:$2:$3";
  } elsif (
    defined($parms{creation_time}) && 
    $parms{creation_time} =~ /^(\d\d)(\d\d)(\d\d)\.(\d+)$/
  ){
    $parms{creation_time} = "$1:$2:$3.$4";
  } elsif (defined $parms{creation_time}){
    push(@errors, "Illegal creation time: \"$parms{creation_time}\"");
    $parms{creation_time} = undef;
  }
  if(
    defined($parms{creation_date}) && 
    $parms{creation_date} =~ /^(\d\d\d\d)(\d\d)(\d\d)$/
  ){
    my $y = $1; my $m = $2; my $d = $3;
    if($m >0 && $m < 13 && $d > 0 && $d < 32){
      $parms{creation_date} = "$y/$m/$d";
    } else {
      push(@errors, "Illegal creation date: \"$parms{creation_date}\"");
      delete $parms{creation_date};
    }
  } elsif(defined $parms{creation_date}) {
    push(@errors, "Illegal creation date: $parms{creation_date}");
    delete $parms{creation_date};
  }
  if($parms{sop_class} =~ /\s/){
    push(@errors, "Sop class has a space: \"$parms{sop_class}\"");
    $sop_class = $parms{sop_class};
    $sop_class =~ s/\s//g;
    $parms{sop_class} = $sop_class;
    push(@errors, "substitution: \"$parms{sop_class}\"");
  }
  if(
    exists($parms{related_general_sop_class}) &&
    ref($parms{related_general_sop_class}) eq "ARRAY"
  ){
    $parms{related_general_sop_class} = 
      join("\\", @{$parms{related_general_sop_class}});
  }
  if(defined($parms{sop_class}) && defined($parms{sop_instance})){
#    print "Insert(
#  $id, $parms{sop_class}, $parms{sop_instance},
#  $parms{spec_char_set}, $parms{creation_date}, $parms{creation_time},
#  $parms{creator_uid}, $parms{related_general_sop_class},
#  $parms{original_specialized_sop_class},
#  $parms{offset_from_utc}, $parms{instance_number}, $parms{instance_status},
#  $parms{auth_date_time}, $parms{auth_comment}, $parms{auth_cert_num}
#);\n";
#     
    $ins_sop_common->execute(
      $id, $parms{sop_class}, $parms{sop_instance},
      $parms{spec_char_set}, $parms{creation_date}, $parms{creation_time},
      $parms{creator_uid}, $parms{related_general_sop_class},
      $parms{original_specialized_sop_class},
      $parms{offset_from_utc}, $parms{instance_number}, $parms{instance_status},
      $parms{auth_date_time}, $parms{auth_comment}, $parms{auth_cert_num}
    );
  }
}
1;
