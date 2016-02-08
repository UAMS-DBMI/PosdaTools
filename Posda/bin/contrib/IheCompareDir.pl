#!/usr/bin/perl -w
#
#Copyright 2013, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use Cwd;
use Posda::Find;
use Posda::Try;
use Posda::UUID;
use Posda::HttpApp::HtmlFileDiff;
use Posda::HttpApp::HttpObj;
use Posda::DataDict;
my $DD = Posda::DataDict->new;
use Debug;
my $dbg = sub {print @_ };
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
    $diffs->render_text_diff($http);
  }
  sub RenderSummary{
    my($this, $http, $dyn) = @_;
    $this->RefreshEngine($http, $dyn, 
      '<http><head><title>Difference Summary</title></head><body>' .
      'Total number of SOP Instance UIDs: <?dyn="echo" field="TotSops"?><br>' .
      'Number only in from directory: <?dyn="echo" field="NumOnlyInFrom"?>' . 
      '<br>' .
      'Number only in to directory: <?dyn="echo" field="NumOnlyInTo"?><br>' .
      'Links to Difference Files:<ul><?dyn="DifferenceLinks"?></ul>' .
      '</body></html>');
  }
  sub DifferenceLinks{
    my($this, $http, $dyn) = @_;
    for my $i (
      sort {
            $dyn->{differences}->{$a}->{class}
          cmp 
            $dyn->{differences}->{$b}->{class}
        or
            $dyn->{differences}->{$a}->{file}
          cmp 
            $dyn->{differences}->{$b}->{file}
      }
      keys %{$dyn->{differences}}
    ){
      my $desc = 
        $DD->{SopCl}->{$dyn->{differences}->{$i}->{class}}->{sopcl_desc};
      $http->queue("<li>" .
        "($desc) <a href=\"file:$dyn->{differences}->{$i}->{file}\">" .
        "$i</a></li>");
    }
  }
}
sub MakeFinder{
  my($from_dir, $info) = @_;
  my $finder = sub {
    my($d) = @_;
    $info->{$d->{mh}->{metaheader}->{"(0002,0003)"}} = {
      file => $d->{file},
      class => $d->{mh}->{metaheader}->{"(0002,0002)"},
    };
  };
  return $finder;
}
my $usage =  "usage: IheRoCompareDir.pl  <from dir> <to dir> " .
  "<results dir>";
unless($#ARGV == 2) { die $usage }
my $cwd = getcwd;
my $from_dir = $ARGV[0];
my $to_dir = $ARGV[1];
my $results_dir = $ARGV[2];
unless($from_dir =~ /^\//) { $from_dir = "$cwd/$from_dir" }
unless(-d $from_dir) { die "$from_dir is not a directory" }
unless($to_dir =~ /^\//) { $to_dir = "$cwd/$to_dir" }
unless(-d $to_dir) { die "$to_dir is not a directory" }
unless($results_dir =~ /^\//) { $results_dir = "$cwd/$results_dir" }
my($results_root, $results_leaf) = $results_dir =~ /(^.+)\/([^\/]+)$/;
unless(-d $results_root) { die "$results_root is not a directory" }
if(-e $results_dir) { die "$results_dir already exists" }
my $count = mkdir($results_dir);
unless($count == 1) { die "couldn't make $results_dir ($!)" }

my %FromInfo;
my %ToInfo;
Posda::Find::MetaHeader($from_dir, MakeFinder($from_dir, \%FromInfo));
Posda::Find::MetaHeader($to_dir, MakeFinder($from_dir, \%ToInfo));
my %AllSops;
my @OnlyInFrom;
my @OnlyInTo;
for my $i (keys %FromInfo){
  $AllSops{$i} = 1;
  unless(exists $ToInfo{$i}) { push @OnlyInFrom, $i }
}
for my $i (keys %ToInfo){
  $AllSops{$i} = 1;
  unless(exists $FromInfo{$i}) { push @OnlyInTo, $i }
}
if(scalar @OnlyInFrom) {
  for my $i (@OnlyInFrom){
    print "$i is only in from directory\n";
  }
}
if(scalar @OnlyInTo) {
  for my $i (@OnlyInTo){
    print "$i is only in from directory\n";
  }
}
my %Changes;
my %diffs;
for my $i (sort keys %FromInfo){
  if(exists $ToInfo{$i}){
    print "Compare:\n\t$FromInfo{$i}->{file}\nto\n\t$ToInfo{$i}->{file}\n";
    my $from_dump = "$results_dir/$i.from.dump";
    my $to_dump = "$results_dir/$i.to.dump";
    `DumpDicom.pl $FromInfo{$i}->{file} >$from_dump`;
    `DumpDicom.pl $ToInfo{$i}->{file} >$to_dump`;
    $Changes{$i} = Posda::HttpApp::HtmlFileDiff->new($from_dump, $to_dump);
    my $hr = HtmlRender->new;
    my $http = Queuer->new("");
    $hr->RenderDiffs($http, {
      from  => $FromInfo{$i}->{file},
      to => $ToInfo{$i}->{file},
      diffs => $Changes{$i},
    });
    open my $fh, ">$results_dir/$i.html"
      or die "Can't open $results_dir/$i.html";
    $http->print($fh);
    close($fh);
    $diffs{$i} = { file => "$i.html", class => $FromInfo{$i}->{class} };
    `rm $from_dump`;
    `rm $to_dump`;
  }
}
my $hr = HtmlRender->new;
my $http = Queuer->new("");

$hr->RenderSummary($http, {
  NumOnlyInFrom => scalar @OnlyInFrom,
  NumOnlyInTo => scalar @OnlyInTo,
  TotSops => scalar keys %AllSops,
  differences => \%diffs,
});
open my $fh, ">$results_dir/index.html";
$http->print($fh);
close $fh;
