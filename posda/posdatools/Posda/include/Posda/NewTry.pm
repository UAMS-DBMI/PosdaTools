#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
package Posda::NewTry;
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
  my($class, $infile) = @_;
  my($digest, $len) = $class->GetDigestAndLength($infile);
  return new_with_digest_and_length($class, $infile, $digest, $len);
}
sub new_with_digest_and_length{
  my($class, $infile, $digest, $len) = @_;
  my $df;
  my $ds;
  my $file_size;
  my $ds_size;
  my $xfr_stx;
  my @errors;
  
  my $parser ;
  eval {
     $parser = Posda::Parser->new(
      dd => $Posda::Dataset::DD,
      from_file => $infile,
    );
  };
  if($@){
    my $cmd = "file \"$infile\"";
    open FILE, "$cmd|";
    my @lines;
    while (my $line = <FILE>){
      chomp $line;
      push @lines, $line;
    }
    my $file_resp = $lines[0];
    my $file_type;
    my $act_file;
    if($file_resp =~ /^(.*): (.*)$/){
      $act_file = $1;
      $file_type = $2;
    }
    return {
      file_name => $infile,
      act_file => $act_file,
      file_type => $file_type,
      length => $len,
      digest => $digest
    };
  }
  unless(defined $parser->{metaheader}){ die "No metaheader in default parser" }
  my $this;
  eval {
    $parser->{skip_large} = 64;
    $ds = $parser->ReadDataset();
  };
  if($@){
    push(@errors, "Part 10 file with bad dataset: $@");
    $this = {
      metaheader => $parser->{metaheader},
      filename => $infile,
      status => "DICOM file - failed to parse",
      parse_errors => \@errors,
      digest => $digest,
      file_size => $len,
    };
  } else {
    $this = {
      metaheader => $parser->{metaheader},
      filename => $infile,
      status => "parsed dicom file",
      digest => $digest,
      dataset => $ds,
      file_size => $parser->{file_length},
      xfr_stx => $xfr_stx,
      parser_warnings => $parser->{errors},
    };
  }
  return bless $this, $class;
}
1;
