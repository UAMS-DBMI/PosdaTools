#!/usr/bin/perl -w
use strict;
use DBI;
use Posda::Config 'Database';
use Posda::Try;
my $c_str = Database('posda_files');
my $db = DBI->connect($c_str);
my $get_work_l = $db->prepare(
"select file_id, root_path || '/' || rel_path as path\n" .
"from dicom_file natural join file_location natural join file_storage_root\n" .
"where dataset_digest is null");
my $upd_dig = $db->prepare(
"update dicom_file set dataset_digest = ? where file_id = ?"
);
$get_work_l->execute;
while(my $h = $get_work_l->fetchrow_hashref){
  my $try = Posda::Try->new($h->{path});
  if(exists $try->{dataset_digest}){
    $upd_dig->execute($try->{dataset_digest}, $h->{file_id});
    print "File $h->{file_id} dataset_digest: $try->{dataset_digest}\n";
  } else {
    print "File $h->{file_id} has no dataset_digest\n";
  }
}
