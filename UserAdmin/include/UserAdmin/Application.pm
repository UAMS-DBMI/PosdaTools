package UserAdmin::Application;
#
# A User Admin application
#

use vars '@ISA';
@ISA = ("GenericApp::Application");

use Modern::Perl '2010';
use Method::Signatures::Simple;
use Storable 'dclone';

use GenericApp::Application;

use Posda::Config 'Config';

use Posda::DebugLog 'on';
use Data::Dumper;


method SpecificInitialize() {
  $self->{dbh} = DBI->connect("DBI:Pg:database=${\Config('auth_db_name')}");
  $self->{AllPermissions} = $self->GetAllPermissionList();
  $self->{AppPermMap} = $self->GetAppPermMap();

  $self->{Mode} = "RenderUserList";
}

method GetAllPermissionList() {
  my $stmt = $self->{dbh}->prepare(qq{
    select *
    from permissions
  });

  $stmt->execute();
  my $results = $stmt->fetchall_arrayref();
  $stmt->finish;

  my $perms = {};
  map {
    my ($id, $name) = @$_;
    $perms->{$name} = $id;
  } @$results;

  return $perms;
}

method GetAppPermMap() {
  # NOTE: This cross product is intentional! Do not be alarmed.
  my $stmt = $self->{dbh}->prepare(qq{
   select * from apps, permissions
  });

  $stmt->execute();
  my $results = $stmt->fetchall_arrayref({});
  $stmt->finish;

  my $map = {};
  map {
    $map->{$_->{app_name}}->{$_->{permission_name}} = 0;

  } @$results;


  return $map;
}

method MenuResponse($http, $dyn) {
  $self->NotSoSimpleButtonButton($http, {
    caption => 'User List',
    op => 'GoToUserList',
  });
}

method ContentResponse($http, $dyn) {
  if ($self->can($self->{Mode})) {
    my $meth = $self->{Mode};
    $self->$meth($http, $dyn);
  }
}

method RenderUserList($http, $dyn) {
  my $users = $self->GetUserList();
  
  $http->queue(qq{
    <h3>Users</h3>
    <div class="list-group" style="width: 35%">
  });

  map {
    $self->NotSoSimpleButtonButton($http, {
      caption => $_,
      op => "TestButton",
      username => $_,
      class => 'list-group-item'
    });
  } @$users;

  $http->queue(qq{
    </div>
  });

}

method RenderAssignPerms($http, $dyn) {
  $http->queue(qq{
    <table class="table">
    <tr>
      <th>App</th>
      <th>Permissions</th>
    </tr>
  });
  my $perm_map = $self->GetPermissionList($self->{SelectedUsername});

  for my $app (sort keys %$perm_map) {
    $http->queue(qq{
      <tr>
        <td>$app</td>
        <td><ul>
    });
    for my $perm (sort keys %{$perm_map->{$app}}) {
      my $checked = $perm_map->{$app}->{$perm} ? 'checked="checked"': '';
      $http->queue(qq{
        <li>
          <input type="checkbox" name="$app|$perm" $checked />
          $perm
        </li>
      });
    }
    $http->queue(qq{
        </ul>
        </td>
      </tr>
    });
  }
  $http->queue(qq{
    </table>
  });
}

method TestButton($http, $dyn) {
  DEBUG $dyn->{username};
  $self->{SelectedUsername} = $dyn->{username};
  $self->{Mode} = 'RenderAssignPerms';
}

method GoToUserList($http, $dyn) {
  $self->{Mode} = 'RenderUserList';
  $self->AutoRefresh;
}

method GetUserList() {
  my $stmt = $self->{dbh}->prepare(qq{
    select
      user_name
    from users
  });

  $stmt->execute();
  my $results = $stmt->fetchall_arrayref();
  $stmt->finish;

  my @users = map {
    $_->[0];
  } @$results;

  return \@users;
}

method GetPermissionList($user) {
  my $stmt = $self->{dbh}->prepare(qq{
    select
      app_name,
      permission_name
    from user_app_permissions
    natural join users
    natural join apps
    natural join permissions
    where user_name = ?
  });

  $stmt->execute($user);
  my $results = $stmt->fetchall_arrayref({});
  $stmt->finish;


  my $perms = dclone($self->{AppPermMap});
  map {
    $perms->{$_->{app_name}}->{$_->{permission_name}} = 1;
  } @$results;

  return $perms;
}


1;
