package Posda::PathologyViewer;
use strict;

use Dispatch::LineReader;
use Posda::PopupWindow;
use Posda::ImageDisplayer;
use Posda::FileVisualizer::JPEG;
use Posda::DB qw( Query );
use JSON;
use Posda::Api;
use Try::Tiny;
use Data::Dumper;
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

  $self->{height} = 900;
  $self->{width} = 1100;

  $self->{MY_API_URL} = "$ENV{POSDA_INTERNAL_API_URL}/v1/pathology";
  $self->{params} = $params;
  $self->{pathology_visual_review_instance_id} = $params->{pathology_visual_review_instance_id};


  $self->{client} = Posda::Api->new_rest_client();
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
  $self->{gammaIndex} = 2;
  $self->{label_setting} = 0;
  $self->{macro_setting} = 0;
  $self->{review_status} = "";
  $self->{edit_status} = "";
  $self->{preview_file_id} = 0;
  $self->{prev_id} = 0;

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
     if($self->{pixel_view}){
      $self->{pixel_preview_file_id}  = $self->{preview_array}->[$self->{prev_id}]->{preview_file_id};
      $self->SubmitValueButton($http, {
        op => "submit_redaction",
        element_id => 'composite_box',
        id => 'redaction_submission',
        caption => "Submit",
        sync => "Update();",
      });
      $self->NotSoSimpleButton($http, {
        op => "update_pixel_image",
        caption => "Change Preview Image",
        sync => "Update();",
      });
      $self->NotSoSimpleButton($http, {
        op => "cancel_redaction",
        caption => "Cancel",
        sync => "Update();",
      });
      $http->queue("<h3>Now redacting file $self->{visible_index} of $self->{num_files} </h3>");
      $http->queue("File $self->{path_file_id} preview: $self->{preview_array}->[$self->{prev_id}]->{preview_file_id} the $self->{prev_id} index.");
             $http->queue(qq{
                 <form>
                 <td><input type="text" id="composite_box" readonly hidden></td>
                 <table>
                  <tr>
                      <td><label>Start X: </label></td>
                      <td><input type="text" id="x_box" readonly></td>
                      <td><label>Start Y: </label></td>
                      <td><input type="text" id="y_box" readonly></td>
                  </tr>
                  <tr>
                      <td><label>Width: </label></td>
                      <td><input type="text" id="w_box" readonly></td>
                      <td><label>Height: </label></td>
                      <td><input type="text" id="h_box" readonly></td>
                  </tr>
                </table>
                </form>
              });

      $http->queue("<canvas id=\"mycanvas\" width=\"1500\" height=\"1500\"> </canvas>");
      $http->queue(qq{<div style="visibility:hidden;">
              <img src=\"FetchPng?obj_path=$self->{path}&file_id=$self->{pixel_preview_file_id}\" id=\"my_pixel_image\"/>
              </div>});
     }else{
       $self->{pathid} = $self->{path_files_for_review}->[$self->{index}]->{path_file_id};
       $self->{client}->GET("$self->{MY_API_URL}/preview/$self->{pathid}/$self->{gammaIndex}");
       $self->{preview_array}  = decode_json($self->{client}->responseContent());
       $self->{num_prevs}  = scalar(@{$self->{preview_array}});
       $self->{visible_index} = $self->{index}+1;
       $http->queue("<h3>Now viewing file $self->{visible_index} of $self->{num_files} </h3>");
       $self->{client}->GET("$self->{MY_API_URL}/mapping/$self->{pathid}");
       $self->{patient_id} = (decode_json($self->{client}->responseContent()))->[0]->{patient_id};
       $self->{client}->GET("$self->{MY_API_URL}/image_desc/$self->{pathid}");
       $self->{image_desc_array} = (decode_json($self->{client}->responseContent()));
       $self->{num_image_desc} = scalar(@{$self->{image_desc_array}});
       $http->queue("<b>Posda File ID:</b> <br> $self->{pathid}");
       $http->queue(" <br>----------------------------- <br>");
       $self->{client}->GET("$self->{MY_API_URL}/find_edits/$self->{pathid}");
       $self->{edits} = (decode_json($self->{client}->responseContent()));
       $self->{num_edits} = scalar(@{$self->{edits}});

       if ($self->{patient_id}){
        $http->queue("<b>Patient ID:</b> $self->{patient_id}");
        $http->queue(" <br>----------------------------- <br>");
       }
       if ($self->{num_image_desc} and $self->{num_image_desc} > 0){
          $http->queue("<b>Image Description:</b> <br>");
          $http->queue("<br>----------------------------- <br>");
          my $j = 0;
          while ($j < $self->{num_image_desc}){
             $http->queue("Layer $self->{image_desc_array}->[$j]->{layer_id}: $self->{image_desc_array}->[$j]->{image_desc}</br></br>");
             $j++;
          }
        }
       $self->NotSoSimpleButton($http, {
         op => "removeFButtonPress",
         caption => "Remove File from Collection",
         sync => "Update();",
       });
       $http->queue("</br>");
       $self->NotSoSimpleButton($http, {
         op => "metaEditButtonPress",
         caption => "Metadata Redaction",
         sync => "Update();",
       });
       $http->queue("</br>");
       if ($self->{num_edits} and $self->{num_edits} > 0){
        $http->queue("<br>----------------------------- <br>");
        $http->queue("<b>This file has  $self->{num_edits} queued edits.</b></br>");
        my $j = 0;
        while ($j < $self->{num_edits}){
           if ($self->{edits}->[$j]->{edit_type} == '1'){
              $http->queue("<b>Macro slide removal queued</b></br>");
           }elsif ($self->{edits}->[$j]->{edit_type} == '2'){
              $http->queue("<b>Label slide removal queued</b></br>");
           }elsif ($self->{edits}->[$j]->{edit_type} == '3'){
              $http->queue("<b>Metadata edit queued</b></br>");
           }elsif ($self->{edits}->[$j]->{edit_type} == '4'){
              $http->queue("<b>Removal of entire file queued</b></br>");
           }elsif ($self->{edits}->[$j]->{edit_type} == '5'){
              $http->queue("<b>Pixel Redaction edit queued</b></br>");
           }else{
              $http->queue("<b>Edit queued</b></br>");
           }
           $j++;
        }
        $self->NotSoSimpleButton($http, {
           op => "editCancelButtonPress",
           caption => "Cancel queued edits",
           sync => "Update();",
        });
        $http->queue("<br>----------------------------- <br>");
       }

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
         op => "pixel_mode_start",
         caption => "Redact Pixels",
         sync => "Update();",
       });
       $http->queue("</br>");
       $self->NotSoSimpleButton($http, {
         op => "removeMacroButtonPress",
         caption => "Remove Macro",
         sync => "Update();",
       });
       $self->NotSoSimpleButton($http, {
         op => "removeLabelButtonPress",
         caption => "Remove Label",
         sync => "Update();",
       });
       $http->queue("</br>");
       $http->queue("<div border-bottom: 1px solid #eee;>");
       $http->queue("<h3> Visual Manipulations </h3>");
       $http->queue("</div>");

       #invert tools
       $self->NotSoSimpleButton($http, {
         op => "invertButtonPress",
         caption => "Invert",
         sync => "Update();",
       });
       $http->queue("Invert Value:  $self->{invertValue}00% </br>");

       #contrast tools
       $self->NotSoSimpleButton($http, {
         op => "contrastButtonPress",
         caption => "Contrast",
         sync => "Update();",
       });
       $http->queue("Contrast Value:  $self->{contrastValue}00% </br>");

       #hue tools
       $self->NotSoSimpleButton($http, {
         op => "hueButtonPress",
         caption => "Hue Rotation",
         sync => "Update();",
       });
       $http->queue("Hue Rotation Value:  $self->{hueRotValue} degrees </br>");

       #gamma tools
       $self->NotSoSimpleButton($http, {
         op => "gammaButtonPress",
         caption => "gamma",
         sync => "Update();",
       });
        if ( $self->{gammaIndex} == 0){
        $http->queue("Gamma Value: 0.4 </br>");
        }elsif ( $self->{gammaIndex} == 1){
         $http->queue("Gamma Value: 0.2 </br>");
        }elsif ( $self->{gammaIndex} == 2) {
         $http->queue("Gamma Value: Base </br>");
        }elsif ( $self->{gammaIndex} == 3){
         $http->queue("Gamma Value: 1.2 </br>");
       }else{
        $http->queue("Gamma Value: 2.2 </br>");
       }
       $self->NotSoSimpleButton($http, {
         op => "clearManipulations",
         caption => "Clear",
         sync => "Update();",
       });
       $http->queue("</br>");
       my $i = 0;
       $self->{preview_file_id} = 0;
       while ($i < $self->{num_prevs}){
        $self->{preview_file_id}  = $self->{preview_array}->[$i]->{preview_file_id};
        #$http->queue("- $preview_file_id -");
         # Query("GetFilePath")->RunQuery(sub{
         #     my($row) = @_;
         #     $self->{file_path} = $row->[0];
         # }, sub{}, $self->{preview_file_id}  );
         $http->queue("<img src=\"FetchPng?obj_path=$self->{path}&file_id=$self->{preview_file_id}\"  style=\"width:650px; filter: invert($self->{invertValue}) contrast($self->{contrastValue}) hue-rotate($self->{hueRotValue}deg) \" />");
         #ActivityBasedCuration/StartBackground_0
         $i++;
        }
    }
    $self->QueueJsCmd(qq{

        (function checkCanvasAndImage() {
          console.log("Window loaded, running script...");
          const mycanvas = document.getElementById('mycanvas');
          const myimage = document.getElementById('my_pixel_image');
          const x_box = document.getElementById('x_box');
          const y_box = document.getElementById('y_box');
          const w_box = document.getElementById('w_box');
          const h_box = document.getElementById('h_box');
          const composite_box = document.getElementById('composite_box');


          if (mycanvas && myimage && myimage.complete) {
              const mycontent = mycanvas.getContext('2d');
              mycontent.drawImage(myimage, 0,0);

              isDrawing = true;
              let startX;
              let startY;

              mycanvas.addEventListener('mousedown', function(e) {
                  isDrawing = true;
                  startX = e.offsetX;
                  startY = e.offsetY;
              });

              mycanvas.addEventListener('mousemove', function(e) {
                  if (isDrawing) {
                      let currentX = e.offsetX;
                      let currentY = e.offsetY;
                      mycontent.clearRect(0, 0, mycanvas.width, mycanvas.height);
                      mycontent.drawImage(myimage, 0, 0);
                      mycontent.strokeStyle = 'red';
                      mycontent.lineWidth = 2;
                      mycontent.strokeRect(startX, startY, currentX - startX, currentY - startY);
                  }
              });

              mycanvas.addEventListener('mouseup', function(e) {
                  isDrawing = false;
                  let currentX = e.offsetX;
                  let currentY = e.offsetY;
                  mycontent.fillStyle = 'black';
                  mycontent.fillRect(startX, startY, currentX - startX, currentY - startY);
                  let width = currentX - startX
                  let height = currentY - startY
                  if (width > 0){
                    x_box.value = startX;
                  }else{
                    x_box.value = currentX;
                  }
                  if (height > 0){
                    y_box.value = startY;
                  }else{
                    y_box.value = currentY;
                  }
                  w_box.value = Math.abs(width)
                  h_box.value = Math.abs(height)
                  composite_box.value = x_box.value + ',' + y_box.value + ',' + w_box.value + ',' + h_box.value + ',' + myimage.width + ',' + myimage.height
              });

          } else {
                setTimeout(checkCanvasAndImage, 100);
          }
      })();

    });
  }else{
    #print STDERR Dumper($self);
    $http->queue("<h3>Review Complete</h3>");
    $self->{client}->GET("$self->{MY_API_URL}/getActEditsByPVRID/$self->{pathology_visual_review_instance_id}");
    $self->{pvrid_edit_counts} = (decode_json($self->{client}->responseContent()));
    $self->{num_pvrid_edit_counts} = scalar(@{$self->{pvrid_edit_counts}});
    my $l = 0;
    #print STDERR Dumper($self);
    while ($l < $self->{num_pvrid_edit_counts}){
      $http->queue("File $self->{pvrid_edit_counts}->[$l]->{file} has $self->{pvrid_edit_counts}->[$l]->{count} edit(s) waiting.</br>");
      $l++;
    }
    $http->queue("</br></br>Please commit any awaiting edits and then create another visual review.");
  }
}

sub Begin() {
  my ($self, $http, $dyn) = @_;
  $self->{startup} = 0;
}

sub pixel_mode_start(){
   my ($self, $http, $dyn) = @_;
   $self->{pixel_view} = 1;
 }

sub submit_redaction(){
  my ($self, $http, $dyn) = @_;
  my $dims = $dyn->{value};
  $self->{client}->PUT("$self->{MY_API_URL}/redact/$dims/$self->{pathid}");
  $self->{client}->PUT("$self->{MY_API_URL}/set_edit/$self->{pathid}/false/$self->{current_user}");
  $self->{pixel_view} = 0;
}

sub cancel_redaction(){
  my ($self, $http, $dyn) = @_;
  $self->{pixel_view} = 0;
}

sub update_pixel_image(){
  my ($self, $http, $dyn) = @_;
  if ($self->{prev_id} < ($self->{num_prevs}-1)){
      $self->{prev_id} = $self->{prev_id}  + 1;
  }else{
    $self->{prev_id} = 0;
  }
  $self->{pixel_preview_file_id}  = $self->{preview_array}->[$self->{prev_id}]->{preview_file_id};
}


sub clearManipulations(){
  my ($self, $http, $dyn) = @_;
  $self->{invertValue} = 0;
  $self->{contrastValue} = 1;
  $self->{hueRotValue} = 1;
  $self->{gammaIndex} = 2;
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

sub gammaButtonPress(){
  my ($self, $http, $dyn) = @_;
  if ($self->{gammaIndex} == 4){
    $self->{gammaIndex} = 0;
  }else{
    $self->{gammaIndex} = $self->{gammaIndex} + 1;
  }
}

sub removeMacroButtonPress(){
  my ($self, $http, $dyn) = @_;
  $self->{client}->PUT("$self->{MY_API_URL}/remM/$self->{pathid}");
  $self->{client}->PUT("$self->{MY_API_URL}/set_edit/$self->{pathid}/false/$self->{current_user}");
  #grey button out
  #alert user

}

sub removeLabelButtonPress(){
  my ($self, $http, $dyn) = @_;
  $self->{client}->PUT("$self->{MY_API_URL}/remL/$self->{pathid}");
  $self->{client}->PUT("$self->{MY_API_URL}/set_edit/$self->{pathid}/false/$self->{current_user}");
}

sub metaEditButtonPress(){
  my ($self, $http, $dyn) = @_;
  $self->{client}->PUT("$self->{MY_API_URL}/editMeta/$self->{pathid}");
  $self->{client}->PUT("$self->{MY_API_URL}/set_edit/$self->{pathid}/false/$self->{current_user}");
}

sub removeFButtonPress(){
  my ($self, $http, $dyn) = @_;
  $self->{client}->PUT("$self->{MY_API_URL}/removeF/$self->{pathid}");
  $self->{client}->PUT("$self->{MY_API_URL}/set_edit/$self->{pathid}/false/$self->{current_user}");
}

sub editCancelButtonPress(){
  my ($self, $http, $dyn) = @_;
  $self->{client}->PUT("$self->{MY_API_URL}/cancelEdit/$self->{pathid}");
}



sub MenuResponse {
  my ($self, $http, $dyn) = @_;
}
