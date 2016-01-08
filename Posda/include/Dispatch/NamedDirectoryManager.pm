#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/include/Dispatch/NamedDirectoryManager.pm,v $
#$Date: 2013/03/28 21:44:50 $
#$Revision: 1.1 $
use strict;
package Dispatch::NamedDirectoryManager;
use Posda::DirectoryManager;
use vars qw( @ISA );
@ISA = ( "Posda::DirectoryManager", "Dispatch::NamedObject" );
sub new {
  my($class, $session, $path, $dir, $fm) = @_;
  my $this = Posda::DirectoryManager::new($class, $dir, $fm);
  $this->AssignName($session, $path);
}
1;
