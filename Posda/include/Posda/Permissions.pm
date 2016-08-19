package Posda::Permissions;

use Modern::Perl '2010';
use Method::Signatures::Simple;
use autodie;

use Posda::Config 'Config';
use Posda::DebugLog 'off';
use Data::Dumper;

use DBI;


method new($class: $username) {
  my $self = {username => $username};
  bless $self, $class;

  $self->_init();
  return $self;
}

method _init() {
  DEBUG 1;
  # Connect to DB, load all permission data for this user
  my $dbh = DBI->connect("DBI:Pg:database=${\Config('auth_db_name')}");
  my $stmt = $dbh->prepare(qq{
    select
      user_name,
      app_name,
      permission_name

    from user_permissions
    natural join users
    natural join apps
    natural join permissions
    where user_name = ?
  });

  $stmt->execute(($self->{username}));
  my $results = $stmt->fetchall_arrayref();

  my $ap = {};

  for my $row (@$results) {
    my ($username, $app_name, $permission) = @$row;
    $ap->{$app_name}->{$permission} = 1;
  }

  $self->{permissions} = $ap;

  $dbh->disconnect;
}

method has_permission($app, $permission) {
  DEBUG @_, $self->{username};
  if (defined $self->{permissions}->{$app}->{$permission}) {
    return 1;
  } else {
    return 0;
  }
}

method has_permission_partial($app) {
  # a simple partial function/closure to bind to a specific app
  return func($perm) {
    return $self->has_permission($app, $perm);
  }
}

method launchable_apps() {
  # return a listref of apps the user has permission to launch
  my @apps = grep {
    defined $self->{permissions}->{$_}->{launch};
  } keys %{$self->{permissions}};
  return \@apps;
}

1;
