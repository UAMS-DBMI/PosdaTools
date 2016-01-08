#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/include/Dispatch/SingleCommandApp.pm,v $
#$Date: 2013/03/22 19:37:13 $
#$Revision: 1.2 $
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
package Dispatch::SingleCommandApp;
sub new{
  my($class) = @_;
  my $this = {
    Inventory => {
    },
    shutting_down => 0,
  };
  return bless $this, $class;
}
sub NewSession{
  my($this) = @_;
  my $inst_id = "000001";
  $this->{Inventory}->{$inst_id} = bless {
     session_id => $inst_id,
     last_access => time(),
   }, "Dispatch::Session";
  return $inst_id;
}
sub GetSession{
  my($this, $session) = @_;
  return $this->{Inventory}->{$session};
}
1;

