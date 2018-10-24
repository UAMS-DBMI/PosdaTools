#!/usr/bin/perl -w
#
use strict;
{
  package Posda::Nicknames;
  use vars qw( @ISA );
  sub new {
    my($class) = @_;
    my $this = {};
    return bless $this, $class;
  }
  sub GetDicomNicknamesByFile{
    my($this, $file, $di) = @_;
    unless($di) {
      print STDERR "No DICOM info for $file\n";
      return undef;
    }
    my $digest = $di->{digest};
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
  sub GetFileNicknameByDigest{
    my($this, $digest) = @_;
    if(exists $this->{digest_to_file_nickname}->{$digest}) {
      return $this->{digest_to_file_nickname}->{$digest}
    }
    return undef; 
  }
  sub GetFilesByFileNickname{
    my($this, $nickname) = @_;
    unless(exists $this->{nickname_to_digest}->{$nickname}){
      return undef;
    }
    my $digest = $this->{nickname_to_digest}->{$nickname};
    return [ keys %{$this->{digest_to_files}->{$digest}} ];
  }
  sub GetFileNicknamesByUid{
    my($this, $uid) = @_;
    unless(exists $this->{uid_to_uid_nicknames}->{$uid}){
      return undef;
    }
    my $unn = $this->{uid_to_uid_nicknames}->{$uid};
    if(exists $this->{uid_nickname_to_files}->{$unn}){
      my @files = keys %{$this->{uid_nickname_to_files}->{$unn}};
      my %fnn;
      for my $f (@files){
        if(exists $this->{files_to_digest}->{$f}){
          my $dig = $this->{files_to_digest}->{$f};
          if(exists $this->{digest_to_file_nickname}->{$dig}){
            $fnn{$this->{digest_to_file_nickname}->{$dig}} = 1;
#            push(@fnn, $this->{digest_to_file_nickname}->{$dig});
          }
        }
      }
      my @fnn = keys %fnn;
      if($#fnn == 0) { return $fnn[0] }
      return \@fnn;
    }
    return undef;
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

