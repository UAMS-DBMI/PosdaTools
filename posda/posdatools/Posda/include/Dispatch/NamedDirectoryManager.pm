#!/usr/bin/perl -w
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
