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

use Posda::Passwords;
use Posda::Config ('Config', 'Database');

use Posda::DebugLog 'on';
use Data::Dumper;


method SpecificInitialize() {
  $self->{dbh} = DBI->connect(Database('posda_auth'));
  # Needed for creating user_inbox entry
  $self->{queries_dbh} = DBI->connect(Database('posda_queries'));
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
  my $stmt = $self->{dbh}->prepare(qq{
   select * from permissions natural join apps
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
    <div class="alert alert-success">
      Changes saved!
    </div>
  });
  $self->NotSoSimpleButtonButton($http, {
    caption => 'Return to User List',
    op => 'GoToUserList',
    class => 'btn btn-primary'
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
    <p class="alert alert-danger">
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
    <div class="alert alert-success">
      User deleted!
    </div>
  });
  $self->NotSoSimpleButtonButton($http, {
    caption => 'Return to User List',
    op => 'GoToUserList',
    class => "btn btn-primary"
  });
}

method RenderUserCreated($http, $dyn) {
  $http->queue(qq{
    <div class="alert alert-success">
      User created!
    </div>
  });
  $self->NotSoSimpleButtonButton($http, {
    caption => 'Assign permissions now',
    op => 'RenderAssignPerms',
    class => 'btn btn-primary'
  });
  $self->NotSoSimpleButtonButton($http, {
    caption => 'Return to User List',
    op => 'GoToUserList',
  });
}

method RenderUserList($http, $dyn) {
  my $users = $self->GetUserList();

  $http->queue(qq{
    <h2>Users</h2>
    <hr>
    <h4>Edit current users</h4>
    <div class="alert alert-info">
      Click on a user's name to edit their app permissions and password.
      Click the <strong>red X</strong> to the right of the user to delete them.
    </div>
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

  my $auth_type = Config('auth_type');
  my $extra_msg = '';
  if ($auth_type eq 'ldap') {
    $extra_msg = qq{
      <p class="alert alert-info">
        LDAP authentication is enabled, but you must create a user with
        the same name here in order to assign permissions.
      </p>
    };
  }

  $http->queue(qq{
    </table>

    <hr>
    <h4>Add new user</h4>
    $extra_msg
    <form class="form-inline" id="NewUserForm"
          onSubmit="PosdaGetRemoteMethod('CreateNewUser', \$('#NewUserForm').serialize(), function(){Update();});return false;">
        <input class="form-control" 
               autocomplete="off"
               type="text" name="NewUserName" placeholder="Username">
        <input class="form-control" 
               autocomplete="off"
               type="text" name="NewEmail" placeholder="Email">

  });

  if ($auth_type eq 'database') {
    $http->queue(qq{
          <input class="form-control" 
                 autocomplete="off"
                 type="password" name="NewUserPass" placeholder="Password">
    });
  }
  $http->queue(qq{
      <button type="submit" class="btn btn-default">Create</button>
    </form>
  });

}

method RenderAssignPerms($http, $dyn) {
  if ($self->{Mode} ne 'RenderAssignPerms') {
    $self->{Mode} = 'RenderAssignPerms';
    return;
  }

  my $username = $self->{SelectedUsername};

  $http->queue(qq{
    <h3>Editing User: $username</h3>
    <hr>
    <p class="alert alert-info">
      Toggle permissions on or off by clicking the buttons to the right of
      each App name. Note that <strong>launch</strong> permission is required
      for the user to be able to use the app.
    </p>
    <p class="alert alert-warning">
      Giving a user the ability to launch the UserAdmin app gives them
      the ability to modify these settings!
    </p>
    <h4>Permissions</h4>
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
    <input id="UpdateFormSubmit" class="btn btn-primary" type="submit" value="Assign Permissions">
    </form>

    <hr>
    <h4>Password</h4>
  });

  if (Config('auth_type') eq 'ldap') {
    $http->queue(qq{
        <p class="alert alert-danger">
          This Posda instance is configured to use LDAP authentication,
          therefore password management is disabled. You will need to change
          your LDAP password using some other means.
        </p>
    });
  } else {
    $http->queue(qq{
      <div class="alert alert-info">
        Passwords are stored in a hashed format, and therefore cannot be 
        displayed. You may change the user's password here at any time.
      </div>
      <form id="ChangePasswordForm" class="form-inline" 
            onSubmit="PosdaGetRemoteMethod('UpdatePassword', \$('#ChangePasswordForm').serialize(), function(){Update();});return false;">
        <input class="form-control" 
               autocomplete="off"
               type="password" name="NewUserPass" placeholder="New Password">

        <input id="ChangePasswordFormSubmit" 
               class="btn btn-warning" type="submit" value="Change Password">
      </form>
    });
  }
}
method UpdatePassword($http, $dyn) {
  my $user = $self->{SelectedUsername};
  my $pass = $dyn->{NewUserPass};

  my $enc_pass = Posda::Passwords::encode($pass);

  my $stmt = $self->{dbh}->prepare(qq{
    update users
    set password = ?
    where user_name = ?
  });

  $stmt->execute($enc_pass, $user);
  $stmt->finish;

  $self->{Mode} = 'RenderChangesSaved';
}

method UpdateSelection($http, $dyn) {
  my @selections;
  map {
    if(/(.*)%7C(.*)/) {
      push @selections, [$self->{SelectedUsername}, $2, $1];
    }
  } keys %$dyn;

  # turn the selection list into a set of inserts
  my $query = qq{
    insert into user_permissions values (
      (select user_id from users where user_name = ?),
      (select permission_id from permissions where permission_name = ?
       and app_id = (select app_id from apps where app_name = ?))
    )
  };
  # begin transaction
  $self->{dbh}->{AutoCommit} = 0;  # disabling AutoCommit begins a transaction
  # delete all current permissions for the user
  my $del_stmt = $self->{dbh}->prepare(qq{
    delete from user_permissions
    where user_id = (select user_id from users where user_name = ?)
  });

  $del_stmt->execute($self->{SelectedUsername});
  $del_stmt->finish;

  # execute the set of inserts
  my $stmt = $self->{dbh}->prepare($query);
  map {
    $stmt->execute(@$_);
  } @selections;

  # commit transaction
  $stmt->finish;
  $self->{dbh}->commit;
  $self->{dbh}->{AutoCommit} = 1; # go back to normal

  $self->{Mode} = 'RenderChangesSaved';
}

method CreateNewUser($http, $dyn) {
  my $name = $dyn->{NewUserName};
  my $email = $dyn->{NewEmail};
  my $pass = $dyn->{NewUserPass} or 'no_pass';

  my $enc_pass = Posda::Passwords::encode($pass);
  DEBUG "$name, $email, $pass, $enc_pass";

  my $stmt = $self->{dbh}->prepare(qq{
    insert into users (user_name, full_name, password)
    values (?, '', ?)
  });

  $stmt->execute($name, $enc_pass);
  $stmt->finish;

  my $email_stmt = $self->{queries_dbh}->prepare(qq{
    insert into user_inbox (user_name, user_email_addr)
    values (?, ?)
  });
  $email_stmt->execute($name, $email);
  $email_stmt->finish;

  $self->{SelectedUsername} = $name;
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

  my $email_stmt = $self->{queries_dbh}->prepare(qq{
    delete from user_inbox
    where user_name = ?
  });

  $email_stmt->execute($user);
  $email_stmt->finish;


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
    order by user_name
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
    from user_permissions
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
