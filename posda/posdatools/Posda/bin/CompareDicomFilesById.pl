#!/usr/bin/perl -w
#
#Copyright 2013, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use Cwd;
use Posda::HttpApp::HtmlFileDiff;
use Posda::HttpApp::HttpObj;
use Posda::DB 'Query';
use File::Temp qw( tempdir );
use Debug;
my $dbg = sub {print STDERR @_ };
use strict;
{
  package Queuer;
  sub new{
      my($class, $text) = @_;
      my $this = { text => [$text] };
      return bless $this, $class;
  } 
  sub queue{
    my($this, $text) = @_;
    push(@{$this->{text}}, $text);
  }
  sub print{
    my($this, $fh) = @_;
    for my $i (@{$this->{text}}){
      print $fh $i;
    }
  }
}
{
  package HtmlRender;
  use vars qw( @ISA );
  @ISA = qw( Posda::HttpObj );
  sub new{
    my($class) = @_;
    my $this = { 
    };
    return bless $this, $class;
  };
  sub RenderDiffs{
    my($this, $http, $dyn) = @_;
    $this->RefreshEngine($http, $dyn,
      '<html><head><title>Dicom File Differences</title></head><body>' .
      "<h3>Differences Between Dicom Files</h3>" . 
      "<ul><li>From: ($dyn->{from_file_id}) $dyn->{from}</li>" .
      "<li>To: ($dyn->{to_file_id}) $dyn->{to}</li></ul>" .
      '<hr>' .
      '<?dyn="RenderLinks"?>' .
      '<?dyn="RenderDifferences"?>' .
      '<hr></body></html>'
    );
  }
  sub RenderLinks{
    my($this, $http, $dyn) = @_;
    my $diffs = $dyn->{diffs};
    $diffs->render_obj_links("", $http);
  }
  sub RenderDifferences{
    my($this, $http, $dyn) = @_;
    my $diffs = $dyn->{diffs};
    $diffs->render_text_diff($http, 1);
  }
}
my $usage =  "usage: CompareDicomFilesById.pl  <from file_id> <to file_id> " .
  "<tmpdir> <results_file>\n";
unless($#ARGV == 3) { die $usage }
my $cwd = getcwd;
my $from_file_id = $ARGV[0];
my $to_file_id = $ARGV[1];
my $tmpdir = $ARGV[2];
my $results_file = $ARGV[3];
my($from_file, $to_file);
Query('GetFilePath')->RunQuery(sub {
  my($row) = @_;
  $from_file = $row->[0];
}, sub{}, $from_file_id);
Query('GetFilePath')->RunQuery(sub {
  my($row) = @_;
  $to_file = $row->[0];
}, sub{}, $to_file_id);
my $from_dump = "$tmpdir/DumpFrom.txt";
my $to_dump = "$tmpdir/DumoTo.txt";
unless($from_file =~ /^\//) { $from_file = "$cwd/$from_file" }
unless(-f $from_file) { die "$from_file is not a file" }
unless($to_file =~ /^\//) { $to_file = "$cwd/$to_file" }
unless(-f $to_file) { die "$to_file is not a file" }
my $cmd = "DumpDicom.pl $from_file >$from_dump";
open FOO, "$cmd|";
while(my $line = <FOO>){
  chomp $line;
  print STDERR "Error from dumping from: $line\n";
}
close FOO;
$cmd = "DumpDicom.pl $to_file >$to_dump";
open FOO, "$cmd|";
while(my $line = <FOO>){
  chomp $line;
  print STDERR "Error from dumping to: $line\n";
}
close FOO;

my $Changes = Posda::HttpApp::HtmlFileDiff->new($from_dump, $to_dump);
print STDERR "Changes: ";
Debug::GenPrint($dbg, $Changes, 1);
print STDERR "\n";

my $hr = HtmlRender->new;
my $http = Queuer->new("");
$hr->RenderDiffs($http, {
  from  => $from_file,
  to => $to_file,
  from_file_id => $from_file_id,
  to_file_id => $to_file_id,
  diffs => $Changes,
});
print "Results file: $results_file\n";
if($results_file){
  open my $fh, ">$results_file"
    or die "Can't open $results_file";
  $http->print($fh);
  close($fh);
} else {
  $http->print(\*STDOUT);
}
