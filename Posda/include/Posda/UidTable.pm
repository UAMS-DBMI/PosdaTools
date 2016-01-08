#
#$Source: /home/bbennett/pass/archive/Posda/include/Posda/UidTable.pm,v $
#$Date: 2012/05/23 16:58:31 $
#$Revision: 1.6 $
#
#Copyright 2011, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
package Posda::UidTable;
use Debug;
my $dbg = sub{print STDERR @_};
my $Revision = 'unknown';
if('$Revision: 1.6 $' =~ /^[^:]*:\s([0-9\.]*)\s*\$$/){
  $Revision = $1;
}
sub Revision {
  my($this_or_class) = @_;
  return $Revision;
}
sub new {
  my($class, $root) = @_;
  my $this = {
    root => $root,
    seq => 1,
    table => {},
    revision => $Revision,
    new_uids => 0,
  };
  return bless $this, $class;
}
sub SetNewUidMode{
  my($this) = @_;
  $this->{new_uids} = 1;
  # print STDERR "Posda::UidTable:SetNewUidMode: $this->{new_uids}.\n";
  if ((scalar keys %{$this->{table}}) > 0) {
    print STDERR "Posda::UidTable:SetNewUidMode: uid table NOT empty!!!";
  }
}
sub NewUid{
  my($this) = @_;
  my $new_uid = "$this->{root}.$this->{seq}";
  $this->{seq}++;
  # print STDERR "UidTable::NewUid: seq: $this->{seq}.\n";
  return $new_uid;
}
sub LookUpOrNew{
  my($this, $uid) = @_;
  if (exists $this->{table}->{$uid}){ 
    # print STDERR "Posda::UidTable:LookUpOrNew: $uid mapped to uid: " .
    #   $this->{table}->{$uid} . ".\n";
    return $this->{table}->{$uid};
  }
  my $new_uid = $this->NewUid();
  $this->{table}->{$uid} = $new_uid;
  $this->{table}->{$new_uid} = $new_uid;
  # print STDERR "Posda::UidTable:LookUpOrNew: $uid mapped to new uid: " .
  #   $this->{table}->{$uid} . ".\n";
  return $this->{table}->{$uid};
}
sub LookUp{
  my($this, $uid) = @_;
  if (exists $this->{table}->{$uid}){ 
    # print STDERR "Posda::UidTable:LookUp: $uid mapped to uid: " .
    #   $this->{table}->{$uid} . ".\n";
    return $this->{table}->{$uid};
  }
  if ($this->{new_uids}) {
    my $new_uid = $this->NewUid();
    $this->{table}->{$uid} = $new_uid;
    $this->{table}->{$new_uid} = $new_uid;
    # print STDERR "Posda::UidTable:LookUp: $uid mapped to new uid: " .
    #   $this->{table}->{$uid} . ".\n";
  } else {
    # print STDERR "Posda::UidTable:LookUp: $uid unity mapped.\n";
    $this->{table}->{$uid} = $uid;
  }
  return $this->{table}->{$uid};
}
sub GetExisting{
  my($this, $uid) = @_;
  if (exists $this->{table}->{$uid}){ return $this->{table}->{$uid} }
  $this->{table}->{$uid} = $uid;
  return $uid;
}
sub SetMapping{
  my($this, $uid, $mapped_to_this_uid) = @_;
  my $map_uid = $this->LookUp($mapped_to_this_uid);
  if (exists ($this->{table}->{$uid})  &&  
      $this->{table}->{$uid} ne $map_uid) {
    print STDERR "Posda::UidTable:SetMapping: $uid to " .
      $mapped_to_this_uid . " but there is allready a table entry!!! ".
    $this->{table}->{$uid} . "\n";
  }
  $this->{table}->{$uid} = $map_uid;
  # print STDERR "Posda::UidTable:SetMapping: $uid to " .
  #   $this->{table}->{$uid} . ".\n";
  # print STDERR "\tSetMapping: UID $mapped_to_this_uid is mapped to " .
  #   $this->{table}->{$mapped_to_this_uid} . ".\n";
  # print STDERR "\tSetMapping: Uid look up table:\n";
  # Debug::GenPrint($dbg, $this->{table}, 5 );
  # print STDERR "\n";
  return $this->{table}->{$uid};
}
# sub AddUnity{
#   my($this, $uid) = @_;
#   if(exists $this->{table}->{$uid}){ return $this->{table}->{$uid} }
#   $this->{table}->{$uid} = $uid;
#   return $uid;
# }
1;
