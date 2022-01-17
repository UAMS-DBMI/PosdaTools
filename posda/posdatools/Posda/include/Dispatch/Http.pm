#!/usr/bin/perl -w

use strict;
use Dispatch::Select;
use Dispatch::Acceptor;
use Dispatch::Queue;
use File::Find;
use Errno qw(EINTR EIO :POSIX);
use Debug;

#package Dispatch::Http;
{
  package Dispatch::Http::Connection;
  # use Time::HiRes;
  # use Time::Format qw( %time );
  # my $Dispatch::Http::Connection::now = 0;
  # my $Dispatch::Http::Connection::then = 0;
  sub new {
    my($class, $socket, $handler) = @_;
    my $this = {
      socket => $socket,
      handler => $handler,
    };
    bless $this, $class;
    if($ENV{POSDA_DEBUG}){
      print "NEW: $this\n";
    }
    return $this;
  }
  sub CreateResponseReader{
    my($this, $socket) = @_;
    my $output_queue = Dispatch::Queue->new(5, 2);
    $this->{output_queue} = $output_queue;
    $this->{output_queue}->CreateQueueEmptierEvent($socket);
  }
  my $null_count = 1;
  sub CreateHeaderReader{
    my($this, $socket) = @_;
if($this->{DebugHeaderReader}){
print STDERR "CreateHeaderReader called\n";
}
    my $buff = "";
    my $count = 0;
    my $foo = sub {
      my($disp, $sock) = @_;
      my $inp;
      while ($inp = sysread $sock, $buff, 1, $count){
        unless($inp == 1){ 
          print STDERR "socket closed prematurely\n";
          $disp->Remove("reader");
          return;
        }
        $count += 1;
        if($buff =~ /^(.*)\n$/s){
          chomp $buff;
          $buff =~ s/\r//g;
          if($buff eq ""){
            $this->{output_queue}->set_identifier($this->{header_lines}->[0]);
            &{$this->{handler}}($this);
            $disp->Remove("reader");
            return;
          }
          push(@{$this->{header_lines}}, $buff);
          $buff = "";
          $count = 0;
        }
      }
      if(defined $inp && $inp == 0 && defined($!)){
        #print STDERR "Read 0 bytes but defined error: \"$!\"\n";
      } else {
        print STDERR "Read $inp bytes Error: \"$!\"\n";
      }
      unless($inp){
        if($! == &Errno::EAGAIN){
print STDERR "Eagain\n";
          return;
        }
        if($! == &Errno::EWOULDBLOCK){
print STDERR "Ewouldblock\n";
          return;
        }
        if($null_count > 50){
          print STDERR "socket closed prematurely (x 50)\n";
          $null_count = 0;
        }
        $null_count += 1;
        $disp->Remove("reader");
        return;
      }
    };
    my $disp = Dispatch::Select::Socket->new($foo, $socket);
    $disp->Add("reader");
  }
  sub ParseIncomingHeader{
    my($http) = @_;
    for my $i (1 .. $#{$http->{header_lines}}){
      my $line = $http->{header_lines}->[$i];
      if($line =~ /^([^:]+):\s*(.*)\s*$/){
        my $key = $1;
        my $value = $2;
        $key =~ tr/A-Z\-/a-z_/;
        $http->{header}->{$key} = $value;
      }
    }
  }
  sub NotFound{
    my($http, $message, $uri) = @_;
      my $queue = $http->{output_queue};
      delete $http->{output_queue};
      $http->HeaderSent;
      $queue->queue("HTTP/1.0 404 Not found\n\n");
      $queue->queue("$message $uri not found");
      $queue->finish();
  }
  sub NotLoggedIn{
    my($http, $uri, $sess_id) = @_;
      my $queue = $http->{output_queue};
      my $host = $http->{header}->{host};
      delete $http->{output_queue};
      $http->HeaderSent;
      $queue->queue("HTTP/1.0 200 OK\ncontent-type: text/html\n\n");
      $queue->queue("<html><head><title>Not logged in</title></head>");
      $queue->queue("<body><h3>Not logged in</h3><p>");
      $queue->queue("There is no session $sess_id.  Perhaps you logged out, ");
      $queue->queue("or perhaps your session timed out.</p>");
      $queue->queue("<p>Try <a target=\"_top\" ");
      $queue->queue("href=\"https://$host/posda\">");
      $queue->queue("returning</a> to the root of the server.</p>");
      $queue->queue("</body></html>");
      $queue->finish();
  }
  sub NotLoggedInApp{
    my($http, $uri, $sess_id) = @_;
    my $queue = $http->{output_queue};
    my $host = $http->{header}->{host};
    delete $http->{output_queue};
    $http->HeaderSent;
    $queue->queue("HTTP/1.0 200 OK\ncontent-type: text/html\n\n");
    $queue->queue("<html><head><title>Not logged in</title></head>");
    $queue->queue("<body><h3>Not logged in</h3><p>");
    $queue->queue("There is no session $sess_id.  Perhaps you logged out, ");
    $queue->queue("or perhaps your session timed out.</p>");
    $queue->queue("Please close this window.");
    $queue->queue("</body></html>");
    $queue->finish();
  }
  sub InternalError{
    my($http, $message) = @_;
      my $queue = $http->{output_queue};
      delete $http->{output_queue};
      $http->HeaderSent;
      $queue->queue("HTTP/1.0 500 Error\n\n");
      $queue->queue("Internal error: $message");
      $queue->finish();
  }
  sub ParseTextPlain {
    # Possibly accept JSON?

    my($http) = @_;
    my $length = $http->{header}->{content_length};
    my $content_type = $http->{header}->{content_type};
    my $buff;
    unless(defined($length) && $length > 0) {
      return undef;
    }
    # read it all in at once - there is a limit on this, maybe
    # look at ParseMultipart for an example of how to handle it
    my $len_read = read $http->{socket}, $buff, $length;
    unless($len_read == $length){
      die "couldn't read data";
    }

    return $buff;

  }
  sub ParseIncomingForm{
    my($http) = @_;
    my $length = $http->{header}->{content_length};
    my $content_type = $http->{header}->{content_type};
    my $buff;
    unless(defined($length) && $length > 0) {
      $http->{form} = {};
      return;
    }
    my $len_read = read $http->{socket}, $buff, $length;
    unless($len_read == $length){
      die "couldn't read form";
    }
    my @pairs = split(/&/, $buff);
    for my $p (@pairs){
      my($key, $val) = split(/=/, $p);
      $key =~ s/\+/ /g;
      $val =~ s/\+/ /g;
      $key =~ s/%(..)/pack("c",hex($1))/ge;
      $val =~ s/%(..)/pack("c",hex($1))/ge;
      if(defined $http->{form}->{$key}){
        unless(ref($http->{form}->{$key}) eq "ARRAY"){
          $http->{form}->{$key} = [ $http->{form}->{$key} ];
        }
        push(@{$http->{form}->{$key}}, $val);
      } else {
        $http->{form}->{$key} = $val;
      }
    }
  }
  sub ParseMultipart{
    my($http, $file) = @_;
    my $content_length = $http->{header}->{content_length};
    my $content_type = $http->{header}->{content_type};
    my $err_count = 0;
    unless($content_type =~ /multipart\/form-data;\s*boundary=(.*)/){
      print STDERR  "Can't handle content_type: $content_type";
      return undef;
    }
    my $fh;
    unless(open $fh, ">$file"){
      print STDERR "Can't open $file\n";
      return undef;
    }
    my $length_read = 0;
    while($length_read < $content_length){
      my $buff;
      my $to_read = 100;
      if ($to_read > $content_length) {
        $to_read = $content_length;
      }
      my $count = sysread($http->{socket}, $buff, $to_read);
      unless($count) { 
        $err_count += 1;
        if($err_count > 1000) { die "Stuck in loop" }
        print STDERR "Yikes\n";
        sleep 1;
        next;
      }
      $length_read += $count;
      print $fh $buff;
    }
    return $file;
  }
  sub ParseMultipartShouldWork{
    my($http, $file, $done) = @_;
    my $content_length = $http->{header}->{content_length};
    my $content_type = $http->{header}->{content_type};
    unless($content_type =~ /multipart\/form-data;\s*boundary=(.*)/){
      print STDERR  "Can't handle content_type: $content_type";
      return undef;
    }
    my $fh;
    unless(open $fh, ">$file"){
      print STDERR "Can't open $file\n";
      return undef;
    }
    my $reader = Dispatch::Select::Socket->new(
      $http->MultipartReader($content_length, $file, $done), $http->{socket},
      "MultpartReader"
    );
    $reader->Add("reader");
  }
  sub MultipartReader{
    my($http, $length, $fh, $done) = @_;
    my $read = 0;
    my $sub = sub {
      my($disp, $socket) = @_;
      my $buff;
      my $count = sysread($socket, $buff, 100);
      unless($count){
        if($! == &Errno::EAGAIN){
print STDERR "Eagain\n";
          return;
        }
        if($! == &Errno::EWOULDBLOCK){
print STDERR "Ewouldblock\n";
          return;
        }
        $read += $count;
        print $fh $buff;
        if($count >= $length){
          $disp->Remove();
          &$done();
        }
      }
    };
    return $sub;
  }
  sub HeaderSent{
    my($http) = @_;
    $http->{header_sent} = 1;
  }
my $HtmlHeaderText = <<EOF;
HTTP/1.0 200 OK
Cache-Control: no-cache
Connection: close
Content-type: text/html
EOF
  sub HtmlHeader{
    my($http,$dyn) = @_;
    unless(exists $http->{header_sent}){
      $http->{output_queue}->queue($HtmlHeaderText);
      if (defined $dyn) {
        if (exists $dyn->{content_length}) {
          $http->{output_queue}->queue(
            "Content-Length: " . $dyn->{content_length} . "\n");
        }
      }
      $http->{output_queue}->queue("\n");
    }
    $http->{header_sent} = 1;
  }
my $TextHeaderText = <<EOF;
HTTP/1.0 200 OK
Cache-Control: no-cache
Connection: close
Content-type: text/plain
EOF
  sub TextHeader{
    my($http,$dyn) = @_;
    unless(exists $http->{header_sent}){
      $http->{output_queue}->queue($TextHeaderText);
      if (defined $dyn) {
        if (exists $dyn->{content_length}) {
          $http->{output_queue}->queue(
            "Content-Length: " . $dyn->{content_length} . "\n");
        }
      }
      $http->{output_queue}->queue("\n");
    }
    $http->{header_sent} = 1;
  }
  sub DownloadHeader{
    my($http, $mime_type, $file_name) = @_;
if($http->{header_sent}){
  die "DownloadHeader called after header sent";
}
    $file_name =~ s/\s|\&|\#/_/g;
    $http->{output_queue}->queue("HTTP/1.0 200 OK\n");
    $http->{output_queue}->queue("Content-Disposition: " .
      "attachment; filename=$file_name\n");
    $http->{output_queue}->queue("Content-Type: $mime_type\n\n");
    $http->{header_sent} = 1;
  }
  sub ready_out {
    my($http) = @_;
    return $http->{output_queue}->ready_out();
  }
  sub wait_output {
    my($http, $bkg) = @_;
    return $http->{output_queue}->wait_output($bkg);
  }
  sub queue{
    my($http, $string) = @_;
    $http->{output_queue}->queue($string);
  }
  sub finish{
    my($http) = @_;
#print STDERR "In $http" . "->finish\n";
    if(
      defined $http->{output_queue} &&
      $http->{output_queue}->can("finish")
    ){
#print STDERR "Calling $http->{output_queue}" . "->finish\n";
      $http->{output_queue}->finish();
    }
    $http->{Finished} = time;
  }
  sub queuer{
    my($http) = @_;
    my $foo = sub {
      for my $string (@_){
        $http->queue($string);
      }
    };
    return $foo;
  }
  sub ExpandText{
    my($this, $text, $Dispatch, $sess, $env) = @_;
    Dispatch::Template::ExpandText($this, $text, $Dispatch, $sess, $env);
  }
  sub DESTROY {
    my($http) = @_;
#if($http->{Finished}){
#my $elapsed = time - $http->{Finished};
#print STDERR "$elapsed seconds between finish and destroy\n";
#print STDERR "In $http" . "->DESTROY\n";
#}
    if (defined $http->{socket}) {
      unless(exists $http->{header_sent}){
        # print STDERR "sending Html Header: OK\n";
        # $http->{socket}->print($TextHeaderText);
        # $http->{socket}->print("\n OK 200 ");
        $http->{socket}->print($HtmlHeaderText);
        $http->{socket}->print(
          "\n<html><head> </head><body> </body></html>\n");
      }
    }
    $http->{header_sent} = 1;
# $Dispatch::Http::Connection::now = Time::HiRes::time;
# my $elapsed = $Dispatch::Http::Connection::now - $Dispatch::Http::Connection::then;
# if ($Dispatch::Http::Connection::then == 0) {
#   print "time start: $Dispatch::Http::Connection::now: ";
# } else {
#   print "Elapsed time: $elapsed: ";
# }
# $Dispatch::Http::Connection::then = $Dispatch::Http::Connection::now;
# print "Closing connection\n";
    if($ENV{POSDA_DEBUG}){
      print "DESTROY: $http\n";
    }
    if(
      defined $http->{output_queue} &&
      $http->{output_queue}->can("finish")
    ){
      $http->{output_queue}->finish();
    }
  }
}
{
  package Dispatch::HttpServer;
  use vars qw ( @ISA );
  @ISA = ( "Dispatch::Select::Socket" );
  sub new {
    my($class, $port, $handler) = @_;
    my $foo = sub {
      my($this, $socket) = @_;
      my $http = Dispatch::Http::Connection->new($socket, $handler);
      my $Response_reader = $http->CreateResponseReader($socket);
      my $header_reader = $http->CreateHeaderReader($socket);
    };
    my $serv = Dispatch::Acceptor->new($foo)->port_server($port);
    bless $serv, $class;
    if($ENV{POSDA_DEBUG}){
      print "NEW: $serv\n";
    }
    return $serv;
  }
  sub DESTROY {
    my($this) = @_;
    my $class = ref($this);
    if($ENV{POSDA_DEBUG}){
      print "Destroying $class\n";
    }
  }
}
{
  package Dispatch::Http::App::Server;
  use vars qw ( @ISA $ExtToMime $ServerPort );
  $ExtToMime = {
    "doc" => "application/msword",
    "bmp" => "image/bmp",
    "gif" => "image/gif",
    "htm" => "text/html",
    "html" => "text/html",
    "jpg" => "image/jpeg",
    "jpeg" => "image/jpeg",
    "png" => "image/png",
    "mpg" => "video/mpeg",
    "ppt" => "application/ppt",
    "qt" => "video/quicktime",
    "rtf" => "application/rtf",
    "tif" => "image/tiff",
    "tiff" => "image/tiff",
    "txt" => "text/plain",
    "wav" => "audio/x-wav",
    "xls" => "application/msexcel",
    "js" => "application/x-javascript",
    "css" => "text/css",
    "ico" => "image/icon",
    "svg" => "image/svg+xml",
  };
  @ISA = ( "Dispatch::Select::Socket" );
  sub make_foo{
    my($this, $port, $interval, $time_to_live) = @_;
    my $foo = sub {
      my($http) = @_;
      if($http->{header_lines}->[0] =~ /^(\S*)\s*(\S*)\s*(\S*)\s*$/){
        my $method = $1;
        my $uri = $2;
        my $prot = $3;
# The following print statement are for debuging recving a hdr
#
# $Dispatch::Http::Connection::now = Time::HiRes::time;
# my $elapsed = $Dispatch::Http::Connection::now - $Dispatch::Http::Connection::then;
# if ($Dispatch::Http::Connection::then == 0) {
#   print "time start: $Dispatch::Http::Connection::now: ";
# } else {
#   print "Elapsed time: $elapsed: ";
# }
# $Dispatch::Http::Connection::then = $Dispatch::Http::Connection::now;
# print "Dispatch::Http::Connection: method: $method uri: $uri prot: $prot\n";
# print "\t: file_root: $this->{file_root}, static: $this->{static}.\n";
  
        unless(defined($this->{file_root}) || defined($this->{static})){
          $this->AppDispatch($http, $method, $uri);
          return;
        }
        if($uri eq "/"){ $uri = "/index.html" }
        if(defined $this->{static}->{$uri}){
          unless($method eq "GET"){
            return $http->InternalError(
              "Only GET supported for static content");
          }
          if($uri =~ /\.([^\/\.]+)$/){
            my $ext = $1;
            if(exists $ExtToMime->{$ext}){
              my $content_type = $ExtToMime->{$ext};
              $http->HeaderSent;
              $http->queue("HTTP/1.0 200 OK\n");
              $http->queue("Content-type: $content_type\n\n");
              $http->queue($this->{static}->{$uri});
              $http->finish();
            }
          }
          return;
        }
        my $path;
        if(defined $this->{file_root}){
          $path = "$this->{file_root}$uri";
        }
        unless(defined($path) && -r $path){
          $this->AppDispatch($http, $method, $uri);
          return;
        }
        unless($method eq "GET"){
          die "Only GET supported for static content";
        }
        if(-d $path) {
          if($path =~ /\/$/){
            $path .= "index.html";
          } else {
            $path .= "/index.html";
          }
        }
        unless(-r $path){
          return $http->NotFound("No file:", $path);
        }
        my $fh = FileHandle->new("<$path");
        unless($fh) {
          print STDERR "Error ($!) opening $path\n";
          print STDERR "Backtrace:\n";
          my $i = 0;
          while(caller($i)){
            my @foo = caller($i);
            $i++;
            my $file = $foo[1];
            my $line = $foo[2];
            print STDERR "\tline $line of $file\n";
          }
          return $http->NotFound("No file:", $path);
        }
        $fh->binmode();
        my $queue = $http->{output_queue};
        delete $http->{output_queue};
        my $content_type = "text/html";
        if($path =~ /\.([^\/\.]+)$/){
          my $ext = $1;
          if(exists $ExtToMime->{$ext}){
            $content_type = $ExtToMime->{$ext};
            $http->HeaderSent;
            $queue->queue("HTTP/1.0 200 OK\n");
            $queue->queue("Content-type: $content_type\n\n");
          }
        }
        $queue->CreateQueueFillerEvent($fh);
        $queue->post_output();
      } else {
        die "unable to parse first line";
      }
    };
    return $foo;
  }
  sub make_fie{
    my($this, $port, $interval, $time_to_live) = @_;
    my $count;
    my $fie = sub {
      my($back) = @_;
      unless(defined($count)){ $count = 6 }
      $count -= 1;
      if($count < 0){
        my $time = `date`;
        chomp $time;
        print STDERR "Log: $time\n";
        $count = 6;
      }
      session:
      for my $id(keys %{$this->{Inventory}}){
        my $sess = $this->{Inventory}->{$id};
        unless(exists $sess->{logged_in}){
          unless(defined $sess->{login_time}){
            $sess->{DieOnTimeout} = 1;
            $sess->{login_time} = time;
          }
          if(time - $sess->{login_time} > $time_to_live){
            print STDERR "Deleting login $id\n";
            if ($sess->can("TearDown")) { $sess->TearDown(); }
            delete $this->{Inventory}->{$id};
            if(scalar keys %{$this->{Inventory}} <= 0){
              unless($sess->{dont_die_on_timeout}){
                die "Time out login, no other session\n";
              }
            }
          }
          next session;
        }
        unless(
          defined $sess  &&  
          ref($sess) eq "Dispatch::Http::Session"
        ){
          delete $this->{Inventory}->{$id};
          next session;
        }
        if($sess->{NoTimeOut}){ next session }
        if(
          exists($sess->{log_me_out}) ||
          time - $sess->{last_access} > $time_to_live
        ){
          if($sess->{DieOnTimeout}){
            if($sess->{dont_die_on_timeout}){
              my $num_sess = scalar keys %{$this->{Inventory}};
              print "No refresh from web client ($num_sess)\n";
            } else {
              $ENV{POSDA_DEBUG} = 1;
              print "Time Out: No refresh from web client\n";
              die "Time Out";
            }
          }
          if($sess->{logged_in}){
            print STDERR "Deleting Inventory ($id)\n";
#           We seem to be hitting this occasionally ...
#           Setting debug doesn't work ...
#           So its commented out
#           To do: figure out what's going on
print STDERR "##################################\n";
print STDERR "#  See if you can figure out how to get here: " .
   __FILE__ . ", line: " . __LINE__ . "\n";
print STDERR "##################################\n";
#            $ENV{POSDA_DEBUG} = 1;
            if ($sess->can("TearDown")) { $sess->TearDown(); }
            print STDERR "Delete session: $id\n";
            delete $this->{Inventory}->{$id};
          } else {
            print STDERR "Not Logged in\n";
          }
        } elsif ((time - $sess->{last_access}) > ($time_to_live / 10)){
          my $sess_count = scalar keys %{$this->{Inventory}};
          print STDERR "$sess_count in inventory\n";
          if($sess->{DieOnTimeout}){
            my $time_remaining = $time_to_live - 
              (time - $sess->{last_access});
            print STDERR "Timing Out in $time_remaining seconds:\n";
            for my $k (keys %{$this->{Inventory}}){
              print STDERR "\t$k\n";
            }
          }
        }
      }
      my $sess_count = scalar keys %{$this->{Inventory}};
      unless($this->{shutting_down} && $sess_count <= 0){
        return $back->timer($interval);
      }
    };
    return $fie
  }
  sub Serve{
    my($this, $port, $interval, $time_to_live) = @_;
    my $foo = $this->make_foo($port, $interval, $time_to_live);
    my $fie = $this->make_fie($port, $interval, $time_to_live);
    $ServerPort = $port;
    my $disp = Dispatch::HttpServer->new($port, $foo);
    $this->{socket_server} = $disp;
    $disp->Add("reader");
    my $back = Dispatch::Select::Background->new($fie);
    $back->queue;
  }
  sub Remove{
    my($this) = @_;
    if(defined($this->{socket_server})){
      $this->{socket_server}->Remove();
      delete($this->{socket_server});
    }
    $this->{shutting_down} = 1;
  }
  sub new {
    my($class, $file_root, $app_root) = @_;
    my $this = {
      Inventory => {
      },
      shutting_down => 0,
      app_root => $app_root,
      file_root => $file_root,
    };
    bless $this, $class;
    if($ENV{POSDA_DEBUG}){
      print "NEW: $this\n";
    }
    return $this;
  }
  sub new_static {
    my($class, $static, $app_root) = @_;
    my $this = {
      Inventory => {
      },
      shutting_down => 0,
      app_root => $app_root,
      static => $static,
    };
    bless $this, $class;
    if($ENV{POSDA_DEBUG}){
      print "NEW: $this\n";
    }
    return $this;
  }
  sub new_static_and_files {
    my($class, $static, $file_root, $app_root) = @_;
    my $this = {
      Inventory => {
      },
      shutting_down => 0,
      app_root => $app_root,
      static => $static,
      file_root => $file_root,
    };
    bless $this, $class;
    if($ENV{POSDA_DEBUG}){
      print "NEW: $this\n";
    }
    return $this;
  }
  sub GetSession {
    my($this, $session) = @_;
    return $this->{Inventory}->{$session};
  }
  sub DeleteSession {
    my($this, $session) = @_;
    print STDERR "Deleting session: $session\n";
    $this->{Inventory}->{$session}->TearDown();
    delete $this->{Inventory}->{$session};
  }
  sub DeleteAllSessions {
    my($this) = @_;
    for my $session (keys %{$this->{Inventory}}) {
      $this->DeleteSession($session);
    }
  }
  sub RandString{
    my $ret;
    for my $i ( 0 .. 4){
      my $num = int rand() * 1000;
      $ret .= sprintf("%03d", $num);
    }
    return $ret;
  }
  sub NewSession {
    my($this) = @_;
    my $inst_id = RandString;
    while(exists $this->{Inventory}->{$inst_id}){
      $inst_id = RandString;
    }
    print "NewSession: $inst_id\n";
    $this->{Inventory}->{$inst_id} = bless {
      session_id => $inst_id,
      last_access => time(),
    }, "Dispatch::Http::Session";
    return $inst_id;
  }
  sub AppDispatch{
    my($this, $http, $method, $uri) = @_;
    $http->ParseIncomingHeader();
    my $app_root = $this->{app_root};
    $http->{method} = $method;
    my $q_string = "";
    if($uri =~ /^(.*)\?(.*)$/){
      $uri = $1;
      $q_string = $2;
    }
    $http->{uri} = $uri;
    $http->{q_string} = $q_string;
    if($uri =~ /^\/login/){
      print STDERR "login uri: $uri\n";
      return $this->Login($http, "/posda/login");
    }
    unless($uri =~ /^\/([^\/]+)(\/.*)$/){
      return $http->NotFound("Can't find session_id in uri: \"$uri\"", $uri);
    }
    my $sess_id = $1;
    my $op = $2;
    unless(defined $this->{Inventory}->{$sess_id}){
      return $http->NotLoggedIn($op, $sess_id);
    }
    my $sess = $this->{Inventory}->{$sess_id};
    if(exists($sess->{log_me_out})){
      $sess->TearDown();
      delete $this->{Inventory}->{$sess_id};
      return $http->NotLoggedIn($op, $sess_id);
    }
    unless(exists $sess->{logged_in}){
      return $http->NotLoggedIn($op, $sess_id);
    }
    my $time = time;
    $sess->{think_time} = $time - $sess->{last_access};
    $sess->{last_access} = $time;
    $app_root->DispatchObj($http, $sess_id, $op, {});
  }
  sub Login{
    my($this, $http, $uri) = @_;
    my $app_root = $this->{app_root};
    print STDERR "\&{\$app_root->{login}}($this, $http, $app_root)\n";
    &{$app_root->{login}}($this, $http, $app_root);
  }
  sub DESTROY{
    my($this) = @_;
    my $class = ref($this);
    if($ENV{POSDA_DEBUG}){
      print "Destroying $class\n";
    }
  }
}
{
  package Dispatch::Http::Session;
  sub TearDown{
    my($sess) = @_;
    if($ENV{POSDA_DEBUG}){
      print STDERR "Tearing down session $sess->{session_id}\n";
     }
    sess_key:
    for my $i (keys %$sess){
      if(ref($sess->{$i}) eq "HASH"){
        for my $j (keys %{$sess->{$i}}){
           if(
             $i eq "root" &&
             defined($sess->{$i}->{$j}) &&
             $sess->{$i}->{$j}->can("DeleteSelf")
           ){
             $sess->{$i}->{$j}->DeleteSelf;
           } else {
             if($ENV{POSDA_DEBUG}){
               print STDERR "\t$i" . "->{$j}: $sess->{$i}->{$j}\n";
             }
             delete $sess->{$i}->{$j};
           }
        }
        delete $sess->{$i};
        next sess_key;
      }
      if($ENV{POSDA_DEBUG}){
        print STDERR "\t$i: $sess->{$i}\n";
      }
    }
  }
}
{
  package Dispatch::Http::App;
  sub new_obj {
    my($class, $login_obj, $app_init, $app_name) = @_;
    my $this = {
      login => $login_obj,
      app_init => $app_init,
    };
    if(defined $app_name) { $this->{app_name} = $app_name }
    return bless $this, $class;
  }
  sub new_single_sess{
    my($class, $app_name, $sess_id) = @_;
    my $this = {
      app_name => $app_name,
      sess_id => $sess_id
    };
    return bless $this, $class;
  }
  
  sub Dispatch{
    my($app_root, $http, $sess, $op, $dyn) = @_;
    if(ref($app_root->{app}->{$op}) eq "CODE"){
      return &{$app_root->{app}->{$op}}($app_root->{app}, $http, $sess, $dyn);
    } else {
      $http->HtmlHeader();
      return Dispatch::Template::ExpandText($http, $app_root->{app}->{$op},
        $app_root->{app}, $sess, $dyn);
    }
  }
  sub DispatchObj{
    my($app_root, $http, $sess_id, $method) = @_;
    my $sess = $main::HTTP_APP_SINGLETON->{Inventory}->{$sess_id};
    if($method =~ /^\/(.*)/){
      $method = $1;
    }
# The following print statement will let you know if you are
# dispatching objects at all (but will generate lots of output)
#
#    print STDERR "DispatchObj: method: $method q_string: $http->{q_string}\n";
#
    my @pairs = split(/&/, $http->{q_string});
    my %env;
    for my $i (@pairs){
      my($key, $value) = split(/=/, $i);
      unless(defined $value) { $value = "" }
      $value =~ s/\+/ /g;
      $value =~ s/%(..)/pack("c",hex($1))/ge;
      $env{$key} = $value;
    }
    my $obj_path = $env{obj_path};
    my $obj = $sess->{root}->{$obj_path};
    unless($obj){
      print STDERR "###################################\n";
      print STDERR "###################################\n";
      print STDERR "Couldn't find object $obj_path\n";
      print STDERR "DispatchObj: method: $method q_string: $http->{q_string}\n";
      $http->NotFound("No obj: ", "$env{obj_path}");
      print STDERR "###################################\n";
      print STDERR "###################################\n";
      return;
    }
    if($obj->can($method)){
      $obj->$method($http, \%env);
    } else {
      print STDERR "Object $obj_path can't $method(\$http, {\n";
      for my $i (keys %env){
        print STDERR "  $i => \"$env{$i}\", \n";
      }
      print STDERR"});\n";
    }
  }
}
{
  package Dispatch::Http::App::SimplifiedServer;
  use vars qw ( @ISA $ExtToMime $ServerPort );
  $ExtToMime = {
    "doc" => "application/msword",
    "bmp" => "image/bmp",
    "gif" => "image/gif",
    "htm" => "text/html",
    "html" => "text/html",
    "jpg" => "image/jpeg",
    "jpeg" => "image/jpeg",
    "png" => "image/png",
    "mpg" => "video/mpeg",
    "ppt" => "application/ppt",
    "qt" => "video/quicktime",
    "rtf" => "application/rtf",
    "tif" => "image/tiff",
    "tiff" => "image/tiff",
    "txt" => "text/plain",
    "wav" => "audio/x-wav",
    "xls" => "application/msexcel",
    "js" => "application/x-javascript",
    "css" => "text/css",
    "ico" => "image/icon",
    "svg" => "image/svg+xml",
  };
  @ISA = ( "Dispatch::Select::Socket" );
  sub make_foo{
    my($this, $port, $interval, $time_to_live) = @_;
    my $foo = sub {
      my($http) = @_;
      if($http->{header_lines}->[0] =~ /^(\S*)\s*(\S*)\s*(\S*)\s*$/){
        my $method = $1;
        my $uri = $2;
        my $prot = $3;
 #The following print statement are for debuging recving a hdr

# $Dispatch::Http::Connection::now = Time::HiRes::time;
# my $elapsed = $Dispatch::Http::Connection::now - $Dispatch::Http::Connection::then;
# if ($Dispatch::Http::Connection::then == 0) {
#   print "time start: $Dispatch::Http::Connection::now: ";
# } else {
#   print "Elapsed time: $elapsed: ";
# }
# $Dispatch::Http::Connection::then = $Dispatch::Http::Connection::now;
# print STDERR "Dispatch::Http::Connection: method: $method uri: $uri prot: $prot\n";
# print STDERR "\t: file_root: $this->{file_root}, static: $this->{static}.\n";
  
        unless(defined($this->{file_root})){
          $this->AppDispatch($http, $method, $uri);
          return;
        }
        if($uri eq "/"){ $uri = "/index.html" }
        if(defined $this->{static}->{$uri}){
          unless($method eq "GET"){
            return $http->InternalError(
              "Only GET supported for static content");
          }
          if($uri =~ /\.([^\/\.]+)$/){
            my $ext = $1;
            if(exists $ExtToMime->{$ext}){
              my $content_type = $ExtToMime->{$ext};
              $http->HeaderSent;
              $http->queue("HTTP/1.0 200 OK\n");
              $http->queue("Content-type: $content_type\n\n");
              $http->queue($this->{static}->{$uri});
              $http->finish();
            }
          }
          return;
        }
        my $path;
        if(defined $this->{file_root}){
          $path = "$this->{file_root}$uri";
        }
        unless(defined($path) && -r $path){
          $this->AppDispatch($http, $method, $uri);
          return;
        }
        unless($method eq "GET"){
          die "Only GET supported for static content";
        }
        if(-d $path) {
          if($path =~ /\/$/){
            $path .= "index.html";
          } else {
            $path .= "/index.html";
          }
        }
        unless(-r $path){
          return $http->NotFound("No file:", $path);
        }
        my $fh = FileHandle->new("<$path");
        unless($fh) {
          print STDERR "Error ($!) opening $path\n";
          print STDERR "Backtrace:\n";
          my $i = 0;
          while(caller($i)){
            my @foo = caller($i);
            $i++;
            my $file = $foo[1];
            my $line = $foo[2];
            print STDERR "\tline $line of $file\n";
          }
          return $http->NotFound("No file:", $path);
        }
        $fh->binmode();
        my $queue = $http->{output_queue};
        delete $http->{output_queue};
        my $content_type = "text/html";
        if($path =~ /\.([^\/\.]+)$/){
          my $ext = $1;
          if(exists $ExtToMime->{$ext}){
            $content_type = $ExtToMime->{$ext};
            $http->HeaderSent;
            $queue->queue("HTTP/1.0 200 OK\n");
            $queue->queue("Content-type: $content_type\n\n");
          }
        }
        $queue->CreateQueueFillerEvent($fh);
        $queue->post_output();
      } else {
        die "unable to parse first line";
      }
    };
    return $foo;
  }
  sub make_fie{
    my($this, $port, $interval, $time_to_live) = @_;
    my $count;
    my $fie = sub {
      my($back) = @_;
      unless(defined($count)){ $count = 6 }
      $count -= 1;
      if($count < 0){
        my $time = `date`;
        chomp $time;
        print STDERR "Log: $time\n";
        $count = 6;
      }
      session:
      for my $id(keys %{$this->{Inventory}}){
        my $sess = $this->{Inventory}->{$id};
        unless(exists $sess->{logged_in}){
          unless(defined $sess->{login_time}){
            $sess->{DieOnTimeout} = 1;
            $sess->{login_time} = time;
          }
          if(time - $sess->{login_time} > $time_to_live){
            print STDERR "Deleting login $id\n";
            if ($sess->can("TearDown")) { $sess->TearDown(); }
            delete $this->{Inventory}->{$id};
            if(scalar keys %{$this->{Inventory}} <= 0){
              unless($sess->{dont_die_on_timeout}){
                die "Time out login, no other session\n";
              }
            }
          }
          next session;
        }
        unless(
          defined $sess  &&  
          ref($sess) eq "Dispatch::Http::Session"
        ){
          delete $this->{Inventory}->{$id};
          next session;
        }
        if($sess->{NoTimeOut}){ next session }
        if(
          exists($sess->{log_me_out}) ||
          time - $sess->{last_access} > $time_to_live
        ){
          if($sess->{DieOnTimeout}){
            if($sess->{dont_die_on_timeout}){
              my $num_sess = scalar keys %{$this->{Inventory}};
              print "No refresh from web client ($num_sess)\n";
            } else {
              $ENV{POSDA_DEBUG} = 1;
              print "Time Out: No refresh from web client\n";
              die "Time Out";
            }
          }
          if($sess->{logged_in}){
            print STDERR "Deleting Inventory ($id)\n";
#           We seem to be hitting this occasionally ...
#           Setting debug doesn't work ...
#           So its commented out
#           To do: figure out what's going on
print STDERR "##################################\n";
print STDERR "#  See if you can figure out how to get here: " .
   __FILE__ . ", line: " . __LINE__ . "\n";
print STDERR "##################################\n";
#            $ENV{POSDA_DEBUG} = 1;
            if ($sess->can("TearDown")) { $sess->TearDown(); }
            print STDERR "Delete session: $id\n";
            delete $this->{Inventory}->{$id};
          } else {
            print STDERR "Not Logged in\n";
          }
        } elsif ((time - $sess->{last_access}) > ($time_to_live / 10)){
          my $sess_count = scalar keys %{$this->{Inventory}};
          print STDERR "$sess_count in inventory\n";
          if($sess->{DieOnTimeout}){
            my $time_remaining = $time_to_live - 
              (time - $sess->{last_access});
            print STDERR "Timing Out in $time_remaining seconds:\n";
            for my $k (keys %{$this->{Inventory}}){
              print STDERR "\t$k\n";
            }
          }
        }
      }
      my $sess_count = scalar keys %{$this->{Inventory}};
      unless($this->{shutting_down} && $sess_count <= 0){
        return $back->timer($interval);
      }
    };
    return $fie
  }
  sub Serve{
    my($this, $port, $interval, $time_to_live) = @_;
    my $foo = $this->make_foo($port, $interval, $time_to_live);
    my $fie = $this->make_fie($port, $interval, $time_to_live);
    $ServerPort = $port;
    my $disp = Dispatch::HttpServer->new($port, $foo);
    $this->{socket_server} = $disp;
    $disp->Add("reader");
    my $back = Dispatch::Select::Background->new($fie);
    $back->queue;
  }
  sub Remove{
    my($this) = @_;
    if(defined($this->{socket_server})){
      $this->{socket_server}->Remove();
      delete($this->{socket_server});
    }
    $this->{shutting_down} = 1;
  }
  sub new {
    my($class, $file_root, $app_root) = @_;
    my $this = {
      Inventory => {
      },
      shutting_down => 0,
      app_root => $app_root,
      file_root => $file_root,
    };
    bless $this, $class;
    if($ENV{POSDA_DEBUG}){
      print "NEW: $this\n";
    }
    return $this;
  }
  sub new_static {
    my($class, $static, $app_root) = @_;
    my $this = {
      Inventory => {
      },
      shutting_down => 0,
      app_root => $app_root,
      static => $static,
    };
    bless $this, $class;
    if($ENV{POSDA_DEBUG}){
      print "NEW: $this\n";
    }
    return $this;
  }
  sub new_static_and_files {
    my($class, $static, $file_root) = @_;
    my $this = {
      Inventory => {},
      shutting_down => 0,
      static => $static,
      file_root => $file_root,
    };
    bless $this, $class;
    if($ENV{POSDA_DEBUG}){
      print "NEW: $this\n";
    }
    return $this;
  }
  sub GetSession {
    my($this, $session) = @_;
    return $this->{Inventory}->{$session};
  }
  sub DeleteSession {
    my($this, $session) = @_;
    print STDERR "Deleting session: $session\n";
    $this->{Inventory}->{$session}->TearDown();
    delete $this->{Inventory}->{$session};
  }
  sub DeleteAllSessions {
    my($this) = @_;
    for my $session (keys %{$this->{Inventory}}) {
      $this->DeleteSession($session);
    }
  }
  sub RandString{
    my $ret;
    for my $i ( 0 .. 4){
      my $num = int rand() * 1000;
      $ret .= sprintf("%03d", $num);
    }
    return $ret;
  }
  sub NewSession {
    my($this, $inst_id) = @_;
    print "NewSession: $inst_id\n";
    $this->{Inventory}->{$inst_id} = bless {
      session_id => $inst_id,
      last_access => time(),
    }, "Dispatch::Http::Session";
  }
  sub AppDispatch{
    my($this, $http, $method, $uri) = @_;
    $http->ParseIncomingHeader();
    my $app_root = $this->{app_root};
    $http->{method} = $method;
    my $q_string = "";
    if($uri =~ /^(.*)\?(.*)$/){
      $uri = $1;
      $q_string = $2;
    }
    $http->{uri} = $uri;
    $http->{q_string} = $q_string;
    if($uri =~ /^\/login/){
      return $this->Login($http, $uri);
    }
    unless($uri =~ /^\/([^\/]+)(\/.*)$/){
      return $http->NotFound("Can't find session_id in uri: \"$uri\"", $uri);
    }
    my $sess_id = $1;
    my $op = $2;
    unless(defined $this->{Inventory}->{$sess_id}){
      return $http->NotLoggedInApp($op, $sess_id);
    }
    my $sess = $this->{Inventory}->{$sess_id};
    if(exists($sess->{log_me_out})){
      $sess->TearDown();
      delete $this->{Inventory}->{$sess_id};
      return $http->NotLoggedInApp($op, $sess_id);
    }
    unless(exists $sess->{logged_in}){
      return $http->NotLoggedInApp($op, $sess_id);
    }
    my $time = time;
    $sess->{think_time} = $time - $sess->{last_access};
    $sess->{last_access} = $time;
    $app_root->DispatchObj($http, $sess_id, $op, {});
  }
  sub Login{
    my($this, $http, $uri) = @_;
    my $app_root = $this->{app_root};
    &{$app_root->{login}}($this, $http, $app_root);
  }
  sub DESTROY{
    my($this) = @_;
    my $class = ref($this);
    if($ENV{POSDA_DEBUG}){
      print "Destroying $class\n";
    }
  }
}
1;
