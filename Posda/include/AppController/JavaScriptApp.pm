# main entry point for Posda???
#
use strict;
use POSIX 'strftime';
use Posda::HttpApp::HttpObj;
use Posda::HttpApp::JsController;
use Posda::HttpApp::DebugWindow;
use Posda::HttpApp::Authenticator;
use Posda::ConfigRead;

use AppController::JsChildProcess;
use AppController::StatusInfo;

use JSON;
use Dispatch::LineReader;
use Debug;
use Switch;

use Posda::DebugLog 'on';

{
  package AppController;
  use vars qw( %RunningApps @HarvestedApps );
}
{
  package AppController::JavaScriptApp;

  use Posda::Config 'Config';
  use Posda::Passwords;
  use DBI;

  use JSON;
  use Storable qw( store retrieve store_fd fd_retrieve );

  use vars qw( @ISA );
  @ISA = ("Posda::HttpApp::JsController", "Posda::HttpApp::Authenticator");

my $redirect = <<EOF;
  HTTP/1.0 201 Created
  Location: <?dyn="echo" field="url"?>
  Content-Type: text/html
  
  <!DOCTYPE html
  PUBLIC "-//W3C//DTD XHTML 1.0 Transitional//EN"
  "http://www.w3.org/TR/xhtml1/DTD/xhtml1-transitional.dtd">
  <html><head>
    <meta http-equiv="refresh" content="0; URL=<?dyn="echo" field="url"?>" />
     <script> CNTLrefresh=window.setTimeout(function(){window.location.href="<?dyn="echo" field="url"?>"},1000);
      </script>
  </head>\n<body>logged out OK, redirecting....
    <a href="<dyn="echo" field="url"?>"><?dyn="echo" field="url"?></a>
  </body></html>
EOF

  sub Shutdown{
    my($this, $http, $dyn) = @_;
    my $url = "http://$http->{header}->{host}/";
    $this->DeleteMySession;
    $this->RefreshEngine($http, {url => $url}, $redirect);
  }
##################################################################
# From here down, A JavaScriptApp
#
  sub Refresh{
    my($this, $http, $dyn) = @_;
    $this->RefreshEngine($http, $dyn, $this->{expander});
  }
  my $expander = <<EOF;
<?dyn="BaseHeader"?>
<script type="text/javascript">
<?dyn="JsController"?>
<?dyn="JsContent"?>
</script>
</head>
<body>
<?dyn="Content"?>
<?dyn="Footer"?>
EOF

my $bad_config = <<EOF;
<?dyn="BadConfigReport"?>
EOF

  sub new {
    my($class, $sess, $path) = @_;
    my $this = Dispatch::NamedObject->new($sess, $path);
    $this->{Config} = $main::HTTP_APP_CONFIG;
    $this->{expander} = $expander;
    $this->{title} = $this->{Config}->{config}->{Identity}->{Title};
    $this->{RoutesBelow}->{ConfigReloaded} = 1;
    $this->{RoutesBelow}->{GetAvailableSockets} = 1;
    $this->{Exports}->{GetAvailableSockets} = 1;
    $this->{Exports}->{ConfigReloaded} = 1;
    $this->{StaticObjs} = \%main::HTTP_STATIC_OBJS;
    bless $this, $class;
    $this->{config_dir} = $main::HTTP_APP_CONFIG->{dir};
    if(exists $main::HTTP_APP_CONFIG->{BadJson}){
      $this->{BadConfigFiles} = $main::HTTP_APP_CONFIG->{BadJson};
    }
    $this->{Identity} = $main::HTTP_APP_CONFIG->{config}->{Identity};
    my $width = $this->{Identity}->{width};
    my $height = $this->{Identity}->{height};
    $this->{height} = $height;
    $this->{width} = $width;
    $this->{menu_width} = 
      $main::HTTP_APP_CONFIG->{config}->{Identity}->{LogoWidth};
    $this->{login_width} = 
      $main::HTTP_APP_CONFIG->{config}->{Identity}->{LogoWidth};
    $this->{content_width} = $this->{width} - $this->{menu_width};
    $this->SetInitialExpertAndDebug("bbennett");
    if($this->CanDebug){
      Posda::HttpApp::DebugWindow->new($sess, "Debug");
    }
    $this->{JavascriptRoot} =
      $main::HTTP_APP_CONFIG->{config}->{Environment}->{JavascriptRoot};
    $this->QueueJsCmd("Update();");
    my $session = $this->get_session;
    $session->{dont_die_on_timeout} = 1;
    $this->ReadConfig;
    $this->{RunningApps} = \%AppController::RunningApps;
    $this->{HarvestedApps} = \%AppController::HarvestedApps;
    $this->{child_index} = 1;
    return $this;
  }

  my $content = <<EOF;
<div id="container" style="width:<?dyn="width"?>px">
<div id="header" style="background-color:#E0E0FF;">
<table width="100%"><tr width="100%"><td width="<?dyn="menu_width"?>px">
<?dyn="Logo"?>
</td><td><div id="title_and_info"></div></td>
<td valign="top" align="right" width="<?dyn="menu_width"?>">
<div id="login">&lt;login&gt;</div>
</td></tr></table></div>
<div id="menu" style="background-color:#F0F0FF;height:<?dyn="height"?>px;width:<?dyn="menu_width"?>px;float:left;">
&lt;wait&gt;
</div>
<div id="content" style="overflow:auto; background-color:#F8F8F8;height:<?dyn="height"?>px;width:<?dyn="content_width"?>px;float:left;">
&lt;Content&gt;</div>
<div id="footer" style="background-color:#E8E8FF;clear:both;text-align:center;">
Posda.com</div>
</div>
EOF

  sub Content{
    my($this, $http, $dyn) = @_;
    if($this->{BadConfigFiles}) {
      return $this->RefreshEngine($http, $dyn, $bad_config);
    }
    $this->RefreshEngine($http, $dyn, $content);
  }
  sub width{
    my($this, $http, $dyn) = @_;
    $http->queue($this->{width});
  }
  sub menu_width{
    my($this, $http, $dyn) = @_;
    $http->queue($this->{menu_width});
  }
  sub content_width{
    my($this, $http, $dyn) = @_;
    $http->queue($this->{content_width});
  }
  sub height{
    my($this, $http, $dyn) = @_;
    $http->queue($this->{height});
  }
  sub BadConfigReport{
    my($this, $http, $dyn) = @_;
    for my $i (keys %{$this->{BadConfigFiles}}){
      $http->queue(
        "<tr><td>$i</td><td>$this->{BadConfigFiles}->{$i}</td></tr>");
    }
  }
  sub Logo{
    my($this, $http, $dyn) = @_;
      my $image = $main::HTTP_APP_CONFIG->{config}->{Identity}->{LogoImage};
      my $height = $main::HTTP_APP_CONFIG->{config}->{Identity}->{LogoHeight};
      my $width = $main::HTTP_APP_CONFIG->{config}->{Identity}->{LogoWidth};
      my $alt = $main::HTTP_APP_CONFIG->{config}->{Identity}->{LogoAlt};
      $http->queue("<img src=\"$image\" height=\"$height\" width=\"$width\" " .
        "alt=\"$alt\">");
  }
  sub JsContent{
    my($this, $http, $dyn) = @_;
    my $js_file = "$this->{JavascriptRoot}/AppController.js";
    unless(-f $js_file) { return }
    my $fh;
    open $fh, "<$js_file" or die "can't open $js_file";
    while(my $line = <$fh>) { $http->queue($line) }
  }
  sub DebugButton{
    my($this, $http, $dyn) = @_;
    if($this->CanDebug){
      $this->RefreshEngine($http, $dyn, qq{
        <button class="btn btn-sm btn-info" 
         onClick="javascript:rt('DebugWindow','Refresh?obj_path=Debug'
         ,1600,1200,0);">
          Debug
        </button>
      });
    } else {
      print STDERR "Can't debug\n";
    }
  }
  sub RevokeLogin{
    my($this, $http, $dyn) = @_;
    $this->{menu_mode} = "initial";
    Posda::HttpApp::Authenticator::RevokeLogin($this, $http, $dyn);
  }
  sub MenuResponse{
    my($this, $http, $dyn) = @_;
    unless(defined $this->{menu_mode}) { $this->{menu_mode} = "avail_apps" }
    if(defined($this->{menu_mode}) && $this->{menu_mode} eq "bom"){
      return $this->MakeBomMenu($http, $dyn);
    }
    if(defined($this->{menu_mode}) && $this->{menu_mode} eq "dicom_receiver"){
      return $this->MakeDrMenu($http, $dyn);
    }
    if(defined($this->{menu_mode}) && $this->{menu_mode} eq "password"){
      return $this->MakePassMenu($http, $dyn);
    }
    $this->MakeMenu($http, $dyn,
      [
        {
          type => "host_link_sync",
          condition => 1,
          caption => "Show Apps",
          method => "SetMenuMode",
          args => { mode => "avail_apps" },
          sync => "Update();",
        },
        {
          type => "host_link_sync",
          condition => $this->{capability}->{IsAdmin},
          caption => "Show BOM",
          method => "SetMenuMode",
          args => { mode => "bom" },
          sync => "Update();",
        },
        {
          type => "host_link_sync",
          condition => 1,
          caption => "Show Receiver",
          method => "SetMenuMode",
          args => { mode => "dicom_receiver" },
          sync => "Update();",
        },
        {
          type => "host_link_sync",
          condition => $this->get_user,
          caption => "Password",
          method => "SetMenuMode",
          args => { mode => "password" },
          sync => "Update();",
        },
      ]
    );
  }
  sub SetMenuMode{
    my($this, $http, $dyn) = @_;
    $this->{menu_mode} = $dyn->{mode};
    if($dyn->{mode} eq "bom"){
      delete $this->{BomDir};
    }
    if($dyn->{mode} eq "password"){
      $this->{password_mode} = "change_own";
      $this->{password_message} = "";
    }
    if($dyn->{mode} eq "dicom_receiver"){
      unless($this->{ReceiverNotifications}){
        my $obj = $this->{StaticObjs}->{DicomReceiver};
        if($obj && $obj->can("NotificationRegistration")){
          $this->{ReceiverNotifications} = 1;
          $obj->NotificationRegistration($this->ReceiverNotification);
        }
      }
    }
    $this->AutoRefresh;
  }
  sub ReceiverNotification{
    my($this) = @_;
    my $sub = sub {
      my($message) = @_;
      unless($this->{ReceiverNotifications}){
        print STDERR "Received Unexpected ReceiverNotification ($message)\n";
        return 0;
      }
      if($this->{menu_mode} eq "dicom_receiver"){
        $this->HandleReceiverNotification($message);
        return 1;
      } else {
        delete $this->{ReceiverNotifications};
        return 0;
      }
    };
    return $sub;
  }

  sub ContentResponse {
    my($this, $http, $dyn) = @_;

    my $mode = 0;
    if (defined $this->{menu_mode}) {
      $mode = $this->{menu_mode};
    }

    switch ($mode) {

      case "bom"            { $this->BomContent($http, $dyn) }
      case "avail_apps"     { $this->AvailAppContent($http, $dyn) }
      case "dicom_receiver" { $this->DicomReceiverContent($http, $dyn) }
      case "password"       { $this->PasswordContent($http, $dyn) }

      else {
        my $resp = "Here's some content";
        $http->queue($resp);
      }
    }
  }

  sub TitleAndInfoResponse{
    my($this, $http, $dyn) = @_;
    unless(defined $this->{menu_mode}){ $this->{menu_mode} = "avail_apps" }
    if($this->{menu_mode} eq "bom"){
      $this->RefreshEngine($http, $dyn,
        '<h2 style="margin-top:0; margin-left:0">' .
        '<?dyn="title"?>: ' .
        'Bill of materials </h2>' .
        (exists($this->{BomDir})? "directory: $this->{BomDir}" :
          "no BOM directory selected"));
    } elsif($this->{menu_mode} eq "avail_apps"){
      $this->RefreshEngine($http, $dyn,
        '<h2 style="margin-top:0; margin-left:0">' .
        '<?dyn="title"?>: ' .
        'Available applications </h2>');
    } elsif($this->{menu_mode} eq "password"){
      $this->RefreshEngine($http, $dyn,
        '<h2 style="margin-top:0; margin-left:0">' .
        '<?dyn="title"?>: ' .
        'Change Password</h2>');
    } elsif($this->{menu_mode} eq "dicom_receiver"){
      $this->DicomReceiverTitle($http, $dyn);
    } else {
      $this->RefreshEngine($http, $dyn,
        '<h1 style="margin-top:0; margin-left:0"><?dyn="title"?></h1>');
    }
  }
  sub DicomReceiverTitle{
    my($this, $http, $dyn) = @_;
    my $obj = $this->{StaticObjs}->{DicomReceiver};
    unless(exists $obj->{ActiveConnections}) { $obj->{ActiveConnections} = {} }
    my $num_act = scalar keys %{$obj->{ActiveConnections}};
    $this->RefreshEngine($http, $dyn,
      '<h2 style="margin-top:0; margin-left:0">' .
      '<?dyn="title"?>: ' .
      'Dicom Receiver Status</h2>' .
      "<small>Serving port: $obj->{dcm_port} " .
      "Active Connections: $num_act " .
      "Receive Dir: $obj->{rcv_dir}</small>");
  }
  sub ReadConfig{
    my($this) = @_;
    my $ConfigTree = $main::HTTP_APP_CONFIG->{config};
    $this->{SocketPool} = $ConfigTree->{Applications}->{SocketPool};
    $this->{Apps} = $ConfigTree->{Applications}->{Apps};
    $this->{BomDirs} = $ConfigTree->{Applications}->{BomDirs};
    $this->{Capabilities} = $ConfigTree->{Capabilities};
  }
  sub ConfigReloaded{
    my($this) = @_;
    print STDERR "ConfigReloaded\n";
    for my $i (keys %main::HTTP_STATIC_OBJS){
      my $obj = $main::HTTP_STATIC_OBJS{$i};
      if(
        defined($obj) &&
        ref($obj) &&
        ref($obj) ne "HASH" &&
        ref($obj) ne "ARRAY" &&
        ref($obj) ne "CODE"
      ){
        if($obj->can("ConfigReloaded")){
          $obj->ConfigReloaded();
        } else {
          my $class = ref($obj);
          print STDERR "class: $class can't ConfigReloaded\n";
        }
      } else {
        my $class = ref($obj);
        print STDERR "Static obj{$i} doesn't appear to be blessed\n";
      }
    }
  }
  sub AvailAppContent{
    DEBUG @_;
    my($this, $http, $dyn) = @_;
    my $default_apps = $this->{Capabilities}->{Default}->{Apps};

    my $table_headers = qq{
      <tr>
        <th "width=10%">Name</th>
        <th "width=30%">Description</th>
        <th "width=10%"></th>
      </tr>
    };

    $this->RefreshEngine($http, $dyn, '<table class="table" width="100%">');


    if(scalar(keys %$default_apps) >= 1){
      $this->RefreshEngine($http, $dyn, 
        '<tr><td colspan=3><h4>Apps Available to All</h4></td</tr>' .
        $table_headers
      );
      $this->AppTableRows($http, $dyn, $default_apps);
    }

    my $user = $this->get_user;
    unless(defined $user) { print STDERR "no user\n";return };
    # unless(exists $this->{Capabilities}->{$user}->{Apps}){ return }

    # get list of apps user can launch
    my $user_apps = $this->{permissions}->launchable_apps();
    $this->RefreshEngine($http, $dyn, 
      "<tr><td colspan=3><h4>Apps Available to $user</h4></td</tr>" .
      $table_headers);
    $this->AppTableRows($http, $dyn, $user_apps);
    $this->RefreshEngine($http, $dyn, '</table>');
  }

  sub AppTableRows{
    my($this, $http, $dyn, $privs) = @_;

    if (ref($privs) eq 'ARRAY') {
      # convert it to a hash
      my %params = map { $_ => 1 } @$privs;
      $privs = \%params;
    }

    for my $app (
      sort 
      {$this->{Apps}->{$a}->{sort_order} <=> $this->{Apps}->{$b}->{sort_order}}
      keys %{$this->{Apps}}
    ){
      if(exists $privs->{$app}){
        $this->RefreshEngine($http, $dyn, "<tr><td>$app</td>" .
          "<td>$this->{Apps}->{$app}->{Description}</td>" .
          "<td><?dyn=\"SimpleButton\"" . 
          'caption="Launch" op="LaunchApp" parm="' . $app . '"?></td></tr>');
      }
    }
  }
  sub LaunchApp{
    my($this, $http, $dyn) = @_;
    my $host = $http->{header}->{host};
    my $process_desc = $this->{Apps}->{$dyn->{parm}};
    $this->StartJsChildProcess($process_desc, $host);
  }
  sub GetAvailableSockets{
    my($this) = @_;
    my @ret;
    for my $s (@{$this->{SocketPool}}){
      unless(exists $this->{RunningApps}->{$s}){
        push(@ret, $s);
      }
    }
    my $count = @ret;
    return \@ret;
  }

  ################### BOM Stuff ############################
  sub MakeBomMenu{
    my($this, $http, $dyn) = @_;
    unless(defined $this->{BomMode}) { $this->{BomMode} = "ShowBom" }
    my $bom_menu = [ 
      {
        type => "host_link_sync",
        condition => 1,
        caption => "Show Apps",
        method => "SetMenuMode",
        args => { mode => "avail_apps" }
      },
      {
        type => "host_link_sync",
        condition => 1,
        caption => "Show Bom",
        method => "SetMenuMode",
        args => { mode => "bom" }
      },
      {
        type => "host_link_sync",
        condition => 1,
        caption => "Show Receiver",
        method => "SetMenuMode",
        args => { mode => "dicom_receiver" }
      },
      {
        type => "host_link_sync",
        condition => $this->get_user,
        caption => "Password",
        method => "SetMenuMode",
        args => { mode => "password" }
      },
      {
        type => "hr",
        condition => 1,
      },
      {
        type => "host_link_sync",
        condition => 1,
        caption => "Clear Diffs",
        method => "ClearBomDiffs",
        args => { mode => "initial" },
      },
      {
        type => "host_link_sync",
        condition => $this->{BomMode} eq "ShowBom",
        caption => "DiffMode",
        method => "SetBomMenuMode",
        args => { mode => "ShowDiffs" },
      },
      {
        type => "host_link_sync",
        condition => $this->{BomMode} eq "ShowDiffs",
        caption => "BomMode",
        method => "SetBomMenuMode",
        args => { mode => "ShowBom" },
      },
      {
        type => "hr",
        condition => 1,
      },
    ];
    for my $i (
      sort keys %{$main::HTTP_APP_CONFIG->{config}->{Applications}->{BomDirs}}
    ){
      push(@$bom_menu, {
        type => "host_link_sync",
        condition => 1,
        caption => $i,
        method => "SetBomDir",
        args => { bom => $i },
        style => "small",
      });
    }
    $this->MakeMenu($http, $dyn, $bom_menu);
  }
  sub SetBomMenuMode{
    my($this, $http, $dyn) = @_;
    $this->{BomMode} = $dyn->{mode};
    $this->AutoRefresh;
  }
  sub SetBomDir{
    my($this, $http, $dyn) = @_;
    $this->{BomDir} = $dyn->{bom};
    $this->AutoRefresh;
  }
  sub BomContent{
    my($this, $http, $dyn) = @_;
    unless(defined $this->{BomDir}){
      return $this->RefreshEngine($http, $dyn,
        "Select a BOM dir from menu at left");
    }
    if($this->{BomMode} eq "ShowBom"){
      my $file = $this->{BomDirs}->{$this->{BomDir}} . "/BOM.html";
      if(-f $file){
        $this->SendHtmlFile($http, $file);
      } else {
        $this->RefreshEngine($http, $dyn,
          "$file is not a file");
      }
    } else {
      my $message = "Select \"clear diffs\" to generate BOM comparisons";
      if(exists $this->{BomDiffs}->{$this->{BomDir}}){
        $http->queue("Results of comparison of BOM to directory contents for " .
          "$this->{BomDir}:<pre>\n");
        for my $i (@{$this->{BomDiffs}->{$this->{BomDir}}}){
          $http->queue("$i\n");
        }
        return $http->queue("</pre>");
      }
      if(exists $this->{BomComputationsInProgress}->{$this->{BomDir}}){
        $message = "BOM for $this->{BomDir} is being compared " .
          "to directory contents";
      } else {
        $message = "BOM for $this->{BomDir} is waiting for  comparison " .
          "to directory contents";
      }
      $http->queue($message);
    }
  }
  sub ClearBomDiffs{
    my($this, $http, $dyn) = @_;
    delete $this->{BomDiffs};
    $this->ReComputeBomDiffs;
    $this->AutoRefresh;
  }
  sub ReComputeBomDiffs{
    my($this) = @_;
    unless(exists $this->{BomComputationsInProgress}){
      $this->{BomComputationsInProgress} = {}
    }
    if(scalar keys %{$this->{BomComputationsInProgress}} >= 1) { return }
    $this->{BomsToCompute} = [ sort keys %{$this->{BomDirs}} ];
    $this->ScheduleBomComputations;
  }
  sub ScheduleBomComputations{
    my($this) = @_;
    while(
      scalar(keys %{$this->{BomComputationsInProgress}}) < 5 &&
      scalar @{$this->{BomsToCompute}} > 0
    ){
      my $next_bom_dir = shift @{$this->{BomsToCompute}};
      $this->StartBomComputation($next_bom_dir);
      $this->{BomComputationsInProgress}->{$next_bom_dir} = 1;
    }
  }
  sub StartBomComputation{
    my($this, $bom_dir) = @_;
    my $bom = "$this->{BomDirs}->{$bom_dir}";
    Dispatch::LineReader->new_cmd("CheckBOM.pl \"$bom\"",
      $this->ReadBomCheckLine($bom_dir), $this->EndBomCheck($bom_dir));
  }
  sub ReadBomCheckLine{
    my($this, $bom_dir) = @_;
    my $sub = sub {
      my($line) = @_;
      unless(exists $this->{BomDiffs}->{$bom_dir}){
        $this->{BomDiffs}->{$bom_dir} = [];
      }
      push @{$this->{BomDiffs}->{$bom_dir}}, $line;
    };
    return $sub;
  }
  sub EndBomCheck{
    my($this, $bom_dir) = @_;
    my $sub = sub {
      delete $this->{BomComputationsInProgress}->{$bom_dir};
      $this->AutoRefresh;
      $this->ScheduleBomComputations;
    };
    return $sub;
  }
  ################### Dicom Receiver Stuff ############################
  sub MakeDrMenu{
    my($this, $http, $dyn) = @_;
    my $dr_menu = [ 
      {
        type => "host_link_sync",
        condition => 1,
        caption => "Show Apps",
        method => "SetMenuMode",
        args => { mode => "avail_apps" }
      },
      {
        type => "host_link_sync",
        condition => 1,
        caption => "Show Bom",
        method => "SetMenuMode",
        args => { mode => "bom" }
      },
      {
        type => "host_link_sync",
        condition => 1,
        caption => "Show Receiver",
        method => "SetMenuMode",
        args => { mode => "dicom_receiver" }
      },
      {
        type => "hr",
        condition => 1,
      },
    ];
    my $obj = $this->{StaticObjs}->{DicomReceiver};
    if(scalar(keys %{$obj->{ActiveConnections}}) > 0){
      push(@$dr_menu, {
        type => "host_link_sync", 
        condition => 1,
        caption => "Active Connections:",
        method => "ShowActiveConnections",
      });
      for my $i (sort keys %{$obj->{ActiveConnections}}){
        push(@$dr_menu, {
          type => "host_link_sync",
          condition => 1,
          caption => "- $i",
          method => "SetActiveConnection",
          style => "small",
          args => { name => $i },
        });
      }
      push(@$dr_menu, { type => "hr", condition => 1 });
    }
    push(@$dr_menu, {
      type => "host_link_sync",
      condition => 1,
      caption => "App Entities",
      method => "ShowApplicationEntities",
    });
    for my $i (keys %{$obj->{aes}}){
      my $foo = $i;
      $foo =~ s/</&lt;/g;
      $foo =~ s/>/&gt;/g;
      push(@$dr_menu, {
        type => "host_link_sync",
        condition => 1,
        caption => "- $foo",
        method => "SetActiveAe",
        args => { name => $foo },
        style => "small",
      });
    }
    $this->MakeMenu($http, $dyn, $dr_menu);
  }
  sub DicomReceiverContent{
    my($this, $http, $dyn) = @_;
    my $obj = $this->{StaticObjs}->{DicomReceiver};
    if(exists $this->{ActiveAe}){
      unless(exists $obj->{aes}->{$this->{ActiveAe}}){
        delete $this->{ActiveAe};
      }
    }
    if(exists $this->{ActiveConnection}){
      unless(exists $obj->{ActiveConnections}->{$this->{ActiveConnection}}){
        delete $this->{ActiveConnection};
      }
    }
    if($this->{ActiveConnection}){
      $this->ActiveConnectionContent($http, $dyn, $obj);
    } elsif($this->{ActiveAe}){
      $this->ActiveAeContent($http, $dyn, $obj);
    } elsif($this->{ShowActiveConnections}){
      $this->ActiveConnectionsContent($http, $dyn, $obj);
    } elsif($this->{ShowApplicationEntities}){
      $this->ApplicationEntitiesContent($http, $dyn, $obj);
    } else {
      $http->queue("Dicom Receiver Content Goes here");
    }
  }
  sub HandleReceiverNotification{
    my($this, $message) = @_;
#    print STDERR "Receiver Notification: $message\n";
    $this->AutoRefresh;
  }
  sub ShowActiveConnections{
    my($this, $http, $dyn) = @_;
    $this->{ShowActiveConnections} = 1;
    delete $this->{ShowApplicationEntities};
    delete $this->{ActiveAe};
    delete $this->{ActiveConnection};
    $this->AutoRefresh;
  }
  sub SetActiveConnection{
    my($this, $http, $dyn) = @_;
    $this->{ActiveConnection} = $dyn->{name};
    delete $this->{ShowApplicationEntities};
    delete $this->{ShowActiveConnections};
    delete $this->{ActiveAe};
    $this->AutoRefresh;
  }
  sub ShowApplicationEntities{
    my($this, $http, $dyn) = @_;
    $this->{ShowApplicationEntities} = 1;
    delete $this->{ShowActiveConnections};
    delete $this->{ActiveAe};
    delete $this->{ActiveConnection};
    $this->AutoRefresh;
  }
  sub SetActiveAe{
    my($this, $http, $dyn) = @_;
    $this->{ActiveAe} = $dyn->{name};
    delete $this->{ShowApplicationEntities};
    delete $this->{ShowActiveConnections};
    delete $this->{ActiveConnection};
    $this->AutoRefresh;
  }
  sub ActiveConnectionContent{
    my($this, $http, $dyn, $obj) = @_;
    unless(exists $obj->{ActiveConnections}->{$this->{ActiveConnection}}){
      delete $this->{ActiveConnection};
      $this->{ShowActiveConnections} = 1;
      return $this->ActiveConnectionsContent($http, $dyn, $obj);
    }
    $http->queue("Content for Active Connection $this->{ActiveConnection} " .
      "goes here");
  }
  sub ActiveAeContent{
    my($this, $http, $dyn, $obj) = @_;
    my $ae = $this->{ActiveAe};
    $ae =~ s/</&lt;/g;
    $ae =~ s/>/&gt;/g;
    $http->queue("Content for Active Ae $ae " .
      "goes here");
  }
  sub ActiveConnectionsContent{
    my($this, $http, $dyn, $obj) = @_;
    if(scalar(keys %{$obj->{ActiveConnections}}) <= 0){
      return $http->queue("No active connections");
    }
    $this->RefreshEngine($http, $dyn,
      'Active Connections:<br><table border="1"><tr>' .
      '<th>Index</th><th>Calling AE</th><th>Called AE</th>' .
      '<th>Connection From</th><th># Proposed PCs</th>' .
      '<th># Accepted PCs</th><th># Files</th><th># Echos</th></tr>');
    for my $i (sort keys %{$obj->{ActiveConnections}}){
      $http->queue("<tr><td>$i</td>");
      my $ac = $obj->{ActiveConnections}->{$i};
      my $ac_obj = $obj->{objs}->{$i};
      $http->queue("<td>$ac->{calling}</td>");
      $http->queue("<td>$ac->{called}</td>");
      $http->queue("<td>$ac_obj->{peer_network_addr}</td>");
      my $num_proposed = scalar(keys %{$ac->{pres_ctx}});
      $http->queue("<td>$num_proposed</td>");
      my $num_ac = 0;
      for my $pc (keys %{$ac->{pres_ctx}}) {
        if(exists $ac->{pres_ctx}->{$pc}->{accepted}){ $num_ac += 1 }
      }
      $http->queue("<td>$num_ac</td>");
      my $num_f = 0;
      for my $i (keys %{$ac->{files}}){
        for my $f (keys %{$ac->{files}->{$i}}){ $num_f += 1 }
      }
      $http->queue("<td>$num_f</td>");
      unless(exists $ac->{num_echo}) { $ac->{num_echo} = "0" };
      $http->queue("<td>$ac->{num_echo}</td>");
      $http->queue("</tr>");
    }
    $this->RefreshEngine($http, $dyn, '</table>');
  }
  sub ApplicationEntitiesContent{
    my($this, $http, $dyn, $obj) = @_;
    $http->queue("Content for Application Entities " .
      "goes here");
  }
  ################### Password Stuff############################
  sub MakePassMenu{
    my($this, $http, $dyn) = @_;
    unless(defined $this->{BomMode}) { $this->{BomMode} = "ShowBom" }
    my $pass_menu = [ 
      {
        type => "host_link_sync",
        condition => 1,
        caption => "Show Apps",
        method => "SetMenuMode",
        args => { mode => "avail_apps" }
      },
      {
        type => "host_link_sync",
        condition => 1,
        caption => "Show Bom",
        method => "SetMenuMode",
        args => { mode => "bom" }
      },
      {
        type => "host_link_sync",
        condition => 1,
        caption => "Show Receiver",
        method => "SetMenuMode",
        args => { mode => "dicom_receiver" }
      },
      {
        type => "hr",
        condition => 1,
      },
    ];
    $this->MakeMenu($http, $dyn, $pass_menu);
  }
  sub PasswordContent{
    my($this, $http, $dyn) = @_;

    $this->{user} = $this->get_user;

    if($this->{password_message}){
      my $alert_type = "alert-success";
      if ($this->{password_message} =~ /^E/) {
        # change to danger if message starts with E
        $alert_type = "alert-danger";
      }
      $http->queue(qq{
        <div class="alert $alert_type">
          $this->{password_message}
        </div>
      });
    }
    my $form = qq{
      <form onSubmit="PosdaGetRemoteMethod('PasswordChange', 'old='+this.elements['OldPassword'].value+'&amp;newp='+this.elements['NewPassword'].value+'&amp;rpt=' +this.elements['RepeatPassword'].value, function(){Update();});return false;">
        <div class="form-group">
          <label for="OldPassword">Current Password</label>
          <input type="password" class="form-control" 
                 id="OldPassword" placeholder="Current Password">
        </div>
        <div class="form-group">
          <label for="NewPassword">New Password</label>
          <input type="password" class="form-control" 
                 id="NewPassword" placeholder="New Password">
        </div>
        <div class="form-group">
          <label for="RepeatPassword">Repeat New Password</label>
          <input type="password" class="form-control" 
                 id="RepeatPassword" placeholder="New Password">
        </div>
        <button type="submit" class="btn btn-warning">Change Password</button>
      </form>
    };
    $this->RefreshEngine($http, $dyn, $form);
  }

  sub PasswordChange {
    my($this, $http, $dyn) = @_;

    my $user = $this->{user};

    my $new_pass = $dyn->{newp};
    my $old_pass = $dyn->{old};
    my $rpt_pass = $dyn->{rpt};

    DEBUG "$new_pass, $old_pass, $rpt_pass";

    # verify they match
    if ($new_pass ne $rpt_pass) {
      $this->{password_message} = "Error: new passwords do not match!";
      return;
    }

    my $dbh = DBI->connect("DBI:Pg:database=${\Config('auth_db_name')}");

    # verify current pass
    my $stmt = $dbh->prepare(qq{
      select password
      from users
      where user_name = ?
    });

    $stmt->execute($user);
    my $current_enc = $stmt->fetchrow_arrayref()->[0];
    $stmt->finish;

    if (not Posda::Passwords::is_valid($current_enc, $old_pass)) {
      $this->{password_message} = "Error: incorrect old password";
      return;
    }


    # change pass
    my $enc_pass = Posda::Passwords::encode($new_pass);

    $stmt = $dbh->prepare(qq{
      update users
      set password = ?
      where user_name = ?
    });

    $stmt->execute($enc_pass, $user);
    $stmt->finish;

    $dbh->disconnect;
    $this->{password_message} = "Success: changed password";
  }
}
1;
