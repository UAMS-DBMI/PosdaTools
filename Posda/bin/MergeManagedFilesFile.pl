#!/usr/bin/perl -w 
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
use Storable qw( lock_store store retrieve store_fd fd_retrieve );
use Fcntl qw(:flock);

my $file = $ARGV[0];
my $cache_dir = $ARGV[1];

my $pgm_data = fd_retrieve(\*STDIN);
my $file_data;
my $time = time;
my $cache_duration = 60 * 60 * 12;
my $deleated_files = {};
my $deleated_digest = {};
my $deleated_dataset_digest = {};
my $deleated_pixel_digest = {};
my $deleated_contour_digest = {};

unless (-f $file) {
  Storable::lock_store($pgm_data, $file);
  print STDERR "MergeStorableFile.pl: Orig File size: " . (-s $file) . ".\n";
  exit 0;
}
print STDERR "MergeStorableFile.pl: Current File size: " . (-s $file) . ".\n";
open (FILE, "+<",  $file) || 
  die "MergeStorableFile.pl: Error $! opening file: $file\n";
flock FILE, LOCK_EX;
eval { $file_data = fd_retrieve(\*FILE); };
if ($@) { 
  print STDERR "MergeStorableFile.pl: Error $@, " .
    "can't retreive hash data from file: $file\n";
  $file_data = {}; 
}

# foreach my $key  (keys %{$pgm_data} ) 
#   { print STDERR "pgm data key: $key.\n"; }
# foreach my $key  (keys %{$file_data} ) 
#   { print STDERR "file data key: $key.\n"; }

# print STDERR "Processing by_file hash.\n";
# Process ->{by_file} hash...
foreach my $file (keys %{$pgm_data->{by_file}} ) {
  my $access_ts = $pgm_data->{by_file}->{$file}->{access_ts};
  if (exists $file_data->{by_file}->{$file}  &&
     $file_data->{by_file}->{$file}->{access_ts} > $access_ts)
    { $access_ts = $file_data->{by_file}->{$file}->{access_ts}; }
  $file_data->{by_file}->{$file} = 
    {
      digest => $pgm_data->{by_file}->{$file}->{digest},
      access_ts => $access_ts,
    };
}
foreach my $file (keys %{$file_data->{by_file}} ) {
  if (! (-f $file )  ||
      $time - $file_data->{by_file}->{$file}->{access_ts} > 
                 $cache_duration)
  {
    $deleated_files->{file}->{$file} = 1;
    $deleated_files->{digest}->{
      $file_data->{by_file}->{$file}->{digest}} = 1;
    delete $file_data->{by_file}->{$file};
    # print STDERR "del file $file from ManagedFiles hash.\n";
  }
}

# print STDERR "Processing by_digest hash.\n";
# Process ->{by_digest} hash...
foreach my $digest (keys %{$pgm_data->{by_digest}}) {
  if (exists $file_data->{by_digest}->{$digest}) {
    foreach my $file (keys %{$pgm_data->{by_digest}->{$digest}->{Files}}) {
       $file_data->{by_digest}->{$digest}->{Files}->{$file} = 1;
    }
  } else {
    $file_data->{by_digest}->{$digest} = 
      $pgm_data->{by_digest}->{$digest};
  }
}
file_digest:
foreach my $digest (keys %{$file_data->{by_digest}}) {
  if (exists $deleated_files->{digest}->{$digest}) {
    foreach my $file (keys %{$file_data->{by_digest}->{$digest}->{Files}}) {
      if (exists $deleated_files->{file}->{$file}) {
        delete $file_data->{by_digest}->{$digest}->{Files}->{$file};
      }
    }
    if ((scalar keys %{$file_data->{by_digest}->{$digest}->{Files}}) <= 0) {
      $deleated_digest->{digest}->{$digest} = 1;
      if (exists $file_data->{by_digest}->{$digest}->{dataset_digest}) {
        $deleated_digest->{dataset_digest}->{
          $file_data->{by_digest}->{$digest}->{dataset_digest}} = 1;
      }
      if (exists $file_data->{by_digest}->{$digest}->{dataset_digest}  &&
      exists $file_data->{by_dataset_digest}->{
          $file_data->{by_digest}->{$digest}->{dataset_digest}
        }->{modality}  &&
          $file_data->{by_dataset_digest}->{
              $file_data->{by_digest}->{$digest}->{dataset_digest}
            }->{modality} eq "RTSTRUCT")
      {
        # print STDERR "\tRTSTRUCT : $digest.\n";
        $deleated_contour_digest->{$digest} = 1;
      }
      if (exists $file_data->{by_digest}->{$digest}->{dataset_digest}  &&
          exists $pgm_data->{by_dataset_digest}->{
              $file_data->{by_digest}->{$digest}->{dataset_digest}
            }->{modality}  &&
          $pgm_data->{by_dataset_digest}->{
              $file_data->{by_digest}->{$digest}->{dataset_digest}
            }->{modality} eq "RTSTRUCT")
      {
        # print STDERR "\tRTSTRUCT : $digest.\n";
        $deleated_contour_digest->{$digest} = 1;
      }
      delete $file_data->{by_digest}->{$digest};
      # print STDERR "del digest $digest from ManagedFiles hash.\n";
    }
  }
}

# print STDERR "Processing by_dataset_digest hash.\n";
# Process ->{by_dataset_digest} hash...
foreach my $ds_digest (keys %{$pgm_data->{by_dataset_digest}}) {
  if (exists $file_data->{by_dataset_digest}->{$ds_digest}) {
    foreach my $digest 
      (keys %{$pgm_data->{by_dataset_digest}->{$ds_digest}->{digest}})
    {
      $file_data->{by_dataset_digest}
        ->{$ds_digest}->{digest}->{$digest} = 1;
    }
  } else {
    $file_data->{by_dataset_digest}->{$ds_digest} = 
      $pgm_data->{by_dataset_digest}->{$ds_digest};
  }
}
foreach my $ds_digest (keys %{$file_data->{by_dataset_digest}}) {
  if (exists $deleated_digest->{dataset_digest}->{$ds_digest}) {
    foreach my $digest 
      (keys %{$file_data->{by_dataset_digest}->{$ds_digest}->{digest}})
    {
      if (exists $deleated_digest->{digest}->{$digest}) 
      {
        delete $file_data->{by_dataset_digest}
                 ->{$ds_digest}->{digest}->{$digest};
      }
    }
    if ((scalar keys 
          %{$file_data->{by_dataset_digest}->{$ds_digest}->{digest}}) <= 0)
    {
      if (exists $file_data->{by_dataset_digest}
                   ->{$ds_digest}->{pixel_digest}) 
      {
        $deleated_pixel_digest->{$file_data->{by_dataset_digest}
          ->{$ds_digest}->{pixel_digest}} = 1;
      }
      # if (exists $file_data->{by_dataset_digest}->{$ds_digest}->{modality}  &&
      #     $file_data->{by_dataset_digest}->{$ds_digest}->{modality} eq "RTSTRUCT")
      # {
      #   print STDERR "\tRTSTRUCT dataset_digest: $ds_digest.\n";
      # }
      $deleated_dataset_digest->{digest}->{$ds_digest} = 1;
      delete $file_data->{by_dataset_digest}->{$ds_digest};
      # print STDERR "del dataset digest $ds_digest from ManagedFiles hash.\n";
    }
  }
}

# print STDERR "Processing by_sop_instance hash.\n";
# Process ->{by_sop_instance} hash.....
foreach my $sop (keys %{$pgm_data->{by_sop_instance}}) {
  if (exists $file_data->{by_sop_instance}->{$sop}) {
    foreach my $ds_digest (keys 
      %{$pgm_data->{by_sop_instance}->{$sop}->{dataset_digests}})
    {
      $file_data->{by_sop_instance}->{$sop}
        ->{dataset_digests}->{$ds_digest} = 1;
    }
    foreach my $digest (keys 
      %{$pgm_data->{by_sop_instance}->{$sop}->{digest}})
    {
      $file_data->{by_sop_instance}->{$sop}->{digest}->{$digest} = 1;
    }
  } else {
    $file_data->{by_sop_instance}->{$sop} = 
      $pgm_data->{by_sop_instance}->{$sop};
  }
}
# print STDERR "SOPs before merge: ";
# foreach my $sop (keys %{$file_data->{by_sop_instance}}) {
#   print STDERR "\t$sop";
# }
# print STDERR "\n";
foreach my $sop (keys %{$file_data->{by_sop_instance}}) {
  foreach my $ds_digest (keys 
    %{$file_data->{by_sop_instance}->{$sop}->{dataset_digests}})
  {
    if (exists $deleated_dataset_digest->{digest}->{$ds_digest}) {
      delete $file_data->{by_sop_instance}->{$sop}
        ->{dataset_digests}->{$ds_digest};
    # print STDERR "del sop $sop dataset_digest: $ds_digest from ManagedFiles hash.\n";
    }
  }
  foreach my $digest (keys 
    %{$file_data->{by_sop_instance}->{$sop}->{digests}})
  {
    if (exists $deleated_digest->{digest}->{$digest}) {
      delete $file_data->{by_sop_instance}->{$sop}
        ->{digests}->{$digest};
    # print STDERR "del sop $sop digest: $digest from ManagedFiles hash.\n";
    }
  }
  if (
      ((scalar keys  
       %{$file_data->{by_sop_instance}->{$sop}->{dataset_digests}}) <= 0) &&
      ((scalar keys  
       %{$file_data->{by_sop_instance}->{$sop}->{digests}}) <= 0))
  {
    delete $file_data->{by_sop_instance}->{$sop};
    # print STDERR "del sop instance: $sop from ManagedFiles hash.\n";
  }
}
# print STDERR "SOPs after merge: ";
# foreach my $sop (keys %{$file_data->{by_sop_instance}}) {
#   print STDERR "\t$sop";
# }
# print STDERR "\n";

seek(FILE, 0, 0);
truncate(FILE, 0);
eval { store_fd($file_data, \*FILE); };
if ($@) {
  print STDERR "MergeStorableFile.pl: Error $@, " .
    "can't store hash data to file: $file\n";
}
close (FILE);
chmod 0664, $file;
print STDERR "MergeStorableFile.pl: new File size: " . (-s $file) . ".\n";
store_fd($file_data, \*STDOUT);
close (STDOUT);

#
# for now - do not delete anything - timeing issues with other copies...
#
#
# # Delete all pixel files: <cache dir>/pixel_files/X/Y/<file digest>.gray
# foreach my $digest (keys %{$deleated_pixel_digest}) {
#   my $fn = $cache_dir . "/pixel_files/" . substr($digest,0,1) ."/" .
#              substr($digest,1,1) . "/$digest.gray";
#   # print STDERR "\t: pixel digest file to del: $fn.\n";
#   my $cmd = "rm -fr \"$fn\"*";
#   # print STDERR "\t: pixel digest cmd: $cmd.\n";
#   `$cmd`;
# }
# 
# # Delete all contour files: <cache dir>/contour_files/X/Y/<file digest>/<file digest>_X_Y.contour
# foreach my $digest (keys %{$deleated_contour_digest}) {
#   my $fn = "\"" . $cache_dir . "/contour_files/" . 
#            substr($digest,0,1) ."/" . substr($digest,1,1) . 
#            "/$digest/$digest\"*.contour";
#   # print STDERR "\t: pixel digest file to del: $fn.\n";
#   my $cmd = "rm -fr $fn";
#   # print STDERR "\t: pixel digest cmd: $cmd.\n";
#   `$cmd`;
# }

exit 0;
