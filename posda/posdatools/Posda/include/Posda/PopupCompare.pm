package Posda::PopupCompare;

use Modern::Perl;

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

sub SpecificInitialize {
  my ($self, $params) = @_;
  $self->{title} = "Popup Compare Tool";
  # Determine temp dir
  $self->{temp_path} = "$self->{LoginTemp}/$self->{session}";

  my $sop_uid = $params->{sop_instance_uid};
  $self->{sop_uid} = $sop_uid;

  # get the list of files with this SOP
  $db_handle = DBI->connect(Database('posda_files'));

  my $qh = $db_handle->prepare(qq{
    select distinct file_id, series_instance_uid,
    root_path || '/' || l.rel_path as path,
    import_event_id, import_comment, import_time,
    visibility, max(activity_timepoint_id) as activity_timepoint_id
    from file_sop_common
    natural join file_series
    natural join file_location l
    natural join file_storage_root
    natural left join ctp_file
    join file_import using(file_id)
    join import_event using(import_event_id)
    join activity_timepoint_file using (file_id)
    where sop_instance_uid = ?
    group by 
    file_id, series_instance_uid, path, import_event_id,
    import_comment, import_time, visibility;
  });

  $qh->execute($sop_uid);
  my $rows = $qh->fetchall_arrayref();

  say Dumper($rows);

  $self->{rows} = $rows;




}

sub ContentResponse {
  my ($self, $http, $dyn) = @_;
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
      <th>import_time</th>
      <th>import_comment</th>
      <th>visibility</th>
      <th>activity_timepoint</th>
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
        <td>$r->[5]</td>
        <td>$r->[4]</td>
        <td>$r->[6]</td>
        <td>$r->[7]</td>
        <td><input type="radio" name="compareFrom" value="$r->[0]|$r->[2]"></td>
        <td><input type="radio" name="compareTo" value="$r->[0]|$r->[2]"></td>
      </tr>
    });
  }

  $http->queue(qq{
    <tr>
    <td></td>
    <td></td>
    <td colspan="4">
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

sub CompareSubmit {
  my ($self, $http, $dyn) = @_;
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

sub MenuResponse {
  my ($self, $http, $dyn) = @_;
}

sub OpenViewer {
  my ($self, $http, $dyn) = @_;
  my $child_path = $self->child_path("ViewerPopup_$dyn->{value}");
  my $child_obj = Posda::PopupImageViewer->new($self->{session}, 
                                              $child_path, {file_id => $dyn->{value}});
  $self->StartJsChildWindow($child_obj);
}

1;
