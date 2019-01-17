#!/usr/bin/perl -w
use strict;
package Posda::ProcessBackgroundEditFileInstructions;
use Posda::DB ('Query');
use Posda::ProcessBackgroundEditInstructions;
use vars qw( @ISA );
@ISA = ( "Posda::ProcessBackgroundEditInstructions" );
#sub new{
#  my($class) = @_;
#  return Posda::ProcessBackgroundEditInstructions::new($class);
#}
##############################
# Override ProcessGetObjectFileList (obj_id file_id)
my $get_file_path = Query('GetFilePath');
sub GetObjectFileList{
  my($this, $file_id) = @_;
  my %obj_hash;;
  $get_file_path->RunQuery(sub{
    my($row) = @_;
    my $from_path = $row->[0];
    my $to_path = "$this->{dest_dir}/edited_$file_id.dcm";
    $obj_hash{$file_id} = { from_file => $from_path, to_file => $to_path };
  }, sub {}, $file_id);
  return \%obj_hash;
}
