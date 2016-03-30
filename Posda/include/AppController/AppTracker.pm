#!/usr/bin/perl -w
#
#Copyright 2013, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
package AppController::AppTracker;
use strict;
use Dispatch::EventHandler;
use Dispatch::Select;
use DBI;

use vars qw(@ISA);
@ISA = qw( Dispatch::EventHandler );
sub new{
  my($class, $db_name, $interval, $file_db, $root_name) = @_;
  my $this = {
    interval => $interval,
    db_name => $db_name,
    pid => $$,
  };
  $this->{db} = DBI->connect("dbi:Pg:dbname=$db_name", "", "");
  $this->{fdb} = DBI->connect("dbi:Pg:dbname=$file_db", "", "");
  $this->{root_name} = $root_name;
  my $qh = $this->{db}->prepare(
    "insert into app_instance (started_at, pid) values (now(), ?)"
  );
  $qh->execute($this->{pid});
  $qh = $this->{db}->prepare(
    "select currval('app_instance_app_instance_id_seq')");
  $qh->execute;
  my $h = $qh->fetchrow_hashref;
  $qh->finish;
  $this->{id} = $h->{currval};
  $this->{qhi} = $this->{db}->prepare(
    "insert into app_measurement(\n" .
    "  app_instance_id, at, pcpu, sz, vsz, num_rcv_sessions,\n " .
    "  num_running_apps, files_in_db_backlog, dirs_in_receive_backlog,\n" .
    "  running_edits_extracts, queued_edits_extracts,\n" .
    "  running_sends, queued_sends, running_discards,\n" .
    "  num_locks, num_sessions, total_transactions\n" .
    ") values (\n" .
    "  ?, now(), ?, ?, ?, ?,\n" .
    "  ?, ?, ?,\n" .
    "  ?, ?,\n" .
    "  ?, ?, ?,\n" .
    "  ?, ?, ?" .
    ")"
  );
  $this->{gfb} = $this->{fdb}->prepare(
     "select count(*) from file where is_dicom_file is null"
  );
  bless $this, $class;
  Dispatch::Select::Background->new($this->Timer)->queue;
  return $this;
}
sub Timer{
  my($this) = @_;
  my $sub = sub {
    my($disp) = @_;
    Dispatch::LineReader->new_cmd("ps -p $this->{pid} -o\"pcpu,size,vsize\"",
      $this->ReadPs, $this->EndPs($disp));
  };
  return $sub;
}
sub ReadPs{
  my($this) = @_;
  my $sub = sub {
    my($line) = @_;
    $line =~ s/^\s*//;
    my @fields = split(/\s+/, $line);
    if($fields[0] eq "%CPU") { return };
    $this->{pcpu} = $fields[0];
    $this->{sz} = $fields[1];
    $this->{vsz} = $fields[2];
  };
  return $sub;
};
sub EndPs{
  my($this, $disp) = @_;
  my $sub = sub {
    my $num_rcv_sessions = 
      keys %{$main::HTTP_STATIC_OBJS{DicomReceiver}->{ActiveConnections}};
    my $num_running_apps = 
      keys %AppController::RunningApps;
    $this->{gfb}->execute;
    my $h = $this->{gfb}->fetchrow_hashref;
    $this->{gfb}->finish;
    my $files_in_db_backlog = $h->{count};
    my $dirs_in_receive_backlog = 0;
    if(exists $main::HTTP_STATIC_OBJS{DicomReceiver}->{PostProcessingQueue}){
      $dirs_in_receive_backlog = 
        @{$main::HTTP_STATIC_OBJS{DicomReceiver}->{PostProcessingQueue}};
    }
    my $running_edits_extracts = 
      keys %{$main::HTTP_STATIC_OBJS{ExtractionManager}->{RunningSubProcesses}};
    my $queued_edits_extracts = 
      keys %{$main::HTTP_STATIC_OBJS{ExtractionManager}->{QueuedSubProcesses}};
    my $running_sends =
      keys %{$main::HTTP_STATIC_OBJS{ExtractionManager}->{RunningSends}};
    my $queued_sends = 
      keys %{$main::HTTP_STATIC_OBJS{ExtractionManager}->{QueuedSends}};
    my $running_discards =
      keys %{$main::HTTP_STATIC_OBJS{ExtractionManager}->{RunningDiscards}};
    my $num_locks = 
      keys %{$main::HTTP_STATIC_OBJS{ExtractionManager}->{locks_by_id}};
    my $num_sessions = 
      keys %{$main::HTTP_APP_SINGLETON->{Inventory}};
    my $total_transactions = 
      $main::HTTP_STATIC_OBJS{ExtractionManager}->{connection_count};
    my $sum_import_time = 0;
    my $count_import_time = 0;
    my $avg_import_time = 0;
    my $imports =
      $main::HTTP_STATIC_OBJS{DbFileImports}->{CompletedSubProcesses};
    for my $k (keys %{$imports}){
      $sum_import_time +=
        $imports->{$k}->{end_time} - $imports->{$k}->{start_time};
      $count_import_time += 1;
    }
    if($count_import_time > 0){
      $avg_import_time = $sum_import_time / $count_import_time;
    };
#    insert into app_measurement(
#      app_instance_id, at, pcpu, sz, vsz, num_rcv_sessions,\
#      num_running_apps, files_in_db_backlog, dirs_in_receive_backlog,\
#      running_edits_extracts, queued_edits_extracts,
#      running_sends, queued_sends, running_discards,
#      num_locks, num_sessions, total_transactions
#    ) values (
#      ?, now(), ?, ?, ?, ?,\
#      ?, ?, ?,
#      ?, ?,
#      ?, ?, ?,
#      ?, ?, ?
#    )
    $this->{qhi}->execute(
      $this->{id}, $this->{pcpu}, $this->{sz}, $this->{vsz}, $num_rcv_sessions,
      $num_running_apps, $files_in_db_backlog, $dirs_in_receive_backlog,
      $running_edits_extracts, $queued_edits_extracts,
      $running_sends, $queued_sends, $running_discards,
      $num_locks, $num_sessions, $total_transactions
    );
    $disp->timer(5);
  };
  return $sub;
}
1;
