#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/include/Dispatch/DicomAnalyze.pm,v $
#$Date: 2010/05/26 20:48:22 $
#$Revision: 1.2 $
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
package Posda::DicomAnalysis;
use strict;

sub MakeLoopStep{
  my($this, $result_obj_name, $session, $file_list, $iterator, $count) = @_;
  my $foo = sub {
    my $disp = shift;
    my $result_obj = 
     $main::HTTP_APP_SINGLETON->{Inventory}->{$session}->
       {root}->{$result_obj_name};
    unless(
      $#{$file_list} >= 0
    ){
      $this->post_process();
      $result_obj->set_analysis($this);
      return;
    }
    my $remaining = $#{$file_list};
    $result_obj->set_analysis("$remaining of $count files remaining");
    my $file = shift(@$file_list);
    my $try = Posda::Try->new($file);
    if(exists $try->{dataset}){
      &$iterator($try);
    }
    $disp->queue();
  };
  return $foo;
}

sub new_from_file_list_obj{
  my($class, $result_obj_name, $session, $file_list) = @_;
  my $this = $class->new_blank();
  my $count = scalar @$file_list;
  my $analyzer = $this->make_wanted;

  my $loop = Dispatch::Select::Background->new(
    MakeLoopStep($this, 
      $result_obj_name, $session, $file_list, $analyzer, $count));
  $loop->queue();
}
1;
