#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/bin/contrib/IheDumpFile.pl,v $
#$Date: 2014/02/19 13:34:12 $
#$Revision: 1.3 $
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
use Posda::DicomHighlighter;
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
  @ISA = qw( Posda::HttpObj Posda::DicomHighlighter);
  sub new{
    my($class, $file) = @_;
    my $this = { 
      file_path => $file,
    };
    return bless $this, $class;
  };
  sub RenderDiffs{
    my($this, $http, $dyn) = @_;
    $this->RefreshEngine($http, $dyn,
      "<html><head><title>Differences</title></head><body>\n" .
      "Dump of file: $dyn->{from}\n" .
      "<hr>\n<pre>" .
      '<?dyn="Dump"?></pre>' .
      '<hr></body></html>'
    );
  }
  sub Dump{
    my($this, $http, $dyn) = @_;
    my $res = open DUMP, "DumpDicom.pl \"$this->{file_path}\"|";
    unless($res) {
      print STDERR "Can't open DumpDicom.pl \"$this->{file_path}\"| : $!\n";
      $http->queue("Open is returning $!\n");
      return;
    }
    my $in_dataset = 0;
    my $last_sig = "";
    my $at_end = 0;
    line:
    while(my $line = <DUMP>){
      $line =~ s/</&lt;/g;
      $line =~ s/>/&gt;/g;
      if($line =~ /^No meta/){
        $in_dataset = 1;
        $last_sig = "";
        next line;
      }
      if($line =~ /^Dataset:/){
        $in_dataset = 1;
        $last_sig = "";
        $http->queue($line);
        next line;
      }
      unless($in_dataset) {
         if($at_end) {
           $http->queue($line);
           next line;
         } else {
           $http->queue($line);
           next line;
         }
      }
      if($line =~/^Errors encountered/) {
        $at_end = 1;
        $in_dataset = 0;
        $http->queue($line);
        next line;
      };
      if($line =~/^\(/){
        my @fields = split(/:/, $line);
        my $new_field_0 = $this->Highlighter($fields[0], $last_sig);
        $last_sig = $fields[0];
        $fields[0] = $new_field_0;
        $line = join(":", @fields);
      }
      $http->queue($line);
    }
    close DUMP;
  }
}
my $usage =  "usage: IheDumpFile.pl  <file> [<results_file>]";
unless($#ARGV == 0 || $#ARGV == 1) { die $usage }
my $cwd = getcwd;
my $file = $ARGV[0];
my $results_file = $ARGV[1];
unless($file =~ /^\//) { $file = "$cwd/file" }
unless(-f $file) { die "$file is not a file" }
if($results_file){
unless($results_file =~ /^\//) { $results_file = "$cwd/$results_file" }
  my($results_root, $results_leaf) = $results_file =~ /(^.+)\/([^\/]+)$/;
  unless(-d $results_root) { die "$results_root is not a directory" }
  if(-e $results_file) { die "$results_file already exists" }
}

my $hr = HtmlRender->new($file);
my $http = Queuer->new("");
$hr->RenderDiffs($http, {
  from  => $file,
  to => $file,
});
if($results_file){
  open my $fh, ">$results_file"
   or die "Can't open $results_file";
 $http->print($fh);
 close($fh);
} else {
 $http->print(\*STDOUT);
}
