#!/usr/bin/perl -w
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
use Posda::Ae::LocalServer;
use DBI;
my $config_dir = "$ENV{POSDA_HOME}/config/ae_test/ae_local";
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
  my $lae = Posda::Ae::LocalServer->new_from_config($c);
  open FILE, ">temp/$rname.config";
  $lae->DumpGuts(\*FILE);
  close FILE;
  $lae->instantiate_in_db($db);
  open FILE, ">temp/$rname.inst";
  $lae->DumpGuts(\*FILE);
  close FILE;
  my $new_lae = Posda::Ae::LocalServer->new_from_db($db, $lae->{id});
  open FILE, ">temp/$rname.reup";
  $new_lae->DumpGuts(\*FILE);
  close FILE;
  my $cmd = "diff temp/$rname.config temp/$rname.inst";
  print "_____${rname}_____\n";
  print "First Diff:\n";
  open FILE, "$cmd|";
  while (my $line = <FILE>){
    print $line;
  }
  close FILE;
  print "Second Diff:\n";
  open FILE, "diff temp/$rname.inst temp/$rname.reup|";
  while (my $line = <FILE>){
    print $line;
  }
}

