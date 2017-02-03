package Posda::PopupWindowTest;

use Modern::Perl;
use Method::Signatures::Simple;

use Posda::PopupWindow;
use Posda::Config ('Config','Database');

use Data::Dumper;
use DBI;

use MIME::Base64;


use vars qw( @ISA );
@ISA = ("Posda::PopupWindow");

my $db_handle;

method SpecificInitialize($params) {
  $self->{menustuff} = "Menu";

  # Determine temp dir
  $self->{temp_path} = "$self->{LoginTemp}/$self->{session}";


  my $sop_uid = $params;
  $self->{sop_uid} = $sop_uid;

  $db_handle = DBI->connect(Database('posda_files'));

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

  $qh->execute($sop_uid);
  my $rows = $qh->fetchrow_arrayref();

  say Dumper($rows);

  # my %ht = map {
  #   $_->[0] => {map {
  #     $_ => 1
  #   } @{$_->[1]}}
  # } @$rows;

  $self->{row} = $rows;

}

method ContentResponse($http, $dyn) {
  # $http->queue(Dumper($self->{LaunchParams}));
  #$self->Test($http, $dyn);
  $http->queue(qq{
    <img src="Test?obj_path=$self->{path}" />
  });

}

method Test($http, $dyn) {
  my ($filename, $offset, $size, $bits_stored, $bits_allocated, $pix_rep, $frames, $samples_per_pixel, $cols, $rows, $photo_interp, $slope, $intercept, $width, $center, $pad_value) = @{$self->{row}};

  my $temp_file = "$self->{temp_path}/$self->{sop_uid}.png";

  # fill in defaults
  if (not defined $slope) { $slope = 1 };
  if (not defined $intercept) { $intercept = 0 };
  if (not defined $width) { $width = 200 };
  if (not defined $center) { $center = 0 };

  my $cmd = "extract -O $temp_file -f $filename -o $offset -s $size -S $bits_stored -A $bits_allocated -r $pix_rep -R $rows -C $cols -l $slope -i $intercept -c $center -w $width";

  my $result = `$cmd`;
  $self->SendFileByPath($http, {file_name => $temp_file});

}

method GetImage($http, $dyn) {

}

method MenuResponse($http, $dyn) {
  $http->queue($self->{menustuff});
}


1;
