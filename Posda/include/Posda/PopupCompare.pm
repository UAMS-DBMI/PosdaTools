package Posda::PopupCompare;

use Modern::Perl;
use Method::Signatures::Simple;

use Posda::PopupWindow;
use Posda::PopupImageViewer;
use Posda::Config ('Config','Database');

use Posda::CompareFiles;

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
    select file_id, series_instance_uid, root_path || '/' || rel_path
    from file_sop_common 
    natural join file_series 
    natural join file_location
    natural join file_storage_root
    where sop_instance_uid = ?;
  });

  $qh->execute($sop_uid);
  my $rows = $qh->fetchall_arrayref();

  say Dumper($rows);

  $self->{rows} = $rows;




}

method ContentResponse($http, $dyn) {
  $self->SimpleJQueryForm($http, {
      op => 'CompareSubmit',
  });
  $http->queue(qq{
    <h2>$self->{sop_uid}</h2>
    <p>This SOP has the following files associated:</p>
    <table class="table">
    <tr>
      <th>file_id</th>
      <th>series_instance_uid</th>
      <th>from</th>
      <th>to</th>
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
        <td><input type="radio" name="compareFrom" value="$r->[0]|$r->[2]"></td>
        <td><input type="radio" name="compareTo" value="$r->[0]|$r->[2]"></td>
      </tr>
    });
  }

  $http->queue(qq{
    <tr>
    <td></td>
    <td></td>
    <td colspan="2">
      <button type="submit" class="btn btn-default">Compare</button>
    </td>
    </table>
    </form>
    <p class="alert alert-info">
      Click on a <strong>file_id</strong> to open the Popup Image Viewer for that file
    </p>
  });
}

method CompareSubmit($http, $dyn) {
  say STDERR Dumper($dyn);
  my @from_parts = split('\|', $dyn->{compareFrom});
  my @to_parts = split('\|', $dyn->{compareTo});

  my $compare_child = Posda::CompareFiles->new(
    $self->{session},  
    "$self->{path}/CompareFiles",
    $self->{temp_path},
    $self->{JavascriptRoot},
    $from_parts[0],
    $from_parts[1],
    $to_parts[0],
    $to_parts[1],
  );

  $self->StartJsChildWindow($compare_child);
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
