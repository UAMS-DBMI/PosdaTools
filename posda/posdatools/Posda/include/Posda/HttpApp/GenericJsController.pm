#!/usr/bin/perl -w
#
use strict;
package Posda::HttpApp::GenericJsController;
use vars qw( @ISA );
@ISA = ( "Posda::HttpObj" );
my $js_controller_hdr = <<EOF;
<script type="text/javascript">
  var ObjPath = "<?dyn="echo" field="path"?>";
  var IsExpert = <?dyn="QueueIsExpert"?>;
  var CanDebug = <?dyn="QueueCanDebug"?>;
  function QueueRepeatingServerCmd(cmd,t){
    var chk_cmd = "CheckServer('"+cmd+"',1000)";
    setTimeout(chk_cmd,t);
  }
  function CheckServer(cmd,t){
    var xmlhttp = nxml();
    if (xmlhttp == null) return;
    xmlhttp.open("POST", cmd, true);
    xmlhttp.setRequestHeader("Content-type", "text/plain");
    xmlhttp.onreadystatechange = function() {
      if (this.readyState == 4 ) {
        if (this.status == 200) {
          if (this.responseText == "reload") {
            window.location.reload(true);
          } else if (this.responseText == "0") {
            // alert('Received nothing to do response');
            QueueRepeatingServerCmd(cmd,t);
          } else {
            // alert('Received cmd: '+this.responseText);
            eval(this.responseText);
            QueueRepeatingServerCmd(cmd,t);
          }
        } else if (this.status == 0  || this.status == 12029) {
          alert('Server program is not responding.');
        }
      }
    }
    xmlhttp.send(cmd); 
  }
  window.onload = function(){
    var CheckCmd = 'ServerCheck?obj_path='+ObjPath+'&window='+window.name;
    QueueRepeatingServerCmd(CheckCmd, 3000);
  }
</script>
EOF
sub JsController{
  my($this, $http, $dyn) = @_;
  $dyn->{path} = $this->{path};
  $this->RefreshEngine($http, $dyn, $js_controller_hdr);
}
sub AutoRefresh{
  my($this) = @_;
  $this->QueueJsCmd("Update();");
}
sub ServerCheck{
  my($this, $http, $dyn) = @_;
  my $content_len = $http->{header}->{content_length};
  my $content;
  my $len = read($http->{socket}, $content, $content_len);
   
  if (exists $this->{_JsCmds}) {
    $this->text_header($http, { content_length => length($this->{_JsCmds}) } );
    $http->queue($this->{_JsCmds});
    delete $this->{_JsCmds};
  } else {
    $this->text_header($http, { content_length => 1 } );
    $http->queue("0");
  }
}
sub QueueJsCmd{
  my($this, $cmd) = @_;
  unless (exists $this->{_JsCmds}) { $this->{_JsCmds} = ""; }
  unless ($cmd =~ /;$/) { $cmd .= ";"; }
  if($this->{_JsCmds} eq $cmd) { return }
  $this->{_JsCmds} .= $cmd;
}
sub QueueIsExpert{
  my($this, $http, $dyn) = @_;
  $http->queue($this->IsExpert() ? "true" : "false");
}
sub QueueCanDebug{
  my($this, $http, $dyn) = @_;
  $http->queue($this->CanDebug() ? "true" : "false");
}
1;
