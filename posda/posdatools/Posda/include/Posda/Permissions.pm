package Posda::Permissions;

use Modern::Perl '2010';
use autodie;

use Posda::Config 'Database';
use Posda::DebugLog 'off';
use Data::Dumper;

use DBI;


sub new {
  my ($class, $username) = @_;
  my $self = {username => $username};
  bless $self, $class;

  $self->_init();
  return $self;
}

sub _init {
  my ($self) = @_;
  # Connect to DB, load all permission data for this user
  my $dbh = DBI->connect(Database('posda_auth'));
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

sub has_permission {
  my ($self, $app, $permission) = @_;
  if (defined $self->{permissions}->{$app}->{$permission}) {
    return 1;
  } else {
    return 0;
  }
}

sub has_permission_partial {
  my ($self, $app) = @_;
  # a simple partial function/closure to bind to a specific app
  return sub {
  my ($perm) = @_;
    return $self->has_permission($app, $perm);
  }
}

sub launchable_apps {
  my ($self) = @_;
  # return a listref of apps the user has permission to launch
  my @apps = grep {
    defined $self->{permissions}->{$_}->{launch};
  } keys %{$self->{permissions}};
  return \@apps;
}

1;
