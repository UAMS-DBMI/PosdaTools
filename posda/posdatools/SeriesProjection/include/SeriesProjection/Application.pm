package SeriesProjection::Application;
#
# A User Admin application
#

use vars '@ISA';
@ISA = ("GenericApp::Application");

use Modern::Perl '2010';
use Storable 'dclone';

use GenericApp::Application;

use Dispatch::Http;

use Posda::Passwords;
use Posda::Config ('Config', 'Database');

use Posda::DebugLog 'on';
use Data::Dumper;
use DBI;


sub SpecificInitialize {
  my ($self) = @_;
  DEBUG 1;
  $self->{Mode} = 'Welcome';
  $self->{user} = $self->get_user();

  $self->{dbh} = DBI->connect(Database('posda_files'));
}

# This is supposed to insert css but can be used
# to insert anything directly into <head>
sub CssStyle {
  my ($self, $http, $dyn) = @_;
  DEBUG 1;
  $self->SUPER::CssStyle($http, $dyn);
  $http->queue(qq{
    <link rel="stylesheet" type="text/css" href="/papaya/papaya.css" />
    <script type="text/javascript" src="/papaya/papaya.js"></script>
  });
}

# Insert JS inline here
sub JsContent {
  my ($self, $http, $dyn) = @_;
  DEBUG 1;
  $self->SUPER::JsContent($http, $dyn);
  $http->queue(qq{
    var params = [];
    params["images"] = [[
  });
  for my $i (@{$self->{DicomFiles}}) {
    $http->queue(qq{"GetFile?obj_path=SeriesProjection&type=dcm&path=$i",});
  }
  $http->queue(qq{

    ]];
  });
}


sub GetNextFileForReview {
  my ($self) = @_;
  DEBUG 1;

  if (defined $self->{CurrentIEC}) {
    unshift @{$self->{history}}, $self->{CurrentIEC};
  }

  # get the next item to display
  my $dbh = $self->{dbh};

  my $sql;

  if ($self->{ReviewMode} eq 'unreviewed') {
    $sql = qq{
      -- Get one SEC id off the done list
      select image_equivalence_class_id

      from image_equivalence_class 
      natural join image_equivalence_class_input_image 
      natural join ctp_file 


      where processing_status = 'ReadyToReview'
        and project_name = ?
        and site_name = ?
      limit 1
    };
  } else {
    return $self->GetNextReviewedFileForReview($self->{ReviewMode});
  }


  my $iec_id = [$dbh->selectall_arrayref($sql, 
      {}, ($self->{SelectedCollection}, $self->{SelectedSite}))]->[0]->[0]->[0];


  DEBUG $iec_id;

  $self->{CurrentIEC} = $iec_id;
  $self->LoadDataForIEC($iec_id);
}

# Cannot rely on the same method as unreviewed because we
# are not changing the processing_status. Must use a seperate curosr
# for tracking this.
sub GetNextReviewedFileForReview {
  my ($self, $review_status) = @_;
  if (not defined $self->{GoodReviewCursor}) {
    DEBUG "Running Query";
    my $sth = $self->{dbh}->prepare(qq{
      select distinct image_equivalence_class_id

      from image_equivalence_class 
      natural join image_equivalence_class_input_image 
      natural join ctp_file 

      where processing_status = 'Reviewed'
        and review_status = ?
        and project_name = ?
        and site_name = ?
    });

    $sth->execute($review_status, 
                  $self->{SelectedCollection},
                  $self->{SelectedSite});

    $self->{GoodReviewCursor} = $sth;
  }


  my $row = $self->{GoodReviewCursor}->fetchrow_arrayref();
  my $iec = $row->[0];

  DEBUG Dumper($iec);

  $self->{CurrentIEC} = $iec;
  $self->LoadDataForIEC($iec);

}

sub LoadDataForIEC {
  my ($self, $iec_id) = @_;
  DEBUG $iec_id;
  my $dbh = $self->{dbh};

  my $file = [$dbh->selectall_arrayref(qq{
    select
      root_path || '/' || rel_path,
      file_id,
      series_instance_uid
    from image_equivalence_class
    natural join image_equivalence_class_out_image
    natural join file_location
    natural join file_storage_root

    where image_equivalence_class_id = ?
  }, {}, $iec_id)]->[0]->[0];


  $self->{CurrentFile} = $file;


  my $series_info = [$dbh->selectall_arrayref(qq{
    select distinct 
      image_type,
      modality,
      series_description,
      performed_procedure_step_desc
    from image_equivalence_class_input_image
    natural join file_image
    natural join image
    natural join file_series

    where image_equivalence_class_id = ?
  }, {}, $iec_id)]->[0]->[0];
  
  $self->{CurrentFileExtInfo} = $series_info;
  if (not defined $self->{CurrentFileExtInfo}) {
    $self->{CurrentFileExtInfo} = [];
  }

  my $dicom_files = [$dbh->selectall_arrayref(qq{
      select root_path || '/' || rel_path
      from image_equivalence_class_input_image
      natural join file_location
      natural join file_storage_root
      where image_equivalence_class_id = ?
  }, {}, $self->{CurrentIEC})]->[0];

  my @df = map {
    $_->[0]
  } @$dicom_files;

  $self->{DicomFiles} = \@df;
}


sub MenuResponse {
  my ($self, $http, $dyn) = @_;
  $self->MakeMenu($http, $dyn,
    [
      { caption => "Start Over",
        op => "StartOver",
        sync => "Update();",
        class => "btn btn-primary"
      },
      { caption => "Good",
        op => "SetGood",
        sync => "Update();",
      },
      { caption => "Bad",
        op => "SetBad",
        sync => "Update();",
      },
      { caption => "Broken",
        op => "SetBroken",
        sync => "Update();",
      },
      { caption => "Go Back",
        op => "WeHaveToGoBack",
        sync => "Update();",
      },
    ]);
}

sub StartOver {
  my ($self, $http, $dyn) = @_;
  delete $self->{GoodReviewCursor};
  $self->SetMode(0, {mode => 'Welcome'});
}

sub ContentResponse {
  my ($self, $http, $dyn) = @_;
  if ($self->can($self->{Mode})) {
    my $meth = $self->{Mode};
    $self->$meth($http, $dyn);
  }
}

sub SetMode {
  my ($self, $http, $dyn) = @_;
  DEBUG Dumper($dyn);
  $self->{Mode} = $dyn->{mode};
}

sub Welcome {
  my ($self, $http, $dyn) = @_;
  $http->queue(qq{
    <p>
      Select a mode.
    </p>
  });
  $self->MakeMenu($http, $dyn,
    [
      { caption => "Review Unreviewed Series",
        op => "SetMode",
        mode => "Welcome2",
        sync => "Update();",
        class => "btn btn-primary"
      },
      { caption => "Review Good Series",
        op => "SetMode",
        mode => "ReviewGoodSeries",
        sync => "Update();",
      },
      { caption => "Review Bad Series",
        op => "SetMode",
        mode => "ReviewBadSeries",
        sync => "Update();",
      },
      { caption => "Review Broken Series",
        op => "SetMode",
        mode => "ReviewBrokenSeries",
        sync => "Update();",
      },
    ]);
}
sub ReviewGoodSeries {
  my ($self, $http, $dyn) = @_;
  $self->{ReviewMode} = 'Good';
  return $self->ReviewReviewedSeries($http, $dyn);
}
sub ReviewBadSeries {
  my ($self, $http, $dyn) = @_;
  $self->{ReviewMode} = 'Bad';
  return $self->ReviewReviewedSeries($http, $dyn);
}
sub ReviewBrokenSeries {
  my ($self, $http, $dyn) = @_;
  $self->{ReviewMode} = 'Broken';
  return $self->ReviewReviewedSeries($http, $dyn);
}
sub ReviewReviewedSeries {
  my ($self, $http, $dyn) = @_;

  # get the list of available project/site combos
  my $available = [$self->{dbh}->selectall_arrayref(qq{
    select 
      project_name,
      site_name,
      count(distinct image_equivalence_class_id)

    from 
      image_equivalence_class 
      natural join image_equivalence_class_input_image 
      natural join ctp_file 

    where processing_status = 'Reviewed' 
      and review_status = '$self->{ReviewMode}'
    group by project_name, site_name
    order by count desc
  })]->[0];

  my @options = map {
    ["$_->[0]/$_->[1] ($_->[2])", $_->[0], $_->[1]]
  } @$available;


  $http->queue(qq{
    <div class="col-md-4">

    <p class="alert alert-info">
      Choose a collection and site to begin review.
    </p>
  });

  $http->queue(qq{
    <div class="btn-group-vertical" style="margin-bottom: 10px" role="group">
  });
  for my $o (@options) {
    my ($display, $proj, $site) = @$o;
    $self->NotSoSimpleButtonButton($http, {
      caption => $display,
      op => 'SelectCollection',
      collection => $proj,
      site => $site
    });
  }
  $http->queue(qq{
    </div>

    <p class="alert alert-info">
      Or enter the Collection and Site manually:
    </p>
  });



  $self->SimpleJQueryForm($http, {
      op => 'SelectCollection'
  });
  $http->queue(qq{
    <div class="form-group">
      <label for="collection">Collection</label>
      <input name="collection" id="collection" class="form-control" type="text">
    </div>
    <div class="form-group">
      <label for="site">Site</label>
      <input name="site" id="site" class="form-control" type="text">
    </div>
    <button type="submit" class="btn btn-primary">Submit</button>
    </form>

    </div>

  });
}

sub Welcome2 {
  my ($self, $http, $dyn) = @_;
  $self->{ReviewMode} = 'unreviewed';
  # get the list of available project/site combos
  my $available = [$self->{dbh}->selectall_arrayref(qq{
    select 
      project_name,
      site_name,
      count(distinct image_equivalence_class_id)

    from 
      image_equivalence_class 
      natural join image_equivalence_class_input_image 
      natural join ctp_file 

    where processing_status = 'ReadyToReview' 
    group by project_name, site_name
    order by count desc
  })]->[0];

  my @options = map {
    ["$_->[0]/$_->[1] ($_->[2])", $_->[0], $_->[1]]
  } @$available;


  $http->queue(qq{
    <div class="col-md-4">

    <p class="alert alert-info">
      Choose a collection and site to begin review.
    </p>
  });

  $http->queue(qq{
    <div class="btn-group-vertical" style="margin-bottom: 10px" role="group">
  });
  for my $o (@options) {
    my ($display, $proj, $site) = @$o;
    $self->NotSoSimpleButtonButton($http, {
      caption => $display,
      op => 'SelectCollection',
      collection => $proj,
      site => $site
    });
  }
  $http->queue(qq{
    </div>

    <p class="alert alert-info">
      Or enter the Collection and Site manually:
    </p>
  });



  $self->SimpleJQueryForm($http, {
      op => 'SelectCollection'
  });
  $http->queue(qq{
    <div class="form-group">
      <label for="collection">Collection</label>
      <input name="collection" id="collection" class="form-control" type="text">
    </div>
    <div class="form-group">
      <label for="site">Site</label>
      <input name="site" id="site" class="form-control" type="text">
    </div>
    <button type="submit" class="btn btn-primary">Submit</button>
    </form>

    </div>

  });
}

sub SelectCollection {
  my ($self, $http, $dyn) = @_;
  my $collection = $dyn->{collection};
  my $site = $dyn->{site};

  $self->{SelectedCollection} = $collection;
  $self->{SelectedSite} = $site;

  $self->GetNextFileForReview();
  $self->{Mode} = 'Review';

}

sub Review {
  my ($self, $http, $dyn) = @_;
  $self->RenderCurrentSeries($http, $dyn);
}

sub WeHaveToGoBack {
  my ($self, $http, $dyn) = @_;
  if (not defined $self->{history}) {
    return;
  }
  if ($#{$self->{history}} < 0) {
    return;
  }

  $self->{CurrentIEC} = shift @{$self->{history}};
  $self->LoadDataForIEC($self->{CurrentIEC});
}

sub SetGood {
  my ($self, $http, $dyn) = @_;
  my $dbh = $self->{dbh};

  $dbh->do(qq{
    update image_equivalence_class
    set processing_status = 'Reviewed',
        review_status = 'Good',
        update_user = ?,
        update_date = now()
    where image_equivalence_class_id = ?
  }, {}, $self->{user}, $self->{CurrentIEC});

  $self->GetNextFileForReview();
  $self->AutoRefresh;
}
sub SetBad {
  my ($self, $http, $dyn) = @_;
  my $dbh = $self->{dbh};

  $dbh->do(qq{
    update image_equivalence_class
    set processing_status = 'Reviewed',
        review_status = 'Bad',
        update_user = ?,
        update_date = now()
    where image_equivalence_class_id = ?
  }, {}, $self->{user}, $self->{CurrentIEC});

  $self->GetNextFileForReview();
  $self->AutoRefresh;
}
sub SetBroken {
  my ($self, $http, $dyn) = @_;
  my $dbh = $self->{dbh};

  $dbh->do(qq{
    update image_equivalence_class
    set processing_status = 'Reviewed',
        review_status = 'Broken',
        update_user = ?,
        update_date = now()
    where image_equivalence_class_id = ?
  }, {}, $self->{user}, $self->{CurrentIEC});

  $self->GetNextFileForReview();
  $self->AutoRefresh;
}

sub RenderCurrentSeries {
  my ($self, $http, $dyn) = @_;
  if (not defined $self->{CurrentFile}) {
    $http->queue(qq{
      <p class="alert alert-info">
        There are currently no images that need review!
      </p>
    });

    return;
  }

  if ($self->{ReviewMode} eq 'Good') {
    $http->queue(qq{
      <p class="alert alert-warning">
        You are viewing Series that have previously been marked as 
        <strong>GOOD</strong>. Use the "Good" button to move forward.
      </p>
    });
  }
  if ($self->{ReviewMode} eq 'Bad') {
    $http->queue(qq{
      <p class="alert alert-warning">
        You are viewing Series that have previously been marked as 
        <strong>BAD</strong>. Use the "Bad" button to move forward, or 
        choose another button to reclassify.
      </p>
    });
  }
  if ($self->{ReviewMode} eq 'Broken') {
    $http->queue(qq{
      <p class="alert alert-warning">
        You are viewing Series that have previously been marked as 
        <strong>BROKEN</strong>. Use the "Broken" button to move forward, or 
        choose another button to reclassify.
      </p>
    });
  }

  my ($filename, $file_id, $series_uid) = @{$self->{CurrentFile}};
  my ($image_type, $modality, $series_desc, $series_extra) = @{$self->{CurrentFileExtInfo}};
  my $file_count = $#{$self->{DicomFiles}} + 1;
  $http->queue(qq{
    <table class="table">
      <tr>
        <td>Image Equivalence Class ID</td>
        <td>$self->{CurrentIEC}</td>
      </tr>
      <tr>
        <td>File on disk</td>
        <td> $filename </td>
      </tr>
      <tr>
        <td>Series Instance UID</td>
        <td> $series_uid </td>
      </tr>
      <tr>
        <td>Number of images in series</td>
        <td>$file_count</td>
      </tr>
      <tr>
        <td>Image Type</td>
        <td>$image_type</td>
      </tr>
      <tr>
        <td>Modality</td>
        <td>$modality</td>
      </tr>
      <tr>
        <td>Series Description</td>
        <td>$series_desc</td>
      </tr>
      <tr>
        <td>Series Extra</td>
        <td>$series_extra</td>
      </tr>
    </table>

    <img style="background-image: url('/checker.svg'); background-size: 40px 40px; min-width: 1050px" 
         src="GetFile?obj_path=SeriesProjection&type=png&file_id=$file_id&path=$filename">
  });

  $http->queue(qq{
    <div id="pview" class="papaya" data-params="params"></div>
  });
  $self->NotSoSimpleButton($http, {
    caption => 'Start Viewer',
    op => 'StartPapaya'
  });
  # $self->ListFiles($http, $dyn);
}

sub StartPapaya {
  my ($self) = @_;

  my $list = '';
  for my $i (@{$self->{DicomFiles}}) {
    $list .= qq{"GetFile?obj_path=SeriesProjection&type=dcm&path=$i",};
  }
  my $cmd = qq{params["images"] = [[$list]];};
  $self->QueueJsCmd($cmd);
  $self->QueueJsCmd("papaya.Container.startPapaya();");
}

sub ListFiles {
  my ($self, $http, $dyn) = @_;
  for my $i (@{$self->{DicomFiles}}) {
    $http->queue("<li>$i</li>");
  }
}

sub GetFile {
  my ($self, $http, $dyn) = @_;
  my $filename = $dyn->{path};
  
  # determine mime type
  #
  my $ExtToMime = $Dispatch::Http::App::Server::ExtToMime;

  my $content_type = "application/octet-stream";
  if(exists $ExtToMime->{$dyn->{type}}){
    $content_type = $ExtToMime->{$dyn->{type}};
  }
  $http->DownloadHeader($content_type, "somefile");
  open my $fh, '<', $filename or die "error opening $filename: $!";
  $http->queue(do { local $/; <$fh> });
  close($fh);
}

1;
