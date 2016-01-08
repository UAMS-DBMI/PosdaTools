#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/TciaCuration/include/TciaCuration/ExtractionManager.pm,v $
#$Date: 2015/10/28 14:19:57 $
#$Revision: 1.16 $
#
#Copyright 2013, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
package TciaCuration::ExtractionManager;
use strict;
use Dispatch::EventHandler;
use Dispatch::Select;
use Dispatch::Queue;
use Dispatch::Acceptor;
use IO::Socket::INET;
use FileHandle;
use File::Path qw(make_path remove_tree);
use Storable;

use vars qw(@ISA);
@ISA = qw( Dispatch::EventHandler );
sub new{
  my($class, $port, $config, $base_dir) = @_;
  unless(-d $config->{extraction_root}) {
    die "$config->{extraction_root} is not a directory"
  }
  my $log_file = $config->{log_file};
  my $log;
  open $log, ">$log_file" or die "can't open log: $log_file";
  my $this = {
    port => $port,
    dir => $config->{extraction_root},
    Log => $log,
    LogFileName => $log_file,
    connection_count => 0,
    locks_by_hierarchy => { },
    locks_by_id => { },
    sub_process_program => $config->{sub_process_program},
    extraction_dir => $config->{extraction_root},
  };
  bless $this, $class;
  $this->KeepAlive("Notify", 5, "Keep Alive");
  Dispatch::Acceptor->new($this->ConnectionHandler)->port_server($port)
    ->Add("reader");
  $this->{parallelism} = $config->{parallelism};
  return $this;
}
sub KeepAlive{
  my($this, $method, $delay, $message) = @_;
  my $foo = sub {
    my($self) = @_;
    my $now = time;
    for my $k (keys %{$this->{CompletedSubProcesses}}){
      if($now - $this->{CompletedSubProcesses}->{$k}->{end_time} > 600){
        delete $this->{CompletedSubProcesses}->{$k}
      }
    }
    unless($this->{KillTimer}){
      $this->$method($message);
      $self->timer($delay);
    }
  };
  my $timer = Dispatch::Select::Background->new($foo);
  $timer->timer($delay);
};
sub Notify{
  my($this, $message) = @_;
  my @survivors;
  unless(exists($this->{notifiers})){
    unless($message eq "Keep Alive"){
      print {$this->{Log}} "$message\n";
    }
    return;
  }
  for my $i (@{$this->{notifiers}}){
    if($i && ref($i) eq "CODE"){
      my $alive = &{$i}($message);
      if($alive) { push @survivors, $i }
    }
  }
  if($#survivors >= 0){
    $this->{notifiers} = \@survivors;
  } else {
    delete $this->{notifiers};
  }
}
sub ConnectionHandler{
  my($this) = @_;
  my $sub = sub {
    my($accept, $sock) = @_;
    $this->{connection_count} += 1;
    my $c_handler = Dispatch::Select::Socket->new(
      $this->TransHandler($this->{connection_count}), $sock);
    $c_handler->Add("reader");
  };
  return $sub;
}
sub TransHandler{
  my($this, $id) = @_;
  my @lines;
  my $txt = "";
  my $sub = sub {
    my($disp, $fh) = @_;
    my $count = sysread($fh, $txt, 1000, length($txt));
    if((!defined($count)) || $count <= 0){
      $disp->Remove;
      $this->DoTransaction($fh, \@lines, $id);
    }
    while($txt =~ /^([^\n]*)\n(.*)/s){
      my $line = $1;
      $line =~ s/\r//;
      $txt = $2;
      unless(defined $txt) { $txt = "" };
      if($line eq ""){
        $disp->Remove;
        shutdown($fh, 0);
        $this->DoTransaction($fh, \@lines, $id);
        return;
      }
      push @lines, $line;
    }
  };
  return $sub; 
}
sub DoTransaction{
  my($this, $fh, $lines, $id) = @_;
  my $xactions = {
    "LockForEdit" => "LockForEdit",
    "ReleaseLockWithNoEdit" => "ReleaseLockWithNoEdit",
    "ApplyEdits" => "ApplyEdits",
    "DiscardLastRevision" => "DiscardLastRevision",
    "DiscardExtraction" => "DiscardExtraction",
    "CheckForPhi" => "CheckForPhi",
    "AbortTransaction" => "AbortTransaction",
    "ListLocks" => "ListLocks",
    "GetLockStatus" => "GetLockStatus",
    "SendAllFiles" => "SendAllFiles",
    "SendFilesInStudy" => "SendFilesInStudy",
  };
  unless(ref($lines) eq "ARRAY" && $#{$lines} >= 0){
    Dispatch::Select::Socket->new($this->SendOperationStatus(
      ["Error: no operands"]), $fh)->Add("writer");
    return;
  }
  my $op = shift @$lines;
  my %args;
  for my $line (@$lines) {
    if($line =~ /\s*([^\:]+):\s*(.*)\s*$/){
      my $key = $1;
      my $value = $2;
      $args{$key} = $value;
    } else {
      print {$this->{Log}} "bad arg line: $line\n";
    }
  }
  if($op eq "echo") {
    Dispatch::Select::Socket->new(
      $this->SendOperationStatus($lines), $fh)->Add("writer");
  } elsif (exists $xactions->{$op}){
    $this->$op(\%args, $fh, $id);
  } else {
    unshift @$lines, "Error: unknown op ($op)";
    Dispatch::Select::Socket->new(
      $this->SendOperationStatus($lines), $fh)->Add("writer");
  }
}
sub SendOperationStatus{
  my($this, $lines) = @_;
  my $sub = sub {
    my($disp, $sock) = @_;
    my $line = shift(@$lines);
    unless(defined $line) {
      $disp->Remove;
      $sock->close;
      return;
    }
    print $sock "$line\n";
  };
  return $sub;
}
sub QueueSubProcess{
  my($this, $id) = @_;
  my $trans = $this->{locks_by_id}->{$id};
  unless(exists $this->{RunningSubProcesses}) {
    $this->{RunningSubProcesses} = {};
  }
  $this->{QueuedSubProcesses}->{$id} = $trans;
  $this->StartNextSubProcess;
}
sub StartNextSubProcess{
  my($this) = @_;
  unless(exists $this->{RunningSubProcesses}) {
    $this->{RunningSubProcesses} = {};
  }
  my $number_running = keys %{$this->{RunningSubProcesses}};
  my $number_queued = keys %{$this->{QueuedSubProcesses}};
  while($number_running < $this->{parallelism} && $number_queued > 0){
    my $next_trans_id = [
      sort { $a <=> $b } keys %{$this->{QueuedSubProcesses}}
    ]->[0];
    my $next_trans = $this->{QueuedSubProcesses}->{$next_trans_id};
    $this->{RunningSubProcesses}->{$next_trans_id} = $next_trans;
    delete $this->{QueuedSubProcesses}->{$next_trans_id};
    $next_trans->{start_time} = time;
    $next_trans->{Status} = "Starting";
    Dispatch::LineReader->new_cmd($next_trans->{cmd},
      $this->UpdateSubProcessStatus($next_trans_id),
      $this->EndSubProcess($next_trans_id));
    $number_running = keys %{$this->{RunningSubProcesses}};
    $number_queued = keys %{$this->{QueuedSubProcesses}};
  }
}
#sub StartSubProcess{
#  my($this, $fh, $cfh, $id, $pid) = @_;
#  Dispatch::LineReader->new_fh($cfh,
#    $this->UpdateSubProcessStatus($id),
#    $this->EndSubProcess($id),
#    $pid
#  );
#  Dispatch::Select::Socket->new(
#    $this->SendOperationStatus(["OK: Transaction $id started on pid $pid"]),
#    $fh)->Add("writer");
#}
sub UpdateSubProcessStatus{
  my($this, $id) = @_;
  my $sub = sub {
    my($line) = @_;
    chomp $line;
    my @statii = split("&", $line);
    my %status;
    for my $s (@statii) {
      if($s =~ /(.*)=(.*)/) {
        $status{$1} = $2;
      } else {
        print {$this->{Log}} "Not a pair in " .
          "$this->{RunningSubProcesses}->{$id}->{Transaction}: $line\n";
      }
    }
    unless(exists $status{Status}){
      print {$this->{Log}} "No status in " .
        "$this->{RunningSubProcesses}->{$id}->{Transaction}: $line\n";
    }
    $this->{RunningSubProcesses}->{$id}->{StatusReport} = $line;
    $this->{RunningSubProcesses}->{$id}->{Status} = $status{Status};
  };
  return $sub;
}
sub EndSubProcess{
  my($this, $id) = @_;
  my $sub = sub {
    my $t = $this->{RunningSubProcesses}->{$id};
    delete $this->{RunningSubProcesses}->{$id};
    $this->DeleteLock($id);
    $this->{CompletedSubProcesses}->{$id} = $t;
    $t->{end_time} = time;
    $t->{elapsed} = $t->{end_time} - $t->{start_time};
    push(@{$t->{History}}, {
      extraction => "Done",
      Status => $t->{Status},
      revision => $t->{NextRev},
    });
    Storable::store $t->{History}, $t->{HistoryFile};
    $t->{RevHist}->{CurrentRev} = $t->{NextRev};
    $t->{RevHist}->{Revisions}->{$t->{NextRev}} = {
      start => $t->{start_time},
      end => $t->{end_time},
      user => $t->{User},
      Session => $t->{Session},
      Pid => $t->{Pid},
      Status => $t->{Status},
    };
    Storable::store $t->{RevHist}, $t->{RevHistFile};
    $this->InvokeAfterDelay("StartNextSubProcess", 0);
  };
  return $sub;
}
sub DeleteLock{
  my($this, $id) = @_;
  if(exists $this->{locks_by_id}->{$id}) {
    my $t = $this->{locks_by_id}->{$id};
    delete $this->{locks_by_id}->{$id};
    my $coll = $t->{Collection};
    my $site = $t->{Site};
    my $subj = $t->{Subj};
    $this->{CompletedSubProcesses}->{$id} = $t;
    $t->{end_time} = time;
    if(exists $this->{locks_by_hierarchy}->{$coll}->{$site}->{$subj}){
      delete $this->{locks_by_hierarchy}->{$coll}->{$site}->{$subj};
    } else {
      print STDERR "$id is not in hierarchy: $coll/$site/$subj\n";
    }
    if(exists($t->{LockFile}) && -f $t->{LockFile}){
      unlink $t->{LockFile};
    }
  }
}
##########################
#  Transactions
sub LockForEdit{
  my($this, $args, $fh, $id) = @_;
  my $coll = $args->{Collection};
  my $site = $args->{Site};
  my $subj = $args->{Subject};
  my $sess = $args->{Session};
  my $user = $args->{User};
  my $pid = $args->{Pid};
  my $url = $args->{Response};
  my $dir = $this->{extraction_dir};
  my $for = $args->{For};
  unless(
    defined($coll) &&
    defined($site) &&
    defined($subj) &&
    defined($sess) &&
    defined($user) &&
    defined($pid)
  ){
    Dispatch::Select::Socket->new(
      $this->SendOperationStatus(["Error: bad params"]),
      $fh)->Add("writer");
    return;
  }
  unless(-d "$dir/$coll") {
    unless(mkdir "$dir/$coll") {
      Dispatch::Select::Socket->new(
        $this->SendOperationStatus(["Error: can't mkdir $dir/$coll"]),
        $fh)->Add("writer");
      return;
    }
  }
  unless(-d "$dir/$coll/$site") {
    unless(mkdir "$dir/$coll/$site") {
      Dispatch::Select::Socket->new(
        $this->SendOperationStatus(["Error: can't mkdir $dir/$coll/$site"]),
        $fh)->Add("writer");
      return;
    }
  }
  unless(-d "$dir/$coll/$site/$subj") {
    unless(mkdir "$dir/$coll/$site/$subj") {
      Dispatch::Select::Socket->new(
        $this->SendOperationStatus(
          ["Error: can't mkdir $dir/$coll/$site/$subj"]),
        $fh)->Add("writer");
      return;
    }
  }
  if(exists $this->{locks_by_hierarchy}->{$coll}->{$site}->{$subj}){
    Dispatch::Select::Socket->new(
      $this->SendOperationStatus(
        ["Error: Already Locked"]),
      $fh)->Add("writer");
    return;
  }
  if(-e "$dir/$coll/$site/$subj/lock.txt") {
    Dispatch::Select::Socket->new(
      $this->SendOperationStatus(
        ["Error: Prexisting lock file:  $dir/$coll/$site/$subj/lock.txt"]),
      $fh)->Add("writer");
    return;
  }
  my $ldir = "$dir/$coll/$site/$subj";
  my $now = time;
  my $trans = {
    Collection => $coll,
    Site => $site,
    Subj => $subj,
    Session => $sess,
    User => $user,
    Pid => $pid,
    LockedAt => $now,
    Id => $id,
    For => $for,
  };
  if(defined $url) { $trans->{Response} = $url }
  $this->{locks_by_id}->{$id} = $trans;
  $this->{locks_by_hierarchy}->{$coll}->{$site}->{$subj} = $trans;
  open my $lfh, ">$ldir/lock.txt";
  print $lfh "Locked at: $now\n";
  print $lfh "by: $user\n";
  print $lfh "in session: $sess\n";
  print $lfh "running under pid: $pid\n";
  close $lfh;
  $trans->{LockFile} = "$ldir/lock.txt";
  $trans->{HistoryFile} = "$ldir/history.pinfo";
  $trans->{RevHistFile} = "$ldir/rev_hist.pinfo";
  $trans->{LockDir} = "$ldir";
  my $history = [];
  if(-e "$ldir/history.pinfo"){
    eval { $history = retrieve "$ldir/history.pinfo" };
    if($@){
      $history = [
        {
          message => "Existing history file failed to parse",
          error => $@,
        },
        {
          initial_lock_time => $now,
          by => $user,
          session => $sess,
          pid => $pid,
        },
      ]
    }
  } else {
    $history = [
      {
        initial_lock_time => $now,
        by => $user,
        session => $sess,
        pid => $pid,
      },
    ];
  }
  $trans->{History} = $history;
  my $rev_hist = {};
  if(-e $trans->{RevHistFile}){
    eval { $rev_hist = retrieve $trans->{RevHistFile} };
    if($@){
      $rev_hist = {
        error => "Failed to parse RevHist file",
      };
    }
  }
  $trans->{RevHist} = $rev_hist;
#  my $rev_dir = "$ldir/revisions";
  unless(-d "$ldir/revisions") {
    unless(mkdir "$ldir/revisions"){
      Dispatch::Select::Socket->new(
        $this->SendOperationStatus(
          ["Error: Can't mkdir $ldir/revisions"]),
        $fh)->Add("writer");
      $this->DeleteLock($id);
      return;
    }
  }
  opendir DIR, "$ldir/revisions" or die "Can't opendir $ldir/revisions";
  my @revisions;
  while(my $f = readdir(DIR)){
    if($f =~ /^\./) { next }
    if($f =~ /^del_/) { next } ## ???
    if($f =~ /^\d+$/){
      unless(-d "$ldir/revisions/$f"){
        print {$this->{Log}} "Error: non directory revision ($f) in $ldir\n";
        next;
      }
      push(@revisions, $f);
    } else {
    }
  }
  unless(@revisions > 0){
    unless(mkdir "$ldir/revisions/0") {
      Dispatch::Select::Socket->new(
        $this->SendOperationStatus(
          ["Error: Can't mkdir (initial) $ldir/revisions/0"]),
        $fh)->Add("writer");
      $this->DeleteLock($id);
      return;
    }
    unless(mkdir "$ldir/revisions/0/files") {
      Dispatch::Select::Socket->new(
        $this->SendOperationStatus(
          ["Error: Can't mkdir $ldir/revisions/0/files"]),
        $fh)->Add("writer");
      $this->DeleteLock($id);
      remove_tree("$ldir/revisions");
      return;
    }
    $trans->{NextRev} = "0";
    my $rev_dir = "$ldir/revisions/$trans->{NextRev}";
    $trans->{RevDir} = "$rev_dir";
    $trans->{Dest} = "$rev_dir/files";
#    $trans->{EditDesc} = "$rev_dir/creation.pinfo";
    Dispatch::Select::Socket->new(
      $this->SendOperationStatus(
        [
          "Locked: OK",
          "Revision Dir: $trans->{RevDir}",
          "Destination File Directory: $trans->{Dest}",
          "Id: $trans->{Id}",
        ]),
      $fh)->Add("writer");
    push(@{$trans->{History}}, {
      lock => "OK",
      revision => 0,
    });
    return;
  }
  @revisions = sort {$a <=> $b} @revisions;
  my $first_rev = $revisions[0];
  my $last_rev = $revisions[$#revisions];
  my $next_rev = $last_rev + 1;
  $trans->{PrevRev} = $last_rev;
  $trans->{NextRev} = $next_rev;
  if(-d "$ldir/revisions/$next_rev"){
      Dispatch::Select::Socket->new(
        $this->SendOperationStatus(
          ["Error: $ldir/revisions/$next_rev already exists"]),
        $fh)->Add("writer");
      $this->DeleteLock($id);
      return;
  }
  unless(-d "$ldir/revisions/$last_rev"){
      Dispatch::Select::Socket->new(
        $this->SendOperationStatus(
          ["Error: (Last Rev) $ldir/revisions/$last_rev/files doesn't exist"]),
        $fh)->Add("writer");
      $this->DeleteLock($id);
      return;
  }
  unless(mkdir "$ldir/revisions/$next_rev") {
    Dispatch::Select::Socket->new(
      $this->SendOperationStatus(
        ["Error: Can't mkdir $ldir/revisions/$next_rev"]),
      $fh)->Add("writer");
    $this->DeleteLock($id);
    return;
  }
  unless(mkdir "$ldir/revisions/$next_rev/files") {
    Dispatch::Select::Socket->new(
      $this->SendOperationStatus(
        ["Error: Can't mkdir $ldir/revisions/$next_rev/files"]),
      $fh)->Add("writer");
    $this->DeleteLock($id);
    return;
  }
  my $rev_dir = "$ldir/revisions/$trans->{NextRev}";
  $trans->{RevDir} = "$rev_dir";
  $trans->{Dest} = "$rev_dir/files";
  $trans->{Source} = "$ldir/revisions/$last_rev/files";
  $trans->{EditDesc} = "$rev_dir/creation.pinfo";
  Dispatch::Select::Socket->new(
    $this->SendOperationStatus(
      [
        "Locked: OK",
        "Revision Dir: $trans->{RevDir}",
        "Destination File Directory: $trans->{Dest}",
        "Id: $trans->{Id}",
      ]),
    $fh)->Add("writer");
  push(@{$trans->{History}}, {
    lock => "OK",
    revision => $next_rev,
  });
  return;
}
sub ReleaseLockWithNoEdit{
  my($this, $args, $fh, $foo) = @_;
  my $xid = $args->{Id};
  my $sess = $args->{Session};
  my $usr = $args->{User};
  my $pid = $args->{Pid};
  unless(exists $this->{locks_by_id}->{$xid}) {
    Dispatch::Select::Socket->new(
      $this->SendOperationStatus(
        ["Error: Lock $xid not found"]),
      $fh)->Add("writer");
    return;
  }
  my $trans = $this->{locks_by_id}->{$xid};
  my @errors;
  my $site = $trans->{Site};
  my $subj = $trans->{Subj};
  my $coll = $trans->{Collection};
  unless(exists $this->{locks_by_hierarchy}){
    Dispatch::Select::Socket->new(
      $this->SendOperationStatus(
        ["Error: Hierarchical Lock $coll/$site/$subj not found"]),
      $fh)->Add("writer");
    return;
  }
  unless($trans->{User} = $args->{User}){
    Dispatch::Select::Socket->new(
      $this->SendOperationStatus(
        [ "Error: User requesting rollback ($args->{User}) " .
          "doesn't match user requesing lock ($trans->{User}"]),
      $fh)->Add("writer");
    return;
  }
  unless($trans->{Session} = $args->{Session}){
    Dispatch::Select::Socket->new(
      $this->SendOperationStatus(
        [ "Error: Session requesting rollback ($args->{Session}) " .
          "doesn't match session requesting lock ($trans->{Session}"]),
      $fh)->Add("writer");
    return;
  }
  unless($trans->{Pid} = $args->{Pid}){
    Dispatch::Select::Socket->new(
      $this->SendOperationStatus(
        [ "Error: Pid requesting rollback ($args->{Pid}) " .
          "doesn't match pid requesting lock ($trans->{Pid}"]),
      $fh)->Add("writer");
    return;
  }
  unless(exists $trans->{Dest} && -d $trans->{Dest}){
    Dispatch::Select::Socket->new(
      $this->SendOperationStatus(
        ["Error: Lock next revision not found"]),
      $fh)->Add("writer");
    return;
  }
  push(@{$trans->{History}}, {
    unlock_with_rollback => "OK",
    dest_dir => $trans->{Dest},
    rev_no => $trans->{NextRev},
    at => time,
  });
  $this->DeleteLock($xid);
  if(exists($trans->{Dest}) && -d $trans->{RevDir}){
    remove_tree $trans->{RevDir};
  }
  Storable::store $trans->{History}, $trans->{HistoryFile};
  Dispatch::Select::Socket->new(
    $this->SendOperationStatus(
      ["Released: OK"]),
    $fh)->Add("writer");
  return;
}
sub ApplyEdits{
  my($this, $args, $fh, $foo) = @_;
  my $xid = $args->{Id};
  unless(exists $this->{locks_by_id}->{$xid}){
    Dispatch::Select::Socket->new(
      $this->SendOperationStatus(
        ["Error: Lock $xid not found"]),
      $fh)->Add("writer");
    return;
  }
  my $trans = $this->{locks_by_id}->{$xid};
  unless($trans->{User} = $args->{User}){
    Dispatch::Select::Socket->new(
      $this->SendOperationStatus(
        [ "Error: User requesting Edits ($args->{User}) " .
          "doesn't match user requesing lock ($trans->{User}"]),
      $fh)->Add("writer");
    return;
  }
  unless($trans->{Session} = $args->{Session}){
    Dispatch::Select::Socket->new(
      $this->SendOperationStatus(
        [ "Error: Session requesting Edits ($args->{Session}) " .
          "doesn't match session requesting lock ($trans->{Session}"]),
      $fh)->Add("writer");
    return;
  }
  unless($trans->{Pid} = $args->{Pid}){
    Dispatch::Select::Socket->new(
      $this->SendOperationStatus(
        [ "Error: Pid requesting Edits ($args->{Pid}) " .
          "doesn't match pid requesting lock ($trans->{Pid}"]),
      $fh)->Add("writer");
    return;
  }
  unless(exists $args->{Commands} && -f $args->{Commands}){
    Dispatch::Select::Socket->new(
      $this->SendOperationStatus(
        [ "Error: No Edit Descriptions file when Edit Requested"]),
      $fh)->Add("writer");
    return;
  }
  $trans->{EditDesc} = $args->{Commands};
  $trans->{cmd} = "HandleTransactionSubProcess.pl \"$trans->{EditDesc}\" " .
    "2>\"$trans->{LockDir}/revisions/$trans->{NextRev}" .
    "/sub_process_errors.txt\"";
  $trans->{queue_time} = time;
  $trans->{Status} = "Queued";
  $this->QueueSubProcess($xid);
}
sub DiscardLastRevision{
  my($this, $args, $fh, $id) = @_;
  my $coll = $args->{Collection};
  my $site = $args->{Site};
  my $subj = $args->{Subject};
  my $sess = $args->{Session};
  my $user = $args->{User};
  my $pid = $args->{Pid};
  my $url = $args->{Response};
  my $dir = $this->{extraction_dir};
  my $for = $args->{For};
  unless(
    defined($coll) &&
    defined($site) &&
    defined($subj) &&
    defined($sess) &&
    defined($user) &&
    defined($pid)
  ){
    Dispatch::Select::Socket->new(
      $this->SendOperationStatus(["Error: bad params"]),
      $fh)->Add("writer");
    return;
  }
  unless(
    -d "$dir/$coll" &&
    -d "$dir/$coll/$site" &&
    -d "$dir/$coll/$site/$subj"
  ) {
    #  Directory doesn't exist
    Dispatch::Select::Socket->new(
      $this->SendOperationStatus(
        ["Error: $dir/$coll/$site/$subj doesn't exist " .
          "(therefore can't DiscardLastRevision)"]
      ),
      $fh)->Add("writer");
    return;
  }
  if(exists $this->{locks_by_hierarchy}->{$coll}->{$site}->{$subj}){
    # Directory is already locked
    Dispatch::Select::Socket->new(
      $this->SendOperationStatus(
        ["Error: Already Locked (Can't DiscardLastRevision)"]),
      $fh)->Add("writer");
    return;
  }
  my $ext_dir = "$dir/$coll/$site/$subj";
  my $cmd = "DiscardLastRevision.pl \"$ext_dir\"";
  my $now = time;
  my $trans = {
    Collection => $coll,
    Site => $site,
    Subj => $subj,
    Session => $sess,
    User => $user,
    Pid => $pid,
    LockedAt => $now,
    Id => $id,
    cmd => $cmd,
    For => $for,
  };
  $this->{locks_by_id}->{$id} = $trans;
  $this->{locks_by_hierarchy}->{$coll}->{$site}->{$subj} = $trans;
  if(defined $url) { $trans->{Response} = $url }
  $trans->{Status} = "Queued";
  Dispatch::Select::Socket->new(
    $this->SendOperationStatus([
      "Discard: OK",
      "Disposition: Queued",
      "Id: $trans->{Id}",
    ]),
    $fh
  )->Add("writer");
  $this->{RunningDiscards}->{$id} = $trans;
  Dispatch::LineReader->new_cmd($cmd,
      $this->UpdateDiscardStatus($id),
      $this->EndDiscard($id));
}
sub DiscardExtraction{
  my($this, $args, $fh, $id) = @_;
  my $coll = $args->{Collection};
  my $site = $args->{Site};
  my $subj = $args->{Subject};
  my $sess = $args->{Session};
  my $user = $args->{User};
  my $pid = $args->{Pid};
  my $url = $args->{Response};
  my $dir = $this->{extraction_dir};
  my $for = $args->{For};
  unless(
    defined($coll) &&
    defined($site) &&
    defined($subj) &&
    defined($sess) &&
    defined($user) &&
    defined($pid)
  ){
    Dispatch::Select::Socket->new(
      $this->SendOperationStatus(["Error: bad params"]),
      $fh)->Add("writer");
    return;
  }
  unless(
    -d "$dir/$coll" &&
    -d "$dir/$coll/$site" &&
    -d "$dir/$coll/$site/$subj"
  ) {
    #  Directory doesn't exist
    Dispatch::Select::Socket->new(
      $this->SendOperationStatus(
        ["Error: $dir/$coll/$site/$subj doesn't exist " .
          "(therefore can't DiscardExtraction)"]
      ),
      $fh)->Add("writer");
    return;
  }
  if(exists $this->{locks_by_hierarchy}->{$coll}->{$site}->{$subj}){
    # Directory is already locked
    Dispatch::Select::Socket->new(
      $this->SendOperationStatus(
        ["Error: Already Locked (Can't DiscardExtraction)"]),
      $fh)->Add("writer");
    return;
  }
  # Do the Discard here (sub-process??)
  my $ext_dir = "$dir/$coll/$site/$subj";
  my $cmd = "DiscardExtraction.pl \"$ext_dir\"";
  my $now = time;
  my $trans = {
    Collection => $coll,
    Site => $site,
    Subj => $subj,
    Session => $sess,
    User => $user,
    Pid => $pid,
    LockedAt => $now,
    Id => $id,
    NextRev => "discard",
    cmd => $cmd,
    For => $for,
  };
  $this->{locks_by_id}->{$id} = $trans;
  $this->{locks_by_hierarchy}->{$coll}->{$site}->{$subj} = $trans;
  if(defined $url) { $trans->{Response} = $url }
  $trans->{Status} = "Queued";
  Dispatch::Select::Socket->new(
    $this->SendOperationStatus([
      "Discard: OK",
      "Disposition: Queued",
      "Id: $trans->{Id}",
    ]),
    $fh
  )->Add("writer");
  $this->{RunningDiscards}->{$id} = $trans;
  Dispatch::LineReader->new_cmd($cmd,
      $this->UpdateDiscardStatus($id),
      $this->EndDiscard($id));
}
sub UpdateDiscardStatus{
  my($this, $id) = @_;
  my $sub = sub {
    my($line) = @_;
    chomp $line;
    my @statii = split("&", $line);
    my %status;
    for my $s (@statii) {
      if($s =~ /(.*)=(.*)/) {
        $status{$1} = $2;
      } else {
        print {$this->{Log}} "Not a pair in " .
          "$this->{RunningDiscards}->{$id}->{cmd}: $line\n";
      }
    }
    unless(exists $status{Status}){
      print {$this->{Log}} "No status in " .
        "$this->{RunningDiscards}->{$id}->{cmd}: $line\n";
    }
    $this->{RunningDiscards}->{$id}->{StatusReport} = $line;
    $this->{RunningDiscards}->{$id}->{Status} = $status{Status};
  };
  return $sub;
}
sub EndDiscard{
  my($this, $id) = @_;
  my $sub = sub {
    my $now = time;
    my $t = $this->{RunningDiscards}->{$id};
    delete $this->{RunningDiscards}->{$id};
    $this->{CompletedSubProcesses}->{$id} = $t;
    $t->{end_time} = $now;
    $t->{elapsed} = $now - $t->{LockedAt};
    $this->DeleteLock($id);
  };
  return $sub;
}
sub SendAllFiles{
  my($this, $args, $fh, $id) = @_;
  my $coll = $args->{Collection};
  my $site = $args->{Site};
  my $subj = $args->{Subject};
  my $sess = $args->{Session};
  my $user = $args->{User};
  my $pid = $args->{Pid};
  my $url = $args->{Response};
  my $host = $args->{Host};
  my $port = $args->{Port};
  my $called = $args->{CalledAeTitle};
  my $calling = $args->{CallingAeTitle};
  my $dir = $this->{extraction_dir};
  unless(
    defined($coll) &&
    defined($site) &&
    defined($subj) &&
    defined($sess) &&
    defined($user) &&
    defined($pid)
  ){
    Dispatch::Select::Socket->new(
      $this->SendOperationStatus(["Error: bad params"]),
      $fh)->Add("writer");
    return;
  }
  unless(
    -d "$dir/$coll" &&
    -d "$dir/$coll/$site" &&
    -d "$dir/$coll/$site/$subj"
  ) {
    #  Directory doesn't exist
    Dispatch::Select::Socket->new(
      $this->SendOperationStatus(
        ["Error: $dir/$coll/$site/$subj doesn't exist " .
          "(therefore can't Send)"]
      ),
      $fh)->Add("writer");
    return;
  }
  if(exists $this->{locks_by_hierarchy}->{$coll}->{$site}->{$subj}){
    # Directory is already locked
    Dispatch::Select::Socket->new(
      $this->SendOperationStatus(
        ["Error: Already Locked (Can't Send)"]),
      $fh)->Add("writer");
    return;
  }
  my $ldir = "$dir/$coll/$site/$subj";
  my $now = time;
  my $trans = {
    Collection => $coll,
    Site => $site,
    Subj => $subj,
    Session => $sess,
    User => $user,
    Pid => $pid,
    LockedAt => $now,
    Id => $id,
    Operation => "SendAllFiles",
    For => "Sending",
    SendParms => {
      Host => $host,
      Port => $port,
      Called => $called,
      Calling => $calling,
    },
  };
  if(defined $url) { $trans->{Response} = $url }
  $this->{locks_by_id}->{$id} = $trans;
  $this->{locks_by_hierarchy}->{$coll}->{$site}->{$subj} = $trans;
  open my $lfh, ">$ldir/lock.txt";
  print $lfh "Locked at: $now\n";
  print $lfh "by: $user\n";
  print $lfh "in session: $sess\n";
  print $lfh "running under pid: $pid\n";
  close $lfh;
  $trans->{LockFile} = "$ldir/lock.txt";
  $trans->{HistoryFile} = "$ldir/history.pinfo";
  $trans->{RevHistFile} = "$ldir/rev_hist.pinfo";
  $trans->{LockDir} = "$ldir";
  my $history = [];
  if(-e "$ldir/history.pinfo"){
    eval { $history = retrieve "$ldir/history.pinfo" };
    if($@){
      $history = [
        {
          message => "Existing history file failed to parse",
          error => $@,
        },
        {
          initial_lock_time => $now,
          by => $user,
          session => $sess,
          pid => $pid,
        },
      ]
    }
  } else {
    $history = [
      {
        initial_lock_time => $now,
        by => $user,
        session => $sess,
        pid => $pid,
      },
    ];
  }
  $trans->{History} = $history;
  my $rev_hist = {};
  if(-e $trans->{RevHistFile}){
    eval { $rev_hist = retrieve $trans->{RevHistFile} };
    if($@){
      $rev_hist = {
        error => "Failed to parse RevHist file",
      };
    }
  }
  $trans->{RevHist} = $rev_hist;
#  my $rev_dir = "$ldir/revisions";
  unless(-d "$ldir/revisions") {
    unless(mkdir "$ldir/revisions"){
      Dispatch::Select::Socket->new(
        $this->SendOperationStatus(
          ["Error: Can't mkdir $ldir/revisions"]),
        $fh)->Add("writer");
      $this->DeleteLock($id);
      return;
    }
  }
  opendir DIR, "$ldir/revisions" or die "Can't opendir $ldir/revisions";
  my @revisions;
  while(my $f = readdir(DIR)){
    if($f =~ /^\./) { next }
    if($f =~ /^del_/) { next } ## ???
    if($f =~ /^\d+$/){
      unless(-d "$ldir/revisions/$f"){
        print {$this->{Log}} "Error: non directory revision ($f) in $ldir\n";
        next;
      }
      push(@revisions, $f);
    } else {
    }
  }
  if(@revisions < 0){
    Dispatch::Select::Socket->new(
      $this->SendOperationStatus(
        ["Error: No Data (Can't Send)"]),
      $fh
    )->Add("writer");
    $this->DeleteLock($id);
    return;
  }
  @revisions = sort {$a <=> $b} @revisions;
  my $first_rev = $revisions[0];
  my $last_rev = $revisions[$#revisions];
  $trans->{SendRev} = $last_rev;
  unless(-d "$ldir/revisions/$last_rev"){
      Dispatch::Select::Socket->new(
        $this->SendOperationStatus(
          ["Error: (Last Rev) $ldir/revisions/$last_rev/files doesn't exist"]),
        $fh)->Add("writer");
      $this->DeleteLock($id);
      return;
  }
  $trans->{dicom_info_file} = "$ldir/revisions/$last_rev/dicom.pinfo";
  $trans->{send_hist_file} = "$ldir/revisions/$last_rev/send_hist.pinfo";
  unless(-f $trans->{dicom_info_file}){
      Dispatch::Select::Socket->new(
        $this->SendOperationStatus(
          ["Error: $ldir/revisions/$last_rev/dicom.pinfo doesn't exist"]),
        $fh)->Add("writer");
      $this->DeleteLock($id);
      return;
  }
  my $cmd = "DicomSendTransaction.pl \"" .
    "$trans->{SendParms}->{Host}\" \"" .
    "$trans->{SendParms}->{Port}\" \"" .
    "$trans->{SendParms}->{Called}\" \"" .
    "$trans->{SendParms}->{Calling}\" \"" .
    "$trans->{dicom_info_file}\" \"" .
    "$trans->{send_hist_file}\"";
  $trans->{Command} = $cmd;
  #  Here we need to lock the dir, and start the process
  if(defined $url) { $trans->{Response} = $url }
  $trans->{Status} = "Queued";
  Dispatch::Select::Socket->new(
    $this->SendOperationStatus([
      "SendAllFiles: OK",
      "Disposition: Queued",
      "Id: $trans->{Id}",
    ]),
    $fh
  )->Add("writer");
  unless(exists $this->{QueuedSends}) { $this->{QueuedSends} = [] }
  push(@{$this->{QueuedSends}}, $trans);
  $this->StartSends;
}
sub SendFilesInStudy{
  my($this, $args, $fh, $id) = @_;
  my $coll = $args->{Collection};
  my $site = $args->{Site};
  my $subj = $args->{Subject};
  my $sess = $args->{Session};
  my $user = $args->{User};
  my $pid = $args->{Pid};
  my $url = $args->{Response};
  my $host = $args->{Host};
  my $port = $args->{Port};
  my $called = $args->{CalledAeTitle};
  my $calling = $args->{CallingAeTitle};
  my $dir = $this->{extraction_dir};
  my $SelectedStudy = $args->{SelectedStudy};
  unless(
    defined($coll) &&
    defined($site) &&
    defined($subj) &&
    defined($sess) &&
    defined($user) &&
    defined($pid)
  ){
    Dispatch::Select::Socket->new(
      $this->SendOperationStatus(["Error: bad params"]),
      $fh)->Add("writer");
    return;
  }
  unless(
    -d "$dir/$coll" &&
    -d "$dir/$coll/$site" &&
    -d "$dir/$coll/$site/$subj"
  ) {
    #  Directory doesn't exist
    Dispatch::Select::Socket->new(
      $this->SendOperationStatus(
        ["Error: $dir/$coll/$site/$subj doesn't exist " .
          "(therefore can't Send)"]
      ),
      $fh)->Add("writer");
    return;
  }
  if(exists $this->{locks_by_hierarchy}->{$coll}->{$site}->{$subj}){
    # Directory is already locked
    Dispatch::Select::Socket->new(
      $this->SendOperationStatus(
        ["Error: Already Locked (Can't Send)"]),
      $fh)->Add("writer");
    return;
  }
  my $ldir = "$dir/$coll/$site/$subj";
  my $now = time;
  my $trans = {
    Collection => $coll,
    Site => $site,
    Subj => $subj,
    Session => $sess,
    User => $user,
    Pid => $pid,
    LockedAt => $now,
    Id => $id,
    Operation => "SendFilesInStudy",
    For => "Sending",
    SelectedStudy => $SelectedStudy,
    SendParms => {
      Host => $host,
      Port => $port,
      Called => $called,
      Calling => $calling,
    },
  };
  if(defined $url) { $trans->{Response} = $url }
  $this->{locks_by_id}->{$id} = $trans;
  $this->{locks_by_hierarchy}->{$coll}->{$site}->{$subj} = $trans;
  open my $lfh, ">$ldir/lock.txt";
  print $lfh "Locked at: $now\n";
  print $lfh "by: $user\n";
  print $lfh "in session: $sess\n";
  print $lfh "running under pid: $pid\n";
  close $lfh;
  $trans->{LockFile} = "$ldir/lock.txt";
  $trans->{HistoryFile} = "$ldir/history.pinfo";
  $trans->{RevHistFile} = "$ldir/rev_hist.pinfo";
  $trans->{LockDir} = "$ldir";
  my $history = [];
  if(-e "$ldir/history.pinfo"){
    eval { $history = retrieve "$ldir/history.pinfo" };
    if($@){
      $history = [
        {
          message => "Existing history file failed to parse",
          error => $@,
        },
        {
          initial_lock_time => $now,
          by => $user,
          session => $sess,
          pid => $pid,
        },
      ]
    }
  } else {
    $history = [
      {
        initial_lock_time => $now,
        by => $user,
        session => $sess,
        pid => $pid,
      },
    ];
  }
  $trans->{History} = $history;
  my $rev_hist = {};
  if(-e $trans->{RevHistFile}){
    eval { $rev_hist = retrieve $trans->{RevHistFile} };
    if($@){
      $rev_hist = {
        error => "Failed to parse RevHist file",
      };
    }
  }
  $trans->{RevHist} = $rev_hist;
#  my $rev_dir = "$ldir/revisions";
  unless(-d "$ldir/revisions") {
    unless(mkdir "$ldir/revisions"){
      Dispatch::Select::Socket->new(
        $this->SendOperationStatus(
          ["Error: Can't mkdir $ldir/revisions"]),
        $fh)->Add("writer");
      $this->DeleteLock($id);
      return;
    }
  }
  opendir DIR, "$ldir/revisions" or die "Can't opendir $ldir/revisions";
  my @revisions;
  while(my $f = readdir(DIR)){
    if($f =~ /^\./) { next }
    if($f =~ /^del_/) { next } ## ???
    if($f =~ /^\d+$/){
      unless(-d "$ldir/revisions/$f"){
        print {$this->{Log}} "Error: non directory revision ($f) in $ldir\n";
        next;
      }
      push(@revisions, $f);
    } else {
    }
  }
  if(@revisions < 0){
    Dispatch::Select::Socket->new(
      $this->SendOperationStatus(
        ["Error: No Data (Can't Send)"]),
      $fh
    )->Add("writer");
    $this->DeleteLock($id);
    return;
  }
  @revisions = sort {$a <=> $b} @revisions;
  my $first_rev = $revisions[0];
  my $last_rev = $revisions[$#revisions];
  $trans->{SendRev} = $last_rev;
  unless(-d "$ldir/revisions/$last_rev"){
      Dispatch::Select::Socket->new(
        $this->SendOperationStatus(
          ["Error: (Last Rev) $ldir/revisions/$last_rev/files doesn't exist"]),
        $fh)->Add("writer");
      $this->DeleteLock($id);
      return;
  }
  $trans->{dicom_info_file} = "$ldir/revisions/$last_rev/dicom.pinfo";
  $trans->{send_hist_file} = "$ldir/revisions/$last_rev/send_hist.pinfo";
  unless(-f $trans->{dicom_info_file}){
      Dispatch::Select::Socket->new(
        $this->SendOperationStatus(
          ["Error: $ldir/revisions/$last_rev/dicom.pinfo doesn't exist"]),
        $fh)->Add("writer");
      $this->DeleteLock($id);
      return;
  }
  my $cmd = "DicomSendStudyTransaction.pl \"" .
    "$trans->{SendParms}->{Host}\" \"" .
    "$trans->{SendParms}->{Port}\" \"" .
    "$trans->{SendParms}->{Called}\" \"" .
    "$trans->{SendParms}->{Calling}\" \"" .
    "$trans->{dicom_info_file}\" \"" .
    "$trans->{send_hist_file}\" \"" .
    "$trans->{SelectedStudy}\"";
  $trans->{Command} = $cmd;
  #  Here we need to lock the dir, and start the process
  if(defined $url) { $trans->{Response} = $url }
  $trans->{Status} = "Queued";
  Dispatch::Select::Socket->new(
    $this->SendOperationStatus([
      "SendFilesInStudy: OK",
      "Disposition: Queued",
      "Id: $trans->{Id}",
    ]),
    $fh
  )->Add("writer");
  unless(exists $this->{QueuedSends}) { $this->{QueuedSends} = [] }
  push(@{$this->{QueuedSends}}, $trans);
  $this->StartSends;
}
sub StartSends{
  my($this) = @_;
  my $num_running = keys %{$this->{RunningSends}};
  my $num_queued = @{$this->{QueuedSends}};
  if($num_running < 1 && $num_queued >= 1){
    my $trans = shift(@{$this->{QueuedSends}});
    my $cmd = $trans->{Command};
    my $id = $trans->{Id};
    $this->{RunningSends}->{$id} = $trans;
    Dispatch::LineReader->new_cmd($cmd,
      $this->UpdateSendStatus($id),
      $this->SendComplete($id));
  }
}
sub UpdateSendStatus{
  my($this, $id) = @_;
  my $sub = sub {
    my($line) = @_;
    chomp $line;
    my @statii = split("&", $line);
    my %status;
    for my $s (@statii) {
      if($s =~ /(.*)=(.*)/) {
        $status{$1} = $2;
      } else {
        print {$this->{Log}} "Not a pair in " .
          "$this->{RunningSends}->{$id}->{Transaction}: $line\n";
      }
    }
    unless(exists $status{Status}){
      print {$this->{Log}} "No status in " .
        "$this->{RunningSends}->{$id}->{Transaction}: $line\n";
    }
    $this->{RunningSends}->{$id}->{StatusReport} = $line;
    $this->{RunningSends}->{$id}->{Status} = $status{Status};
  };
  return $sub;
}
sub SendComplete{
  my($this, $id) = @_;
  my $sub = sub {
    my $now = time;
    my $t = $this->{RunningSends}->{$id};
    delete $this->{RunningSends}->{$id};
    $this->{CompletedSubProcesses}->{$id} = $t;
    $t->{end_time} = $now;
    $t->{elapsed} = $now - $t->{LockedAt};
    $this->DeleteLock($id);
    $this->StartSends;
  };
  return $sub;
}
sub CheckForPhi{
  my($this, $args, $fh, $id) = @_;
  my $coll = $args->{Collection};
  my $site = $args->{Site};
  my $subj = $args->{Subject};
  my $sess = $args->{Session};
  my $user = $args->{User};
  my $pid = $args->{Pid};
  my $url = $args->{Response};
  my $dir = $this->{extraction_dir};
  my $for = $args->{For};
  unless(
    defined($coll) &&
    defined($site) &&
    defined($subj) &&
    defined($sess) &&
    defined($user) &&
    defined($pid)
  ){
    Dispatch::Select::Socket->new(
      $this->SendOperationStatus(["Error: bad params"]),
      $fh)->Add("writer");
    return;
  }
  unless(
    -d "$dir/$coll" &&
    -d "$dir/$coll/$site" &&
    -d "$dir/$coll/$site/$subj"
  ) {
    #  Directory doesn't exist
    Dispatch::Select::Socket->new(
      $this->SendOperationStatus(
        ["Error: $dir/$coll/$site/$subj doesn't exist " .
          "(therefore can't CheckForPhi)"]
      ),
      $fh)->Add("writer");
    return;
  }
  if(exists $this->{locks_by_hierarchy}->{$coll}->{$site}->{$subj}){
    # Directory is already locked
    Dispatch::Select::Socket->new(
      $this->SendOperationStatus(
        ["Error: Already Locked (Can't CheckForPhi)"]),
      $fh)->Add("writer");
    return;
  }
  # Check for PHI here in sub-process
  my $ext_dir = "$dir/$coll/$site/$subj";
  my $cmd = "CheckForPhi.pl \"$ext_dir\"";
  my $now = time;
  my $trans = {
    Collection => $coll,
    Site => $site,
    Subj => $subj,
    Session => $sess,
    User => $user,
    Pid => $pid,
    LockedAt => $now,
    Id => $id,
    cmd => $cmd,
    For => $for,
  };
  $this->{locks_by_id}->{$id} = $trans;
  $this->{locks_by_hierarchy}->{$coll}->{$site}->{$subj} = $trans;
  if(defined $url) { $trans->{Response} = $url }
  $trans->{Status} = "Queued";
  Dispatch::Select::Socket->new(
    $this->SendOperationStatus([
      "CheckForPhi: OK",
      "Disposition: Queued",
      "Id: $trans->{Id}",
    ]),
    $fh
  )->Add("writer");
  $this->{RunningPhiChecks}->{$id} = $trans;
  Dispatch::LineReader->new_cmd($cmd,
      $this->UpdatePhiCheckStatus($id),
      $this->EndPhiCheck($id));
}
sub UpdatePhiCheckStatus{
  my($this, $id) = @_;
  my $sub = sub {
    my($line) = @_;
    chomp $line;
    my @statii = split("&", $line);
    my %status;
    for my $s (@statii) {
      if($s =~ /(.*)=(.*)/) {
        $status{$1} = $2;
      } else {
        print {$this->{Log}} "Not a pair in " .
          "$this->{RunningPhiChecks}->{$id}->{cmd}: $line\n";
      }
    }
    unless(exists $status{Status}){
      print {$this->{Log}} "No status in " .
        "$this->{RunningPhiChecks}->{$id}->{cmd}: $line\n";
    }
    $this->{RunningPhiChecks}->{$id}->{StatusReport} = $line;
    $this->{RunningPhiChecks}->{$id}->{Status} = $status{Status};
  };
  return $sub;
}
sub EndPhiCheck{
  my($this, $id) = @_;
  my $sub = sub {
    my $now = time;
    my $t = $this->{RunningPhiChecks}->{$id};
    delete $this->{RunningPhiChecks}->{$id};
    $this->{CompletedSubPhiChecks}->{$id} = $t;
    $t->{end_time} = $now;
    $t->{elapsed} = $now - $t->{LockedAt};
    $this->DeleteLock($id);
  };
  return $sub;
}
sub AbortTransaction{
  my($this, $args, $fh, $foo) = @_;
}
sub ListLocks{
  my($this, $args, $fh, $foo) = @_;
  my @resp_list;
  for my $id (keys %{$this->{locks_by_id}}){
    my $lock = $this->{locks_by_id}->{$id};
    my $resp = "Lock: Id=$id";
    my @parm_list;
    for my $k (
      "Collection", "For", "Site", "Subj", "Session", "User", "Status",
      "NextRev"
    ){
      if(exists $lock->{$k}){
        push(@parm_list, "$k=$lock->{$k}");
      }
    }
    for my $pi (0 .. $#parm_list){
      $resp .= "|$parm_list[$pi]";
    }
    push(@resp_list, $resp);
  }
  Dispatch::Select::Socket->new(
    $this->SendOperationStatus(
      \@resp_list),
    $fh)->Add("writer");
}
sub GetLockStatus{
  my($this, $args, $fh, $foo) = @_;
}
sub RollLogs{
  my($this, $args, $fh, $foo) = @_;
}
1;
