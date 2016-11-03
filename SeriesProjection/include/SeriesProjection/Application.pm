package SeriesProjection::Application;
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
use DBI;


method SpecificInitialize() {
  $self->{Mode} = 'Welcome';
  $self->{user} = $self->get_user();

  opendir(my $dh, $self->{Environment}->{TempPNGStorage})
    or die "Can't open TempPNGStorage!";
  my @files = map { /^(.*)\.png/ } grep { /^[^\.]/ } sort readdir($dh);
  closedir $dh;

  $self->{FilesToInspect} = \@files;

  $self->RemoveCompletedFiles();



  # start with the first one!
  # TODO: This actually needs to run a query to remove the ones that
  # have already been visited first!
  $self->{CurrentFile} = shift @{$self->{FilesToInspect}};
  $self->{CompletedFiles} = [];


}


method RemoveCompletedFiles() {
  $self->{dbh} = DBI->connect(Database('posda_files'));
  my $dbh = $self->{dbh};

  my $existing = [$dbh->selectall_arrayref(qq{
    select series_instance_uid
    from series_projection
  })]->[0];

  # stirp off even more extra arrays...
  my @stripped = map {
    $_->[0]
  } @$existing;

  my %in_db = map {$_ => 1} @stripped;
  my @diff = grep {not $in_db{$_}} @{$self->{FilesToInspect}};

  $self->{FilesToInspect} = \@diff;
}


method MenuResponse($http, $dyn) {
  $self->NotSoSimpleButtonButton($http, {
    caption => 'Welcome',
    op => 'Welcome',
  });
}

method ContentResponse($http, $dyn) {
  if ($self->can($self->{Mode})) {
    my $meth = $self->{Mode};
    $self->$meth($http, $dyn);
  }
}

method Welcome($http, $dyn) {
  $self->RenderCurrentSeries($http, $dyn);
}

method RenderCurrentSeries($http, $dyn) {
  my $file = $self->{CurrentFile};
  $http->queue(qq{
    <div class="btn-toolbar">
    <div class="btn-group">
  });
  $self->NotSoSimpleButtonButton($http, {
    caption => 'Good',
    op => 'SetGood',
    class => 'btn btn-success'
  });
  $self->NotSoSimpleButtonButton($http, {
    caption => 'Bad',
    op => 'SetBad',
    class => 'btn btn-warning'
  });
  $http->queue(qq{
    </div>
    <div class="btn-group">
  });
  $self->NotSoSimpleButtonButton($http, {
    caption => 'Go Back One',
    op => 'GoBack',
    class => 'btn btn-danger'
  });
  $http->queue(qq{
    </div>
    </div>
  });
  # check the file, see how big it is
  my $size = (stat("$self->{Environment}->{TempPNGStorage}/$file.png"))[7];
  if ($size > 10*1024*1024) {
    $http->queue(qq{
      <p class="alert alert-danger">
        Image is over 10MB in size! This is an error, you should click Bad.
        I will not attempt to display it, as that may crash your browser!
      </p>
    });
  } else {
    $http->queue("<img src='/pngs/$file.png'>");
  }

  $http->queue(qq{
    <p class="alert alert-info">
      Series: $self->{CurrentFile}
    </p>
  });
}

method SetGood($http, $dyn) {
  say "Setting good: $self->{CurrentFile}";

  $self->Set("good");
  $self->NextFile();
}

method SetBad($http, $dyn) {
  say "Setting bad: $self->{CurrentFile}";

  $self->Set("bad");
  $self->NextFile();
}

method Set($state) {
  my $needs_inspection;
  if ($state eq 'good') {
    $needs_inspection = 0;
  } else {
    $needs_inspection = 1;
  }

  if (not defined $self->{qh}) {
    $self->{qh} = $self->{dbh}->prepare(qq{
      insert into series_projection
      values (?, now(), ?, ?)
    }); 
  }
  if (not defined $self->{qh_update}) {
    $self->{qh_update} = $self->{dbh}->prepare(qq{
      update series_projection
      set date=now(), who=?, needs_closer_inspection=?
      where series_instance_uid = ?
    }); 
  }

  eval {
    $self->{qh}->execute($self->{CurrentFile}, $self->{user}, $needs_inspection);
  };
  if (defined $@) { # probably it failed becuase it already exists, try update
    $self->{qh_update}->execute($self->{user}, $needs_inspection, $self->{CurrentFile});
  }
}

method GoBack($http, $dyn) {
  unshift @{$self->{FilesToInspect}}, $self->{CurrentFile};
  $self->{CurrentFile} = shift @{$self->{CompletedFiles}};
}

method NextFile() {
  unshift @{$self->{CompletedFiles}}, $self->{CurrentFile};
  $self->{CurrentFile} = shift @{$self->{FilesToInspect}};
}


1;
