#!/usr/bin/perl
while(my $line = <STDIN>){
  chomp $line;
  $line =~ s/^\s*//;
  $line =~ s/\s*$//;
  print "select distinct site_name, patient_id|| '&' ||\n" .
    "study_instance_uid || '&' ||\n" .
    "series_instance_uid\n" .
    "from ctp_file natural join file_series\n" .
    "natural join file_study natural join file_patient\n" .
    "where series_instance_uid = '$line';\n";
}
