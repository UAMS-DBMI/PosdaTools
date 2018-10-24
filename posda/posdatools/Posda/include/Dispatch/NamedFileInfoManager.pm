#!/usr/bin/perl -w
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
