package Posda::Inbox;

use Modern::Perl;
use Method::Signatures::Simple;

use DBI;

use Posda::Config 'Database';

use File::Slurp;
use Regexp::Common "URI";


method new($class: $username) {

  my $self = {
    username => $username,
  };


  return bless $self, $class;
}

# Utility methods #############################################################

method get_handle() {
  my $db_handle = DBI->connect(Database('posda_queries'));
  return $db_handle;
}

method release_handle($handle) {
  $handle->disconnect();
}

method execute_and_fetchall($query, $args) {
  my $handle = $self->get_handle;

  my $qh = $handle->prepare($query);

  $qh->execute(@$args);

  my $rows = $qh->fetchall_arrayref({});
  $qh->finish;

  $self->release_handle($handle);

  return $rows;
}

method execute_and_fetchone($query, $args) {
  my $handle = $self->get_handle;

  my $qh = $handle->prepare($query);

  $qh->execute(@$args);

  my $rows = $qh->fetchrow_hashref();
  $qh->finish;

  $self->release_handle($handle);

  return $rows;
}
method execute($query, $args) {
  my $handle = $self->get_handle;

  my $qh = $handle->prepare($query);

  my $rows_affected = $qh->execute(@$args);

  $qh->finish;

  $self->release_handle($handle);

  return $rows_affected;
}

method change_status_to($message_id, $new_status, $operation_type) {
  $self->execute(qq{
    update user_inbox_content
    set current_status = ?
    where user_inbox_content_id = ?
  }, [$new_status, $message_id]);

  $self->execute(qq{
    insert into user_inbox_content_operation
    (user_inbox_content_id,
     operation_type,
     when_occurred,
     how_invoked,
     invoking_user)
    values (?, ?, now(), ?, ?)
  }, [$message_id, $operation_type, 'Posda::Inbox', $self->{username}]);
}
# End Utility methods #########################################################

method UnreadCount() {
  return $self->execute_and_fetchone(qq{
    select count(*)
    from user_inbox_content
    natural join user_inbox
    where current_status in ('entered', 'new')
      and date_dismissed is null
      and user_name = ?
  }, [$self->{username}])->{count};
}
method UndismissedCount() {
  return $self->execute_and_fetchone(qq{
    select count(*)
    from user_inbox_content
    natural join user_inbox
    where user_name = ?
      and date_dismissed is null
  }, [$self->{username}])->{count};
}

method AllItems() {
  return $self->execute_and_fetchall(qq{
    select
      user_inbox_content_id,
      background_subprocess_report_id,
      current_status,
      date_entered
    from user_inbox_content 
    natural join user_inbox
    where user_name = ?
    order by date_entered desc
  }, [$self->{username}]);
}

method AllUndismissedItems() {
  return $self->execute_and_fetchall(qq{
    select
      user_inbox_content_id,
      background_subprocess_report_id,
      current_status,
      date_entered
    from user_inbox_content 
    natural join user_inbox
    where user_name = ?
      and date_dismissed is null
    order by current_status, date_entered desc
  }, [$self->{username}]);
}

method ItemDetails($message_id) {
  return $self->execute_and_fetchone(qq{
    select
      user_inbox_content_id,
      current_status,
      statuts_note,
      date_entered,
      date_dismissed,
      file_id
    from user_inbox_content
    natural join background_subprocess_report
    where user_inbox_content_id = ?
  }, [$message_id]);
}

method RecentOperations($message_id) {
  return $self->execute_and_fetchall(qq{
    select *
    from user_inbox_content_operation
    where user_inbox_content_id = ?
    order by when_occurred desc
    limit 15
  }, [$message_id]);
}

method ReportFilename($file_id) {
  my $db_handle = DBI->connect(Database('posda_files'));

  my $dbh = $db_handle->prepare(qq{
    select root_path || '/' || rel_path as filename
    from file
    natural join file_location
    natural join file_storage_root
    where file_id = ?
  });

  $dbh->execute($file_id);
  my $row = $dbh->fetchrow_hashref;

  $dbh->finish;
  $db_handle->disconnect;

  return $row->{filename};
}

method ReportContent($file_id) {
  my $filename = $self->ReportFilename($file_id);
  my $file_content = read_file($filename);
  return $file_content;
}

method SetRead($message_id) {
  $self->change_status_to($message_id, 'read', 'message read');
}

method SetDismissed($message_id) {
  $self->change_status_to($message_id, 'dismissed', 'message dismissed');
  $self->execute(qq{
    update user_inbox_content
    set date_dismissed = now()
    where user_inbox_content_id = ?
  }, [$message_id]);
}

1;
