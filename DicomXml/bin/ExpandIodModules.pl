#!/usr/bin/perl
#$Source: /home/bbennett/pass/archive/DicomXml/bin/ExpandIodModules.pl,v $
#$Date: 2014/08/14 12:56:30 $
#$Revision: 1.7 $
#
#Copyright 2014, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
# 
use strict;
use XML::Parser;
use Socket;
use Storable qw( fd_retrieve retrieve store_fd);
use Cwd;
use Debug;
my $dbg = sub { print STDERR @_ };
my $c_dbg = sub { print @_ };
unless($#ARGV == 1) {
  die "usage: ExpandIodModules.pl <parsed_xml_file> " .
    "<iod_modules_table_id>\n" .
    "  Produces Output as Storable Object on STDOUT:\n" .
    "  \$obj = {\n" .
    "    errors = [ <error>, ... ],\n" .
    "    tags = {\n" .
    "      <tag> => {\n" .
    "        desc => <description>,\n" .
    "        name => <element_name>,\n" .
    "        mod_tables => [<mod_table>, ...],\n" .
    "        req => <req>,\n" .
    "        entity => <entity>,\n" .
    "        module_name => <module_name>,\n" .
    "        usage => <usage>,\n" .
    "      }, ...\n" .
    "    },\n" .
    "  };\n";
}
my $doc = retrieve($ARGV[0]);
open my $fh, "GetIodModuleTable.pl \"$ARGV[0]\" \"$ARGV[1]\"|" or
  die "Can't open command";
my @sub_mods;
while (my $line = <$fh>){
  chomp $line;
  my @mods = split(/\|/, $line);
  push(@sub_mods, \@mods);
}
close $fh;
my @Errors;
my %Tags;
for my $i (@sub_mods){
  my $ent = $i->[0];
  my $mod = $i->[1];
  my $tab = $i->[2];
  my $usage = $i->[3];
  my $cmd = "ExpandModuleTable.pl";
  if($tab eq ""){
    print STDERR "no table reference ($ent, $mod, $tab, $usage) in $ARGV[1]\n";
    push @Errors, "no table reference ($ent, $mod, $tab, $usage)";
    next;
  }
##################################
#uncomment for logging
#print STDERR "Ent: $ent Module: $mod\n>>>>Command: $cmd\n";
########### bad table ############
#  if($tab eq "table_C.12-1"){ 
#    push @Errors, "Can't handle processing of table_C.12.1 in $ent:$mod" .
#     " of $ARGV[1]";
#    next;
#  }
  if($tab eq "table_C.19-1"){ 
    push @Errors, "Can't handle processing of table_C.19.1 in $ent:$mod" .
     " of $ARGV[1]";
    next;
  }
  if($tab eq "table_C.7.6.16-1"){ 
    push @Errors, "Can't handle processing of table_C.7.6.16-1 in $ent:$mod" .
     " of $ARGV[1]";
    next;
  }
  if($tab eq "table_C.8.28.2-1"){ 
    push @Errors, "Can't handle processing of $tab in $ent:$mod" .
     " of $ARGV[1]";
    next;
  }
  ###################################
  my($child, $child_pid) = ReadWriteChild($cmd);
  my $args = {
    doc => $ARGV[0],
    index => $tab,
  };
  store_fd($args, $child);
  my $foo = fd_retrieve($child);
  close $child;
  waitpid $child_pid, 0;
  for my $e (@{$foo->{errors}}){
    push @Errors, $e;
  }
  for my $k (keys %{$foo->{tags}}){
    my $t = $foo->{tags}->{$k};
    $t->{entity} = $ent;
    $t->{module} = $mod;
    $t->{usage} = $usage;
    if(exists $Tags{$k}) {
      unless(ref($Tags{$k}) eq "ARRAY"){ $Tags{$k} = [$Tags{$k}] }
      push(@{$Tags{$k}}, $t);
#      my $err = {
#        message => "Duplicate Tag",
#        tag => $k,
#        value => $t,
#      };
#      push @Errors, $err;
    } else {
      $Tags{$k} = $t;
    }
  }
}
my $result = {
  errors => \@Errors,
  tags => \%Tags,
};
store_fd($result, \*STDOUT);
sub ReadWriteChild{
  my($cmd) = @_;
  my($child, $parent, $oldfh);
  socketpair($parent, $child, AF_UNIX, SOCK_STREAM, PF_UNSPEC) or
   die ("socketpair: $!");
  $oldfh = select($parent); $| = 1; select($oldfh);
  $oldfh = select($child); $| = 1; select($oldfh);
  my $child_pid = fork;
  unless(defined $child_pid) {
    die("couldn't fork: $!");
  }
  if($child_pid == 0){
    close $child;
    unless(open STDIN, "<&", $parent){die "Redirect of STDIN failed: $!"}
    unless(open STDOUT, ">&", $parent){die "Redirect of STDOUT failed: $!"}
    exec $cmd;
    print STDERR "CMD: $cmd\n";
    die "exec failed: $!";
  } else {
#    my $flags = fcntl($child, F_GETFL, 0);
#    $flags = fcntl($child, F_SETFL, $flags | O_NONBLOCK);
    close $parent;
  }
  return $child, $child_pid;
}
