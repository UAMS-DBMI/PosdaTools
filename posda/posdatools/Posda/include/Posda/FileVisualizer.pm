package Posda::FileVisualizer;

use Posda::PopupWindow;
use Posda::DB qw( Query );
use Digest::MD5;


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
  if($self->{params}->{file_type} eq "parsed dicom file"){
    $self->{is_dicom_file} = 1;
    $self->{sop_class_name} = $self->{params}->{dicom_file_type};
    $self->{modality} = $self->{params}->{modality};
  } else {
    $self->{is_dicom_file} = 0;
  }
#  Query('GetBasicFileInfo')->RunQuery(sub{
#  }, sub  {}, $self->{file_id};

}

sub ContentResponse {
  my ($self, $http, $dyn) = @_;
  if(defined($self->{mode}) && $self->{mode} eq "show_dump"){
    $http->queue("<h3>Dump of DICOM file $self->{file_id}</h3><pre>");
    open FILE, "<$self->{dump_file}";
    while(my $line = <FILE>){
      $http->queue($line);
    }
    $http->queue("</pre>");
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
    $http->queue("<h3>Processed ASCII file: $self->{file_id} as non-dicom manifest</h3><pre>");
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

sub ShowDicomDump{
  my ($self, $http, $dyn) = @_;
  unless(exists $self->{dump_file}){
    my $path;
    Query("GetFilePath")->RunQuery(sub{
      my($row) = @_;
      $path = $row->[0];
    }, sub{}, $self->{file_id});
    if(defined $path){
      my $dump_name = "$self->{temp_path}/Dumpfile";
      my $dump_cmd = "DumpDicom.pl \"$path\" >$dump_name";
      open DUMP, "$dump_cmd|";
      while(my $line = <DUMP>){}
      $self->{dump_file} = $dump_name;
    }
  }
  if(defined($self->{dump_file}) && -e $self->{dump_file}){
    $self->{mode} = "show_dump";
  }
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
  $self->{zip_expand} = [];
  my $cmd = "cd $self->{temp_path};unzip $self->{zip_file}";
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

sub MenuResponse {
  my ($self, $http, $dyn) = @_;
  if($self->{is_dicom_file}){
    $self->NotSoSimpleButton($http, {
       op => "ShowDicomDump",
       caption => "ShowDicomDump",
       sync => "Update();"
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
        my $dir = $self->{temp_path};
        line:
        for my $line (@{$self->{zip_expand}}){
          if($line =~ /^Archive:\s*(.*)$/) { next line }
          if($line =~ /^\s*inflating:\s*([^\s]+)\s*$/){
            my $file = $1;
            my $path = "$dir/$1";
            unless(-e $path) {
              print STDERR "Error: file $path not found\n";
              next line;
            }
            my $q = { path => $path };
            my $ctx = Digest::MD5->new;
            open PATH, "<$path";
            $ctx->addfile(PATH);
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
      $self->NotSoSimpleButton($http, {
         op => "ListZipExpansion",
         caption => "Show Expanded ZIP",
         sync => "Update();"
      });
      $self->NotSoSimpleButton($http, {
         op => "ExpandZip",
         caption => "Extract and Import ZIP contents",
         sync => "Update();"
      });
    } else {
      $http->queue("Error: couldn't find file\n");
    }
  } else {
  }
}

1;
