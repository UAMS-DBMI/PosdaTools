package Posda::Inbox;
=head1 NAME

Posda::Inbox - A module for interacting with the Posda Inbox.

=head1 SYNOPSIS

 use Posda::Inbox;
 my $inbox = Posda::Inbox->new('some_username');

 # get count of unread items
 $inbox->UnreadCount;

 # Send a new email to some_other_user; the content of the mail message
 # is stored in a background report with ID 7
 $inbox->SendMail('some_other_user', 7, 'Test');

=head1 METHODS
=cut

use Modern::Perl;


use DBI;

use Posda::Config ('Database', 'Config');

use File::Slurp;
use Regexp::Common "URI";
use FileHandle;
use Posda::DB 'Query';

sub new {
  my ($class, $username) = @_;

  my $self = {
    username => $username,
  };


  return bless $self, $class;
}

# Utility methods ##########################################################{{{

sub send_real_email_notification {
  my ($self, $username) = @_;
  my $send_email = Config('real_email');
  if (defined $send_email && $send_email == 1) {
    my $email_handle = FileHandle->new(
      '|mail -s "New Posda Inbox Item!" '
      . $self->get_email_addr_by_username($username));
    unless($email_handle) { die "Couldn't open email handle ($!)" }
    $email_handle->print("A new message has arrived in your Posda Inbox!\n");
    close($email_handle);
  }
}
sub get_handle {
  my ($self) = @_;
  my $db_handle = DBI->connect(Database('posda_queries'));
  return $db_handle;
}

sub release_handle {
  my ($self, $handle) = @_;
  $handle->disconnect();
}

sub execute_and_fetchall {
  my ($self, $query, $args) = @_;
  my $handle = $self->get_handle;

  my $qh = $handle->prepare($query);

  $qh->execute(@$args);

  my $rows = $qh->fetchall_arrayref({});
  $qh->finish;

  $self->release_handle($handle);

  return $rows;
}

sub execute_and_fetchone {
  my ($self, $query, $args) = @_;
  my $handle = $self->get_handle;

  my $qh = $handle->prepare($query);

  $qh->execute(@$args);

  my $rows = $qh->fetchrow_hashref();
  $qh->finish;

  $self->release_handle($handle);

  return $rows;
}

sub execute {
  my ($self, $query, $args) = @_;
  my $handle = $self->get_handle;

  my $qh = $handle->prepare($query);

  my $rows_affected = $qh->execute(@$args);

  $qh->finish;

  $self->release_handle($handle);

  return $rows_affected;
}

sub change_status_to {
  my ($self, $message_id, $new_status, $operation_type) = @_;
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
sub get_email_addr_by_username {
  my ($self, $username) = @_;
  return $self->execute_and_fetchone(qq{
    select user_email_addr
    from user_inbox
    where user_name = ?
  }, [$username])->{user_email_addr};
}
# End Utility methods ######################################################}}}


=head2 SendMail($username, $background_subprocess_report_id, $how)

Add a new email item to the inbox of $username.

If the environment var POSDA_REAL_EMAIL is set to 1,
an email notification will also be sent to the
user's email.

B<Arguments:>

 $username: The username who's inbox will get the mail item.
 $background_subprocess_report_id: ID of the report that contains the
  email content.
 $how: A short note explaining the source of this email.

=cut
sub SendMail {
  print STDERR "\n####SENDING MAIL #####\n";

  my ($self, $username, $report_id, $how, $activity_id) = @_;
  my $result = $self->execute_and_fetchone(qq{
    insert into user_inbox_content (
      user_inbox_id,
      background_subprocess_report_id,
      current_status,
      statuts_note,
      date_entered,
      date_dismissed
    ) values (
      (select user_inbox_id
       from user_inbox
       where user_name = ?), ?, ?, ?, now(), null
    )
    returning user_inbox_content_id
  }, [$username,
      $report_id,
      'entered',
      "created by $how"]);

  my $rows = $self->execute(qq{
    insert into user_inbox_content_operation (
      user_inbox_content_id,
      operation_type,
      when_occurred,
      how_invoked,
      invoking_user
    ) values (
      ?, ?, now(), ?, ?
    )
  }, [$result->{user_inbox_content_id},
      'entered',
      $how,
      $self->{username}]);

  $self->send_real_email_notification($username);

  #print STDERR "\n####Time to file #####\n";
  #print STDERR  $activity_id ;
  #print STDERR "\n####Time to file #####\n";

  if (defined $activity_id){
    my $q = Query('InsertActivityInboxContent');
    $q->RunQuery(sub {}, sub{}, $activity_id, $result->{user_inbox_content_id});
    #print STDERR "\n#### I tried to file it #####\n";
    $self->SetFiled($result->{user_inbox_content_id});
  }

   return $rows;
 }

=head2 Forward($message_id, $username)

Forward the message identified by $message_id to $username.

If the environment var POSDA_REAL_EMAIL is set to 1,
an email notification will also be sent to the
user's email.

=cut
sub Forward {
  my ($self, $message_id, $username) = @_;
  my $details = $self->ItemDetails($message_id);

  my $report_id = $details->{background_subprocess_report_id};
  my $note = $details->{statuts_note};


  my $result = $self->execute_and_fetchone(qq{
    insert into user_inbox_content (
      user_inbox_id,
      background_subprocess_report_id,
      current_status,
      statuts_note,
      date_entered,
      date_dismissed
    ) values (
      (select user_inbox_id
       from user_inbox
       where user_name = ?), ?, ?, ?, now(), null
    )
    returning user_inbox_content_id
  }, [$username,
      $report_id,
      'entered',
      $note]);

  my $rows = $self->execute(qq{
    insert into user_inbox_content_operation (
      user_inbox_content_id,
      operation_type,
      when_occurred,
      how_invoked,
      invoking_user
    ) values (
      ?, ?, now(), ?, ?
    )
  }, [$result->{user_inbox_content_id},
      'entered',
      'manually forwarded', # TODO: add the original how here?
      $self->{username}]);

  $self->send_real_email_notification($username);

  return $rows;
}

=head2 UnreadCount()

Return a count of unread items in the current user's inbox.

A message is B<unread> if date_dismissed is null, and the current_status is
set to one of the statuses: entered, new
=cut
sub UnreadCount {
  my ($self) = @_;
  return $self->execute_and_fetchone(qq{
    select count(*)
    from user_inbox_content
    natural join user_inbox
    where current_status in ('entered', 'new')
      and date_dismissed is null
      and user_name = ?
  }, [$self->{username}])->{count};
}

=head2 UndismissedCount()

Return a count of undismissed items in the current user's inbox.

=cut
sub UndismissedCount {
  my ($self) = @_;
  return $self->execute_and_fetchone(qq{
    select count(*)
    from user_inbox_content
    natural join user_inbox
    where user_name = ?
      and date_dismissed is null
  }, [$self->{username}])->{count};
}

=head2 AllItems()

Return a list of all items in the current user's Inbox. This includes
dismissed items.

=cut
sub AllItems {
  my ($self) = @_;
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

=head2 AllUndismissedItems()

Return a list of all items in the current user's Inbox that have not been
dismissed.

=cut
sub AllUndismissedItems {
  my ($self) = @_;
  return $self->execute_and_fetchall(qq{
    select
      user_inbox_content_id,
      background_subprocess_report_id,
      current_status,
      date_entered,
      operation_name

    from user_inbox_content
    natural join user_inbox
    natural left join background_subprocess_report
    natural left join background_subprocess
    natural left join subprocess_invocation

    where user_name = ?
      and date_dismissed is null
    order by user_inbox_content_id desc
  }, [$self->{username}]);
}

=head2 ItemDetails($message_id)

Returns a hashref with details about Inbox item identified by $message_id.

=cut
sub ItemDetails {
  my ($self, $message_id) = @_;
  return $self->execute_and_fetchone(qq{
    select *
    from
      user_inbox_content
      natural join background_subprocess_report
      natural join background_subprocess
      natural join subprocess_invocation
    where user_inbox_content_id = ?
  }, [$message_id]);
}

=head2 RecentOperations($message_id)

Return an arrayref of the last 15 operations that were performed on
the Inbox item identified by $message_id.

=cut
sub RecentOperations {
  my ($self, $message_id) = @_;
  return $self->execute_and_fetchall(qq{
    select *
    from user_inbox_content_operation
    where user_inbox_content_id = ?
    order by when_occurred desc
    limit 15
  }, [$message_id]);
}

=head2 ReportFilename($file_id)

Return the absolute path to the file identified by $file_id.

B<NOTE:> this method must establish a connection to posda_files, which
is not the main database this module uses. It also disconnects immediately
after retrieving the filename, so you probably should not call this inside
a tight loop.

=cut
sub ReportFilename {
  my ($self, $file_id) = @_;
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

=head2 ReportContent($file_id)

Return the entire content of the report identified by $file_id.

B<NOTE:> This method calls Posda::Inbox::ReportFilename, which creates
an extra database connection. See notes above.

=cut
sub ReportContent {
  my ($self, $file_id) = @_;
  my $filename = $self->ReportFilename($file_id);
  my $file_content = read_file($filename);
  return $file_content;
}

=head2 SetRead($message_id)

Set an Inbox item, identified by $message_id, to the 'read' status.
This method also adds an entry into the user_inbox_content_operation table.

=cut
sub SetRead {
  my ($self, $message_id) = @_;
  $self->change_status_to($message_id, 'read', 'message read');
}

=head2 SetDismissed($message_id)

Set an Inbox item, identified by $message_id, to the 'dismissed' status,
and set the date_dismissed to now.

This method also adds an entry into the user_inbox_content_operation table.

=cut
sub SetDismissed {
  my ($self, $message_id) = @_;
  $self->change_status_to($message_id, 'dismissed', 'message dismissed');
  $self->execute(qq{
    update user_inbox_content
    set date_dismissed = now()
    where user_inbox_content_id = ?
  }, [$message_id]);
}

=head2 GetAllUsernames()

Return an arrayref containing a list of all usernames which
are valid targets for sending email to.

=cut
sub GetAllUsernames {
  my ($self) = @_;
  return $self->execute_and_fetchall(qq{
    select user_name
    from user_inbox
  });
}

1;
