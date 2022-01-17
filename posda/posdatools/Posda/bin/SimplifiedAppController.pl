#!/usr/bin/perl -w
#
use strict;
use DBI;
use IO::Socket::INET;
use FileHandle;
use Dispatch::Http;
use Dispatch::Select;
use Posda::ConfigRead;
use Posda::Permissions;
use Cwd;
use JSON;
use Debug;
my $dbg = sub {print STDERR @_ };


$| = 1;

use vars qw( $HTTP_APP_SINGLETON $HTTP_APP_CONFIG );
$SIG{PIPE} = 'IGNORE';
my $host = $ARGV[0];
my $port = $ARGV[1];
my $dir = $ARGV[2];
my $hashed_token = $ARGV[3];
my $user = $ARGV[4];
my $port_mapper = {
  64615 => 'pa1',
  64616 => 'pa2',
  64617 => 'pa3',
  64618 => 'pa4',
  64619 => 'pa5',
  64620 => 'pa6',
  64621 => 'pa7',
  64622 => 'pa8',
  64623 => 'pa9',
  64624 => 'pa10',
  64625 => 'pa11',
  64626 => 'pa12',
  64627 => 'pa13',
  64628 => 'pa14',
  64629 => 'pa15',
};
$HTTP_APP_CONFIG = Posda::ConfigRead->new($dir);
my $int = 10;
my $ttl = 60;
my $class = $HTTP_APP_CONFIG->{config}->{Environment}->{ApplicationInitClass};
$HTTP_APP_CONFIG->{hashed_token} = $user;
eval "require $class";
if($@) { 
  print "Failed to compile: xyzzy\n$@\nxyzzy\n";
  die $@ 
}
my %Static;
sub RandString{
  my $ret;
  for my $i ( 0 .. 4){
    my $num = int rand() * 1000;
    $ret .= sprintf("%03d", $num);
  }
  return $ret;
}
{
  #  In own block to release app_struct at end  #
  my $session_id = RandString();
  my $app_name = $HTTP_APP_CONFIG->{config}->{Environment}->{ApplicationName};
#  my $app_inst = $class->new($session_id, $app_name);
  $HTTP_APP_SINGLETON =
    Dispatch::Http::App::SimplifiedServer->new_static_and_files(
      \%Static, "$HTTP_APP_CONFIG->{config}->{Environment}->{AppHttpRoot}"
  );
  my $ref_type = ref($main::HTTP_APP_SINGLETON);
  $HTTP_APP_SINGLETON->NewSession($session_id);
  if(defined $user) { $HTTP_APP_SINGLETON->{token} = $user }
  if(defined $user) { $HTTP_APP_SINGLETON->{user} = $user }
#  print STDERR "############################\n(Before) App Singleton ($ref_type): ";
#  Debug::GenPrint($dbg, $main::HTTP_APP_SINGLETON, 1);
#  print STDERR "\n###########################\n";
  $HTTP_APP_SINGLETON->{app_root} = Dispatch::Http::App->new_single_sess(
    $app_name, $session_id
  );
  my $app_inst = $class->new($session_id, $app_name);
  $HTTP_APP_SINGLETON->{port_served} = $port;
  $HTTP_APP_SINGLETON->Serve($port, $int, $ttl);

  my $re_host = $host;
#  if($host =~ /^(.*\.nip\.io)\/\.*/){
#    $re_host = $1;
#    print STDERR "###################\n$host remapped to $re_host\n###################\n";
#  } else {
#    die "!!!!!!!!!!!!!!!!!!!!!!!!!\n" .
#    "Host: \"$host\" not recognized for remapping\n" .
#    "!!!!!!!!!!!!!!!!!!!!!!!!!";
#
#  }
  $HTTP_APP_SINGLETON->{base_url} = "http://$re_host/$port_mapper->{$port}";

  $ref_type = ref($main::HTTP_APP_SINGLETON);
#  print STDERR "############################\n(After) App Singleton ($ref_type): ";
#  Debug::GenPrint($dbg, $main::HTTP_APP_SINGLETON, 1);
  print STDERR "###########################\n";
  print STDERR "Redirect to https://$re_host/$port_mapper->{$port}/$session_id" .
    "/Refresh?obj_path=$app_name\n";
  print STDERR "\n###########################\n";
  print "Redirect to https://$re_host/$port_mapper->{$port}/$session_id" .
    "/Refresh?obj_path=$app_name\n";
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
