#!/usr/bin/perl -w
#
use strict;
package FileDist::DirectoryAnalyzer;
use Posda::DirectoryManager;
use vars qw( @ISA );
@ISA = qw( Posda::DirectoryManager );
sub new{
  my($class, $dir, $fm, $notify) = @_;
  my $high = 20;
  my $low = 15;
  my $this = Posda::DirectoryManager::new($class, $dir, $fm, $high, $low);
  if(defined $notify){
    $this->{notifier} = $notify;
  }
  return $this;
}
sub DM_Initialized{
  my($this) = @_;
  if(defined $this->{notifier} && ref($this->{notifier}) eq "CODE"){
    &{$this->{notifier}}();
  }
}
sub InitializingState{
  my($this, $http, $dyn) = @_; 
  my $dm = $this->{DirectoryManager};
  $http->queue("<small>Analyzing Dicom files in $dm->{dir}:" .
    "</small><ul>");
  if(exists $dm->{FileFinder}){
    $http->queue("<li><small>FileFinder: " .
      ($dm->{FileFinder}->{paused} ? "paused" : "not paused") .
      "</small></li>\n");
  }
  $http->queue("<li><small>Number processed: $dm->{NumProcessed}</small></li>");
  my @awaited = sort keys %{$dm->{Awaited}};
  if(@awaited){
    $http->queue("<li><small>Awaited:</small><ul>");
    for my $i (@awaited){
      $http->queue("<li><small>$i</small></li>");
    }
    $http->queue("</ul></li>"); 
    return 1;
  }
  return 0;
}
1;
