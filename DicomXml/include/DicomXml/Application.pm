#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/DicomXml/include/DicomXml/Application.pm,v $
#$Date: 2014/09/18 16:44:59 $
#$Revision: 1.7 $
#
use strict;
use charnames;
use Posda::HttpApp::GenericMfWindow;
use Posda::HttpApp::HttpObj;
use Posda::HttpApp::SubController;
use Posda::HttpApp::WindowButtons;
use Dispatch::LineReader;
use Debug;
my $dbg = sub { print STDERR @_ };
my $header = <<EOF;
<table style="width:100%" summary="window header">
  <tr>
    <td valign="top" align="left" width="160">
      <?dyn="Logo"?>
    </td>
    <td valign="top">
      <h2><?dyn="title"?></h2>
      </td>
    <td valign="top" align="right" width="180" height="120">
<?dyn="iframe" height="0" width="0" style="visibility:hidden;display:none" child_path="Controller"?>
<?dyn="iframe" frameborder="0" height="100%" child_path="WindowButtons"?>
    </td>
  </tr>
</table>
<?dyn="Selection"?>
<hr>
<?dyn="iframe" height="600" child_path="Content"?>
<hr>
EOF
my $bad_config = <<EOF;
<table style="width:100%" summary="window header">
  <tr>
    <td valign="top" align="left" width="160">
      <?dyn="Logo"?>
    </td>
    <td valign="top">
      <h2><?dyn="title"?></h2>
      </td>
    <td valign="top" align="right" width="180" height="120">
<?dyn="iframe" height="0" width="0" style="visibility:hidden;display:none" child_path="Controller"?>
<?dyn="iframe" frameborder="0" height="100%" child_path="WindowButtons"?>
    </td>
  </tr>
</table>
<table border="1"><hr><th colspan="2">Bad Configuration Files</th></tr>
<?dyn="BadConfigReport"?>
</table>
EOF
my $waiting = <<EOF;
<table style="width:100%" summary="window header">
  <tr>
    <td valign="top" align="left" width="160">
      <?dyn="Logo"?>
    </td>
    <td valign="top">
      <h2><?dyn="title"?></h2>
      </td>
    <td valign="top" align="right" width="180" height="120">
<?dyn="iframe" height="0" width="0" style="visibility:hidden;display:none" child_path="Controller"?>
<?dyn="iframe" frameborder="0" height="100%" child_path="WindowButtons"?>
    </td>
  </tr>
</table>
Waiting
<hr>
EOF
{
  package DicomXml::Application;
  use Storable;
  use vars qw( @ISA );
  @ISA = ( "Posda::HttpApp::GenericMfWindow" );
  sub new {
    my($class, $sess, $path) = @_;
    my $this = Posda::HttpApp::GenericMfWindow->new($sess, $path);
    $this->{title} = "Dicom Standard Browser Application";
    bless $this, $class;
    $this->{w} = 800;
    $this->{h} = 800;
    $this->{RoutesBelow}->{ExpertModeChanged} = 1;
    $this->{RoutesBelow}->{SetRenderMode} = 1;
    $this->{RoutesBelow}->{GetTitleFromId} = 1;
    $this->{Exports}->{GetTitleFromId} = 1;
    $this->{ParsedDicomRoot} = 
      $main::HTTP_APP_CONFIG->{config}->{Environment}->{ParsedDicomRoot};
    $this->{ParsedIodRoot} = 
      $main::HTTP_APP_CONFIG->{config}->{Environment}->{ParsedIodRoot};
    $this->{DicomXmlRoot} = 
      $main::HTTP_APP_CONFIG->{config}->{Environment}->{DicomXmlRoot};
    $this->{DicomIndexFile} = "$this->{ParsedDicomRoot}/XmlIdIndex";
    if(-f $this->{DicomIndexFile}) {
      my $foo;
      eval { $foo = retrieve("$this->{DicomIndexFile}") };
      if($@){
        $this->{IndexError} = $@;
      } else {
        $this->{Index} = $foo;
      }
    } else {
      $this->{IndexError} = "No such file: $this->{DicomIndexFile}";
    }
    Posda::HttpApp::Controller->new($this->{session}, 
      $this->child_path("Controller"));
    Posda::HttpApp::WindowButtons->new($this->{session},
      $this->child_path("WindowButtons"));
    DicomXml::Application::Content->new(
        $this->{session}, $this->child_path("Content"), $this->{db_name},
        $this->{db_host});
    Posda::HttpApp::DebugWindow->new($sess, "Debug");
    $this->SetInitialExpertAndDebug;
    $this->ReOpenFile();
    if(exists $main::HTTP_APP_CONFIG->{BadJson}){
      $this->{BadConfigFiles} = $main::HTTP_APP_CONFIG->{BadJson};
    }
#    $this->{AppConfig} = $main::HTTP_APP_CONFIG;
    my $session = $main::HTTP_APP_SINGLETON->GetSession($this->{session});
    $session->{Privileges}->{capability}->{CanDebug} = 1;
    $this->InitCompositeConversion;
    return $this;
  }
  sub InitCompositeConversion{
    my($this) = @_;
    my $cmd = "GetIodModuleTableIds.pl " .
      "$this->{ParsedDicomRoot}/part03/part03.xml.perl";
    open CMD, "$cmd|";
    while (my $line = <CMD>){
      chomp $line;
      unless($line =~ /^([^:]+): (.*)$/) {
        print STDERR "unrecognized line: $line\n";
      }
      my $table = $1;
      my $desc = $2;
      $this->{IodTabToDesc}->{$table} = $desc;
    }
    my @list;
    opendir DIR, $this->{ParsedIodRoot} or
      die "Can't opendir $this->{ParsedIodRoot}";
    while(my $f = readdir(DIR)){
      unless(-f "$this->{ParsedIodRoot}/$f") { next }
      unless($f =~ /^(.*)\.perl/){ next }
      my $table = $1;
      my $file = "$this->{ParsedIodRoot}/$f";
      push (@list, {
        file => $file,
        table_id => $table,
        desc => $this->{IodTabToDesc}->{$table},
      });
    }
    $this->{CompositeIodMenu} = [ sort {$a->{desc} cmp $b->{desc}} @list ];
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
  sub Content {
    my($this, $http, $dyn) = @_;
    $this->RefreshEngine($http, $dyn, $header);
  }
  sub Selection{
    my($this, $http, $dyn) = @_;
    $this->RefreshEngine($http, $dyn, 
    'Select Mode: <?dyn="SelectNsByValue" op="SelectMode"?>' .
    '<?dyn="ModeDropDown"?></select>' .
    '<?dyn="ModalMenu"?>');
  }
  sub ModeDropDown{
    my($this, $http, $dyn) = @_;
    unless($this->{SelMode}){ $this->{SelMode} = "--- SelectMode ---"  }
    for my $i (
      "--- SelectMode ---", keys %{$this->{Index}->{ByEl}}, "CompositeIods"
    ){
      $http->queue("<option value=\"$i\"" .
        ($this->{SelMode} eq $i ? " selected" : "") .
        ">$i</option>");
    }
  }
  sub SelectMode{
    my($this, $http, $dyn) = @_;
    $this->{SelMode} = $dyn->{value};
    delete $this->{SelFile};
    delete $this->{SelId};
    $this->RouteAbove("SetRenderMode", "none");
    $this->AutoRefresh;
  }
  sub ModalMenu{
    my($this, $http, $dyn) = @_;
    unless(defined $this->{SelMode}) { return }
    if ($this->{SelMode} eq "--- SelectMode ---"){
      return;
    }
    $this->RefreshEngine($http, $dyn,
      ' Select: <?dyn="SelectNsByValue" op="SelFile"?><?dyn="FileDropDown"?>' .
      '</select>' .
      '<?dyn="IdSelect"?>');
  }
  sub FileDropDown{
    my($this, $http, $dyn) = @_;
    if($this->{SelMode} eq "CompositeIods"){
      unless(exists $this->{SelectedCompositeIod}) {
        $this->{SelectedCompositeIod} = 0;
      }
      for my $i (0 .. $#{$this->{CompositeIodMenu}}){
        $http->queue("<option value=\"$i\"" .
          ($i == $this->{SelectedCompositeIod} ? " selected" : "") .
          ">$this->{CompositeIodMenu}->[$i]->{desc}</option>");
      }
    } else {
      my @file_list  = sort keys %{$this->{Index}->{ByEl}->{$this->{SelMode}}};

      unless($this->{SelFile}){ $this->{SelFile} = "--- SelectFile ---"  }
      for my $i ("--- SelectFile ---", @file_list){
        $http->queue("<option value=\"$i\"" .
          ($this->{SelFile} eq $i ? " selected" : "") .
          ">$i</option>");
      }
    }
  }
  sub SelFile{
    my($this, $http, $dyn) = @_;
    if($this->{SelMode} eq "CompositeIods"){
      $this->{SelectedCompositeIod} = $dyn->{value};
      $this->{SelFile} = $this->{CompositeIodMenu}->[$dyn->{value}]->{file};
      $this->RouteAbove("SetRenderMode", "CompositeIods",
        $this->{SelFile},
        $this->{CompositeIodMenu}->[$dyn->{value}]->{table_id},
        $this->{CompositeIodMenu}->[$dyn->{value}]->{desc},
      );
      $this->AutoRefresh;
      return;
    }
    $this->{SelFile} = $dyn->{value};
    delete $this->{SelId};
    if($this->{SelFile} eq "--- SelectFile ---"){
      $this->RouteAbove("SetRenderMode", "none")
    } elsif ($this->{SelMode} eq "svg"){
      $this->RouteAbove("SetRenderMode", "svg", $this->{SelFile})
    }
    $this->AutoRefresh;
  }
  sub IdSelect{
    my($this, $http, $dyn) = @_;
    if($this->{SelMode} eq "CompositeIods") { return }
    unless(defined $this->{Index}->{ByFile}->{$this->{SelFile}}) { return }
    unless($this->{SelMode} eq "book") { return }
    $this->RefreshEngine($http, $dyn,
      ' Select: <?dyn="SelectNsByValue" op="SelectId"?>' .
      '<?dyn="IdDropDown"?></select>');
  }
  sub IdDropDown{
    my($this, $http, $dyn) = @_;
    my @id_list  = 
      sort keys %{$this->{Index}->{ByFile}->{$this->{SelFile}}};
    unless($this->{SelId}){ $this->{SelId} = "--- SelectId ---"  }
    for my $i ("--- SelectId ---", @id_list){
      $http->queue("<option value=\"$i\"" .
        ($this->{SelId} eq $i ? " selected" : "") .
        ">$i:" .
        $this->GetShortTitle($i) .
        "</option>");
    }
  }
  sub GetShortTitle{
    my($this, $index) = @_;
    my $title = $this->{Index}->{ByFile}->{$this->{SelFile}}->{$index};
    unless(defined $title) { $title = "no title" }
    if(length($title) < 40) { return $title }
    $title =~ /^(.{40})/;
    return $1 . "...";
  }
  sub GetTitleFromId{
    my($this, $index) = @_;
    my $title = $this->{Index}->{ByFile}->{"part03/part03.xml"}->{$index};
    unless(defined $title) { $title = "no title" }
    if($title =~ /^caption - (.*)$/) { return $1 }
    if($title =~ /^title - (.*)$/) { return $1 }
    return $title;
  }
  sub SelectId{
    my($this, $http, $dyn) = @_;
    $this->{SelId} = $dyn->{value};
    if($this->{SelId} eq "--- SelectId ---"){
      $this->RouteAbove("SetRenderMode", "none");
    } else {
      $this->RouteAbove("SetRenderMode", "book", 
        $this->{SelFile}, $this->{SelId});
    }
    $this->AutoRefresh;
  }
  sub CleanUp{
    my($this) = @_;
    $this->delete_descendants;
  }
  sub DESTROY{
    my($this) = @_;
  }
}
{
  package DicomXml::Application::Content;
  use Posda::HttpApp::GenericIframe;
  use Storable qw( store_fd fd_retrieve );
  use vars qw( @ISA );
  @ISA = ( "Posda::HttpApp::GenericIframe" );
  sub new{
    my($class, $sess, $path, $db_name, $db_host) = @_;
    my $this = Posda::HttpApp::GenericIframe->new($sess, $path);
    $this->{db_name} = $db_name;
    $this->{db_host} = $db_host;
    bless $this, $class;
    $this->AutoRefresh;
    $this->{RenderMode} = "none";
    $this->{Exports}->{SetRenderMode} = 1;
    return $this;
  }
  sub Content{
    my($this, $http, $dyn) = @_;
    if($this->{RenderMode} eq "none"){
      $http->queue("^^^ Select something to render ^^^");
    } elsif($this->{RenderMode} eq "svg"){
      my $dicom_xml_root = $this->parent->{DicomXmlRoot};
      $http->queue("Render $this->{RenderMode}: $this->{file}<br/>");
      $http->queue("<img " .
        "src=\"RetrieveTempFile?obj_path=$this->{path}&amp;" .
        "content_name=$dicom_xml_root/$this->{file}&amp;".
        " alt=\"$dicom_xml_root/$this->{file}\"" .
        "><br/>");
    } elsif($this->{RenderMode} eq "book"){
      my $element = $this->{StructToRender}->{el};
      $http->queue("Type of struct to render: $element<br>");
      $http->queue("Id of struct to render: \"$this->{id}\" in " .
        "file: $this->{file}<br><hr>");
      $this->SimpleRendering($http, $dyn);
    } elsif($this->{RenderMode} eq "CompositeIods"){
      $this->RefreshEngine($http, $dyn, 
        "<h3>$this->{desc}</h3><h4>$this->{id}</h4>" .
        '<small><?dyn="EntitySelection"?><table border="1">' .
        '<tr><th>Element</th><th>Entity</th><th>Module</th>' .
        '<th>Usage</th><th>Req</th><th>Name<th>Comments</th></tr>' .
        '<?dyn="ExpandTableRows"?></table></small>'
      ); 
    }
  }
  sub ExpandTableRows{
    my($this, $http, $dyn) = @_;
    for my $tag (sort keys %{$this->{StructToRender}->{tags}}){
      my $td = $this->{StructToRender}->{tags}->{$tag};
      if(ref($td) eq "HASH") {
        $this->ExpandRow($http, $dyn, $tag, $td);
      } elsif(ref($td) eq "ARRAY"){
        print STDERR "ref($tag) has dup entries\n";
        for my $h (@$td){
          $this->ExpandRow($http, $dyn, $tag, $h);
        }
      }
    }
  }
  sub ExpandRow{
    my($this, $http, $dyn, $tag, $td) = @_;
    unless($this->{SelEntities}->{$td->{entity}}->{$td->{module}} eq "checked"){
      return;
    }
    $http->queue("<tr>");
    $http->queue("<td valign=\"top\" width=\"30%\">$tag</td>");
    $http->queue("<td valign=\"top\">$td->{entity}</td>");
    my $module_title = $this->GetModuleTitle($td->{mod_tables});
    $http->queue("<td$module_title valign=\"top\">$td->{module}</td>");
    if($td->{usage} =~ /^C - (.*)$/){
      $http->queue("<td title=\"$1\" valign=\"top\">C</td>");
    } else {
      $http->queue("<td valign=\"top\">$td->{usage}</td>");
    }
    if($td->{req} =~ /C/){
      my $cond = $this->GetCondition($td->{desc});
      if(defined $cond) {
        $http->queue("<td title=\"$cond\" valign=\"top\">");
      } else {
        $http->queue("<td valign=\"top\">");
      }
    } else {
      $http->queue("<td valign=\"top\">");
    }
    $http->queue($td->{req});
    $http->queue("</td>");
    $http->queue("<td valign=\"top\">$td->{name}</td>");
    $http->queue("<td valign=\"top\">");
    $this->RenderDesc($http, $dyn, $td->{desc});
    $http->queue("</td>");
    $http->queue("</tr>");
  }
  sub GetModuleTitle{
    my($this, $list) = @_;
    my $tooltip = "";
    if($#{$list} >= 0){
      for my $i (0 .. $#{$list}){
        $tooltip .= $this->RouteAbove("GetTitleFromId", $list->[$i]);
        unless($i == $#{$list}) { $tooltip .= " => " }
      }
    } else { return "" }
    return " title=\"$tooltip\"";
  }
  sub GetCondition{
    my($this, $desc) = @_;
    if(ref($desc) eq "") {
      if($desc =~ /(Required if[^.]+\.)/){ return $1 }
      else { return undef }
    } elsif(ref($desc) eq "ARRAY"){
      for my $i (@$desc) {
        my $cond = $this->GetCondition($i);
        if($cond) { return $cond }
      }
    } else { return undef }
  }
  sub RenderDesc{
    my($this, $http, $dyn, $desc) = @_;
    if(ref($desc) eq "") {
      $http->queue($desc)
    } elsif(ref($desc) eq "ARRAY") {
      for my $i (@{$desc}) {
        $this->RenderDesc($http, $dyn, $i);
        $http->queue(" ");
      }
    } elsif(ref($desc) eq "HASH"){
      unless(defined $desc->{el}){
        if($desc->{type} eq "variablelist"){
          $http->queue("<p>$desc->{title}</p><ul>");
          for my $i (@{$desc->{list}}){
            $http->queue("<li>");
            for my $j (0 .. $#{$i}){
              if(
                $j > 0 && defined($i->[$j]) && $i->[$j] ne ""
              ){ $http->queue(" -- ") }
              $http->queue($i->[$j]);
            }
            $http->queue("</li>");
          }
          $http->queue("</ul>");
        } else {
          print STDERR "$desc has no el:\n";
          for my $i (keys %$desc) {
            print STDERR "\t$i: $desc->{$i}\n";
          }
        }
        return;
      }
      if($desc->{el} eq "para"){
        $http->queue("<p>");
        $this->RenderDesc($http, $dyn, $desc->{content});
        $http->queue("</p>");
      } elsif($desc->{el} eq "note"){
        $http->queue("<p><b>Note:</b></p> ");
        $this->RenderDesc($http, $dyn, $desc->{content});
        $http->queue("</p>");
      } elsif($desc->{el} eq "xref"){
        my $label = $desc->{attrs}->{linkend};
        if($label =~ /^([^_]*)_(.*)$/){
          $http->queue($2);
        } else {
          $http->queue("&lt;uparsed xref&gt;");
        }
      } elsif($desc->{el} eq "olink"){
        $http->queue($desc->{attrs}->{targetptr});
      }
    }
  }
  sub SimpleRendering{
    my($this, $http, $dyn) = @_;
    my $element = $this->{StructToRender}->{el};
    unless($element eq "table") {
      $http->queue("Simple Rendering only currently supported for tables");
      return;
    }
    $this->{table} = $this->SemanticParseTable($this->{StructToRender});
    $http->queue("Caption: $this->{table}->{caption}<br>");
    $http->queue("<table border>");
    for my $i (@{$this->{table}->{rows}}){
      $http->queue("<tr>");
        for my $j (@$i){
          $http->queue("<td>$j</td>");
        }
      $http->queue("</tr>");
    }
    $http->queue("</table>");
  }
  sub SemanticParseTable{
    my($this, $struct) = @_;
    if($struct->{el} eq "table"){
      my $result = {
        rows => [],
      };
      item:
      for my $i (0 .. $#{$struct->{content}}){
        my $c = $struct->{content}->[$i];
        unless(ref($c)){ next item }
        if($c->{el} eq "caption") {
          $result->{caption} = $this->GetText($c);
        } elsif(
          $c->{el} eq "thead" ||
          $c->{el} eq "tbody"
        ) {
          sub_item:
          for my $j (@{$c->{content}}){
            unless(ref($j)) { next sub_item }
            my $row = $this->SemanticParseTable($j);
            push @{$result->{rows}}, $row;
          }
        } else {
          print STDERR "skipping el: $c->{el} in table content\n";
        }
      }
      return $result;
    } elsif($struct->{el} eq "tr"){
      my @result;
      tr_item:
      for my $i (@{$struct->{content}}){
        unless(ref($i)) { next tr_item }
        if($i->{el} eq "td" || $i->{el} eq "th"){
          my $txt = $this->SemanticParseTable($i);
          push(@result, $txt);
        }
      }
      return \@result;
    } elsif(
      $struct->{el} eq "td" ||
      $struct->{el} eq "th"
    ){
      my $txt = $this->GetText($struct);
      $txt =~ s/^\s*//g;
      $txt =~ s/\s*$//g;
      utf8::decode($txt);
      $txt =~ s/\N{ZERO WIDTH SPACE}//g;
      utf8::encode($txt);
      return $txt;
    } else {
      print STDERR "ignoring $struct->{el} in ParseSemanticTable"
    }
  }
  sub GetText{
    my($this, $xml) = @_;
    my $ref_desc = ref($xml);
    unless($ref_desc){ return $xml }
    if($ref_desc){
      my $text = "";
      for my $i (@{$xml->{content}}){
        $text .= GetText($this, $i);
      }
      return $text;
    }
    print STDERR "malformed xml: ($xml)";
    Debug::GenPrint($dbg, $xml, 1, 2);
    print STDERR "\n";
    return "";
  };
  sub SetRenderMode{
    my $this = shift @_;
    my $mode = shift @_;
    $this->{RenderMode} = $mode;
    if($mode eq "none") {
       delete $this->{file};
       delete $this->{id};
       delete $this->{desc};
    } elsif($mode eq "svg") {
       delete $this->{id};
       $this->{file} = shift @_;
    } elsif($mode eq "book") {
       $this->{file} = shift @_;
       $this->{id} = shift @_;
       my $parsed_dicom_root = $this->parent->{ParsedDicomRoot};
       open FILE, "GetXmlById.pl \"$parsed_dicom_root/$this->{file}.perl\" " .
         "\"$this->{id}\" |" or die "can't open command";
       my $struct;
       eval {
         $struct = fd_retrieve \*FILE;
       };
       close FILE;
       if($@) { die $@; }
       $this->{StructToRender} = $struct;
    } elsif($mode eq "CompositeIods"){
       $this->{file} = shift @_;
       $this->{id} = shift @_;
       $this->{desc} = shift @_;
       my $struct;
       open my $fd, $this->{file} or die "Can't open $this->{file}\n";
      eval {
         $struct = fd_retrieve $fd;
       };
       close $fd;
       if($@) { die $@; }
       $this->{StructToRender} = $struct;
       $this->InitializeEntitiesAndModules;
    }
    $this->AutoRefresh;
  }
  sub InitializeEntitiesAndModules{
    my($this) = @_;
    delete $this->{Entities};
    delete $this->{SelEntities};
    for my $t (keys %{$this->{StructToRender}->{tags}}){
      if(ref($this->{StructToRender}->{tags}->{$t}) eq "HASH"){
        my $entity = $this->{StructToRender}->{tags}->{$t}->{entity};
        my $module = $this->{StructToRender}->{tags}->{$t}->{module};
        $this->{Entities}->{$entity}->{$module} = 1;
        $this->{SelEntities}->{$entity}->{$module} = "checked";
      } elsif(ref($this->{StructToRender}->{tags}->{$t}) eq "ARRAY") {
        for my $i (@{$this->{StructToRender}->{tags}->{$t}}){
          my $entity = $i->{entity};
          my $module = $i->{module};
          $this->{Entities}->{$entity}->{$module} = 1;
          $this->{SelEntities}->{$entity}->{$module} = 1;
        }
      }
    }
  }
  sub EntitySelection{
    my($this, $http, $dyn) = @_;
    $this->RefreshEngine($http, $dyn,
    '<table border="1"><tr><th>Entity</th><th>Modules</th></tr>' .
    '<?dyn="Entities"?></table>');
  }
  sub Entities{
    my($this, $http, $dyn) = @_;
    for my $i (keys %{$this->{Entities}}){
      $this->RefreshEngine($http, $dyn, 
      '<tr><td><?dyn="Entity" Entity="' . $i . '"?></td>' .
      '<td><?dyn="Modules" Entity="' . $i . '"?></td></tr>');
    }
  }
  sub Entity{
    my($this, $http, $dyn) = @_;
    $http->queue($dyn->{Entity});
  }
  sub Modules{
    my($this, $http, $dyn) = @_;
    my @mods = sort keys %{$this->{Entities}->{$dyn->{Entity}}};
    for my $i (0 .. $#mods){
      my $m = $mods[$i];
      $this->ModuleCheckBox($http, $dyn, $dyn->{Entity}, $m);
      $http->queue("$m");
      unless($i == $#mods) { $http->queue(";&nbsp;") }
    }
  }
  sub ModuleCheckBox{
    my($this, $http, $dyn, $e, $m) = @_;
    $this->RefreshEngine($http, $dyn,
      '<input type="checkbox" name="' . $e .
      '" value="' . $m . '"' .
      (($this->{SelEntities}->{$e}->{$m} eq "checked") ? " checked " : "") .
      'onClick="ns(' . "'" .'SetModuleSelection?obj_path=' . $this->{path} .
      '&amp;module=' . $m . '&amp;entity=' . $e . 
      '&amp;value=' . "'+(this.checked ? 'checked' : 'not_checked'));" . '"/>');
     
  }
  sub SetModuleSelection{
    my($this, $http, $dyn) = @_;
    $this->{SelEntities}->{$dyn->{entity}}->{$dyn->{module}} = $dyn->{value};
    $this->AutoRefresh;
  }
}
1;
