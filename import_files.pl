#!/usr/bin/env perl

use Modern::Perl;
use Method::Signatures::Simple;

use Posda::Config 'Database';

use DBI;
use Digest::MD5;

our $FILES_SEEN = '/home/posda/FilesAlreadySeen';
our $LINK_BIN = '/home/posda/bin/SendLinkToPosda.pl';
our $STORAGE_DIR = '/home/posda/Intake';
our $HOST = 'localhost';
our $PORT = '64614';

my $dbh = DBI->connect(Database('posda_backlog'));

my $sub_q = $dbh->prepare(
  "select submitter_id from submitter where collection = ? and " .
  "site = ? and subj = ?"
);
my $ins_sub = $dbh->prepare(
  "insert into submitter(collection, site, subj) values (?, ?, ?)"
);
my $get_id = $dbh->prepare(
  "select currval('submitter_submitter_id_seq')"
);
my $ins_req = $dbh->prepare(
  "insert into request(\n" .
  "  submitter_id, received_file_path, copied_file_path,\n" .
  "  file_copied, copy_error, copy_path, file_digest,\n" .
  "  file_in_posda, import_error, time_received,\n" .
  "  time_copied, time_entered, size\n" .
  ") values (\n" .
  "  ?, ?, null,\n" .
  "  false, false, null, ?,\n" .
  "  false, false, ?,\n" .
  "  null, null, ?\n" .
  ")"
);


func GetSubmitterId($collection, $site, $subj) {

  $sub_q->execute($collection, $site, $subj);
  my $h = $sub_q->fetchrow_hashref;
  $sub_q->finish;
  if(defined($h) && exists($h->{submitter_id})){
    return $h->{submitter_id};
  }
  $ins_sub->execute($collection, $site, $subj);
  $get_id->execute;
  my $hid = $get_id->fetchrow_hashref;
  $get_id->finish;
  unless(defined($hid) && exists($hid->{currval})){
    return undef, "Unable to create a new submitter row for ($collection, " .
       "$site, $subj)";
  }
  return $hid->{currval}, undef;
}

func InsertRequest($submitter, $file, $digest, $data, $size) {
  return $ins_req->execute($submitter, $file, $digest, $data, $size);
};

func insert($filename, $digest, 
            $collection, $site, $subject, 
            $receive_date, $size) {

    # get the submitter id
    my $submitter_id = GetSubmitterId($collection, $site, $subject);

    say "Submitter id: $submitter_id";
    InsertRequest($submitter_id, $filename, $digest, $receive_date, $size);
    say "Inserted: $digest [$collection/$site/$subject] ($filename)";
}


my $usage = <<EOF;
FindUnsentFilesTest.pl <count>
EOF
unless($#ARGV == 0) { die $usage }
my $count = $ARGV[0];
#unless($count > 10) { $count = 1000 }
my %FilesAlreadySeen;
my %FilesSeenThisTime;
sub Convert{
  my($string) = @_;
  my $conv_string = "";
  while($string =~ /^([0-9A-F][0-9A-F])(.*)$/){
    my $hex_char = $1;
    $string = $2;
    if($hex_char ne "00"){
      $conv_string .=  unpack("a", pack("c", hex($hex_char)));
    }
  }
  $conv_string =~ s/\s*$//;
  return $conv_string;
}
if(-e $FILES_SEEN) {
  open my $fh1, "<$FILES_SEEN";
  while(my $line = <$fh1>){
    chomp $line;
    my($rel_path, $digest, $collection, 
       $site, $subj, $rcv_ts, $size, $sent_at) =
      split(/\|/, $line);
    $FilesAlreadySeen{$rel_path} = 1;
  }
  close($fh1);
}
my $files_seen_at_beginning = keys %FilesAlreadySeen;
open my $fh2, "find $STORAGE_DIR -type f|";
unless(defined $fh2) { die "Can't open find script" }
while(my $line = <$fh2>){
  chomp $line;
  unless($line =~ /^$STORAGE_DIR\/(.*)$/){
    print STDERR "WTF?? file: $line\n";
    next;
  }
  my $rel_path = $1;
  if(exists $FilesAlreadySeen{$rel_path}){
    # print "$rel_path already seen\n";
    next;
  }
  $count -= 1;
  if($count < 0){ last }
  my($dev,$ino,$mode,$nlink,$uid,$gid,$rdev,$size,
     $atime,$rcv_ts,$ctime,$blksize,$blocks)
     = stat($line);
  unless(open FILE, "<$line"){
    print STDERR "WTF?? digest of $line\n";
  }
  my $ctx = Digest::MD5->new;
  $ctx->addfile(*FILE);
  my $digest = $ctx->hexdigest;
  close FILE;
  my($collection, $site, $subj);
  # Set based on path: $collection/$site/$subj/<filename>
  if($rel_path =~ /^([^\/]+)\/([^\/]+)\/([^\/]+)\//){
    $collection = $1;
    $site = $2;
    $subj = $3;
    if(
      $collection =~ /^([0-9A-F]+)$/ &&
      $site =~ /^[0-9A-F]+$/ &&
      (length($collection) & 1) == 0 &&
      (length($site) & 1) == 0
    ){
      $collection = Convert($collection);
      $site = Convert($site);
    }
  } else {
#    print STDERR "WTF?? rel_path: $rel_path\n";
    $collection = 'UNKNOWN';
    $site = 'UNKNOWN';
    $subj = 'UNKNOWN';
  }
  my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) =
                                               localtime($rcv_ts);
  my $yr = $year + 1900;
  my $date = sprintf("%4d/%02d/%02d %02d:%02d:%02d",
    $yr, $mon + 1, $mday, $hour, $min, $sec);

  my $cmd = "$LINK_BIN $HOST $PORT " .
    "\"$rel_path\" $digest \"$collection\" \"$site\" " .
    "\"$subj\" \"$date\" $size";

  # inserting the absolute path here, rather than rel_path
  # TODO: figure out why it doesn't work with rel_path????
  insert($line, $digest, $collection, $site, $subj, $date, $size);

  my $sent_at = time;
  $FilesSeenThisTime{$rel_path} = [
    $digest,
    $collection,
    $site,
    $subj,
    $rcv_ts,
    $size,
    $sent_at,
  ];
}

my $files_seen_this_time = keys %FilesSeenThisTime;
if($files_seen_this_time > 0){
  print "$files_seen_this_time New Files Found\n";
  open SAVE, ">>$FILES_SEEN" or
    die "can't open >>$FILES_SEEN";
  for my $i (keys %FilesSeenThisTime){
    my $e = $FilesSeenThisTime{$i};
    print SAVE "$i|$e->[0]|$e->[1]|$e->[2]|$e->[3]" .
      "|$e->[4]|$e->[5]|$e->[6]\n";
  }
  close SAVE;
  print "List of files seen updated\n";
}
