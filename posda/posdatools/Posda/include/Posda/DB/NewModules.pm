#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
package Posda::DB::NewModules;
use Posda::DB 'Query';
use Posda::Dataset;
use Carp;
use Debug;
my $dbg = sub { print STDERR @_ };
use vars qw( %ModuleTables );
##################
#  Initialize Module Data
##################
{
  my %module_to_table;
  my %query_args;
  my %insert_parms;
  my $get_modules_to_tables = Query('GetModuleToPosdaTable');
  my $get_query_args = Query('GetQueryArgs');
  my $get_table_args = Query('GetModuleToTableArgs');
  $get_modules_to_tables->RunQuery(sub {
    my($row) = @_;
    $module_to_table{$row->[0]} = {
      query => $row->[1],
      table => $row->[2]
    };
  }, sub {});
  for my $Module (keys %module_to_table){
    my $ins_query = $module_to_table{$Module}->{query};
    my $table_name = $module_to_table{$Module}->{table};
    $get_query_args->RunQuery(sub {
      my($row) = @_;
      $query_args{$table_name} = $row->[0];
    }, sub {}, $ins_query);
    my @rows;
    $get_table_args->RunQuery(sub {
      my($row) = @_;
      push @rows, $row;
    }, sub {}, $table_name);
    $insert_parms{$table_name} =  \@rows;
    my $table = $module_to_table{$Module}->{table};
    $ModuleTables{$Module}->{insert_query} = $module_to_table{$Module}->{query};
    $ModuleTables{$Module}->{query_arg_list} = $query_args{$table};
    row:
    for my $i (@{$insert_parms{$table}}){
      my $cannon_name = $i->[0];
      my $tag = $i->[1];
      my $table_c = $i->[2];
      my $column = $i->[3];
      my $Modification = $i->[4];
      unless($table eq $table_c){
        print "Error table names don't match: $table vs $table_c\n";
        next row;
      }
      $ModuleTables{$Module}->{mod_parms}->{$column} = $tag;
      if(defined $Modification){
        $ModuleTables{$Module}->{mod_list}->{$column} = $Modification;
      }
    }
  }
}
##################
#  End Initialize Module Data
##################
sub ImportModule{
  my($ds, $module, $file_id, $hist, $errors) = @_;
  my $mod_parms = $ModuleTables{$module}->{mod_parms};
  my $mod_list = $ModuleTables{$module}->{mod_list};
  my $query_args = $ModuleTables{$module}->{query_arg_list};
  my $ins_module = Query($ModuleTables{$module}->{insert_query});
  my $parms = GetAttrs($ds, $mod_parms, $mod_list, $errors);
  my @ins_parms;
  for my $a (@$query_args){
    if(exists $parms->{$a}){
      push(@ins_parms, $parms->{$a});
    } elsif($a eq "file_id"){
      push(@ins_parms, $file_id);
    } else {
      print STDERR "parm: $a, not in column list, nor is file_id\n";
    }
  }
  $ins_module->RunQuery(sub{}, sub {}, @ins_parms);
}
#sub Study{
#  my($db, $ds, $file_id, $hist, $errors) = @_;
#  my $study_parms = {
#    study_instance_uid => "(0020,000d)",
#    study_date => "(0008,0020)",
#    study_time => "(0008,0030)",
#    referring_phy_name => "(0008,0090)",
#    study_id => "(0020,0010)",
#    accession_number => "(0008,0050)",
#    study_description => "(0008,1030)",
#    phys_of_record => "(0008,1048)",
#    phys_reading => "(0008,1060)",
#    admitting_diag => "(0008,1080)",
#  };
#  my $ModList = {
#    study_date => "Date",
#    study_time => "Timetag",
#    phys_of_record => "MultiText",
#    phys_reading => "MultiText",
#    admitting_diag => "MultiText",
#  };
#  my $parms = GetAttrs($ds, $study_parms, $ModList, $errors);
#  my $ins_study = $db->prepare(
#    "insert into file_study\n" .
#    "  (file_id, study_instance_uid, study_date,\n" .
#    "   study_time, referring_phy_name, study_id,\n" .
#    "   accession_number, study_description, phys_of_record,\n" .
#    "   phys_reading, admitting_diag)\n" .
#    "values\n" .
#    "  (?, ?, ?,\n" .
#    "   ?, ?, ?,\n" .
#    "   ?, ?, ?,\n" .
#    "   ?, ?)"
#  );
#  return $ins_study->execute(
#    $file_id,
#    $parms->{study_instance_uid},
#    $parms->{study_date},
#    $parms->{study_time},
#    $parms->{referring_phy_name},
#    $parms->{study_id},
#    $parms->{accession_number},
#    $parms->{study_description},
#    $parms->{phys_of_record},
#    $parms->{phys_reading},
#    $parms->{admitting_diag},
#  );
#}
sub GetAttrs{
  my($ds, $parms, $mod, $errors) = @_;
  my %ret;
  for my $key (keys %$parms){
    my $value = $ds->ExtractElementBySig($parms->{$key});
    if(exists $mod->{$key}){
      my $dispatch = {
        Date => sub {
          my($text, $id) = @_;
          unless(defined $text) { return undef };
          if($text eq "<undef> ") { return undef };
          if(
            $text &&
            $text =~ /^(....)(..)(..)$/
          ){
            my $y = $1; my $m = $2; my $d = $3;
            if($y eq "    "){
              push(@$errors, "Bad date \"$text\" in $id");
              return undef;
            }
            if($y eq "????"){
              push(@$errors, "Bad date \"$text\" in $id");
              return undef;
            }
            if($m =~ /^ (\d)$/){
              $m = "0".$1;
            }
            if($d =~ /^ (\d)$/){
              $d = "0".$1;
            }
            unless($y >0 && $m > 0 && $m < 13 && $d > 0 && $d < 32 ){
              push(@$errors, "Bad date \"$text\" in $id");
              return undef;
            }
            $text = sprintf("%04d/%02d/%02d", $y, $m, $d);
            return $text;
          } else {
            push(@$errors, "Bad date \"$text\" in $id");
            return undef;
          }
        },
        Timetag => sub {
          my($time, $id) = @_;
          unless(defined $time) { return undef };
          if(
            $time && 
            $time =~ /^(\d\d)(\d\d)(\d\d)$/
          ){
            $time = "$1:$2:$3";
            return $time;
          } elsif (
            $time && 
            $time =~ /^(\d\d)(\d\d)(\d\d)\.(\d+)$/
          ){
            $time = "$1:$2:$3.$4";
            return $time;
          } else {
            push(@$errors, "Bad time \"$time\" in $id");
            return undef;
          }
        },
        MultiText => sub {
          my($text, $id) = @_;
          if(ref($text) eq "ARRAY"){
            $text = join("\\", @$text);
          }
          return $text;
        },
        UndefIfNotNumber => sub {
          my($text, $id) = @_;
          unless(defined $text){ return undef }
          unless($text =~ /^\s*[+-]?[0-9]+\s*$/){
            push(@$errors, "Bad number \"$text\" in $id");
            return undef;
          }
          return $text;
        },
        Integer => sub {
          my($text, $id) = @_;
          unless(defined $text) { return undef }
          my $int = int($text);
          unless($int == $text){
            push @$errors, "Error making $text an integer\n";
          }
          return $int;
        },
      };
      if(exists $dispatch->{$mod->{$key}}){
         $value = &{$dispatch->{$mod->{$key}}}($value, $key);
      }
    }
    $ret{$key} = $value;
  }
  return \%ret
}
1;
