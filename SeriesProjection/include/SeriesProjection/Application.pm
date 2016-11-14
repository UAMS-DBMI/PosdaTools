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

use Dispatch::Http;

use Posda::Passwords;
use Posda::Config ('Config', 'Database');

use Posda::DebugLog 'on';
use Data::Dumper;
use DBI;


method SpecificInitialize() {
  DEBUG 1;
  $self->{Mode} = 'Welcome';
  $self->{user} = $self->get_user();

  $self->{dbh} = DBI->connect(Database('posda_files'));
}

# This is supposed to insert css but can be used
# to insert anything directly into <head>
method CssStyle($http, $dyn) {
  DEBUG 1;
  $self->SUPER::CssStyle($http, $dyn);
  $http->queue(qq{
    <link rel="stylesheet" type="text/css" href="/papaya/papaya.css" />
    <script type="text/javascript" src="/papaya/papaya.js"></script>
  });
}

# Insert JS inline here
method JsContent($http, $dyn) {
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


method GetNextFileForReview() {
  DEBUG 1;

  if (defined $self->{CurrentIEC}) {
    unshift @{$self->{history}}, $self->{CurrentIEC};
  }

  # get the next item to display
  my $dbh = $self->{dbh};

  my $iec_id = [$dbh->selectall_arrayref(qq{
    -- Get one SEC id off the done list
    select image_equivalence_class_id

    from image_equivalence_class 
    natural join image_equivalence_class_input_image 
    natural join ctp_file 


    where processing_status = 'ReadyToReview'
      and project_name = ?
      and site_name = ?
    limit 1
  }, {}, ($self->{SelectedCollection}, $self->{SelectedSite}))]->[0]->[0]->[0];

  DEBUG $iec_id;

  $self->{CurrentIEC} = $iec_id;
  $self->LoadDataForIEC($iec_id);
}

method LoadDataForIEC($iec_id) {
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


method MenuResponse($http, $dyn) {
  $self->MakeMenu($http, $dyn,
    [
      { type => "host_link_sync",
        caption => "Good",
        method => "SetGood",
        sync => "Update();",
      },
      { type => "host_link_sync",
        caption => "Bad",
        method => "SetBad",
        sync => "Update();",
      },
      { type => "host_link_sync",
        caption => "Broken",
        method => "SetBroken",
        sync => "Update();",
      },
      { type => "host_link_sync",
        caption => "Go Back",
        method => "WeHaveToGoBack",
        sync => "Update();",
      },
    ]);
}

method ContentResponse($http, $dyn) {
  if ($self->can($self->{Mode})) {
    my $meth = $self->{Mode};
    $self->$meth($http, $dyn);
  }
}

method Welcome($http, $dyn) {
  $http->queue(qq{
    <div class="col-md-4">

    <p>
      Choose a collection and site to begin review.
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

method SelectCollection($http, $dyn) {
  my $collection = $dyn->{collection};
  my $site = $dyn->{site};

  $self->{SelectedCollection} = $collection;
  $self->{SelectedSite} = $site;

  $self->GetNextFileForReview();
  $self->{Mode} = 'Review';

}

method Review($http, $dyn) {
  $self->RenderCurrentSeries($http, $dyn);
}

method WeHaveToGoBack($http, $dyn) {
  if (not defined $self->{history}) {
    return;
  }
  if ($#{$self->{history}} < 0) {
    return;
  }

  $self->{CurrentIEC} = shift @{$self->{history}};
  $self->LoadDataForIEC($self->{CurrentIEC});
}

method SetGood($http, $dyn) {
  my $dbh = $self->{dbh};

  $dbh->do(qq{
    update image_equivalence_class
    set processing_status = 'Reviewed',
        review_status = 'Good'
    where image_equivalence_class_id = ?
  }, {}, $self->{CurrentIEC});

  $self->GetNextFileForReview();
  $self->AutoRefresh;
}
method SetBad($http, $dyn) {
  my $dbh = $self->{dbh};

  $dbh->do(qq{
    update image_equivalence_class
    set processing_status = 'Reviewed',
        review_status = 'Bad'
    where image_equivalence_class_id = ?
  }, {}, $self->{CurrentIEC});

  $self->GetNextFileForReview();
  $self->AutoRefresh;
}
method SetBroken($http, $dyn) {
  my $dbh = $self->{dbh};

  $dbh->do(qq{
    update image_equivalence_class
    set processing_status = 'Reviewed',
        review_status = 'Broken'
    where image_equivalence_class_id = ?
  }, {}, $self->{CurrentIEC});

  $self->GetNextFileForReview();
  $self->AutoRefresh;
}

method RenderCurrentSeries($http, $dyn) {
  if (not defined $self->{CurrentFile}) {
    $http->queue(qq{
      <p class="alert alert-info">
        There are currently no images that need review!
      </p>
    });

    return;
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

    <img style="background-image: url('/checkered.png');" 
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

method StartPapaya() {

  my $list = '';
  for my $i (@{$self->{DicomFiles}}) {
    $list .= qq{"GetFile?obj_path=SeriesProjection&type=dcm&path=$i",};
  }
  my $cmd = qq{params["images"] = [[$list]];};
  $self->QueueJsCmd($cmd);
  $self->QueueJsCmd("papaya.Container.startPapaya();");
}

method ListFiles($http, $dyn) {
  for my $i (@{$self->{DicomFiles}}) {
    $http->queue("<li>$i</li>");
  }
}

method GetFile($http, $dyn) {
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
