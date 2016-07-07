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

method RenderChangesSaved($http, $dyn) {
  $http->queue(qq{
    Changes saved!
  });
}

method RenderConfirmDelete($http, $dyn) {
  DEBUG 1;
  if ($self->{Mode} ne 'RenderConfirmDelete') {
    $self->{Mode} = 'RenderConfirmDelete';
    $self->{DeletingUser} = $dyn->{username};
    return;
  }
  $http->queue(qq{
    <p>
      You are about to delete the user $self->{DeletingUser}.
      This operation CANNOT be undone.
    </p>
    <div class="btn-group">
  });
  $self->NotSoSimpleButtonButton($http, {
    caption => 'Delete them!',
    op => 'DeleteUser',
    class => "btn btn-danger"
  });
  $self->NotSoSimpleButtonButton($http, {
    caption => "Don't do it, this was a mistake!",
    op => 'GoToUserList',
    class => "btn btn-default"
  });
  $http->queue(qq{
    </div>
  });
}
method RenderUserDeleted($http, $dyn) {
  $http->queue(qq{
    User deleted!
  });
  $self->NotSoSimpleButtonButton($http, {
    caption => 'Return to User List',
    op => 'GoToUserList',
  });
}

method RenderUserCreated($http, $dyn) {
  $http->queue(qq{
    User created!
  });
  $self->NotSoSimpleButtonButton($http, {
    caption => 'Return to User List',
    op => 'GoToUserList',
  });
}

method RenderUserList($http, $dyn) {
  my $users = $self->GetUserList();

  $http->queue(qq{
    <h3>Users</h3>
    <table class="table" style="width: auto">
  });

  map {
    $http->queue(qq{
      <tr>
      <td>
    });
    $self->NotSoSimpleButtonButton($http, {
      caption => $_,
      op => "TestButton",
      username => $_,
    });
    $http->queue(qq{
      </td>
      <td>
    });
    $self->NotSoSimpleButtonButton($http, {
      caption => "X",
      op => "RenderConfirmDelete",
      username => $_,
      class => "btn btn-danger"
    });
    $http->queue(qq{
      </td>
      </tr>
      </div>
    });
  } @$users;

  $http->queue(qq{
    </table>

    <hr>
    <h4>Add new user</h4>
    <form class="form-inline" id="NewUserForm"
          onSubmit="PosdaGetRemoteMethod('CreateNewUser', \$('#NewUserForm').serialize(), function(){Update();});return false;">
        <input class="form-control" 
               autocomplete="off"
               type="text" name="NewUserName" placeholder="Username">
        <input class="form-control" 
               autocomplete="off"
               type="password" name="NewUserPass" placeholder="Password">
        <button type="submit" class="btn btn-default">Create</button>
    </form>
  });

}

method RenderAssignPerms($http, $dyn) {
  $http->queue(qq{
    <form id="UpdateForm" onSubmit="PosdaGetRemoteMethod('UpdateSelection', \$('#UpdateForm').serialize(), function(){Update();});return false;">
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
        <td><div class="btn-group" data-toggle="buttons">
    });
    for my $perm (sort keys %{$perm_map->{$app}}) {
      my $checked = $perm_map->{$app}->{$perm} ? 'checked': '';
      my $active = $perm_map->{$app}->{$perm} ? 'active': '';
      $http->queue(qq{
        <label class="btn btn-default $active">
          <input type="checkbox" autocomplete="off" name="$app|$perm" $checked />
          $perm
        </label>
      });
    }
    $http->queue(qq{
        </div>
        </td>
      </tr>
    });
  }
  $http->queue(qq{
    </table>
    <input id="UpdateFormSubmit" class="btn btn-default" type="submit">
    </form>
  });
}

method UpdateSelection($http, $dyn) {
  my $selections = {};
  map {
    if(/(.*)%7C(.*)/) {
      $selections->{$1}->{$2} = 1;
    }
  } keys %$dyn;

  DEBUG Dumper($selections);

  $self->{Mode} = 'RenderChangesSaved';
}

method CreateNewUser($http, $dyn) {
  my $name = $dyn->{NewUserName};
  my $pass = $dyn->{NewUserPass};

  DEBUG "$name, $pass";

  my $stmt = $self->{dbh}->prepare(qq{
    insert into users (user_name, full_name, password)
    values (?, '', ?)
  });

  $stmt->execute($name, $pass);
  $stmt->finish;

  $self->{Mode} = "RenderUserCreated";

}

method DeleteUser($http, $dyn) {
  my $user = $self->{DeletingUser};
  delete $self->{DeletingUser};

  my $stmt = $self->{dbh}->prepare(qq{
    delete from users
    where user_name = ?
  });

  $stmt->execute($user);
  $stmt->finish;

  $self->{Mode} = "RenderUserDeleted";

}

method TestButton($http, $dyn) {
  DEBUG $dyn->{username};
  $self->{SelectedUsername} = $dyn->{username};
  $self->{Mode} = 'RenderAssignPerms';
}

method GoToUserList($http, $dyn) {
  $self->{Mode} = 'RenderUserList';
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
