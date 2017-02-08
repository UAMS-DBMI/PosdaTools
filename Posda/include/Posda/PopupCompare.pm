package Posda::PopupCompare;

use Modern::Perl;
use Method::Signatures::Simple;

use Posda::PopupWindow;
use Posda::PopupImageViewer;
use Posda::Config ('Config','Database');

use Data::Dumper;
use DBI;
use URI;

use MIME::Base64;


use vars qw( @ISA );
@ISA = ("Posda::PopupWindow");

my $db_handle;

method SpecificInitialize($params) {
  $self->{title} = "Popup Compare Tool";
  # Determine temp dir
  $self->{temp_path} = "$self->{LoginTemp}/$self->{session}";

  my $sop_uid = $params;
  $self->{sop_uid} = $sop_uid;

  # get the list of files with this SOP
  $db_handle = DBI->connect(Database('posda_files'));

  my $qh = $db_handle->prepare(qq{
    select file_id, series_instance_uid 
    from file_sop_common 
    natural join file_series 
    where sop_instance_uid = ?;
  });

  $qh->execute($sop_uid);
  my $rows = $qh->fetchall_arrayref();

  say Dumper($rows);

  $self->{rows} = $rows;
}

method ContentResponse($http, $dyn) {
  $http->queue(qq{
    <h2>$self->{sop_uid}</h2>
    <p>This SOP has the following files associated:</p>
    <table class="table">
    <tr>
      <th>file_id</th>
      <th>series_instance_uid</th>
    </tr>
  });

  for my $r (@{$self->{rows}}) {
    $http->queue(qq{
      <tr>
        <td>
    });
    $self->NotSoSimpleButton($http, {
        class => "",
        caption => $r->[0],
        op => "OpenViewer",
        value => $r->[0],
        element => 'a',
        title => 'Open in Popup Image Viewer',
        sync => 'Update();'
    });
    $http->queue(qq{
        </td>
        <td>$r->[1]</td>
      </tr>
    });
  }

  $http->queue(qq{
    </table>
    <p class="alert alert-info">
      Click on a <strong>file_id</strong> to open the Popup Image Viewer for that file
    </p>
  });
}

method MenuResponse($http, $dyn) {
}

method OpenViewer($http, $dyn) {
  my $child_path = $self->child_path("ViewerPopup_$dyn->{value}");
  my $child_obj = Posda::PopupImageViewer->new($self->{session}, 
                                              $child_path, {file_id => $dyn->{value}});
  $self->StartJsChildWindow($child_obj);
}

1;
