#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/include/Posda/HttpApp/DirBrowse.pm,v $
#$Date: 2011/03/07 14:37:16 $
#$Revision: 1.13 $
#
use strict;
use File::Spec;

my $refresh = <<EOF;
<?dyn="html_header"?><?dyn="header"?><?dyn="vol_sel"?><?dyn="enter_path"?><?dyn="browser_body"?>
<?dyn="trailer"?>
EOF
my $html_header = <<EOF;
<!DOCTYPE html
        PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
         "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
<html xmlns="http://www.w3.org/1999/xhtml" lang="en-US" xml:lang="en-US">
<head>
<title>Posda Directory Browser</title>
<meta http-equiv="Content-Type" content="text/html; charset=iso-8859-1" />
</head>
<body>
EOF
my $html_trailer = <<EOF;
</body>
</html>
EOF
my $path_form = <<EOF;
<?dyn="FormHandleAction"?>
<?dyn="CheckPathToFind"?>
<?dyn="TextHandler" name="PathToFind" default="Enter Path"?>
<?dyn="SubmitHandler" caption="Set Path"?>
</form>
EOF
{
  package Posda::HttpApp::DirBrowser;
  use Cwd;
  use vars qw( @ISA );
  @ISA = ( "Posda::HttpObj" );
  sub new {
    my($class, $sess, $path, $root,
       $sel_obj_name, $sel_window_name, $sel_method_name) = @_;
    my $this = Posda::HttpObj->new($sess, $path);
    $this->set_expander($refresh);
    $this->{header} = $html_header;
    $this->{html_trailer} = $html_trailer;
    $this->{sel_obj_name} = $sel_obj_name;
    $this->{sel_window_name} = $sel_window_name;
    $this->{sel_method_name} = $sel_method_name;
    $this->{root} = $root;    
    my($vol, $dirs, $file) = File::Spec->splitpath($root, 1);
    my @dirs = File::Spec->splitdir($dirs);
    $this->{vol} = $vol;
    $this->{dirs} = \@dirs;
    $this->{file} = $file;
    return bless $this, $class;
  }
  sub enter_path{
    my($this, $http, $dyn) = @_;
    $this->RefreshEngine($http, $dyn, $path_form);
  }
  sub CheckPathToFind{
    my($this, $id, $value) = @_;
    unless(defined $this->{PathToFind}){
      $this->{PathToFind} = $this->{root};
    }
  }
  sub PathToFind{
    my($this, $id, $value) = @_;
    unless(($value =~ /^\//) && (-d $value)){
      $this->{PathToFind} = "Invalid Path";
      return;
    }
    $this->{PathToFind} = $value;
    $this->SetVolume("", $value);
  }
  sub vol_sel{
    my($this, $http, $dyn) = @_;
    my($vol, $dirs, $file) = File::Spec->splitpath(getcwd, 1);
    unless($vol){ return }
    my @vols;
    vol:
    for my $i ("A" .. "Z"){
      my $vol_name = "$i:\\";
#      if(-d $vol_name) { push @vols, $vol_name }
      push(@vols, $vol_name);
    }
    $http->queue("<form method=\"POST\" target=\"_top\" " .
      "action=\"HandleForm?obj_path=$this->{path}&amp;" .
      "refresh=DirBrowser\">" .
      "<input type=\"submit\" " .
      "name=\"$this->{path}+NoOp++10\" " .
      "value=\"Set Volume\">" .
      "<select name=\"$this->{path}+SetVolume++0\">");
    for my $i (@vols){
      $http->queue("<option name=\"$i\"");
      if($i eq $this->{root}){
        $http->queue(" selected");
      }
      $http->queue(">$i</option>\n");
    }
    $http->queue("</select></form><br />\n");
  }
  sub header{
    my($this, $http, $dyn) = @_;
    $this->RefreshEngine($http, $dyn, $this->{header});
  }
  sub trailer{
    my($this, $http, $dyn) = @_;
    $this->RefreshEngine($http, $dyn, $this->{html_trailer});
  }
  sub ToggleDirectory{
    my($this, $http, $dyn) = @_;
    my $dir = $dyn->{dir};
    if($this->{OpenDirs}->{$dir}){
      delete $this->{OpenDirs}->{$dir};
    } else {
      $this->{OpenDirs}->{$dir} = 1;
    }
    $this->Refresh($http, $dyn);
  }
  sub SetVolume{
    my($this, $id, $value) = @_;
    $this->{PathToFind} = $value;
    my $root = $value;
    unless(-d $root) { print STDERR "$root is not a directory\n"; return }
    $this->{root} = $root;
    my($vol, $dirs, $file) = File::Spec->splitpath($root, 1);
    my @dirs = File::Spec->splitdir($dirs);
    $this->{vol} = $vol;
    $this->{dirs} = \@dirs;
    $this->{file} = $file;
    if(
      $#{$this->{dirs}} == 1 &&
      $this->{dirs}->[0] eq "" &&
      $this->{dirs}->[1] eq ""
    ){
      $this->{dirs} = [""];
    }
  }
  sub SetRoot{
    my($this, $http, $dyn) = @_;
    my $root = $dyn->{root};
    $this->SetVolume("", $root);
    $this->Refresh($http, $dyn);
  }
  sub browser_body{
    my($this, $http, $dyn) = @_;
    my $max_depth = 10;
    my $stack = [];
    my $cur_depth = 0;
    my $root = $this->{root};
    ###
    my $target = "";
    my $action = "SelectPath";
    my @dirs;
    ###
    $http->queue("<table>");
    my $colsp = $max_depth - $cur_depth;
    $http->queue(
      "<tr><td colspan=\"$max_depth\"><small><a target=\"Browser\" " .
      "href=\"ToggleDirectory?obj_path=$this->{path}&amp;dir=$this->{root}\">" .
      (($this->{OpenDirs}->{$this->{root}})?"[&minus;]</a> " : "[+]</a> ") );
    for my $i (0 .. $#{$this->{dirs}}){
      push(@dirs, $this->{dirs}->[$i]);
      my($method, $dir, $text, $target, $obj);
      if($i == 0) {
        my $ref_path = File::Spec->catpath($this->{vol}, 
          File::Spec->catdir(@dirs), '');
        $text = "[$ref_path]";
        if($#{$this->{dirs}} == 0){
          $target = "Info";
          $method = $this->{sel_method_name};
          $dir = $ref_path;
        } else {
          $target = "Browser";
          $method = "SetRoot";
          $dir = $ref_path;
        }
      } elsif($i == $#{$this->{dirs}}) {
        my $ref_path = File::Spec->catpath($this->{vol}, 
          File::Spec->catdir(@dirs), '');
        $method = $this->{sel_method_name};
        $dir = $ref_path;
        $target = "Info";
        $text = $this->{dirs}->[$i];
      } else {
        my $ref_path = File::Spec->catpath($this->{vol}, 
          File::Spec->catdir(@dirs), '');
        $method = "SetRoot";
        $dir = $ref_path;
        $text = $this->{dirs}->[$i];
        $target = "Browser";
      }
      if($method eq "SetRoot"){
        $this->MakeLinkDyn($http, {
          target => $target,
          method => "SetRoot",
          caption => $text,
          root => $dir,
        });
      } elsif($method eq $this->{sel_method_name}){
        my $obj = $this->get_obj($this->{sel_obj_name});
        $obj->MakeLinkDyn($http, {
           target => $target,
           method => $this->{sel_method_name},
           caption => $text,
           dir => $dir,
        });
      }
      unless($i == $#{$this->{dirs}} || $i == 0){
        $http->queue(" / ");
      }
    }
    $http->queue("</small></td></tr>");
    my $subs = [];
    opendir DIR, $root;
    while(my $sub = readdir(DIR)){
      if($sub eq '.' || $sub eq '..') { next }
      if($sub =~ /^\./) { next } unless(-d "$root/$sub") { next }
      if($root =~ /\/$/){
        push(@$subs, [$sub, "$root$sub"]);
      } else {
        push(@$subs, [$sub, "$root/$sub"]);
      }
    }
    $subs = [ sort {$a->[0] cmp $b->[0]} @$subs ];
    close DIR;
    if($this->{OpenDirs}->{$root}) {
      subdirs:
      while(1){
        my $this_dir = shift(@$subs);
        unless($this_dir){
          unless($#{$stack} >= 0){
            last subdirs;
          }
          my $temp = pop(@$stack);
          $subs = $temp->[0];
          $cur_depth = $temp->[1];
          next subdirs;
        }
        $http->queue("<tr>" .
          "<td><small><a target=\"Browser\" " .
          "href=\"ToggleDirectory?obj_path=$this->{path}" . 
          "&amp;dir=$this_dir->[1]\"" .
          ">" .
          (($this->{OpenDirs}->{$this_dir->[1]})?"[&minus;]" : "[+]") .
          "<a>\n</small></td>"
        );
        for my $i (0 .. $cur_depth){ $http->queue("<td>&nbsp;</td>") };
        my $csp = $max_depth - $cur_depth;
        my $obj = $this->get_obj($this->{sel_obj_name});
        $http->queue("<td colspan=\"$csp\"><small>");
        $obj->MakeLinkDyn($http, {
          target => "Info",
          method => $this->{sel_method_name},
          dir => $this_dir->[1],
          caption => $this_dir->[0]
        });
        $http->queue(" [\n");
        $this->MakeLinkDyn($http, {
           target => "Browser",
           method => "SetRoot",
           root => $this_dir->[1],
           caption => " ^ ",
        });
        $http->queue(" ]</small></td>" .
          "</tr>");
        if($this->{OpenDirs}->{$this_dir->[1]}){
          push(@$stack, [$subs, $cur_depth]);
          $cur_depth += 1;
          my @subsubs;
          unless(opendir DIR, "$this_dir->[1]"){
            print "opendir failed on \"$this_dir->[1]\"\n";
          }
          while (my $subsub = readdir(DIR)){
            if($subsub eq '.' || $subsub eq '..') { next }
            unless(-d "$this_dir->[1]/$subsub") { next }
            push(@subsubs, [$subsub, "$this_dir->[1]/$subsub"]);
          }
          close DIR;
#          $subs = \@subsubs;
          $subs = [ sort {$a->[0] cmp $b->[0]} @subsubs ];
        }
      }
    }
    $http->queue("</table>");
    $http->queue("<hr>\n");
  }
}
1;
