package Posda::FileVisualizer::DicomImage;
use strict;

use Posda::PopupWindow;
use Posda::DB qw( Query );
use Digest::MD5;
use ActivityBasedCuration::Quince;
use Posda::SeriesVisualizer;
use Posda::FileVisualizer::DicomImageCompare;


use vars qw( @ISA );
@ISA = ("Posda::PopupWindow");
sub MakeQueuer{ 
  my($http) = @_;
  my $sub = sub {
    my($txt) = @_;
    $http->queue($txt);
  };
  return $sub;
}

sub SpecificInitialize {
  my ($self, $params) = @_;
  $self->{title} = "Dicom Image File Visualizer";
print STDERR "#########\n";
print STDERR "In specific FileVisualizer::DicomImage::SpecificInitialize\n";
print STDERR "params:\n";
for my $k (keys %$params){
  print STDERR "$k = $params->{$k}\n";
}
  $self->{file_id} = $params->{file_id};
  $self->{activity_id} = $params->{activity_id};
print STDERR "Calling WhereFileSitsExtended($self->{file_id})\n";
  my %info;
  Query("WhereFileSitsExtended")->RunQuery(sub{
    my($row) = @_;
    ($info{collection},
     $info{site},
     $info{visibility},
     $info{patient_id},
     $info{study_instance_uid},
     $info{series_instance_uid},
     $info{sop_instance_uid},
     $info{frame_of_reference},
     $info{sop_class_uid},
     $info{modality},
     $info{dicom_file_type},
     $info{path},
     $info{pixel_data_digest},
     $info{earliest_import_day},
     $info{latest_import_day}) = @$row;
    print STDERR "Got a row\n";
  }, sub {}, $self->{file_id});
  $self->{where_file_sits} = \%info;
  $self->{display_mode} = "BasicFileInfo";
  $info{file_id} = $self->{file_id};
print STDERR "#########\n";
}

sub ContentResponse {
  my ($self, $http, $dyn) = @_;
    if($self->{display_mode} eq "BasicFileInfo"){
      $self->DisplayBasicFileInfo($http, $dyn);
    } elsif($self->{display_mode} eq "DicomDump"){
      $self->DisplayDicomDump($http, $dyn);
    } else {
      die "unknown display_mode: $self->{display_mode}";
    }
}
my $Decorations = {
  file_id => sub {
    my($self, $http, $dyn) = @_;
    $self->NotSoSimpleButton($http, {
      op => "FileHistoryWindow",
      caption => "hist",
      sync => "Update();",
    });
    $self->NotSoSimpleButton($http, {
      op => "OpenFileInQuince",
      caption => "disp",
      sync => "Update();",
    });
  },
  sop_instance_uid => sub {
    my($self, $http, $dyn) = @_;
    $self->NotSoSimpleButton($http, {
      op => "SopHistoryWindow",
      caption => "hist",
      sync => "Update();",
    });
  },
  frame_of_reference => sub {
    my($self, $http, $dyn) = @_;
    $self->NotSoSimpleButton($http, {
      op => "FrameOfReferenceReport",
      caption => "rpt",
      sync => "Update();",
    });
  },
  series_instance_uid => sub {
    my($self, $http, $dyn) = @_;
    $self->NotSoSimpleButton($http, {
      op => "SeriesReportWindow",
      caption => "rpt",
      sync => "Update();",
    });
    $self->NotSoSimpleButton($http, {
      op => "OpenSeriesInQuince",
      caption => "disp",
      sync => "Update();",
    });
  },
};

sub DisplayBasicFileInfo{
  my ($self, $http, $dyn) = @_;
  $http->queue("<table class=\"table table-striped table-condensed\"><thead>Basic Dicom File Info:<thead>");
  for my $k ("file_id", "collection", "site", "patient_id",
    "study_instance_uid", "series_instance_uid", "sop_instance_uid",
    "frame_of_reference", "sop_class_uid", "modality", "dicom_file_type",
    "path", "pixel_data_digest", "earliest_import_day", "latest_import_day"){
    $http->queue("<tr><td align=\"right\">$k</td>" .
    "<td align=\"left\">$self->{where_file_sits}->{$k}&nbsp;");
    if(exists $Decorations->{$k}){
      &{$Decorations->{$k}}($self, $http, $dyn);
    }
    $http->queue("</td></tr>");
  }
  $http->queue("</table>");
}

sub SeriesReportWindow{
  my ($self, $http, $dyn) = @_;
  my $class = "Posda::SeriesVisualizer";
#  require $class;
  unless(exists $self->{sequence_no}){$self->{sequence_no} = 0}
  $self->{sequence_no} += 1;
  my $child_path = $self->{path} . "_quince_$self->{sequence_no}";
  my $child_obj = $class->new($self->{session},
    $child_path, {
      activity_id => $self->{activity_id}, 
      series_instance_uid => $self->{where_file_sits}->{series_instance_uid}
    }
  );
  $self->StartJsChildWindow($child_obj);
}

sub OpenFileInQuince{
  my ($self, $http, $dyn) = @_;
  my $class = "ActivityBasedCuration::Quince";
  #require $class;
  unless(exists $self->{sequence_no}){$self->{sequence_no} = 0}
  $self->{sequence_no} += 1;
  my $child_path = $self->{path} . "_quince_$self->{sequence_no}";
  my $child_obj = $class->new($self->{session},
    $child_path, { type => "file", file_id => $self->{file_id} });
  $self->StartJsChildWindow($child_obj);
}
sub OpenSeriesInQuince{
  my ($self, $http, $dyn) = @_;
  my $class = "ActivityBasedCuration::Quince";
  #require $class;
  unless(exists $self->{sequence_no}){$self->{sequence_no} = 0}
  $self->{sequence_no} += 1;
  my $child_path = $self->{path} . "_quince_$self->{sequence_no}";
  my $child_obj = $class->new($self->{session},
    $child_path, { type => "series", series_instance_uid => $self->{where_file_sits}->{series_instance_uid}});
  $self->StartJsChildWindow($child_obj);
}
sub ShowDicomDump{
  my ($self, $http, $dyn) = @_;
  $self->{display_mode} = "DicomDump";
}
sub ShowBasicDicomInfo{
  my ($self, $http, $dyn) = @_;
  $self->{display_mode} = "BasicFileInfo";
}

sub DisplayDicomDump{
  my ($self, $http, $dyn) = @_;

  $http->queue("<h3>Dump of DICOM file $self->{file_id}</h3>");
  $self->NotSoSimpleButton($http, {
    op => "CompareDicomFiles",
    caption => "Compare",
    sync => "Update();",
  });
  $http->queue(" to file: ");
  $self->ClasslessBlurEntryBox($http, {
    name => "SetFileToCompareTo",
    size => 10,
    op => "SetFileToCompareTo",
    value => $self->{FileToCompareTo}
  }, "Update();");
  $http->queue("<pre>");
  open DUMP, "DumpDicom.pl \"$self->{file_path}\"|";
  while(my $line = <DUMP>){
    $line =~ s/</&lt/g;
    $line =~ s/>/&gt/g;
    $http->queue($line);
  }
  return;
}
sub SetFileToCompareTo {
  my ($self, $http, $dyn) = @_;
  my $value = $dyn->{value};
  $self->{FileToCompareTo} = $value;
}

sub CompareDicomFiles{
  my ($self, $http, $dyn) = @_;
  my $parms = {
    from_file => $self->{file_id},
    to_file => $self->{FileToCompareTo},
  };
  my $class = "Posda::FileVisualizer::DicomImageCompare";
  unless(exists $self->{sequence_no}){$self->{sequence_no} = 0}
  $self->{sequence_no} += 1;
  my $child_path = $self->{path} . "_compare_$self->{sequence_no}";
  my $child_obj = $class->new($self->{session},
    $child_path, $parms);
  $self->StartJsChildWindow($child_obj);
  
}


sub MenuResponse {
  my ($self, $http, $dyn) = @_;
  $self->NotSoSimpleButton($http, {
    op => "ShowDicomDump",
    caption => "ShowDicomDump",
    sync => "Update();"
  });
  $self->NotSoSimpleButton($http, {
    op => "ShowBasicDicomInfo",
    caption => "BasicDicomInfo",
    sync => "Update();"
  });
}

1;
