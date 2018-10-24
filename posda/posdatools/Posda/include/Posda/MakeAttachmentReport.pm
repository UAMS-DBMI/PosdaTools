use strict;
{
  package Posda::MakeAttachmentReport;
  use Posda::Dataset;
  my %Elements = (
    "(0008,0005)" => "ISO_IR 100",
    "(0008,0016)" => "1.2.840.10008.5.1.4.1.1.88.11",
    "(0008,0018)" => "<sop_inst>",
    "(0008,0020)" => "<study_date>",
    "(0008,0023)" => "<study_date>",
    "(0008,0030)" => "<study_time>",
    "(0008,0033)" => "<study_time>",
    "(0008,0050)" => "<accession_number>",
    "(0008,0060)" => "SR",
    "(0008,0070)" => "POSDA DICOM Curation Tools",
    "(0008,0090)" => undef,
    "(0008,1030)" => "<study_description>",
    "(0008,103e)" => "<series_description>",
    "(0008,1111)" => undef,
    "(0010,0010)" => "<patient_name>",
    "(0010,0020)" => "<patient_id>",
    "(0010,0030)" => undef,
    "(0010,0040)" => undef,
    "(0012,0062)" => "YES",
    "(0012,0063)" => "Per DICOM PS 3.15 AnnexE. Details in 0012,0064",
    "(0012,0064)[0](0008,0100)" => "113100",
    "(0012,0064)[0](0008,0102)" => "DCM",
    "(0012,0064)[0](0008,0104)" => "Basic Application Confidentiality Profile",
    "(0012,0064)[1](0008,0100)" => "113101",
    "(0012,0064)[1](0008,0102)" => "DCM",
    "(0012,0064)[1](0008,0104)" => "Clean Pixel Data Option",
    "(0012,0064)[2](0008,0100)" => "113104",
    "(0012,0064)[2](0008,0102)" => "DCM",
    "(0012,0064)[2](0008,0104)" => "Clean Structured Content Option",
    "(0012,0064)[3](0008,0100)" => "113105",
    "(0012,0064)[3](0008,0102)" => "DCM",
    "(0012,0064)[3](0008,0104)" => "Clean Descriptors Option",
    "(0012,0064)[4](0008,0100)" => "113107",
    "(0012,0064)[4](0008,0102)" => "DCM",
    "(0012,0064)[4](0008,0104)" => "Retain Longitudinal Temporal Information Modified Dates Option",
    "(0012,0064)[5](0008,0100)" => "113108",
    "(0012,0064)[5](0008,0102)" => "DCM",
    "(0012,0064)[5](0008,0104)" => "Retain Patient Characteristics Option",
    "(0012,0064)[6](0008,0100)" => "113109",
    "(0012,0064)[6](0008,0102)" => "DCM",
    "(0012,0064)[6](0008,0104)" => "Retain Device Identity Option",
    "(0012,0064)[7](0008,0100)" => "113111",
    "(0012,0064)[7](0008,0102)" => "DCM",
    "(0012,0064)[7](0008,0104)" => "Retain Safe Private Option",
    "(0013,\"CTP\",10)" => "<collection>",
    "(0013,\"CTP\",11)" => "<collection>",
    "(0013,\"CTP\",12)" => "<site_name>",
    "(0013,\"CTP\",13)" => "<site_id>",
    "(0013,\"CTP\",50)" => undef,
    "(0020,000d)" => "<study_instance_uid>",
    "(0020,000e)" => "<series_instance_uid>",
    "(0020,0010)" => undef,
    "(0020,0011)" => "1001",
    "(0020,0013)" => "1",
    "(0028,0303)" => "MODIFIED",
    "(0040,a040)" => "CONTAINER",
    "(0040,a043)[0](0008,0100)" => "Attachment",
    "(0040,a043)[0](0008,0102)" => "Posda Tools",
    "(0040,a043)[0](0008,0104)" => "Descriptor of non-DICOM format files attached as a zip file",
    "(0040,a050)" => "SEPARATE",
    "(0040,a491)" => "COMPLETE",
    "(0040,a493)" => "UNVERIFIED",
    "(0040,a730)[0](0040,a010)" => "CONTAINS",
    "(0040,a730)[0](0040,a040)" => "TEXT",
    "(0040,a730)[0](0040,a043)[0](0008,0100)" => "Attachment",
    "(0040,a730)[0](0040,a043)[0](0008,0102)" => "Posda Tools",
    "(0040,a730)[0](0040,a043)[0](0008,0104)" => "Descriptor of non-DICOM format files attached as a zip file",
    "(0040,a730)[0](0040,a160)" => "<text_goes_here>",
  );
  sub new{
    my $class = shift @_;
    my $this = {
      elements => {},
    };
    bless $this, $class;
    for my $i (keys %Elements){
      $this->{elements}->{$i} = $Elements{$i};
    }
    return $this;
  }
  sub values_needed{
    my($this) = @_;
    my %values;
    for my $tag (keys %{$this->{elements}}){
      if(
        defined $this->{elements}->{$tag} &&
        $this->{elements}->{$tag} =~ /<(.*)>/
      ){
        $values{$1} = 1;
      }
    }
    return [sort keys %values];
  }
  sub substitute{
    my($this, $substitutions) = @_;
    unless(ref($substitutions) eq "HASH"){
      die "substitutions not hash";
    }
    for my $tag (keys %{$this->{elements}}){
      if(
        defined $this->{elements}->{$tag} &&
        $this->{elements}->{$tag} =~ /<(.*)>/
      ){
        my $sub_name = $1;
        if(exists $substitutions->{$sub_name}){
          $this->{elements}->{$tag} = $substitutions->{$sub_name};
        }
      }
    }
  }
  sub WriteFile{
    my($this, $file_name) =  @_;
    my $ds = Posda::Dataset->new_blank;
    for my $el (keys %{$this->{elements}}){
      $ds->Insert($el, $this->{elements}->{$el});
    }
    $ds->WritePart10($file_name, "1.2.840.10008.1.2.1", "POSDA", undef, undef);
  }
}
1;
