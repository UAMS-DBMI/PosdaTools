package Posda::PathologyViewer;
use strict;

use Dispatch::LineReader;
use Posda::PopupWindow;
use Posda::ImageDisplayer;
use Posda::FileVisualizer::JPEG;
use Posda::DB qw( Query );
use JSON;
use REST::Client;
use Try::Tiny;

use vars qw( @ISA );
@ISA = ("Posda::PopupWindow", "Posda::ImageDisplayer");
sub MakeQueuer{
  my($http) = @_;
  my $sub = sub {
    my($txt) = @_;
    $http->queue($txt);
  };
  return $sub;
}

sub SpecificInitialize {
  my ($self, $params) = @_;
  $self->{title} = "Pathology Visual Review";
  # Determine temp dir
  # $self->{temp_path} = "$self->{LoginTemp}/$self->{session}";
  $self->{MY_API_URL} = "$ENV{POSDA_INTERNAL_API_URL}/v1/pathology";
  $self->{params} = $params;
  $self->{pathology_visual_review_instance_id} = $params->{pathology_visual_review_instance_id};


  $self->{client} = REST::Client->new();
  $self->{client}->GET("$self->{MY_API_URL}/start/$self->{pathology_visual_review_instance_id}");
  #$self->{path_files_for_review} = "$ENV{POSDA_API_URL}/v1/pathology/start/$self->{pathology_visual_review_instance_id}";
  #$self->{path_files_for_review}  = $client->responseContent()
  $self->{path_files_for_review}  = decode_json($self->{client}->responseContent());
  $self->{num_files}  = scalar(@{$self->{path_files_for_review}});
  $self->{startup} = 1;# as true
  $self->{end} = 0; # as false
  $self->{index} = 0;
  $self->{current_user} = $self->get_user;
  $self->{invertValue} = 0;
  $self->{contrastValue} = 1;
  $self->{hueRotValue} = 0;


}

sub ContentResponse {
 my ($self, $http, $dyn) = @_;
  if ($self->{startup}){
    $http->queue("<h3>Hello $self->{current_user}, Scan Instance $self->{pathology_visual_review_instance_id} has $self->{num_files} image files.</h3>");
    $self->NotSoSimpleButton($http, {
      op => "Begin",
      caption => "Begin",
      sync => "Update();",
    });
  }elsif($self->{index} < $self->{num_files}){
     $self->{pathid} = $self->{path_files_for_review}->[$self->{index}]->{path_file_id};
     $self->{client}->GET("$self->{MY_API_URL}/preview/$self->{pathid}");
     $self->{preview_array}  = decode_json($self->{client}->responseContent());
     $self->{num_prevs}  = scalar(@{$self->{preview_array}});
     $http->queue("<h3>Now viewing file $self->{index} of $self->{num_files} </h3>");
     $self->NotSoSimpleButton($http, {
       op => "backButtonPress",
       caption => "Back",
       sync => "Update();",
     });
     $self->NotSoSimpleButton($http, {
       op => "nextButtonPress",
       caption => "Next",
       sync => "Update();",
     });
     $http->queue("</br>");
     $self->NotSoSimpleButton($http, {
       op => "badButtonPress",
       caption => "Bad",
       sync => "Update();",
     });
     $self->NotSoSimpleButton($http, {
       op => "goodButtonPress",
       caption => "Good",
       sync => "Update();",
     });
     $http->queue("</br>");
     $http->queue("<div border-bottom: 1px solid #eee;>");
     $http->queue("<h3> Visual Manipulations </h3>");
     $http->queue("</div>");
     $self->NotSoSimpleButton($http, {
       op => "invertButtonPress",
       caption => "Invert",
       sync => "Update();",
     });
     $http->queue("Invert Value:  $self->{invertValue}00% </br>");
     $self->NotSoSimpleButton($http, {
       op => "contrastButtonPress",
       caption => "Contrast",
       sync => "Update();",
     });
     $http->queue("Contrast Value:  $self->{contrastValue}00% </br>");
     $self->NotSoSimpleButton($http, {
       op => "hueButtonPress",
       caption => "Hue Rotation",
       sync => "Update();",
     });
     $http->queue("Hue Rotation Value:  $self->{hueRotValue} degrees </br>");
     $self->NotSoSimpleButton($http, {
       op => "clearManipulations",
       caption => "Clear",
       sync => "Update();",
     });
     $http->queue(" </br>");
     my $i = 0;
     my $preview_file_id = 0;
     while ($i < $self->{num_prevs}){
      $preview_file_id = $self->{preview_array}->[$i]->{preview_file_id};
      #$http->queue("- $preview_file_id -");
       Query("GetFilePath")->RunQuery(sub{
           my($row) = @_;
           $self->{file_path} = $row->[0];
       }, sub{}, $preview_file_id );
       $http->queue("<img src=\"FetchPng?obj_path=$self->{path}&file_id=$preview_file_id\"  style=\"width:650px; filter: invert($self->{invertValue}) contrast($self->{contrastValue}) hue-rotate($self->{hueRotValue}deg) \" />");
       #ActivityBasedCuration/StartBackground_0
       $i++;
    }

  }else{
    $http->queue("<h3>Review Complete</h3>");
  }
}

sub Begin {
  my ($self, $http, $dyn) = @_;
  $self->{startup} = 0;
}
sub clearManipulations(){
  my ($self, $http, $dyn) = @_;
  $self->{invertValue} = 0;
  $self->{contrastValue} = 1;
  $self->{hueRotValue} = 1;
}

sub nextButtonPress(){
  my ($self, $http, $dyn) = @_;
  if ($self->{index} < $self->{num_files}){
    $self->{index}++;
  }else{
    $self->{end}= 1;
  }
  $self->clearManipulations();
}

sub backButtonPress(){
  my ($self, $http, $dyn) = @_;
  if ($self->{index} > 0){
    $self->{index}--;
  }
  $self->clearManipulations();
}

sub goodButtonPress(){
  my ($self, $http, $dyn) = @_;
  $self->{client}->PUT("$self->{MY_API_URL}/set_edit/$self->{pathid}/true/$self->{current_user}");
  $self->nextButtonPress();
}

sub badButtonPress(){
  my ($self, $http, $dyn) = @_;
  $self->{client}->PUT("$self->{MY_API_URL}/set_edit/$self->{pathid}/false/$self->{current_user}");
  $self->nextButtonPress();
}
sub invertButtonPress(){
  my ($self, $http, $dyn) = @_;
  if ($self->{invertValue} == 1){
    $self->{invertValue} = 0;
  }else{
    $self->{invertValue} = 1;
  }
}

sub contrastButtonPress(){
  my ($self, $http, $dyn) = @_;
  if ($self->{contrastValue} == 1){
    $self->{contrastValue} = 2;
  }elsif ($self->{contrastValue} == 2){
    $self->{contrastValue} = 3;
  }else{
    $self->{contrastValue} = 1;
  }
}

sub hueButtonPress(){
  my ($self, $http, $dyn) = @_;
  if ($self->{hueRotValue} <= 360){
    $self->{hueRotValue} += 90;
  }else{
    $self->{hueRotValue} = 0;
  }
}


sub MenuResponse {
  my ($self, $http, $dyn) = @_;
}
