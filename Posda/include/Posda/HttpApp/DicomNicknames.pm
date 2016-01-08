#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/include/Posda/HttpApp/DicomNicknames.pm,v $
#$Date: 2013/10/07 02:39:26 $
#$Revision: 1.3 $
#
use strict;
{
  package Posda::HttpApp::DicomNicknames;
  use Dispatch::NamedObject;
  use vars qw( @ISA );
  @ISA = ( "Dispatch::NamedObject" );
  sub new {
    my($class, $sess, $path ) = @_;
    my $this = Dispatch::NamedObject->new($sess, $path);
    $this->{Exports}->{GetDicomNicknamesByFile} = 1;
    $this->{Exports}->{GetFilesByFileNickname} = 1;
    $this->{Exports}->{GetFilesByUidNickname} = 1;
    $this->{Exports}->{GetEntityNicknameByEntityId} = 1;
    $this->{Exports}->{GetEntityIdByNickname} = 1;
    return bless $this, $class;
  }
  sub GetDicomNicknamesByFile{
    my($this, $file) = @_;
    my $fm = $this->get_obj("FileManager");
    unless(defined $fm){
      print STDERR "FileManager not defined.\n";
      return undef; 
    }
    my $di = $fm->DicomInfo($file);
    unless($di) {
      print STDERR "No DICOM info for $file\n";
      return undef;
    }
    my $digest = $fm->FileDigest($file);
    unless($digest) {
      print STDERR "No digest for $file\n";
      return undef;
    }
    my $sop_inst = $di->{sop_inst_uid};
    unless($sop_inst) {
      print STDERR "No sop inst uid for $file\n";
      return undef;
    }
    my $modality = $di->{modality};
    unless($sop_inst) {
      print STDERR "No sop inst uid for $file\n";
      return undef;
    }
    unless(exists $this->{files_to_digest}->{$file}){
      $this->{files_to_digest}->{$file} = $digest;
      $this->{digest_to_files}->{$digest}->{$file} = 1;
    }
    unless(exists $this->{digest_to_file_nickname}->{$digest}){
      unless(exists $this->{seq}->{$modality}){
        $this->{seq}->{$modality} = 0;
      }
      $this->{seq}->{$modality} += 1;
      my $new_file_nickname = $modality . "_$this->{seq}->{$modality}";
      $this->{digest_to_file_nickname}->{$digest} = $new_file_nickname;
      $this->{nickname_to_digest}->{$new_file_nickname} = $digest;

      my $uid_nickname;
      if(exists $this->{uid_to_uid_nicknames}->{$sop_inst}){
        $uid_nickname = $this->{uid_to_uid_nicknames}->{$sop_inst};
      } else {
        unless(exists $this->{seq}->{uids}->{$modality}){
          $this->{seq}->{uids}->{$modality} = 0;
        }
        $this->{seq}->{uids}->{$modality} += 1;
        $uid_nickname = "Uid_$modality" . "_$this->{seq}->{uids}->{$modality}";
        $this->{uid_to_uid_nicknames}->{$sop_inst} = $uid_nickname;
        $this->{uid_nickname_to_uid}->{$uid_nickname} = $sop_inst;
      }
      $this->{uid_nickname_to_digest}->{$uid_nickname}->{$digest} = 1;
      $this->{uid_nickname_to_files}->{$uid_nickname}->{$file} = 1;
      $this->{digest_to_uid_nickname}->{$digest} = $uid_nickname;
    }
    return ([$this->{digest_to_file_nickname}->{$digest},
      $this->{digest_to_uid_nickname}->{$digest}]);
  }
  sub GetFilesByFileNickname{
    my($this, $nickname) = @_;
    unless(exists $this->{nickname_to_digest}->{$nickname}){
      return undef;
    }
    my $digest = $this->{nickname_to_digest}->{$nickname};
    return [ keys %{$this->{digest_to_files}->{$digest}} ];
  }
  sub GetFilesByUidNickname{
    my($this, $uid_nickname) = @_;
  }
  sub GetEntityNicknameByEntityId{
    my($this, $entity_type, $entity_id) = @_;
    unless(exists $this->{EntityIdToNickname}->{$entity_type}->{$entity_id}){
      unless(exists $this->{EntitySeq}->{$entity_type}){
        $this->{EntitySeq}->{$entity_type} = 0;
      }
      my $entity_nickname = $entity_type . 
        "_$this->{EntitySeq}->{$entity_type}";
      $this->{EntitySeq}->{$entity_type} += 1;
      $this->{EntityIdToNickname}->{$entity_type}->{$entity_id} = 
        $entity_nickname;
      $this->{EntityNicknameToId}->{$entity_nickname} = $entity_id;
    }
    return $this->{EntityIdToNickname}->{$entity_type}->{$entity_id};
  }
  sub GetEntityIdByNickname{
    my($this, $entity_nickname) = @_;
    unless(exists $this->{EntityNicknameToId}->{$entity_nickname}){
      return undef;
    }
    return $this->{EntityNicknameToId}->{$entity_nickname};
  }
}
1;

