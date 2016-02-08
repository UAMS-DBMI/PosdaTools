#!/usr/bin/perl -w
#
use strict;
use JSON::PP;
use Debug;
my $dbg = sub {print @_};

package Posda::ConfigRead;

sub new{
  my($class, $dir) = @_;
  my $this = {};
  $this->{dir} = $dir;
  bless $this, $class;
  $this->ReadJsonFiles($dir);
  return $this;
}

sub ReadJsonFile{
  my ($this, $file) = @_;
  # print "ReadJsonFile:: file: $file.\n";
  my $text = "";
  my $data;
  my $cf;
  unless (open($cf, '<', $file)) {
    print STDERR "ReadJsonFile:: " .
      "can not open config file: $file, Error $!.\n";
    return undef;
  }
  while (<$cf>) { chomp; unless ($_ =~ m/^\s*\/\//) {$text .= $_;} }
  close($cf);
  my $json = JSON::PP->new();
  $json->relaxed(1);
  eval {
    $data = $json->decode( $text );
  };
  if ($@) {
    print STDERR "ReadJsonFile:: bad json file: $file.\n";
    print STDERR "##########\n$@\n###########\n";
    $this->{BadJson}->{$file} = $@;
    return undef;
  }
  return $data;
}
sub ReadJsonFiles{
  my ($this, $dir) = @_;
  my $dh;
  unless(opendir $dh, $dir) {
    die "can't opendir $dir";
  }
  while (my $f = readdir $dh){
    if($f =~ /^\./) { next }
    unless($f =~ /^(.*)\.json$/) { next }
    my $base = $1;
    unless(-f "$dir/$f") { next }
    $this->{config}->{$base} = $this->ReadJsonFile("$dir/$f");
  }
}

sub GetEnvValue{
  my ($this, $name) = @_;
  unless(exists $this->{config}->{Environment}){
    die "No Environment.json file found";
  }
  my $sys_env = $this->{config}->{Environment};
  unless ($sys_env) { die "Error on System Environment.json file"; }
  unless (exists $sys_env->{$name}) { return undef; }
  while ($sys_env->{$name} =~ /(.*)\$\s*{\s*(.+)\s*}(.*)$/) {
    unless (defined $ENV{$2}) { return undef; }
    $sys_env->{$name} = $1 . $ENV{$2} . $3; 
  }
  if ($sys_env->{$name} =~ /^\~\/(.*)$/)
    { $sys_env->{$name} = $ENV{ITC_TOOLS_ROOT} . "/" . $1; }
  return $sys_env->{$name};
}

sub GetEnvValueUser{
  my ($name, $user) = @_;
  my $sys_config_dir = $ENV{ITC_TOOLS_ROOT} . "/Config";
  # print "sys_config_dir: $sys_config_dir.\n";
  my $sys_env = ReadJsonFile("$sys_config_dir/Environment.json");
  unless ($sys_env) { die "Error on System Environment.json file"; }
  unless (exists $sys_env->{$name}) { return undef; }
  while ($sys_env->{$name} =~ /(.*)\$\s*{\s*(.+)\s*}(.*)$/) {
    if($2 eq "ITC_TOOLS_USER"){
      $sys_env->{$name} = $1 . $user . $3;
    } else {
      unless(defined $ENV{$2}){ return undef }
      $sys_env->{$name} = $1 . $ENV{$2} . $3; 
    }
  }
  if($sys_env->{$name} =~ /^\~\/(.*)$/){
    $sys_env->{$name} = $ENV{ITC_TOOLS_ROOT} . "/" . $1;
  }
  return $sys_env->{$name};
}

sub GetPorts{
  my @ports;
  my $sys_config_dir = $ENV{ITC_TOOLS_ROOT} . "/Config";
  # print "sys_config_dir: $sys_config_dir.\n";
  my $sys_users = ReadJsonFile("$sys_config_dir/Users.json");
  unless ($sys_users) { die "Error on System Users.json file"; }
  for my $i (keys %{$sys_users}) {
    # print "GetPorts: port: $sys_users->{$i}->{port}.\n"; 
    for my $p (@ports) {
      if ($p eq $sys_users->{$i}->{port}) {
        die "Error on System Users.json file: port used twice..."; 
      }
    }
    push(@ports, $sys_users->{$i}->{port}); 
  }
  return @ports;
}

sub GetUsers{
  my($this) = @_;
  my @ports;
  my $sys_config_dir = $ENV{ITC_TOOLS_ROOT} . "/Config";
  # print "sys_config_dir: $sys_config_dir.\n";
  my $sys_users = ReadJsonFile("$sys_config_dir/Users.json");
  unless ($sys_users) { die "Error on System Users.json file"; }
  return $sys_users;
}

sub EnvSetup{
  my($this) = @_;
  $this->{ROOT} = $this->{APPCONTROLLERROOT};
  $SIG{'PIPE'} = 'IGNORE';
  umask 002;

  unless ($this->{ROOT}){
    die "$0: Enviroment var APPCONTROLLERROOT not set and is required.";
 }
  unless ($ENV{ITC_TOOLS_SCRIPTS}){
    die "$0: Enviroment var ITC_TOOLS_SCRIPTS not set and is required.";
 }
  unless ( -d "$ENV{ITC_TOOLS_LOGS}"){
    mkdir("$ENV{ITC_TOOLS_LOGS}",0775);
  }
  unless ( -d "$ENV{ITC_TOOLS_ROOT}/bin"){
    mkdir("$ENV{ITC_TOOLS_ROOT}/bin",0775);
  }
}

