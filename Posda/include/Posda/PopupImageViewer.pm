package Posda::PopupImageViewer;

use Modern::Perl;
use Method::Signatures::Simple;

use Posda::PopupWindow;
use Posda::Config ('Config','Database');

use Data::Dumper;
use DBI;
use URI;

use MIME::Base64;


use vars qw( @ISA );
@ISA = ("Posda::PopupWindow");

my $db_handle;

method LoadFromSOP($db_handle, $sop) {
  my $qh = $db_handle->prepare(qq{
    select distinct
        root_path || '/' || rel_path as file, 
        file_offset, 
        size, 
        bits_stored, 
        bits_allocated, 
        pixel_representation, 
        number_of_frames,
        samples_per_pixel, 
        pixel_columns, 
        pixel_rows, 
        photometric_interpretation,

        slope,
        intercept,

        window_width,
        window_center,
        pixel_pad,

        series_instance_uid
    from
        file_sop_common
        natural join file_image
        natural join image 
        natural join unique_pixel_data 
        natural join pixel_location
        natural join file_location 
        natural join file_storage_root
        natural join file_series
        natural join file_equipment

        natural left join file_slope_intercept
        natural left join slope_intercept

        natural left join file_win_lev
        natural left join window_level

    where sop_instance_uid = ?

  });

  $qh->execute($sop);
  my $rows = $qh->fetchrow_arrayref();

  # say Dumper($rows);

  return $rows;

}
method LoadFromFID($db_handle, $fid) {
  my $qh = $db_handle->prepare(qq{
    select distinct
        root_path || '/' || rel_path as file, 
        file_offset, 
        size, 
        bits_stored, 
        bits_allocated, 
        pixel_representation, 
        number_of_frames,
        samples_per_pixel, 
        pixel_columns, 
        pixel_rows, 
        photometric_interpretation,

        slope,
        intercept,

        window_width,
        window_center,
        pixel_pad,

        series_instance_uid
    from
        file_sop_common
        natural join file_image
        natural join image 
        natural join unique_pixel_data 
        natural join pixel_location
        natural join file_location 
        natural join file_storage_root
        natural join file_series
        natural join file_equipment

        natural left join file_slope_intercept
        natural left join slope_intercept

        natural left join file_win_lev
        natural left join window_level

    where file_id = ?

  });

  $qh->execute($fid);
  my $rows = $qh->fetchrow_arrayref();

  # say Dumper($rows);

  return $rows;

}

method SpecificInitialize($params) {
  $self->{title} = "Popup Image Viewer";
  # Determine temp dir
  $self->{temp_path} = "$self->{LoginTemp}/$self->{session}";


  $db_handle = DBI->connect(Database('posda_files'));

  my $rows;

  if (defined $params->{sop_uid}) {
    my $sop_uid = $params->{sop_uid};
    $self->{sop_uid} = $sop_uid;

    $rows = $self->LoadFromSOP($db_handle, $sop_uid)
  } else {
    $rows = $self->LoadFromFID($db_handle, $params->{file_id})
  }

  $self->{row} = $rows;
  if (not defined $rows) {
    $self->QueueJsCmd("alert('Error loading file details');");
    return;
  }

  # break into usable bits
  my ($filename, $offset, $size, 
      $bits_stored, $bits_allocated, 
      $pix_rep, $frames, $samples_per_pixel, 
      $cols, $rows, $photo_interp, $slope, 
      $intercept, $width, $center, $pad_value) = @{$self->{row}};

  # fill in defaults
  if (not defined $slope) { $slope = 1 };
  if (not defined $intercept) { $intercept = 0 };
  if (not defined $width) { $width = 200 };
  if (not defined $center) { $center = 0 };

  $self->{image_params} = {
    filename         => $filename,
    offset           => $offset,
    size             => $size,
    bits_stored      => $bits_stored,
    bits_allocated   => $bits_allocated,
    pix_rep          => $pix_rep,
    frames           => $frames,
    samples_per_pixel=> $samples_per_pixel,
    cols             => $cols,
    rows             => $rows,
    photo_interp     => $photo_interp,
    slope            => $slope,
    intercept        => $intercept,
    width            => $width,
    center           => $center,
    pad_value        => $pad_value,
  };
}

method ContentResponse($http, $dyn) {
  my $uri = URI->new();
  $uri->query_form($self->{image_params});
  my $extra = substr $uri->as_string(), 1;

  $http->queue(qq{
    <div class="row">
    <div class="col-md-5">
    <img src="GetImage?obj_path=$self->{path}&$extra" />

    <p>Width</p>
    <input type="range" id="window_width" 
           min="-2000" max="2000" value="$self->{image_params}->{width}"
           onchange="PosdaGetRemoteMethod('SetWidth', 'val=' + this.value, function() { Update(); })">
    <p>Center</p>
    <input type="range" id="window_center" 
           min="-100" max="1024" value="$self->{image_params}->{center}"
           onchange="PosdaGetRemoteMethod('SetCenter', 'val=' + this.value, function() { Update(); })">

    <p>SOP UID: $self->{sop_uid}<p>
    <p>Filename: $self->{image_params}->{filename}</p>
    <p>Resolution $self->{image_params}->{cols}x$self->{image_params}->{rows}</p>


    </div>
    </div>
  });

  
}

method GetImage($http, $dyn) {
  # say STDERR Dumper($dyn);
  my $temp_file = "$self->{temp_path}/$self->{sop_uid}.png";

  my $a = $self->{image_params};

  my $cmd = "extract -O $temp_file -f $a->{filename} -o $a->{offset} -s $a->{size} -S $a->{bits_stored} -A $a->{bits_allocated} -r $a->{pix_rep} -R $a->{rows} -C $a->{cols} -l $a->{slope} -i $a->{intercept} -c $a->{center} -w $a->{width}";

  my $result = `$cmd`;
  $self->SendFileByPath($http, {file_name => $temp_file});

}

method SetWidth($http, $dyn) {
  $self->{image_params}->{width} = $dyn->{val};
}
method SetCenter($http, $dyn) {
  $self->{image_params}->{center} = $dyn->{val};
}

method MenuResponse($http, $dyn) {
}

1;
