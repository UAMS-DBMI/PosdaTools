#!/usr/bin/perl -w
use strict;
#$Source: /home/bbennett/pass/archive/Posda/bin/DB/ImportTgz.pl,v $
#$Date: 2012/04/10 14:14:45 $
#$Revision: 1.3 $
#
#Copyright 2012, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use DBI;
use Posda::DB::File;
use Cwd;
my $db_name = $ARGV[0];
my $db = DBI->connect("dbi:Pg:dbname=$ARGV[0];host=$ARGV[1]", "", "");
my $line = $ARGV[2];
my $user = `whoami`;
chomp $user;
my $host = `hostname`;
chomp $host;
my $temp_root = getcwd;
if(defined($ARGV[3])){ $temp_root = $ARGV[3] }
if(-e "$temp_root/temp") {
  `chmod -R +w \"$temp_root/temp\"`;
  `rm -rf \"$temp_root/temp\"`;
}
`mkdir \"$temp_root/temp\"`;
unless( -d "$temp_root/temp" ) { die "mkdir $temp_root/temp must have failed" }
my $q = $db->prepare(
  "select count(*) from import_event where remote_file = ?"
);
$q->execute($line);
my $h = $q->fetchrow_hashref();
$q->finish();
if($h->{count} > 0) {
   print "Already imported $line\n";
   exit;
}
print "Importing $line\n";
`cd \"$temp_root/temp\";tar -zxvf $line`;

my $in = $db->prepare(
  "insert into import_event(\n" .
  "  import_type, importing_user, import_time, remote_file\n" .
  ") values (\n" .
  "  ?, ?, now(), ?" .
  ")"
);
  
unless($line =~ /^(.*)\.tgz$/) { die "bad file: $line" }
$in->execute("tar_only", "bbennett", $line);
my $gid = $db->prepare(
  "select currval('import_event_import_event_id_seq') as id"
);
$gid->execute();
$h = $gid->fetchrow_hashref();
$gid->finish();
unless($h && ref($h) eq "HASH"){ die "Couldn't get import_event_id" }
my $import_event_id = $h->{id};

#my $dir = `pwd`;
#chomp $dir;

Posda::DB::File::ImportFromTarOnly($db, $import_event_id, "$temp_root/temp");

print "Completed Import\n";
print "Preparing For DoseBin Generation\n";
my $get_rt_dvh_dvh_id = $db->prepare("
  select 
    rt_dvh_dvh_id 
  from 
    rt_dvh_dvh
    natural join rt_dvh 
    natural join rt_dvh_rt_dose
    natural join file_dose
    natural join file_import
  where import_event_id = ?
");
$get_rt_dvh_dvh_id->execute($import_event_id);
print "Getting dvh_ids\n";
while(my $h = $get_rt_dvh_dvh_id->fetchrow_hashref){
  my $rt_dvh_dvh_id = $h->{rt_dvh_dvh_id};
  if($rt_dvh_dvh_id){
    print "Generating DoseBins for rt_dvh_dvh: $rt_dvh_dvh_id\n";
    `GenerateDoseBins.pl $ARGV[0] $ARGV[1] bbennett $rt_dvh_dvh_id`;
    print "Generating rt_dvh_protocol_case_roi row for $rt_dvh_dvh_id\n";
    `GenerateDvhRoiProtocolCase.pl $ARGV[0] $ARGV[1] bbennett $rt_dvh_dvh_id`;
  }
}
