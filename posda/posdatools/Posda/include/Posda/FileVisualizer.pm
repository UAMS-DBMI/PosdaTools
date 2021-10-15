package Posda::FileVisualizer;
use strict;

use Dispatch::LineReader;
use Posda::PopupWindow;
use Posda::FileVisualizer::SR;
use Posda::FileVisualizer::DicomImage;
use Posda::FileVisualizer::Segmentation;
use Posda::FileVisualizer::StructureSet;
use Posda::FileVisualizer::RtDose;
use Nifti::Parser;
use Posda::DB qw( Query );
use Digest::MD5;
use ActivityBasedCuration::Quince;


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
  $self->{title} = "Generic File Visualizer";
  # Determine temp dir
  $self->{temp_path} = "$self->{LoginTemp}/$self->{session}";
  $self->{params} = $params;
  $self->{file_id} = $params->{file_id};
  Query('GetDatasetStart')->RunQuery(sub{
    my($row) = @_;
    $self->{data_set_start} = $row->[0];
  }, sub {}, $self->{file_id});
  Query('GetBasicFileInfo')->RunQuery(sub{
    my($row) = @_;
    my($file_id_cp, $file_type, $dicom_file_type,
      $patient_id, $non_dicom_file_type, $subject,
      $non_dicom_file_subtype) = @$row;
    $self->{file_desc} = {
       file_id => $file_id_cp,
       file_type => $file_type,
       dicom_file_type => $dicom_file_type,
       patient_id => $patient_id,
       non_dicom_file_type  => $non_dicom_file_type,
       subject => $subject,
       non_dicom_file_subtype => $non_dicom_file_subtype
    };
  }, sub {}, $self->{file_id});
  if($self->{file_desc}->{file_type} eq "parsed dicom file"){
    unless($self->{file_desc}->{dicom_file_type}){
      print STDERR "Not really DICOM file\n";
      $self->{file_desc}->{file_type} = "unknown";
      $self->{params}->{file_type} = "unknown";
      $self->{is_dicom_file} = 0;
    }
  }
  Query("GetFilePath")->RunQuery(sub{
      my($row) = @_;
      $self->{file_path} = $row->[0];
  }, sub{}, $self->{file_id});
print STDERR "#######################################\n";
  if($self->{file_desc}->{file_type} eq "parsed dicom file"){
print STDERR "Dicom file\n";
    $self->{is_dicom_file} = 1;
    $self->{sop_class_name} = $self->{file_desc}->{dicom_file_type};
#    $self->InitializeDicomDump();
    if($self->{file_desc}->{dicom_file_type} =~ /SR/){
      bless $self, "Posda::FileVisualizer::SR";
      print STDERR "bless \$self, Posda::FileVisualizer::SR\n";
      return $self->SpecificInitialize;
    } elsif ($self->{file_desc}->{dicom_file_type} =~ /Image/){
      print STDERR "bless \$self, Posda::FileVisualizer::DicomImage\n";
      bless $self, "Posda::FileVisualizer::DicomImage";
      return $self->SpecificInitialize;
    } elsif ($self->{file_desc}->{dicom_file_type} =~ /Segmentation/){
      print STDERR "bless \$self, Posda::FileVisualizer::Segmentation\n";
      bless $self, "Posda::FileVisualizer::Segmentation";
      return $self->SpecificInitialize;
    } elsif ($self->{file_desc}->{dicom_file_type} =~ /RT Dose/){
      bless $self, "Posda::FileVisualizer::RtDose";
      return $self->SpecificInitialize;
    } elsif ($self->{file_desc}->{dicom_file_type} =~ /Structure/){
      bless $self, "Posda::FileVisualizer::StructureSet";
      return $self->SpecificInitialize;
    }
  } elsif($self->{file_desc}->{file_type} =~ /PNG/) {
    my $params = {
      file_id => $self->{file_id},
      path => $self->{file_path}
    };
    $self->{is_dicom_file} = 0;
    require Posda::FileVisualizer::PNG;
    bless $self, "Posda::FileVisualizer::PNG";
    return $self->SpecificInitialize($params);
  } elsif($self->{file_desc}->{file_type} eq "Nifti Image (gzipped)") {
print STDERR "Gzipped Nifti\n";
    my $nifti = Nifti::Parser->new_from_zip(
      $self->{file_path},
      $self->{file_id},
      $self->{temp_path});
    my $params = {
      file_id => $self->{file_id},
      file_path => $self->{file_path},
      nifti => $nifti,
      temp_path => $self->{temp_path},
    };
    if(defined $nifti){
      $self->{is_dicom_file} = 0;
      require Posda::FileVisualizer::Nifti;
      bless $self, "Posda::FileVisualizer::Nifti";
      return $self->SpecificInitialize($params);
    }
  } elsif($self->{file_desc}->{file_type} eq "Nifti Image"){
print STDERR "Nifti\n";
    my $nifti = Nifti::Parser->new($self->{file_path});
    my $params = {
      file_id => $self->{file_id},
      file_path => $self->{file_path},
      nifti => $nifti,
      temp_path => $self->{temp_path},
    };
    if(defined $nifti){
      $self->{is_dicom_file} = 0;
      require Posda::FileVisualizer::Nifti;
      bless $self, "Posda::FileVisualizer::Nifti";
      return $self->SpecificInitialize($params);
    }
    #...  Here is place to all other file type checks ...
  }
print STDERR "#######################################\n";

}

sub ContentResponse {
  my ($self, $http, $dyn) = @_;
  if(defined($self->{mode}) && $self->{mode} eq "show_dicom_dump"){
    $self->DisplayDicomDump($http, $dyn);
    return;
  } elsif($self->{mode} eq "show_text"){
    $http->queue("<h3>ASCII file: $self->{file_id}</h3><pre>");
    open FILE, "<$self->{text_file}";
    while(my $line = <FILE>){
      $http->queue($line);
    }
    $http->queue("</pre>");
    return;
  } elsif($self->{mode} eq "show_json"){
    $http->queue("<h3>Json file: $self->{file_id}</h3><pre>");
    open FILE, "<$self->{text_file}";
    while(my $line = <FILE>){
      $http->queue($line);
    }
    $http->queue("</pre>");
    return;
  } elsif($self->{mode} eq "show_csv"){
    $http->queue("<h3>CSV file: $self->{file_id}</h3><pre>");
    open FILE, "<$self->{text_file}";
    while(my $line = <FILE>){
      $http->queue($line);
    }
    $http->queue("</pre>");
    return;
  } elsif($self->{mode} eq "show_zip_list"){
    $http->queue("<h3>ZIP file ($self->{file_id} listing:</h3><pre>");
    for my $line (@{$self->{zip_list}}){
      $http->queue("$line\n");
    }
    $http->queue("</pre>");
    return;
  } elsif($self->{mode} eq "show_zip_expand"){
    $http->queue("<h3>ZIP file ($self->{file_id}) expansion:</h3><pre>");
    for my $line (@{$self->{zip_expand}}){
      $http->queue("$line\n");
    }
    $http->queue("</pre>");
    return;
  } elsif($self->{mode} eq "list_zip_expansion"){
    $http->queue("<h3>ZIP file ($self->{file_id}) expansion:</h3>");
    $http->queue("<table class=\"table\"><tr><th>file_id</th><th>digest</th>". 
      "<th>in db</th><th>in timepoint</th><th>file</th></tr>");
    for my $q (@{$self->{expanded_zips}}){
      $http->queue("<tr>");
      $http->queue("<td>$q->{file_id}</td>");
      $http->queue("<td>$q->{digest}</td>");
      $http->queue("<td>$q->{in_database}</td>");
      $http->queue("<td>$q->{in_timepoint}</td>");
      $http->queue("<td>$q->{path}</td>");
      $http->queue("</tr>");
    }
    $http->queue("</table>");
    return;
  } elsif($self->{mode} eq "non_dicom_file processing complete"){
    $http->queue("<h3>Processed ASCII file: " .
      "$self->{file_id} as non-dicom manifest</h3><pre>");
    for my $mess (@{$self->{non_dicom_processing_results}}){
      $http->queue("$mess\n");
    }
    $http->queue("</pre>");
    return;
  }
  my $queuer = MakeQueuer($http);
  $http->queue("<pre>Params: ");
  Debug::GenPrint($queuer, $self->{params}, 1);
  $http->queue(";\n");
  $http->queue("</pre>");
}

sub DisplayDicomDump{
  my ($self, $http, $dyn) = @_;
  
  $http->queue("<h3>Dump of DICOM file $self->{file_id}</h3><pre>");
  open DUMP, "DumpDicom.pl \"$self->{file_path}\"|";
  while(my $line = <DUMP>){
    $line =~ s/</&lt/g;
    $line =~ s/>/&gt/g;
    $http->queue($line);
  }
  return;
  unless(defined($self->{dicom_dump_file})){
    $http->queue("&lt;preparing&gt;");
    return;
  }
  open FILE, "<$self->{dicom_dump_file}";
  while(my $line = <FILE>){
    $line =~ s/</&lt/g;
    $line =~ s/>/&gt/g;
    $http->queue($line);
  }
  $http->queue("</pre>");
}

sub InitializeDicomDump{
  my ($self) = @_;
  my $dump_name = "$self->{temp_path}/" . rand(1000);
  my $dump_cmd = "DumpDicom.pl \"$self->{file_path}\" >\"$dump_name\"";
  print STDERR "####################\n" .
    "Invoking cmd '$dump_cmd'\n" .
    "####################\n";
  Dispatch::LineReader->new_cmd($dump_cmd, sub {},
    sub {
      $self->{dicom_dump_file} = $dump_name;
      $self->AutoRefresh();
      print STDERR "####################\n" .
        "Finished cmd '$dump_cmd'\n" .
        "####################\n";
    }
  );
}

sub ShowDicomDump{
  my ($self, $http, $dyn) = @_;
  $self->{mode} = "show_dicom_dump";
}

sub ShowAsciiText{
  my ($self, $http, $dyn) = @_;
  Query('GetFilePath')->RunQuery(sub {
    my($row) = @_;
    $self->{text_file} = $row->[0];
  }, sub{}, $self->{params}->{file_id});
  if(defined($self->{text_file})&& -e $self->{text_file}){
    $self->{mode} = "show_text";
  }
}

sub ShowJson{
  my ($self, $http, $dyn) = @_;
  Query('GetFilePath')->RunQuery(sub {
    my($row) = @_;
    $self->{text_file} = $row->[0];
  }, sub{}, $self->{params}->{file_id});
  if(defined($self->{text_file})&& -e $self->{text_file}){
    $self->{mode} = "show_json";
  }
}

sub ShowCsv{
  my ($self, $http, $dyn) = @_;
  Query('GetFilePath')->RunQuery(sub {
    my($row) = @_;
    $self->{text_file} = $row->[0];
  }, sub{}, $self->{params}->{file_id});
  if(defined($self->{text_file})&& -e $self->{text_file}){
    $self->{mode} = "show_csv";
  }
}

sub ProcessNonDicomManifest{
  my ($self, $http, $dyn) = @_;
  my $q1 = Query('GetFileIdByDigest');
  my $q2 = Query('GetNonDicomFileRow');
  my $q3 = Query('PopulateNonDicomFileRow');
  $self->{non_dicom_processing_results} = [];
  open FILE, "<$self->{text_file}";
  line:
  while(my $line = <FILE>){
    chomp $line;
    my($digest,$file_type,$non_dicom_file_type,
      $non_dicom_file_subtype,$subject,$collection,
      $site,$time_of_last_characterization,$path,$fname) = 
      split(/\|/, $line);
    my $file_id;
    $q1->RunQuery(sub{
      my($row) = @_;
      $file_id = $row->[0];
    }, sub {}, $digest);
    unless(defined($file_id)){
      push @{$self->{non_dicom_processing_results}},  "#### Error: no file for non_dicom_digest: $digest";
      next line;
    }
    my $non_dicom_file_row;
    $q2->RunQuery(sub{
      my($row) = @_;
      $non_dicom_file_row = $row->[0];
    }, sub{}, $file_id);
    if(defined $non_dicom_file_row) {
      push @{$self->{non_dicom_processing_results}},  "file $file_id already in  non_dicom_file table";
      next line;
    }
    $q3->RunQuery(sub{}, sub{},
      $file_id, $non_dicom_file_type, 
      $non_dicom_file_subtype,$collection,
      $site,$subject, $time_of_last_characterization);
    push @{$self->{non_dicom_processing_results}},  "entered $file_id into non_dicom_file table";
  }
  $self->{mode} = "non_dicom_file processing complete";
}

sub ListZip{
  my($self, $http, $dyn) = @_;
  $self->{zip_list} = [];
  open SUB, "unzip -v $self->{zip_file} |";
  while (my $line = <SUB>){
    chomp $line;
    push @{$self->{zip_list}}, $line;
  }
  close SUB;
  $self->{mode} = "show_zip_list";
}

sub ExpandZip{
  my($self, $http, $dyn) = @_;
  my $zip_dir = "$self->{temp_path}/zip_dir/$self->{file_id}";
  if(-d $zip_dir || exists $self->{zip_expand}){
    $self->{mode} = "show_zip_expand";
    return;
  }
  unless(mkdir($zip_dir) == 1){
    print STDERR "unable to mkdir $zip_dir\n";
    return;
  }
  $self->{zip_expand} = [];
  my $cmd = "cd $zip_dir;unzip $self->{zip_file}";
  open SUB, "$cmd |";
  while (my $line = <SUB>){
    chomp $line;
    push @{$self->{zip_expand}}, $line;
  }
  close SUB;
  $self->{mode} = "show_zip_expand";
}

sub ListZipExpansion{
  my ($self, $http, $dyn) = @_;
  $self->{mode} = "list_zip_expansion";
}

sub OpenInQuince{
  my ($self, $http, $dyn) = @_;
  bless $self, "ActivityBasedCuration::Quince";
  $self->Initialize({
    type => "file",
    file_id => $self->{params}->{file_id}
  });
}

sub MenuResponse {
  my ($self, $http, $dyn) = @_;
  if($self->{is_dicom_file}){
    $self->NotSoSimpleButton($http, {
       op => "ShowDicomDump",
       caption => "ShowDicomDump",
       sync => "Update();"
    });
    $self->NotSoSimpleButton($http, {
       op => "OpenInQuince",
       caption => "Open in Quince",
       sync => "Reload();"
    });
  } elsif($self->{params}->{file_type} eq "ASCII text"){
    $self->NotSoSimpleButton($http, {
       op => "ShowAsciiText",
       caption => "Show ASCII",
       sync => "Update();"
    });
    if($self->{mode} eq "show_text"){
      $self->NotSoSimpleButton($http, {
         op => "ProcessNonDicomManifest",
         caption => "Process NonDicomManifest",
         sync => "Update();"
      });
    }
  } elsif($self->{params}->{non_dicom_file_type} eq "json"){
    $self->NotSoSimpleButton($http, {
       op => "ShowJson",
       caption => "Show Json File",
       sync => "Update();"
    });
  } elsif($self->{params}->{non_dicom_file_type} eq "csv"){
    $self->NotSoSimpleButton($http, {
       op => "ShowCsv",
       caption => "Show CSV File",
       sync => "Update();"
    });
  } elsif($self->{params}->{non_dicom_file_type} eq "zip"){
    if(exists $self->{zip_expand}){
      unless(exists $self->{expanded_zips}){
        $self->{expanded_zips} = [];
        #my $dir = $self->{temp_path};
        my $zip_dir = "$self->{temp_path}/zip_dir/$self->{file_id}";
        line:
        for my $line (@{$self->{zip_expand}}){
          if($line =~ /^Archive:\s*(.*)$/) { next line }
          if($line =~ /^\s*inflating:\s*([^\s]+)\s*$/){
            my $file = $1;
            my $path = "$zip_dir/$1";
            unless(-e $path) {
              print STDERR "Error: file $path not found\n";
              next line;
            }
            my $q = { path => $path };
            my $ctx = Digest::MD5->new;
            open PATH, "<$path";
            $ctx->addfile(*PATH);
            my $digest = $ctx->hexdigest;
            $q->{digest} = $digest;
            close PATH;
            my $file_id;
            Query('GetFileIdByDigest')->RunQuery(sub{
              my($row) = @_;
              $file_id = $row->[0];
            }, sub{}, $digest);
            if(defined($file_id)){
              $q->{file_id} = $file_id;
              $q->{in_database} = "yes";
              my $in_timepoint = "no";
              Query('IsFileInActivity')->RunQuery(sub{
                my($row) = @_;
                $in_timepoint = "yes";
              }, sub {}, $file_id, $self->{params}->{activity_id});
              $q->{in_timepoint} = $in_timepoint;
            } else {
              $q->{file_id} = "N/A";
              $q->{in_database} = "no";
              $q->{in_timepoint} = "no";
            }
            push @{$self->{expanded_zips}}, $q;
          }
        }
      }
    }
    unless(exists $self->{zip_file}){
      Query('GetFilePath')->RunQuery(sub {
        my($row) = @_;
        $self->{zip_file} = $row->[0];
      }, sub{}, $self->{params}->{file_id});
    }
    if(exists $self->{zip_file}){
      $self->NotSoSimpleButton($http, {
         op => "ListZip",
         caption => "List files in ZIP File",
         sync => "Update();"
      });
      if(exists $self->{expanded_zips}){
        $self->NotSoSimpleButton($http, {
           op => "ListZipExpansion",
           caption => "Show Expanded ZIP",
           sync => "Update();"
        });
      }
      unless(exists $self->{expanded_zips}){
        $self->NotSoSimpleButton($http, {
           op => "ExpandZip",
           caption => "Extract and Import ZIP contents",
           sync => "Update();"
        });
      }
    } else {
      $http->queue("Error: couldn't find file\n");
    }
  } else {
  }
}

1;
