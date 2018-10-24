#!/usr/bin/perl -w
#
use strict;
package Posda::HttpApp::GenericIframe;
use vars qw( @ISA );
@ISA = ( "Posda::HttpObj" );
my $content = <<EOF;
<?dyn="Header"?>
<body  <?dyn="_QueueBGColor"?>>
<?dyn="Content"?>
<?dyn="Footer"?>
EOF
sub new {
  my($class, $sess, $path)  = @_;
  my $this = Posda::HttpObj::new($class, $sess, $path);
  $this->GIFrame_Init;
  Dispatch::Select::Background->new($this->MakeInitializer)->queue;
  return $this;
}
sub GIFrame_Init{
  my($this) = @_;
  $this->{expander} = $content;
}
sub Initialize{
  my($this) = @_;
  #  override for initialization
}
sub class{
  my($this, $http, $dyn) = @_;
  my $class = ref($this);
  $http->queue($class);
}
sub Content{
  # override for content
  my($this, $http, $dyn) = @_;
  my $class = ref($this);
  $http->queue("<p>Generic iframe ($class)</p>");
  $http->queue("<p>Developer: please override routine Content " .
               "in object: $this->{path}</p>");
}
sub AutoRefresh{
  my($this) = @_;
  my $controller = $this->Controller;
  if (defined $controller) { $controller->RefreshFrame($this->{path}); }
  else {
    my $foo = $this->get_obj($this->{path});
    unless($foo) {
       print STDERR "Augh!!  Autorefresh when I've already been removed!!!\n";
       my $text = $this->TraceBack;
       print STDERR "$text\n";
    }
    my $class = ref($this);
    print STDERR "no Controller in GenericIframe::AutoRefresh\n" .
      "\tpath: $this->{path}\n" .
      "\tclass: $class\n";
  }
}
sub CloseWindow{
  my($this) = @_;
  $this->parent->CloseWindow;
}
1;
