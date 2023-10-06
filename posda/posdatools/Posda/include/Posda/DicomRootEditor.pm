package Posda::DicomRootEditor;
use strict;

use Dispatch::LineReader;
use Posda::PopupWindow;
use Posda::DB qw( Query );
use JSON;
use REST::Client;
use Try::Tiny;

use vars qw( @ISA );
@ISA = ("Posda::PopupWindow");

sub SpecificInitialize {
  my ($self, $params) = @_;
  $self->{title} = "DICOM Roots Row Editor";
  $self->{MY_API_URL} = "$ENV{POSDA_INTERNAL_API_URL}/v1/dicom_roots";
  $self->{params} = $params;
  $self->{submission_id} = $params->{rootid};
  $self->{client} = REST::Client->new();
  $self->{client}->GET("$self->{MY_API_URL}/getRecord/$self->{submission_id}");
  $self->{record_data}  = decode_json($self->{client}->responseContent());
  $self->{field}  = "";
  $self->{value}  = "";
  $self->{changing} = "none";
  $self->{site_code_in_examination}  = "";
  $self->{site_name_in_examination}  = "";
}

sub ContentResponse {
  my ($self, $http, $dyn) = @_;

  if ($self->{changing} eq "none"){
    $http->queue("<h3>Viewing DICOM Root record. $self->{submission_id} </h3>");
    $http->queue("<br>------------------------------------------------</br>");
    $http->queue("Site Name:   $self->{record_data}->[0]->{site_name}</br>");
    $http->queue("Site Code: $self->{record_data}->[0]->{site_code}</br>");
    $self->NotSoSimpleButton($http, {
      op => "changeSite",
      caption => "Change Site",
      sync => "Update();",
    });
    $http->queue("<br>------------------------------------------------</br>");
    $http->queue("Collection Name: $self->{record_data}->[0]->{collection_name}</br>");
    $http->queue("Collection Code: $self->{record_data}->[0]->{collection_code}</br>");
    $self->NotSoSimpleButton($http, {
      op => "changeCollection",
      caption => "Change Collection",
      sync => "Update();",
    });
    $http->queue("<br>------------------------------------------------</br>");
    $http->queue("Patient Id Prefix: $self->{record_data}->[0]->{patient_id_prefix}</br>");
    $self->NotSoSimpleButton($http, {
      op => "changePP",
      caption => "edit",
      sync => "Update();",
    });
    $http->queue("<br>------------------------------------------------</br>");
    $http->queue("</br>Body Part: $self->{record_data}->[0]->{body_part}</br>");
    $self->NotSoSimpleButton($http, {
      op => "changeBP",
      caption => "edit",
      sync => "Update();",
    });
    $http->queue("<br>------------------------------------------------</br>");
    $http->queue("</br>Access Type: $self->{record_data}->[0]->{access_type}</br>");
    $self->NotSoSimpleButton($http, {
      op => "changeAC",
      caption => "edit",
      sync => "Update();",
    });
    $http->queue("<br>------------------------------------------------</br>");
    if($self->{record_data}->[0]->{baseline_date}){
      $http->queue("</br>Baseline Date: $self->{record_data}->[0]->{baseline_date}</br>")
    }else{
      $http->queue("</br>Baseline Date: Undefined - this record uses date shift</br>")
    }
    $self->NotSoSimpleButton($http, {
      op => "changeBD",
      caption => "edit",
      sync => "Update();",
    });
    $http->queue("<br>------------------------------------------------</br>");
    if($self->{record_data}->[0]->{date_shift}){
      $http->queue("</br>Date Shift: $self->{record_data}->[0]->{date_shift}</br>");
    }else{
      $http->queue("</br>Date Shift:  Undefined - this record uses baseline date</br>")
    }
    $self->NotSoSimpleButton($http, {
      op => "changeDS",
      caption => "edit",
      sync => "Update();",
    });
    $http->queue("<br>------------------------------------------------</br>");

    $self->DelegateButton($http, {
      op => "Cancel",
      caption => "Cancel",
      sync => "CloseThisWindow();",
    });
  }elsif($self->{changing} eq "pp"){
    $http->queue("Patient Id Prefix: $self->{record_data}->[0]->{patient_id_prefix}</br>");
    $self->{field} = "patient_id_prefix";
    $self->NewEntryBox($http, {
      name => "pip_box",
      op => "SetArg",
      });
      $self->NotSoSimpleButton($http, {
        op => "changeValue",
        caption => "submit",
        sync => "Update();",
    });
  }elsif($self->{changing} eq "bp"){
    $http->queue("</br>Body Part: $self->{record_data}->[0]->{body_part}</br>");
    $self->{field} = "body_part";
    $self->NewEntryBox($http, {
      name => "bp_box",
      op => "SetArg",
      });
    $self->NotSoSimpleButton($http, {
      op => "changeValue",
      caption => "submit",
      sync => "Update();",
    });
  }elsif($self->{changing} eq "ac"){
    $http->queue("</br>Access Type: $self->{record_data}->[0]->{access_type}</br>");
    $self->{field} = "access_type";
    $self->NewEntryBox($http, {
      name => "ac_box",
      op => "SetArg",
      });
    $self->NotSoSimpleButton($http, {
      op => "changeValue",
      caption => "submit",
      sync => "Update();",
    });
    }elsif($self->{changing} eq "bd"){
    $http->queue("</br>Baseline Date: $self->{record_data}->[0]->{baseline_date} (YYYY-MM-DD)</br>");
    $self->{field} = "baseline_date";
    $self->NewEntryBox($http, {
      name => "bd_box",
      op => "SetArg",
      });
      $self->NotSoSimpleButton($http, {
        op => "changeValue",
        caption => "submit",
        sync => "Update();",
      });
  }elsif($self->{changing} eq "ds"){
    $http->queue("</br>Date Shift: $self->{record_data}->[0]->{date_shift}</br>");
    $self->{field} = "date_shift";
    $self->NewEntryBox($http, {
      name => "ds_box",
      op => "SetArg",
      });
    $self->NotSoSimpleButton($http, {
      op => "changeValue",
      caption => "submit",
      sync => "Update();",
    });
  }elsif($self->{changing} eq "site"){
    $http->queue("Site Name:   $self->{record_data}->[0]->{site_name}</br>");
    $http->queue("Site Code: $self->{record_data}->[0]->{site_code}</br>");
    $http->queue("<br>------------------------------------------------</br>");
    $http->queue("This Site is used by the following collection+site combinations:</br>");
    $self->{client}->GET("$self->{MY_API_URL}/searchRoots?site_code=$self->{record_data}->[0]->{site_code}");
    my $search_results  = decode_json($self->{client}->responseContent());
    if ($search_results){
      my $i = 0;
      for( $i < $search_results.length){
        $http->queue("$search_results->[0]->{collection_name} + $search_results->[0]->{site_name}</br>");
      }
    }else{
      $http->queue("No collections are using this site</br>");
    }
    $http->queue("<br>------------------------------------------------</br>");
    $http->queue("I want to change the site for this collection by:</br>");
    $http->queue("Site Code:</br>");
    $self->NewEntryBox($http, {
      name => "site_box_C",
      op => "SetArg",
      });
    $self->NotSoSimpleButton($http, {
      op => "RefreshSite_C",
      caption => "Check Site Info With Code",
      sync => "Update();",
     });
    $http->queue("</br></br>Site Name:</br>");
    $self->NewEntryBox($http, {
      name => "site_box_N",
      op => "SetArg",
      });
    $self->NotSoSimpleButton($http, {
      op => "RefreshSite_N",
      caption => "Check Site Info With Name",
      sync => "Update();",
     });
    try{
      my $search_results2 = [];
      if ($self->{site_code_in_examination}){
         $http->queue("<br>------------------------------------------------</br>");
         $http->queue("$self->{site_name_in_examination} ($self->{site_code_in_examination}) is used by the following collection+site combinations:</br>");
         $self->{client}->GET("$self->{MY_API_URL}/searchRoots?site_code=$self->{site_code_in_examination}");
         $search_results2 = decode_json($self->{client}->responseContent());
       }
       if ($search_results2 and $search_results2->[0] != ''){
         my $i = 0;
         for( $i < $search_results2.length){
           $http->queue("$search_results2->[0]->{collection_name} + $search_results2->[0]->{site_name}</br>");
         }
        }else{
         $http->queue("No collections are using this site</br>");
        }
    } catch {
      $http->queue("Search failed, please enter a different code / name</br>");
    };
    $http->queue("<br>------------------------------------------------</br>");
    $self->{field} = "site_code";
    $self->{value} = $self->{site_code_in_examination};
    $self->NotSoSimpleButton($http, {
       op => "changeValue",
       caption => "Change to this Site!",
       sync => "Update();",
     });
  }elsif($self->{changing} eq "col"){
    $http->queue("Collection Name: $self->{record_data}->[0]->{collection_name}</br>");
    $http->queue("Collection Code: $self->{record_data}->[0]->{collection_code}</br>");
    $http->queue("<br>------------------------------------------------</br>");
    $http->queue("This Collection is associated with the following collection+site combinations:</br>");
    $self->{client}->GET("$self->{MY_API_URL}/searchRoots?collection_code=$self->{record_data}->[0]->{collection_code}");
    my $search_results  = decode_json($self->{client}->responseContent());
    if ($search_results){
      my $i = 0;
      for( $i < $search_results.length){
        $http->queue("$search_results->[0]->{collection_name} + $search_results->[0]->{site_name}</br>");
      }
   }else{
      $http->queue("No collections are  associated with this collection</br>");
   }
   $http->queue("<br>------------------------------------------------</br>");
   $http->queue("I want to change the collection associated with this site to:</br>");
   $self->NewEntryBox($http, {
     name => "collection_box",
     op => "SetArg",
     });
   $self->NotSoSimpleButton($http, {
     op => "RefreshCollection",
     caption => "Check Collection Info",
     sync => "Update();",
    });
    my $search_results2 = [];
    if ($self->{collection_code_in_examination}){
      if ($self->{collection_code_in_examination} =~ /^\d{4}$/){ #if they enter a code
        $self->{client}->GET("$self->{MY_API_URL}/findCollectionNameFromCode/$self->{collection_code_in_examination}");
        my $collection_name = decode_json($self->{client}->responseContent());
        $http->queue("<br>------------------------------------------------</br>");
        $http->queue("$collection_name ($self->{collection_code_in_examination}) is associated with the following collection+site combinations:</br>");
        $self->{client}->GET("$self->{MY_API_URL}/searchRoots?collection_code=$self->{record_data}->[0]->{collection_code_in_examination}");
        $search_results2 = decode_json($self->{client}->responseContent());
     }else{
        $self->{client}->GET("$self->{MY_API_URL}/findCollectionCodeFromName/$self->{collection_code_in_examination}");
        my $collection_code = decode_json($self->{client}->responseContent());
        $http->queue("<br>------------------------------------------------</br>");
        $http->queue("($self->{collection_code_in_examination}) $collection_code  is associated with the following collection+site combinations:</br>");
        $self->{client}->GET("$self->{MY_API_URL}/searchRoots?collection_code=$collection_code");
        $search_results2  = decode_json($self->{client}->responseContent());
     }
     if ($search_results2 and $search_results2->[0] != ''){
       my $i = 0;
       for( $i < $search_results2.length){
         $http->queue("$search_results2->[0]->{collection_name} + $search_results2->[0]->{collection_name}</br>");
       }
      }else{
       $http->queue("No sites are associated with this collection</br>");
      }
   }
   $http->queue("<br>------------------------------------------------</br>");
   $self->{field} = "collection_code";
   $self->NotSoSimpleButton($http, {
      op => "changeValue",
      caption => "Change to this Collection!",
      sync => "Update();",
    });
  }
}

sub SetArg{
  my ($self, $http, $dyn) = @_;
  $self->{value}  = $dyn->{value};
}

sub changeSite{
  my ($self, $http, $dyn) = @_;
  $self->{changing} = "site";
}
sub changeCollection{
  my ($self, $http, $dyn) = @_;
    $self->{changing} = "col";
}
sub changeValue{
  my ($self, $http, $dyn) = @_;
  $self->SendChange($self,$http,$dyn);
  $self->{field} = "";
  $self->{value} = "";
  $self->{changing} = "none";
}
sub changePP{
  my ($self, $http, $dyn) = @_;
  $self->{changing} = "pp";
}
sub changeBP{
  my ($self, $http, $dyn) = @_;
  $self->{changing} = "bp";
}
sub changeAC{
  my ($self, $http, $dyn) = @_;
  $self->{changing} = "ac";
}
sub changeBD{
  my ($self, $http, $dyn) = @_;
  $self->{changing} = "bd";
}
sub changeDS{
  my ($self, $http, $dyn) = @_;
  $self->{changing} = "ds";
}

sub SendChange{
   my ($self, $http, $dyn) = @_;
   $self->{client}->PUT("$self->{MY_API_URL}/updateRecord/$self->{submission_id}/$self->{field}/$self->{value}");
   $self->RefreshData($self,$http,$dyn);
}

sub RefreshData{
    my ($self, $http, $dyn) = @_;
    $self->{client}->GET("$self->{MY_API_URL}/getRecord/$self->{submission_id}");
    $self->{record_data}  = decode_json($self->{client}->responseContent());
    $self->{field}  = "";
    $self->{value}  = "";
    $self->{changing} = "none";
    $self->QueueJsCmd("Update();");
}

sub RefreshSite_C{
  my ($self, $http, $dyn) = @_;
  $self->{site_code_in_examination} = $self->{value};
  $self->{client}->GET("$self->{MY_API_URL}/findSiteNameFromCode/$self->{site_code_in_examination}");
  my $site_name = decode_json($self->{client}->responseContent());
  $self->{site_name_in_examination} = $site_name;
}
sub RefreshSite_N{
  my ($self, $http, $dyn) = @_;
  $self->{site_name_in_examination} = $self->{value};
}
sub RefreshCollection{
  my ($self, $http, $dyn) = @_;
  $self->{collection_code_in_examination} = $self->{value};
}
sub MenuResponse {
  my ($self, $http, $dyn) = @_;
}

#causign errors
sub RenderSiteDropDown {
  my ($self, $http, $dyn) = @_;
  my @sitelist;
  push @sitelist, ["<none>", "----- No Site Selected ----"];
  $self->{client}->GET("$self->{MY_API_URL}/getSitePairs");
  my $search_r  = decode_json($self->{client}->responseContent());
  my $j = 0;
    for( $j < $search_r.length){
     push @sitelist, [$j]
  }
  $self->SelectDelegateByValue($http, {
    op => 'RefreshSite_C',
    id => "SelectSiteDropDown",
    sync => "Update();",
  });
  for my $m (@sitelist){
    $http->queue("<option value=\"$m->[0]\"");
    $http->queue(">$m->[1]</option>");
  }
  $http->queue(qq{
    </select>
  });
}
