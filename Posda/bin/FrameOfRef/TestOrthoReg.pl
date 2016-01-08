#!/usr/bin/perl -w 
#$Source: /home/bbennett/pass/archive/Posda/bin/FrameOfRef/TestOrthoReg.pl,v $
#$Date: 2011/06/23 15:31:25 $
#$Revision: 1.2 $
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use Cwd;
use Posda::Dataset;
use Posda::Transforms;
use Debug;
my $dbg = sub {print @_};

my $usage = "usage: $0 <file> <register>";
unless($#ARGV == 1) {die $usage}
my $dir = getcwd;
my $file_name = $ARGV[0];
my $reg_name = $ARGV[1];
unless($file_name =~ /^\//) {
	$file_name = "$dir/$file_name";
}

my($df, $ds, $size, $xfr_stx, $errors) = Posda::Dataset::Try($file_name);
unless($ds) { die "$file_name didn't parse" };
my($rdf, $rds, $rsize, $rxfr_stx, $rerrors) = Posda::Dataset::Try($reg_name);
unless($rds) { die "$reg_name didn't parse" };

my $source_for = $ds->Get("(0020,0052)");
my $dest_for = $rds->Get("(0020,0052)");
my $source_ipp = $ds->Get("(0020,0032)");
my $source_iop = $ds->Get("(0020,0037)");

print "Source FOR: $source_for\n";
print "Dest FOR: $dest_for\n";

my $match = $rds->Search("(0070,0308)[<0>](0020,0052)", $source_for);
unless($#{$match} == 0){ die "didn't find one transform" }
my $indx = $match->[0]->[0];
my $xform_type = $rds->Get(
  "(0070,0308)[$indx](0070,0309)[0](0070,030a)[0](0070,030c)");
my $xform = Posda::Transforms::MakeFromDicomXform(
  $rds->Get(
    "(0070,0308)[$indx](0070,0309)[0](0070,030a)[0](3006,00c6)"));

print "Transform Type: $xform_type\n";
print "Transform:\n";
Posda::Transforms::PrintTransform($xform);
my $inv_xform = Posda::Transforms::InvertTransform($xform);
print "InverseTransform:\n";
Posda::Transforms::PrintTransform($inv_xform);

print "Source Iop:\n";
PrintIop($source_iop);
print "Source Ipp:\n";
PrintIpp($source_ipp);

my $x_iopr = Posda::Transforms::ApplyTransform($xform,
  [$source_iop->[0], $source_iop->[1], $source_iop->[2]]);
my $x_iopc = Posda::Transforms::ApplyTransform($xform,
  [$source_iop->[3], $source_iop->[4], $source_iop->[5]]);
my $x_iop = [$x_iopr->[0], $x_iopr->[1], $x_iopr->[2],
            $x_iopc->[0], $x_iopc->[1], $x_iopc->[2]];
print "Transformed IOP:\n";
PrintIop($x_iop);

my $x_ipp = Posda::Transforms::ApplyTransform($xform, $source_ipp);
print "Transformed IPP:\n";
PrintIpp($x_ipp);

my $r_iopr = Posda::Transforms::ApplyTransform($inv_xform,
  [$x_iop->[0], $x_iop->[1], $x_iop->[2]]);
my $r_iopc = Posda::Transforms::ApplyTransform($inv_xform,
  [$x_iop->[3], $x_iop->[4], $x_iop->[5]]);
my $r_iop = [$r_iopr->[0], $r_iopr->[1], $r_iopr->[2],
            $r_iopc->[0], $r_iopc->[1], $r_iopc->[2]];
print "Back Transformed IOP:\n";
PrintIop($r_iop);

my $r_ipp = Posda::Transforms::ApplyTransform($inv_xform, $x_ipp);
print "Back Transformed IPP:\n";
PrintIpp($r_ipp);

sub PrintIop{
  my($iop) = @_;
  printf "%14f\t%14f\t\%14f\n", $iop->[0], $iop->[1], $iop->[2];
  printf "%14f\t%14f\t\%14f\n", $iop->[3], $iop->[4], $iop->[5];
}
sub PrintIpp{
  my($ipp) = @_;
  printf "%14f\t%14f\t\%14f\n", $ipp->[0], $ipp->[1], $ipp->[2];
}
