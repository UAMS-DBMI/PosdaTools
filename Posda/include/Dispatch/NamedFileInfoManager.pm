#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/include/Dispatch/NamedFileInfoManager.pm,v $
#$Date: 2013/03/28 21:41:21 $
#$Revision: 1.1 $
use strict;
package Dispatch::NamedFileInfoManager;
use Posda::FileInfoManager;
use vars qw( @ISA );
@ISA = ( "Posda::FileInfoManager", "Dispatch::NamedObject" );
sub new {
  my($class, $session, $path, $analyzer, $cache_dir, $num_procs) = @_;
  my $this = Posda::FileInfoManager::new(
    $class, $analyzer, $cache_dir, $num_procs);
  $this->AssignName($session, $path);
}
1;
