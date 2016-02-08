#!/usr/bin/perl -w
#
#Copyright 2010, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
#####################
use strict;
package Posda::HttpApp::StructToHtml;
use Posda::HttpApp::GenericIframe;
my $content = <<EOF;
EOF
use vars qw( @ISA );
@ISA = ( "Posda::HttpApp::GenericIframe" );
sub new {
  my($class, $session, $path) = @_;
  my $this = Posda::HttpApp::GenericIframe->new($session, $path);
  bless $this, $class;
  return $this;
}
sub Content{
  my($this, $http, $dyn) = @_;
  $this->RefreshEngine($http, $dyn, $content);
}
sub DumpHtml{
  my($this, $q, $title, $struct, $path) = @_;
  my $indent = 0;
  unless(defined $this->{depth}->{$title}){ $this->{depth}->{$title} = 0 }
  $q->queue("[$this->{depth}->{$title} " .
    "<a href=\"IncDepth?obj_path=$this->{path}&amp;title=$title\">+</a> " .
    "<a href=\"DecDepth?obj_path=$this->{path}&amp;title=$title\">-</a>] ");
  $q->queue("\$root->{\"".
    "<a href=\"SetRootPath?obj_path=$this->{path}&amp;title=$title\">" .
    "$title</a>\"}");
  my $where = $struct;
  my $url_path = "";
  for my $i (0 .. $#{$path}){
    my $cp = $path->[$i];
    if($url_path ne "") { $url_path .= "|$cp" } else {$url_path = $cp}
    if(
      ref($where) eq "ARRAY" ||
      (IsBlessed($where) && $where->isa("ARRAY"))
    ){
      $q->queue("->[<a href=\"SetSelectedPath?" .
        "obj_path=$this->{path}&amp;path=$url_path&amp;title=$title\">" .
        "$cp</a>]");
      $where = $where->[$cp];
    } elsif (
      ref($where) eq "HASH" ||
      (IsBlessed($where) && $where->isa("HASH"))
    ){
      $q->queue("->{<a href=\"SetSelectedPath?" .
        "obj_path=$this->{path}&amp;path=$url_path&amp;title=$title\">" .
        "$cp</a>}");
      $where = $where->{$cp};
    } else {
      $q->queue("ERROR - not an ARRAY or HASH\n");
      return;
    }
  }
  $q->queue(" = ");
  $this->DumpHtmlStruct($q, $where, $title, 
    $url_path, 0, $this->{depth}->{$title});
  $q->queue("\n\n");
}
sub DumpHtmlStruct{
  my($this, $q, $where, $title ,$path, $indent, $depth) = @_;
  my $ref = ref($where);
  if($depth <= 0){
    if($ref eq ""){
      unless(defined $where){ $where = "" }
      QueueNonHtmlText($q, "\"$where\"");
    } else {
      $q->queue("-<a href=\"" .
        "SetSelectedPath?obj_path=$this->{path}&amp;path=$path" .
        "&amp;title=$title\">" .
        "$ref<a>-");
    }
    return;
  }
  if(
    ref($where) eq "ARRAY" ||
    (IsBlessed($where) && $where->isa("ARRAY"))
  ){
    $q->queue("[\n");
    for my $i (0 .. $#{$where}){
      my $new_path = $path eq "" ? $i : "$path|$i";
      my $new_indent = $indent + 1;
      QueueHtmlText($q, "  " x $new_indent . "<a href=\"" .
        "SetSelectedPath?obj_path=$this->{path}&amp;path=$new_path" .
        "&amp;title=$title\">");
      QueueNonHtmlText($q,"$i:");
      QueueHtmlText($q,"</a> ");
      $this->DumpHtmlStruct($q, 
        $where->[$i], $title, $new_path, $new_indent, $depth - 1);
      if($indent == 0){
        QueueHtmlText($q, "\n");
      } else {
        QueueHtmlText($q, ",\n");
      }
    }
    QueueHtmlText($q, "  " x $indent . "]");
  } elsif(
    ref($where) eq "HASH" ||
    (IsBlessed($where) && $where->isa("HASH"))
  ){
    $q->queue("{\n");
    for my $i (sort keys %$where){
      my $new_path = $path eq "" ? $i : "$path|$i";
      my $new_indent = $indent + 1;
      QueueHtmlText($q, "  " x $new_indent . 
        "<a href=\"SetSelectedPath?obj_path=$this->{path}&amp;path=$new_path" .
        "&amp;title=$title\">");
      QueueNonHtmlText($q,"$i");
      QueueHtmlText($q,"</a> => ");
      $this->DumpHtmlStruct($q, 
        $where->{$i}, $title, $new_path, $new_indent, $depth - 1);
      if($indent == 0){
        QueueHtmlText($q, "\n");
      } else {
        QueueHtmlText($q, ",\n");
      }
    }
    QueueHtmlText($q, "  " x $indent . "}");
  } elsif($ref =~ "CODE" ){
    my $at = main::coderef2where($where);
    QueueNonHtmlText($q, "$ref at $at");
  } elsif($ref eq "" ){
    unless(defined $where) { $where = "" }
    QueueNonHtmlText($q, "\"$where\"");
  } else {
    QueueNonHtmlText($q, $ref);
  }
}
sub IncDepth{
  my($this, $http, $env) = @_;
  my $title = $env->{title};
  $this->{depth}->{$title} += 1;
  $this->Refresh($http, $env);
}
sub DecDepth{
  my($this, $http, $env) = @_;
  my $title = $env->{title};
  $this->{depth}->{$title} -= 1;
  $this->Refresh($http, $env);
}
sub SetSelectedPath{
  my($this, $http, $env) = @_;
  my $title = $env->{title};
  my @path = split(/\|/, $env->{path});
  $this->{selected_path}->{$title} = \@path;
  $this->Refresh($http, $env);
}
sub SetRootPath{
  my($this, $http, $env) = @_;
  my $title = $env->{title};
  $this->{selected_path}->{$title} = [];
  $this->Refresh($http, $env);
}
sub IsBlessed {
  my($var) = @_;
  my $builtin = {
    CODE => 1,
    ARRAY => 1,
    SCALAR => 1,
    REF => 1,
    HASH => 1,
    GLOB => 1
  };
  if(ref($var) eq "" || exists($builtin->{ref($var)})){
    return 0;
  }
  return 1;
}
sub QueueNonHtmlText{
  my($q, $text) = @_;
  $text =~ s/\n/\\n/g;
  $text =~ s/\@/\\@/g;
  $text =~ s/&/&amp;/g;
  $text =~ s/</&lt;/g;
  $text =~ s/>/&gt;/g;
  $q->queue($text);
}
sub QueueHtmlText{
  my($q, $text) = @_;
  $text =~ s/\@/\\@/g;
  $q->queue($text);
}

1;
