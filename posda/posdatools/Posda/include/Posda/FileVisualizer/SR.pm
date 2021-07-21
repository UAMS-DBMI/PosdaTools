package Posda::FileVisualizer::SR;

use Posda::PopupWindow;
use Posda::DB qw( Query );
use Digest::MD5;
use ActivityBasedCuration::Quince;


use vars qw( @ISA );
@ISA = ("Posda::FileVisualizer");

sub SpecificInitialize {
  my ($self) = @_;
  $self->{is_SR} = 1;
  $self->InitializeSrText($http, $dyn);
  $self->InitializeSrSimpleText($http, $dyn);
  $self->InitializeSrStruct($http, $dyn);
  $self->InitializeSrUnique($http, $dyn);
  $self->InitializeSrSimpleUnique($http, $dyn);
  $self->{mode} = "show_dicom_dump";
}

sub ContentResponse {
  my ($self, $http, $dyn) = @_;
  if(defined($self->{mode}) && $self->{mode} eq "show_dicom_dump"){
    $http->queue("<h3>Dump of DICOM file $self->{file_id}</h3><pre>");
    $self->DisplayDicomDump($http, $dyn);
    return;
  } elsif(defined($self->{mode}) && $self->{mode} eq "show_sr_simple_text"){
    $http->queue("<h3>Simplified SR Text representation of DICOM file $self->{file_id}</h3><pre>");
    open FILE, "<$self->{sr_simple_text_file}";
    while(my $line = <FILE>){
      $line =~ s/</&lt/g;
      $line =~ s/>/&gt/g;
      $http->queue($line);
    }
    $http->queue("</pre>");
    return;
  } elsif(defined($self->{mode}) && $self->{mode} eq "show_sr_text"){
    $http->queue("<h3>SR Text representation of DICOM file $self->{file_id}</h3><pre>");
    open FILE, "<$self->{sr_text_file}";
    while(my $line = <FILE>){
      $line =~ s/</&lt/g;
      $line =~ s/>/&gt/g;
      $http->queue($line);
    }
    $http->queue("</pre>");
    return;
  } elsif(defined($self->{mode}) && $self->{mode} eq "show_sr_struct"){
    $http->queue("<h3>SR Structure representation of DICOM file $self->{file_id}</h3><pre>");
    open FILE, "<$self->{sr_struct_file}";
    while(my $line = <FILE>){
      $line =~ s/</&lt/g;
      $line =~ s/>/&gt/g;
      $http->queue($line);
    }
    $http->queue("</pre>");
    return;
  } elsif(defined($self->{mode}) && $self->{mode} eq "show_sr_unique"){
    $http->queue("<h3>SR Unique path/value representation of " .
      "DICOM file $self->{file_id}</h3><pre>");
    open FILE, "<$self->{sr_unique_file}";
    while(my $line = <FILE>){
      $line =~ s/</&lt/g;
      $line =~ s/>/&gt/g;
      $http->queue($line);
    }
    $http->queue("</pre>");
    return;
  }elsif(defined($self->{mode}) && $self->{mode} eq "show_sr_simple_unique"){
    $http->queue("<h3>Simple SR Unique path/value representation of " .
      "DICOM file $self->{file_id}</h3><pre>");
    open FILE, "<$self->{sr_simple_unique_file}";
    while(my $line = <FILE>){
      $line =~ s/</&lt/g;
      $line =~ s/>/&gt/g;
      $http->queue($line);
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

sub ShowSrText{
  my ($self, $http, $dyn) = @_;
  if(defined($self->{sr_text_file}) && -e $self->{sr_text_file}){
    $self->{mode} = "show_sr_text";
  }
}

sub ShowSrSimpleText{
  my ($self, $http, $dyn) = @_;
  if(defined($self->{sr_simple_text_file}) && -e $self->{sr_simple_text_file}){
    $self->{mode} = "show_sr_simple_text";
  }
}

sub InitializeSrText{
  my ($self, $http, $dyn) = @_;
  unless(exists $self->{sr_text_file}){
    if(defined $self->{file_path}){
      my $dump_name = "$self->{temp_path}/SrTextFile";
      my $dump_cmd = "DumpSr.pl \"$self->{file_path}\" >$dump_name";
      open DUMP, "$dump_cmd|";
      while(my $line = <DUMP>){}
      close DUMP;
      $self->{sr_text_file} = $dump_name;
    }
  }
}

sub InitializeSrSimpleText{
  my ($self, $http, $dyn) = @_;
  unless(exists $self->{sr_simple_text_file}){
    if(defined $self->{file_path}){
      my $dump_name = "$self->{temp_path}/SrSimpleTextFile";
      my $dump_cmd = "DumpSimpleSr.pl \"$self->{file_path}\" >$dump_name";
      open DUMP, "$dump_cmd|";
      while(my $line = <DUMP>){}
      close DUMP;
      $self->{sr_simple_text_file} = $dump_name;
    }
  }
}

sub ShowSrStruct{
  my ($self, $http, $dyn) = @_;
  if(defined($self->{sr_text_file}) && -e $self->{sr_text_file}){
    $self->{mode} = "show_sr_struct";
  }
}

sub InitializeSrStruct{
  my ($self, $http, $dyn) = @_;
  unless(exists $self->{sr_struct_file}){
    if(defined $self->{file_path}){
      my $dump_name = "$self->{temp_path}/SrStructFile";
      my $dump_cmd = "DumpSrStruct.pl \"$self->{file_path}\" >$dump_name";
      open DUMP, "$dump_cmd|";
      while(my $line = <DUMP>){}
      close DUMP;
      $self->{sr_struct_file} = $dump_name;
    }
  }
}

sub ShowSrUnique{
  my ($self, $http, $dyn) = @_;
  if(defined($self->{sr_unique_file}) && -e $self->{sr_unique_file}){
    $self->{mode} = "show_sr_unique";
  }
}

sub ShowSrSimpleUnique{
  my ($self, $http, $dyn) = @_;
  if(defined($self->{sr_simple_unique_file}) && -e $self->{sr_simple_unique_file}){
    $self->{mode} = "show_sr_simple_unique";
  }
}

sub InitializeSrUnique{
  my ($self, $http, $dyn) = @_;
  unless(exists $self->{sr_unique_file}){
    if(defined $self->{file_path}){
      my $dump_name = "$self->{temp_path}/SrUniqueFile";
      my $dump_cmd = "UniqSrPathValues.pl \"$self->{file_path}\" >$dump_name";
      open DUMP, "$dump_cmd|";
      while(my $line = <DUMP>){}
      close DUMP;
      $self->{sr_unique_file} = $dump_name;
    }
  }
}

sub InitializeSrSimpleUnique{
  my ($self, $http, $dyn) = @_;
  unless(exists $self->{sr_simple_unique_file}){
    if(defined $self->{file_path}){
      my $dump_name = "$self->{temp_path}/SrUniqueSimpleFile";
      my $dump_cmd = "UniqSimpleSr.pl \"$self->{file_path}\" >$dump_name";
      open DUMP, "$dump_cmd|";
      while(my $line = <DUMP>){}
      close DUMP;
      $self->{sr_simple_unique_file} = $dump_name;
    }
  }
}



sub MenuResponse {
  my ($self, $http, $dyn) = @_;
  $self->NotSoSimpleButton($http, {
     op => "ShowDicomDump",
     caption => "ShowDicomDump",
     sync => "Update();"
  });
  $self->NotSoSimpleButton($http, {
     op => "ShowSrStruct",
     caption => "Sr Struct Dump",
     sync => "Update();"
  });
  $self->NotSoSimpleButton($http, {
     op => "ShowSrText",
     caption => "Sr Text Dump",
     sync => "Update();"
  });
  $self->NotSoSimpleButton($http, {
     op => "ShowSrSimpleText",
     caption => "Sr Simple Text Dump",
     sync => "Update();"
  });
  $self->NotSoSimpleButton($http, {
     op => "ShowSrUnique",
     caption => "Sr Unique Scan",
     sync => "Update();"
  });
  $self->NotSoSimpleButton($http, {
     op => "ShowSrSimpleUnique",
     caption => "Sr Simple Unique Scan",
     sync => "Update();"
  });
}

1;
