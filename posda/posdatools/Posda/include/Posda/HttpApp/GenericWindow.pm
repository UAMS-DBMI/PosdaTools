#!/usr/bin/perl -w
#
use strict;
{
  package Posda::HttpApp::GenericWindow;
my $content = <<EOF;
<?dyn="Header"?>
<body <?dyn="_QueueBGColor"?>>
<?dyn="Content"?>
<?dyn="Footer"?>
EOF
my $Content = <<EOF;
<table width=100%><tr><td align="right" valign="top">
<small>
<a href="DeleteCloseWindow?obj_path=<?dyn="q_path"?>">close</a>
</small>
</td></tr></table>
<small>
class: <?dyn="class"?><br>
obj: <?dyn="q_path"?><br>
</small>
EOF
  use vars qw( @ISA );
  @ISA = ( "Posda::HttpObj" );
  sub new{
    my($class, $sess, $path) = @_;
    my $this = Posda::HttpObj->new($sess, $path);
    $this->set_expander($content);
    $this->{h} = 640;
    $this->{w} = 480;
    $this->{url} = "Refresh?obj_path=$path";
    $this->{title} = "Generic Window (please set title)";
    bless $this, $class;
    Dispatch::Select::Background->new($this->MakeInitializer)->queue;
    return $this;
  }
  sub class{
    my($this, $http, $dyn) = @_;
    my $class = ref($this);
    $http->queue($class);
  }
  sub ReOpenFile{
    my($this) = @_;
    # print "GenericMfWindow: ReOpenFile called: path: $this->{path}.\n";
    # print "  $this->{url}, $this->{w}, $this->{h}.\n";
    my $parent = $this->parent;
    unless(defined $parent){
      # print "GenericMfWindow: ReOpenFile called, no parent.\n";
      my $controller = $this->Controller;
      unless (defined $controller) {
        print STDERR 
          "$this->{path}::ReOpenFile Error: no parent or controller.\n";
        my($package, $filename, $line, $subroutine, $hasargs,
        $wantarray, $evaltext, $is_require, $hints, $bit_mask);
        for my $i (1 .. 20){
          ($package, $filename, $line, $subroutine, $hasargs,
          $wantarray, $evaltext, $is_require, $hints, $bit_mask) = caller($i);
          unless (defined $filename) { last; }
          print STDERR "\tfrom:$filename, $line\n";
        }
      } else {
        $controller->RefreshParent;
      }
      return;
    }
    my $controller = $this->parent->Controller;
    unless(defined $controller){
    print STDERR "$this->{path}::ReOpenFile Error: Controller not defined.\n";
      my($package, $filename, $line, $subroutine, $hasargs,
      $wantarray, $evaltext, $is_require, $hints, $bit_mask);
      for my $i (1 .. 20){
        ($package, $filename, $line, $subroutine, $hasargs,
        $wantarray, $evaltext, $is_require, $hints, $bit_mask) = caller($i);
        unless (defined $filename) { last; }
        print STDERR "\tfrom:$filename, $line\n";
      }
      return;
    }
    # print "GenericMfWindow: ReOpenFile using parent controller to open window.\n";
    $controller->AddChildWindow($this->{path},
      {
        url => $this->{url},
        w => $this->{w},
        h => $this->{h},
      }
    );
  }
  sub AutoRefresh{
    my($this) = @_;
    $this->ReOpenFile();
  }
  sub CloseWindow{
    my($this) = @_;
    $this->{HttpObjTimeToCloseWindow} = 1;
    my $parent = $this->parent;
    if($parent && $parent->can("AutoRefresh")){
      $parent->AutoRefresh;
    }
    $this->AutoRefresh;
  }
  sub DESTROY{
    my($this) = @_;
    $this->delete_children();
    Posda::HttpObj::DESTROY($this);
  }
  ## override for initializer
  sub Initialize{
    my($this) = @_;
  }
  ## override for content
  sub Content{
    my($this, $http, $dyn) = @_;
    print STDERR "Posda::HttpApp::GenericWindow: Content called.\n" .
      "  The Content routine should be overridden " .
      "by the object: $this->{path}.\n";
    $this->RefreshEngine($http, $dyn, $Content);
  }
}
1;
