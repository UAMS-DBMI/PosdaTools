#!/usr/bin/perl -w 
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
use Cwd;
use Posda::DB qw(Query);
use Posda::File::Import 'insert_file';
use Digest::MD5;
#################################################################
#  Initialization  First phase of processing
my $usage = <<EOF;
Usage: ImportMultipleTempFilesIntoPosda.pl <comment>";
or: ImportMultipleTempFilesIntoPosda.pl -h

expects a list of files on STDIN;
  These will be imported into posda and then DELETED
  All of these files will be associated with an import_event with
  an import_comment of <comment>

EOF
if($#ARGV == 0 && $ARGV[0] eq "-h" ) {print STDERR $usage; exit }
unless ($#ARGV == 0) {die $usage;}
my $comment = $ARGV[0];
############################################################
# Create import_event 
Query('InsertEditImportEvent')->RunQuery(
  sub{}, sub{}, "ImportMultipleTempFilesIntoPosda.pl", $comment);
####GetImportEventId
my $ie_id;
Query('GetImportEventId')->RunQuery(sub{
  my($row) = @_;
    $ie_id = $row->[0];
  }, sub {});
my @FileErrors;
############################################################
# Process files on STDIN
while(my $path = <STDIN>){
  chomp $path;
  my $resp = Posda::File::Import::insert_file($path, "", $ie_id);
  if ($resp->is_error){
      die $resp->error;
  }else{
    my $file_id =  $resp->file_id;
  }
  unlink $path;
}
Query('CompleteImportEvent')->RunQuery(sub{},sub{}, $ie_id);
#print STDERR "End of process loop in ImportMultipleFilesIntoPosda.pl\n";
exit;
