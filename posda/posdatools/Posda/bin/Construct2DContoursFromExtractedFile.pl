#!/usr/bin/perl -w
#
# Input Structure:
#<STDIN> = [
#  {
#    type => "2dContourBatch",
#    pix_sp_x => <pix_sp_x>,
#    pix_sp_y => <pix_sp_y>,
#    x_shift => <x_shift>, (optional)
#    y_shift => <y_shift>, (optional)
#    color => <color>,
#    file => <2d Contours File>,
#  },
#  ...
#];
#<2d Contour File> is format produced by BitmapToContours:
#  BEGIN
#  <x>, <y>,
#  ...
#  END
#  ...
#  <eof>
use strict;
use JSON;
use Storable qw( store_fd fd_retrieve );
use Posda::FlipRotate;
use Debug;
$| = 1;
my $dbg = sub {print STDERR @_ };
my $to_do = fd_retrieve(\*STDIN);
my @Contours;
unless(ref($to_do) eq "ARRAY"){
  die "Instructions are not a list";
}
inst:
for my $i (@$to_do){
  if($i->{type} eq "2dContourBatch"){
    Process2dContourBatch($i, \@Contours)
  } else {
    print STDERR "Construct2DContoursFromExtractedFile.pl: " .
      "Unknown type $i->{type}\n";
  }
}
my $json = JSON->new();
#$json->pretty(0);
#my $json_text = $json->encode(\@Contours);
#print STDERR "Json text: $json_text\n";
#$json->pretty(0);
print $json->encode(\@Contours);
exit(0);
sub Process2dContourBatch{
  my($desc, $Contours) = @_;
  my $file = $desc->{file};
  my $color = $desc->{color};
  my $id = $desc->{id};
  my $pix_sp_x = $desc->{pix_sp_x};
  my $pix_sp_y = $desc->{pix_sp_y};
  my $x_shift = 0;
  my $y_shift = 0;
  if(exists $desc->{x_shift}) { $x_shift = $desc->{x_shift} }
  if(exists $desc->{y_shift}) { $y_shift = $desc->{y_shift} }
  my @contours;
  open my $fh, "<$file" or return;
  my $state = "BEGIN_Search";
  my $contour = [];
  while (my $line = <$fh>){
    chomp $line;
    if($state eq "BEGIN_Search"){
      if($line eq "BEGIN"){
        $state = "END_Search";
      } else {
        die "Should have seen a BEGIN or EOF here";
      }
    } elsif($state eq "END_Search"){
      if($line eq "END"){
        push(@contours, $contour);
        $contour = [];
        $state = "BEGIN_Search";
      } elsif ($line =~ /^(.*),\s*(.*)$/){
        my $x = $1;
        my $y = $2;
        push @{$contour}, [($x + $x_shift)/$pix_sp_x,
          ($y + $y_shift)/$pix_sp_y];
      } else {
        die "Couldn't make sense of line: $line";
      }
    }
  }
  for my $c (@contours){
    push(@$Contours,{
      id => $id,
      color => "#$color",
      points => $c,
    });
  }
}
1;
