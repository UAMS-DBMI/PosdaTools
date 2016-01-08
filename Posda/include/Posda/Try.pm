#$Source: /home/bbennett/pass/archive/Posda/include/Posda/Try.pm,v $
#$Date: 2012/07/19 19:47:33 $
#$Revision: 1.16 $
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
package Posda::Try;
use Posda::Dataset;
use Posda::Parser;
use Digest::MD5;

################################################################
#Try - see if a file is a Dicom File
#
#  my $try = Posda::Try->new($path);
#
#  $df is Dicom File (Part 10) header if file is Part 10
#         undef if not Part 10 format
#  $ds is Dicom Dataset
#         undef if not Dicom File
#
sub GetDigestAndLength{
  my($class, $infile) = @_;
  my $res = open FILE, "<", "$infile";
  unless($res){
    my $this = {
      filename => $infile,
      status => "failed to open file: $infile",
      error => [ $! ],
    };
    return bless $this, $class;
  }
  binmode FILE ;
  my $ctx = Digest::MD5->new();
  $ctx->addfile(*FILE);
  seek(FILE, 0, 2);
  my $len = tell(FILE);
  close FILE;
  my $digest = $ctx->hexdigest;
  return($digest, $len);
}
sub new{
  my($class, $infile, $fast, $extremely_verbose) = @_;
  my($digest, $len) = $class->GetDigestAndLength($infile);
  return new_with_digest_and_length($class, $infile, $digest, $len, $fast,
    $extremely_verbose);
}
sub new_with_digest_and_length{
  my($class, $infile, $digest, $len, $fast, $extremely_verbose) = @_;
  my $df;
  my $ds;
  my $file_size;
  my $ds_size;
  my $xfr_stx;
  my @errors;
  
  my $parser;
  eval {
    $parser = Posda::Parser->new(
      dd => $Posda::Dataset::DD,
      from_file => $infile,
    );
    if($fast) { $parser->{skip_large} = $fast }
    if($extremely_verbose) { $parser->{extremely_verbose} = 1 }
    $ds = $parser->ReadDataset();
  };
  if($@){
    if($parser->{metaheader}){
      push(@errors, "Part 10 file with bad dataset: $@");
      my $this = {
        metaheader => $parser->{metaheader},
        filename => $infile,
        status => "failed to parse",
        parse_errors => \@errors,
        digest => $digest,
        file_size => $len,
      };
      return bless $this, $class;
    }
    push @errors, $@;
    my @to_try = (
      "1.2.840.10008.1.2",
      "1.2.840.10008.1.2.1",
      "1.2.840.10008.1.2.2",
      "1.2.826.0.1.3680043.2.494.1.1",
      "1.3.6.1.4.1.22213.1.147"
    );
    my $found_one;
    for my $x (@to_try){
      $parser = Posda::Parser->new(
        dd => $Posda::Dataset::DD,
        from_file => $infile,
        xfr_stx => $x,
      );
      if($fast) { $parser->{skip_large} = $fast }
      if($extremely_verbose) { $parser->{extremely_verbose} = 1 }
      eval { $ds = $parser->ReadDataset() };
      if($@){
        push @errors, "\n\nTrying $x:\n$@";
        next;
      }
      $found_one = 1;
      $file_size = $parser->{file_length};
      $xfr_stx = $parser->{xfrstx};

      last;
    }
    unless($found_one){
      my $this = {
        filename => $infile,
        status => "failed to parse",
        digest => $digest,
        parse_errors => \@errors,
        file_size => $len,
      };
      return bless $this, $class;
    }
    unless($xfr_stx eq "1.2.840.10008.1.2"){
      my $xf_name = $Posda::Dataset::DD->{XferSyntax}->{$xfr_stx}->{name};
      push(@{$parser->{errors}}, 
        "No metaheader with xfr_stx: $xfr_stx ($xf_name)");
    }
  } else {
    $file_size = $parser->{file_length};
    $df = $parser->{metaheader};
    $xfr_stx = $parser->{metaheader}->{xfrstx};
  }
  unless(
    defined($ds) &&
    ref($ds) eq "Posda::Dataset"
  ){
    print STDERR "undefined dataset when one expected for file $infile\n";
    push(@errors, 
      "Error in Posda::Try, undefined dataset returned from parser");
    my $this = {
      filename => $infile,
      status => "internal error",
      digest => $digest,
      parse_errors => \@errors,
      file_size => $len,
    };
    return bless $this, $class;
  }
  my $this = {
    filename => $infile,
    status => "parsed dicom file",
    digest => $digest,
    dataset => $ds,
    file_size => $parser->{file_length},
    xfr_stx => $xfr_stx,
    parser_warnings => $parser->{errors},
  };
  if(defined $df){
    my $res = open FILE, "<", "$infile" or 
      die "WTF?? - couldn't open $infile a second time";
    binmode FILE;
    seek(FILE, $parser->{dataset_start_offset}, 0);
    my $ctx = Digest::MD5->new();
    $ctx->addfile(*FILE);
    close FILE;
    my $ds_digest = $ctx->hexdigest;
    $this->{has_meta_header} = 1;
    $this->{meta_header} = $df;
    $this->{dataset_start_offset} = $parser->{dataset_start_offset};
    $this->{dataset_size} = $parser->{dataset_length};
    $this->{dataset_digest} = $ds_digest;
  } else {
    $this->{has_meta_header} = 0;
    $this->{dataset_digest} = $this->{digest};
  }
  return bless $this, $class;
}
sub DumpMetaHeader{
  my($this, $pr) = @_;
  my $dd = $Posda::Dataset::DD;
  if(exists($this->{meta_header})){
    $pr->print("Part10 Metaheader:\n");
    my $mh = $this->{meta_header}->{metaheader};
    for my $key (sort keys %$mh){
      if($key eq "(0002,0000)") { next }
      if($key eq "(0002,0001)") { next }
      my $value = $mh->{$key};
      $pr->print("$key: \"$value\"");
      if(exists $dd->{SopCl}->{$value}){
        $pr->print(" ($dd->{SopCl}->{$value}->{sopcl_desc})");
      } elsif (exists $dd->{XferSyntax}->{$value}){
        $pr->print(" ($dd->{XferSyntax}->{$value}->{name})");
      }
      $pr->print("\n");
    }
    $pr->print("Dataset:\n");
  } else {
    $pr->print("No metaheader\n");
  }
}
sub DumpWarnings{
  my($this, $pr) = @_;
  unless(exists $this->{parser_warnings}){ return }
  my $errors = $this->{parser_warnings};
  if($errors && ref($errors) eq "ARRAY" && $#{$errors} >= 0){
    $pr->print("Warnings issued during parsing:\n");
    for my $e (@$errors){
      $pr->print("$e\n");
    }
  }
}
1;
