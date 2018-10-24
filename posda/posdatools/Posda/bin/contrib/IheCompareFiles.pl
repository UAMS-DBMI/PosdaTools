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
#use Debug;
#my $dbg = sub {print STDERR @_ };
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
      '<html><head><title>Differences</title></head><body>' .
      "Difference<ul><li>From: $dyn->{from}</li>" .
      "<li>To: $dyn->{to}</li></ul>" .
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
my $usage =  "usage: IheCompareFiles.pl  <from file> <to file> " .
  "[<results file>]\n";
unless($#ARGV == 2 || $#ARGV ==1) { die $usage }
my $cwd = getcwd;
my $from_file = $ARGV[0];
my $to_file = $ARGV[1];
my $results_file = $ARGV[2];
unless($from_file =~ /^\//) { $from_file = "$cwd/$from_file" }
unless(-f $from_file) { die "$from_file is not a file" }
unless($to_file =~ /^\//) { $to_file = "$cwd/$to_file" }
unless(-f $to_file) { die "$to_file is not a file" }
if($results_file){
  unless($results_file =~ /^\//) { $results_file = "$cwd/$results_file" }
  my($results_root, $results_leaf) = $results_file =~ /(^.+)\/([^\/]+)$/;
  unless(-d $results_root) { die "$results_root is not a directory" }
  if(-e $results_file) { die "$results_file already exists" }
}

my $Changes = Posda::HttpApp::HtmlFileDiff->new($from_file, $to_file);
#print STDERR "Changes: ";
#Debug::GenPrint($dbg, $Changes, 1);
#print STDERR "\n";

my $hr = HtmlRender->new;
my $http = Queuer->new("");
$hr->RenderDiffs($http, {
  from  => $from_file,
  to => $to_file,
  diffs => $Changes,
});
if($results_file){
  open my $fh, ">$results_file"
    or die "Can't open $results_file";
  $http->print($fh);
  close($fh);
} else {
  $http->print(\*STDOUT);
}
