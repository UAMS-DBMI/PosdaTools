#!/usr/bin/perl -w
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
use Posda::Ae::AssocAc;
use DBI;
my $config_dir = "$ENV{POSDA_HOME}/config/ae_test/assoc_ac";
opendir DIR, $config_dir or die "can't open $config_dir";
my @configs;
while(my $config = readdir(DIR)){
  if($config =~ /^\./) {next}
  push(@configs, "$config_dir/$config");
}
closedir DIR;
`dropdb ae_test_db >/dev/null 2>/dev/null`;
`createdb ae_test_db >/dev/null 2>/dev/null`;
`cat $ENV{POSDA_HOME}/sql/Assoc.sql|psql ae_test_db >/dev/null 2>/dev/null`;
my $db = DBI->connect("dbi:Pg:dbname=ae_test_db", "", "");
mkdir "temp";
for my $c (@configs){
  unless($c =~ /\/([^\/]+)$/){ die "bad name" }
  my $rname = $1;
  my $lae = Posda::Ae::AssocAc->from_config($c);
  open FILE, ">temp/$rname.config";
  $lae->DumpGuts(\*FILE);
  close FILE;
  my $pdu = $lae->to_pdu();
  open FILE, ">temp/$rname.pdu";
  print FILE $pdu;
  close FILE;
  my $lae_1 = Posda::Ae::AssocAc->from_pdu($pdu);
  open FILE, ">temp/$rname.from_pdu";
  $lae_1->DumpGuts(\*FILE);
  close FILE;
  $lae->instantiate($db);
  open FILE, ">temp/$rname.instantiate";
  $lae->DumpGuts(\*FILE);
  close FILE;
  my $lae_2 = Posda::Ae::AssocAc->from_db($db, $lae->{id});
  open FILE, ">temp/$rname.from_db";
  $lae_2->DumpGuts(\*FILE);
  close FILE;
}

