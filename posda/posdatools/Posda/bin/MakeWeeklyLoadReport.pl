#!/usr/bin/perl -w
use strict;
use Posda::DB 'Query';
use Posda::BackgroundProcess;
use Debug;
my $dbg = sub{print STDERR @_};
my $usage = <<EOF;
MakeWeeklyLoadReport.pl <?bkgrnd_id?> <notify> <from> <to>
or
MakeWeeklyLoadReport.pl -h

No input on stdin

EOF
sub CondenseType{
  my($type) = @_;
  if($type =~ /PNG image/){
    return "PNG image";
  } elsif($type eq ""){
    return "<undefined or empty>";
  } elsif($type =~ /XML.*document/){
    return "XML document";
  } elsif($type =~ /Microsoft.*Excel/){
    return "Microsoft Excel";
  } elsif($type =~ /Microsoft.*Word/){
    return "Microsoft Word";
  } elsif($type eq "parsed dicom file"){
    return "Good DICOM";
  } elsif($type =~ "DICOM medical"){
    return "Bad DICOM";
  } elsif($type =~ "PDF document"){
    return "PDF document";
  } elsif($type =~ "ASCII.*text"){
    return "ASCII Text";
  } elsif($type =~ "Unicode.*text"){
    return "Unicode Text";
  } elsif($type =~ "ISO-8859.*text"){
    return "ISO-8859 Text";
  } else {
    return $type;
  }
}
unless($#ARGV == 3 ){ die $usage }
my $invoc_id = $ARGV[0];
my $notify = $ARGV[1];
my $from = $ARGV[2];
my $to = $ARGV[3];
unless($from =~ /^\d\d\d\d-\d\d-\d\d$/){
  print "from should be yyyy-mm-dd\n";
  exit;
}
unless($to =~ /^\d\d\d\d-\d\d-\d\d$/){
  print "to should be yyyy-mm-dd\n";
  exit;
}
my $back = Posda::BackgroundProcess->new($invoc_id, $notify);
print "Processing all in backgound\n";
$back->Daemonize;
my $g_start = Query("GetStartOfWeek");
my $g_end = Query("GetEndOfWeek");
my $g_today = Query("GetToday");
my $week_info = Query("RawFilesByDateRange");
$back->WriteToEmail("Starting WeeklyLoadReport\n");
my @Weeks;
my $start_week;
$g_start->RunQuery(sub{
  my($row) = @_;
  $start_week = $row->[0];
  if($start_week =~ /^(....-..-..)/){
    $start_week = $1;
  }
}, sub{}, $from);
my $end_week;
$g_end->RunQuery(sub{
  my($row) = @_;
  $end_week = $row->[0];
  if($end_week =~ /^(....-..-..)/){
    $end_week = $1;
  }
}, sub{}, $to);
my $cur_week = $start_week;
while ($cur_week lt $end_week){
  my $next_week;
  $g_end->RunQuery(sub{
    my($row) = @_;
    $next_week = $row->[0];
    if($next_week =~ /^(....-..-..)/){
      $next_week = $1;
    }
  }, sub{}, $cur_week);
  push(@Weeks, [$cur_week, $next_week]);
  $cur_week = $next_week;
}
my $num_weeks = @Weeks;
$back->WriteToEmail("$num_weeks weeks\n");
$back->WriteToEmail("From $start_week to $end_week\n");
my @Rows;
my %AllFileTypes;
for my $i (@Weeks){
  my $Row = {
    week_starting => $i->[0],
    types => {},
  };
  $week_info->RunQuery(sub{
    my($row) = @_;
    my($file_type, $max_file_id, $min_file_id,
      $num_files, $largest, $smallest, $total_size,
      $avg_size) = @$row;
    my $type = CondenseType($file_type);
    $AllFileTypes{$type} = 1;
    if(! exists($Row->{types}->{$type})){
      $Row->{types}->{$type} = {
        max_id => $max_file_id,
        min_id => $min_file_id,
        num_files => $num_files,
        largest => $largest,
        smallest => $smallest,
        total_bytes => $total_size,
      };
    } else {
      if($min_file_id < $Row->{types}->{$type}->{min_id}){
        $Row->{types}->{$type}->{min_id} = $min_file_id;
      }
      if($max_file_id > $Row->{types}->{$type}->{max_id}){
        $Row->{types}->{$type}->{max_id} = $max_file_id;
      }
      $Row->{types}->{$type}->{num_files} += $num_files;
      $Row->{types}->{$type}->{total_bytes} += $total_size;
      if($largest > $Row->{types}->{$type}->{largest}){
        $Row->{types}->{$type}->{largest} = $largest;
      }
      if($smallest < $Row->{types}->{$type}->{smallest}){
        $Row->{types}->{$type}->{smallest} = $smallest;
      }
    }
  }, sub {}, 'week', $i->[0], $i->[1]);
  push(@Rows, $Row);
}
my @Types = sort keys %AllFileTypes;
$back->WriteToEmail("File types found:\n");
for my $i (0 .. $#Types){
  my $seq = $i + 1;
  $back->WriteToEmail("$seq: $Types[$i]\n");
}
my $rpt = $back->CreateReport("File Types and Counts By Week");
$rpt->print("key,value\r\n");
$rpt->print("report_name,File Types and Counts By Week\r\n");
my $date = `date`;
chomp $date;
$rpt->print("date run,$date\r\n");
$rpt->print("from,$from\r\n");
$rpt->print("to,$to\r\n");
$rpt->print("run by, $notify\r\n\r\n");
$rpt->print("week starting");
for my $t (@Types){
  $t =~ s/"/""/g;
  $rpt->print(",\"$t\",,,,,");
}
$rpt->print("\r\n");
for my $t (@Types){
  $rpt->print(",max_id,min_id,num_files,largest,smallest,total_bytes");
}
$rpt->print("\r\n");
for my $r (@Rows){
  $rpt->print($r->{week_starting});
  for my $t (@Types){
    if(exists $r->{types}->{$t}){
      $rpt->print(
        ",$r->{types}->{$t}->{max_id}," .
        "$r->{types}->{$t}->{min_id}," .
        "$r->{types}->{$t}->{num_files}," .
        "$r->{types}->{$t}->{largest}," .
        "$r->{types}->{$t}->{smallest}," .
        "$r->{types}->{$t}->{total_bytes}");
    } else {
      $rpt->print(",,,,,,");
    }
  }
  $rpt->print("\r\n");
}
$back->Finish;
