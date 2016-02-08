#!/usr/bin/perl -w
#
use strict;
use DBI;
use IO::Socket::INET;
use FileHandle;
use Dispatch::Http;
use Dispatch::Select;
use Posda::ConfigRead;
use Cwd;
use JSON::PP;

$| = 1;

use vars qw( $HTTP_APP_SINGLETON $HTTP_APP_CONFIG %HTTP_RUNNING_SUB_PROGRAMS %HTTP_STATIC_OBJS  *sym *sys *code );
######### Don't modify
$SIG{PIPE} = 'IGNORE';
sub DumpSymName{
  local *sym = shift;
  my $pre_path = shift;
  unless(defined $pre_path) { $pre_path = "" }
  for my $symname (sort keys %sym){
    if($symname =~ /::$/){
      unless(
        $symname eq "main::" ||
        $symname eq "::" ||
        $symname eq "<none>::"
      ){
        *sys = $sym{$symname};
        DumpSymName(*sys, "$pre_path$symname");
      }
    } else {
      *sys = $sym{$symname};
      my $ref = *sys{CODE};
      if(defined $ref){
        print "$pre_path$symname = $ref\n";
      }
    }
  }
}
sub GetMethodRef{
  my $class_name = shift;
  my $method = shift;
  local *sym = shift;
  my $pre_path = shift;
  if($class_name =~ /^([^:]+::)(.*)$/){
    my $symname = $1;
    my $remain = $2;
    *sys = $sym{$symname};
    return GetMethodRef($remain, $method, *sys, "$pre_path$symname");
  } elsif(defined $class_name){
    my $hash_name = $class_name . "::";
    *sys = $sym{$hash_name};
    *code = $sys{$method};
    my $ref = *code{CODE};
    if(defined $ref){
      return $ref;
    }
    return undef;
  }
}
sub ProcessArg{
  my($arg) = @_;
  unless(ref($arg)) { return $arg }
  if(ref($arg) eq "ARRAY" && $arg->[0] eq "Config"){
    if($#{$arg} == 2){
      return $HTTP_APP_CONFIG->{config}->{$arg->[1]}->{$arg->[2]};
    } elsif($#{$arg} == 1){
      return $HTTP_APP_CONFIG->{config}->{$arg->[1]};
    }
  }
}
######### End Don't modify
my $host = $ARGV[0];
my $port = $ARGV[1];
my $dir = $ARGV[2];
my $color = "white";
if(defined $ARGV[3]){
  $color = $ARGV[3];
}
my $token;
if(defined $ARGV[4]){
  $token = $ARGV[4];
  $HTTP_APP_SINGLETON->{token} = $token;
}
$HTTP_APP_CONFIG = Posda::ConfigRead->new($dir);
my $int = 10;
my $ttl = 60;
use vars qw( %Static );
%Static = ();
my $class = $HTTP_APP_CONFIG->{config}->{Environment}->{ApplicationInitClass};
my $method = $HTTP_APP_CONFIG->{config}->{Environment}->{ApplicationInitMethod};
my $login = $HTTP_APP_CONFIG->{config}->{Environment}->{ApplicationLoginMethod};
eval "require $class";
if($@) { 
  print "Failed to compile: xyzzy\n$@\nxyzzy\n";
  die $@ 
}
my $App = GetMethodRef("Posda::HttpObj", $method, \%main::, "");
unless(defined $App) { die "App not defined: Posda::HttpObj::$method" }
my $Login = GetMethodRef("Posda::HttpObj", $login, \%main::, "");
unless(defined $App) { die "Login not defined Posda::HttpObj::$login" }
if(exists $HTTP_APP_CONFIG->{config}->{Applications}->{StaticObjs}){
  for my $i (keys %{$HTTP_APP_CONFIG->{config}->{Applications}->{StaticObjs}}){
    my $desc = $HTTP_APP_CONFIG->{config}->{Applications}->{StaticObjs}->{$i};
    my $stat_class = "$desc->{ObjClass}";
    eval "require $stat_class";
    if($@) { die $@ }
    my $new = GetMethodRef($stat_class, "new", \%main::, "");
    if(defined $new){
      my @args;
      for my $i (@{$desc->{CreationArgs}}){
        push @args, ProcessArg($i);
      }
      $HTTP_STATIC_OBJS{$i} = &{$new}($stat_class, @args);
    }
  }
}
sub Init{
  my($this, $sess) = @_;
  my $sess_obj = $main::HTTP_APP_SINGLETON->{Inventory}->{$sess};
  $sess_obj->{logged_in} = 1;
  $sess_obj->{Privileges} = {};
  $sess_obj->{bgcolor} = $color;
  &$App($class, $sess, $HTTP_APP_CONFIG->{config}->{Environment}->{ApplicationName});
}
{
  #  In own block to release app_struct at end  #

  my $app_struct = Dispatch::Http::App->new_obj(
    $Login, \&Init,
    $HTTP_APP_CONFIG->{config}->{Environment}->{ApplicationName});
    $HTTP_APP_SINGLETON = Dispatch::Http::App::Server->new_static_and_files(
      \%Static, "$HTTP_APP_CONFIG->{config}->{Environment}->{AppHttpRoot}",
      $app_struct
  );
  $HTTP_APP_SINGLETON->{port_served} = $port;
  if(defined $token) { $HTTP_APP_SINGLETON->{token} = $token }
  $HTTP_APP_SINGLETON->Serve($port, $int, $ttl);
  $HTTP_APP_SINGLETON->{base_url} = "http://$host:$port";
  print "Redirect to http://$host:$port\n";
  for my $signal (qw(TERM ABRT QUIT HUP))
  {
    my $old_handler = $SIG{$signal};
    if (defined $old_handler && ref($old_handler) eq "CODE") {
      $SIG{$signal} = sub {
        print STDERR "Signal $signal received.\n";
        $HTTP_APP_SINGLETON->DeleteAllSessions();
        $HTTP_APP_SINGLETON->Remove();
        $old_handler->(@_) if $old_handler;
        Dispatch::Select::Background::clear_all_timers();
        if($signal eq "TERM"){
          Dispatch::Select::Dump(\*STDERR);
          $ENV{POSDA_DEBUG} = 1;
          if($ENV{POSDA_DEBUG}){
            print STDERR "We're shutting down (see what DESTROYS)\n";
          }
          exit 0;
        }
      }
    } else {
      $SIG{$signal} = sub {
        print STDERR "Signal $signal received.\n";
        $HTTP_APP_SINGLETON->DeleteAllSessions();
        $HTTP_APP_SINGLETON->Remove();
        Dispatch::Select::Dump(\*STDERR);
        Dispatch::Select::Background::clear_all_timers();
        if($signal eq "TERM"){
          $ENV{POSDA_DEBUG} = 1;
          if($ENV{POSDA_DEBUG}){
            print STDERR "We're shutting down (see what DESTROYS)\n";
          }
          exit 0;
        }
      }
    }
    $SIG{INT} = sub {
      print STDERR "Signal $signal received.\n";
      Dispatch::Select::Dump(\*STDERR);
    };
  }
  Dispatch::Select::Dispatch(); 
  print STDERR "Returned from Dispatch\n";
  $HTTP_APP_SINGLETON = undef;
  $HTTP_APP_CONFIG = undef;
  $ENV{POSDA_DEBUG} = 1;
}
if($ENV{POSDA_DEBUG}){
  print STDERR "We're shutting down (see what DESTROYS)\n";
}
