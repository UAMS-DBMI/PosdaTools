#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/bin/contrib/MakePlan.pl,v $
#$Date: 2008/07/24 11:30:24 $
#$Revision: 1.2 $

use strict;
use Posda::Dataset;
use GetNewPosdaRoot;

Posda::Dataset::InitDD();
#use Debug;
#my $dbg = sub {
#  print @_;
#};

my $file1 = $ARGV[0];  # RT Struct
unless(-r $file1 && -f $file1){ die "Can't read $file1" }
my ($df1, $ds1, $size1, $xfr_stx1, $errors1) = Posda::Dataset::Try($file1);
unless($ds1) { 
  print "First file is not a DICOM file\n";
}
unless($ds1->ExtractElementBySig("(0008,0060)") eq "RTSTRUCT"){
  die "first file is not a Structure Set";
}

my $file2 = $ARGV[1];  # RT Dose
unless(-r $file2 && -f $file2){ die "Can't read $file2" }
my ($df2, $ds2, $size2, $xfr_stx2, $errors2) = Posda::Dataset::Try($file2);
unless($ds2) { 
  print "Second file is not a DICOM file\n";
}

unless($ds2->ExtractElementBySig("(0008,0060)") eq "RTDOSE"){
  die "Second file is not an RT DOSE";
}

unless($ds1 && $ds2){
  die "Must have an RTSTRUCT and an RTDOSE to continue";
}


my $p_ds = Posda::Dataset->new_blank;
#
#(0008,0005) = "ISO_IR 100"
#(0008,0016) = "1.2.840.10008.5.1.4.1.1.481.5"
#(0008,0018) = <new sop instance>
#(0008,0020) = <study_date> from RTSTRUCT
#(0008,0030) = <study_time> from RTSTRUCT
#(0008,0050) = <accession number> from RTSTRUCT
#(0008,0060) = 'RTPLAN'
#(0008,0070) = 'CMS, Inc'
#(0008,0090) = ''
#(0008,1070) = ''
#(0008,1090) = 'Plan stubbing script'
#(0010,0010) = <patients name> from RTSTRUCT
#(0010,0020) = <patients id> from RTSTRUCT
#(0010,0030) = <patients birth date> from RTSTRUCT
#(0010,0040) = <patients sex> from RTSTRUCT
#(0010,1000) = <other patients ids> from RTSTRUCT
#(0010,1001) = <other patients names> from RTSTRUCT
#(0018,1020) = '0.1'
#(0020,000d) = <Study Instance UID> from RTSTRUCT
#(0020,000e) = <new series instance uid>
#(0020,0010) = <Study ID> from RTSTRUCT
#(0020,0011) = ''
#(0020,0052) = <frame of reference UID> from RTSTRUCT
#(0020,1040) = <Position Reference Indicator> from RTSTRUCT
#(300a,0002) = 'Bogus'
#(300a,0003) = 'Bogus plan to link RTDOSE to RTSTRUCT'
#(300a,0004) = 'Bogus plan to link RTDOSE to RTSTRUCT'
#(300a,000c) = 'PATIENT'
# patient setup
#(300a,0180)[0]>(0018,5100) = 'HFS'
#(300a,0180)[0]>(300a,0182) = 1
#(300a,0180)[0]>(300a,01b0) = 'ISOCENTRIC'
#referenced structure set
#(300c,0060)[0]>(0008,1150) = '1.2.840.10008.5.1.4.1.1.481.3'
#(300c,0060)[0]>(0008,1155) = <sop instance of RTSTRUCT>
#frac group seq
#(300a,0070)[0]>(300a,0071) = 1
#(300a,0070)[0]>(300a,0078) = 1
#(300a,0070)[0]>(300a,0080) = 1
#(300a,0070)[0]>(300a,00a0) = 0
#beam seq
#(300a,00b0)[0]>(0008,1040) = 'Bogus dept name'
#(300a,00b0)[0]>(300a,00b2) = 'Bogus'
#(300a,00b0)[0]>(300a,00b3) = 'MU'
#(300a,00b0)[0]>(300a,00b4) = '1000.0'
#               beam limiting device
#(300a,00b0)[0]>(300a,00b6)[0]>(300a,00b8) = 'X'
#(300a,00b0)[0]>(300a,00b6)[0]>(300a,00bc) = 1
#(300a,00b0)[0]>(300a,00c0) = 1
#(300a,00b0)[0]>(300a,00c2) = ''
#(300a,00b0)[0]>(300a,00c3) = 'Bogus beam'
#(300a,00b0)[0]>(300a,00c4) = 'Static'
#(300a,00b0)[0]>(300a,00c6) = 'Unknown'
#(300a,00b0)[0]>(300a,00ce) = 'TREATMENT'
#(300a,00b0)[0]>(300a,00d0) = 0
#(300a,00b0)[0]>(300a,00e0) = 0
#(300a,00b0)[0]>(300a,00ed) = 0
#(300a,00b0)[0]>(300a,00f0) = 0
#(300a,00b0)[0]>(300a,010e) = 1.0
#(300a,00b0)[0]>(300a,0110) = 2
#               control point 0
#(300a,00b0)[0]>(300a,0111)[0]>(300a,0112) = 0
#(300a,00b0)[0]>(300a,0111)[0]>(300a,0114) = 0
#(300a,00b0)[0]>(300a,0111)[0]>(300a,011a) = []
#(300a,00b0)[0]>(300a,0111)[0]>(300a,011e) = 0.0
#(300a,00b0)[0]>(300a,0111)[0]>(300a,011f) = NONE
#(300a,00b0)[0]>(300a,0111)[0]>(300a,012c) = [0.0, 0.0, 0.0]
#(300a,00b0)[0]>(300a,0111)[0]>(300a,0134) = 0.0
#               control point 1
#(300a,00b0)[0]>(300a,0111)[1]>(300a,0112) = 0
#(300a,00b0)[0]>(300a,0111)[1]>(300a,0114) = 0
#(300a,00b0)[0]>(300a,0111)[1]>(300a,011a) = []
#(300a,00b0)[0]>(300a,0111)[1]>(300a,011e) = 1.0
#(300a,00b0)[0]>(300a,0111)[1]>(300a,011f) = NONE
#(300a,00b0)[0]>(300a,0111)[0]>(300a,012c) = [0.0, 0.0, 0.0]
#(300a,00b0)[0]>(300a,0111)[0]>(300a,0134) = 1.0

my $new_root = Dicom::Posda::GetRoot( {
    app => $0,
    org => 'CMS',
    purpose => 'creating bogus plan',
    status => 'testing'
  }
);
my $char_set = "ISO_IR 100";
my $sop_class = "1.2.840.10008.5.1.4.1.1.481.5";
my $sop_inst = "$new_root.1.1";
my $study_date = $ds1->ExtractElementBySig("(0008,0020)");
my $study_time = $ds1->ExtractElementBySig("(0008,0030)");
my $acc_num = $ds1->ExtractElementBySig("(0008,0050)");
my $modality = 'RTPLAN';
my $manuf = 'CMS, Inc';
my $ref_phy_name = '';
my $opr_name = '';
my $manuf_model_name = 'Plan stubbing script';
my $pat_name = $ds1->ExtractElementBySig("(0010,0010)");
my $pat_id = $ds1->ExtractElementBySig("(0010,0020)");
my $pat_dob = $ds1->ExtractElementBySig("(0010,0030)");
my $pat_sex = $ds1->ExtractElementBySig("(0010,0040)");
my $ot_pat_id = $ds1->ExtractElementBySig("(0010,1000)");
my $ot_pat_name = $ds1->ExtractElementBySig("(0010,1001)");
my $software_version =  '0.1';
my $study_inst_uid = $ds1->ExtractElementBySig("(0020,000d)");
my $series_inst_uid = "$new_root.1";
my $study_id = $ds1->ExtractElementBySig("(0020,0010)");
my $series_num= undef;
my $for_uid = $ds1->ExtractElementBySig("(0020,0052)");
my $pos_ref_ind = $ds1->ExtractElementBySig("(0020,1040)");
my $rt_plan_label = 'BOGUS';
my $rt_plan_name = 'Bogus Plan';
my $rt_plan_desc = 'Bogus plan to link RTDOSE to RTSTRUCT';
my $rt_plan_geo = 'PATIENT';
# patient setup
my $patient_position = 'HFS';
#patient_setup_num = 1
my $setup_technique = 'ISOCENTRIC';
#referenced structure set
my $struct_sop_class = '1.2.840.10008.5.1.4.1.1.481.3';
my $ref_struct_uid = $ds1->ExtractElementBySig("(0008,0018)");
#frac group seq
my $frac_group_num = 1;
my $num_frac = 1;
my $num_beams = 1;
my $num_brachy = 0;
#beam seq
my $inst_dept_name = 'Bogus dept name';
my $treat_mach_name = 'Bogus';
my $prim_dos_unit = 'MU';
my $source_axis_dist =  '1000.0';
#               beam limiting device
my $rt_beam_limiting_dev_type = 'X';
my $num_leaf_jaw_pairs = 1;
my $beam_num = 1;
my $beam_name = undef;
my $beam_desc = 'Bogus beam';
my $beam_type = 'Static';
my $rad_type = 'Unknown';
my $treat_del_type = 'TREATMENT';
my $num_wedges = 0;
my $num_comp = 0;
my $num_boli = 0;
my $num_blks = 0;
my $fin_cum_met_wgt = 1.0;
my $num_ct_pt = 2;
#               control point 0
my $cnt_pt_index_1 = 0;
my $nom_bm_eng_1 = 0;
my $bm_lim_dev_pos_seq_1 = [];
my $gan_ang_1 = 0.0;
my $gan_rot_1 = "NONE";
my $pat_sup_ang_1 = 0;
my $pat_sup_rot_1 = "NONE";
my $iso_cent_pos_1 = [0.0, 0.0, 0.0];
my $cum_met_wgt_1 = 0.0;
#               control point 1
my $cnt_pt_index_2 = 0;
my $nom_bm_eng_2 = 0;
my $bm_lim_dev_pos_seq_2 = [];
my $gan_ang_2 = 0.0;
my $gan_rot_2 = "NONE";
my $pat_sup_ang_2 = 0;
my $pat_sup_rot_2 = "NONE";
my $iso_cent_pos_2 = [0.0, 0.0, 0.0];
my $cum_met_wgt_2 = 1.0;

$p_ds->InsertElementBySig("(0008,0005)", $char_set);
$p_ds->InsertElementBySig("(0008,0016)", $sop_class);
$p_ds->InsertElementBySig("(0008,0018)", $sop_inst);
$p_ds->InsertElementBySig("(0008,0020)", $study_date);
$p_ds->InsertElementBySig("(0008,0030)", $study_time);
$p_ds->InsertElementBySig("(0008,0050)", $acc_num);
$p_ds->InsertElementBySig("(0008,0060)", $modality);
$p_ds->InsertElementBySig("(0008,0070)", $manuf);
$p_ds->InsertElementBySig("(0008,0090)", $ref_phy_name);
$p_ds->InsertElementBySig("(0008,1070)", $opr_name);
$p_ds->InsertElementBySig("(0008,1090)", $manuf_model_name);
$p_ds->InsertElementBySig("(0010,0010)", $pat_name);
$p_ds->InsertElementBySig("(0010,0020)", $pat_id);
$p_ds->InsertElementBySig("(0010,0030)", $pat_dob);
$p_ds->InsertElementBySig("(0010,0040)", $pat_sex);
$p_ds->InsertElementBySig("(0010,1000)", $ot_pat_id);
$p_ds->InsertElementBySig("(0010,1001)", $ot_pat_name);
$p_ds->InsertElementBySig("(0018,1020)", $software_version);
$p_ds->InsertElementBySig("(0020,000d)", $study_inst_uid);
$p_ds->InsertElementBySig("(0020,000e)", $series_inst_uid);
$p_ds->InsertElementBySig("(0020,0010)", $study_id);
$p_ds->InsertElementBySig("(0020,0011)", $series_num);
$p_ds->InsertElementBySig("(0020,0052)", $for_uid);
$p_ds->InsertElementBySig("(0020,1040)", $pos_ref_ind);
$p_ds->InsertElementBySig("(300a,0002)", $rt_plan_label);
$p_ds->InsertElementBySig("(300a,0003)", $rt_plan_name);
$p_ds->InsertElementBySig("(300a,0004)", $rt_plan_desc);
$p_ds->InsertElementBySig("(300a,000c)", $rt_plan_geo);
# patient setup
$p_ds->InsertElementBySig("(300a,0180)[0]>(0018,5100)", $patient_position);
$p_ds->InsertElementBySig("(300a,0180)[0]>(300a,0182)", 1);
$p_ds->InsertElementBySig("(300a,0180)[0]>(300a,01b0)", $setup_technique);
#referenced structure set
$p_ds->InsertElementBySig("(300c,0060)[0]>(0008,1150)", $struct_sop_class);
$p_ds->InsertElementBySig("(300c,0060)[0]>(0008,1155)", $ref_struct_uid);
#frac group seq
$p_ds->InsertElementBySig("(300a,0070)[0]>(300a,0071)", $frac_group_num);
$p_ds->InsertElementBySig("(300a,0070)[0]>(300a,0078)", $num_frac);
$p_ds->InsertElementBySig("(300a,0070)[0]>(300a,0080)", $num_beams);
$p_ds->InsertElementBySig("(300a,0070)[0]>(300a,00a0)", $num_brachy);
#beam seq
$p_ds->InsertElementBySig("(300a,00b0)[0]>(0008,1040)", $inst_dept_name);
$p_ds->InsertElementBySig("(300a,00b0)[0]>(300a,00b2)", $treat_mach_name);
$p_ds->InsertElementBySig("(300a,00b0)[0]>(300a,00b3)", $prim_dos_unit);
$p_ds->InsertElementBySig("(300a,00b0)[0]>(300a,00b4)", $source_axis_dist);
#               beam limiting device
$p_ds->InsertElementBySig("(300a,00b0)[0]>(300a,00b6)[0]>(300a,00b8)", 
   $rt_beam_limiting_dev_type);
$p_ds->InsertElementBySig("(300a,00b0)[0]>(300a,00b6)[0]>(300a,00bc)",
   $num_leaf_jaw_pairs);
$p_ds->InsertElementBySig("(300a,00b0)[0]>(300a,00c0)", $beam_num);
$p_ds->InsertElementBySig("(300a,00b0)[0]>(300a,00c2)", $beam_name);
$p_ds->InsertElementBySig("(300a,00b0)[0]>(300a,00c3)", $beam_desc);
$p_ds->InsertElementBySig("(300a,00b0)[0]>(300a,00c4)", $beam_type);
$p_ds->InsertElementBySig("(300a,00b0)[0]>(300a,00c6)", $rad_type);
$p_ds->InsertElementBySig("(300a,00b0)[0]>(300a,00ce)", $treat_del_type);
$p_ds->InsertElementBySig("(300a,00b0)[0]>(300a,00d0)", $num_wedges);
$p_ds->InsertElementBySig("(300a,00b0)[0]>(300a,00e0)", $num_comp);
$p_ds->InsertElementBySig("(300a,00b0)[0]>(300a,00ed)", $num_boli);
$p_ds->InsertElementBySig("(300a,00b0)[0]>(300a,00f0)", $num_blks);
$p_ds->InsertElementBySig("(300a,00b0)[0]>(300a,010e)", $fin_cum_met_wgt);
$p_ds->InsertElementBySig("(300a,00b0)[0]>(300a,0110)", $num_ct_pt);
#               control point 0
$p_ds->InsertElementBySig("(300a,00b0)[0]>(300a,0111)[0]>(300a,0112)",
    $cnt_pt_index_1);
$p_ds->InsertElementBySig("(300a,00b0)[0]>(300a,0111)[0]>(300a,0114)",
    $nom_bm_eng_1);
$p_ds->InsertElementBySig("(300a,00b0)[0]>(300a,0111)[0]>(300a,011a)",
    $bm_lim_dev_pos_seq_1);
$p_ds->InsertElementBySig("(300a,00b0)[0]>(300a,0111)[0]>(300a,011e)",
    $gan_ang_1);
$p_ds->InsertElementBySig("(300a,00b0)[0]>(300a,0111)[0]>(300a,011f)",
    $gan_rot_1);
$p_ds->InsertElementBySig("(300a,00b0)[0]>(300a,0111)[0]>(300a,0120)",
    $pat_sup_ang_1);
$p_ds->InsertElementBySig("(300a,00b0)[0]>(300a,0111)[0]>(300a,0121)",
    $pat_sup_rot_1);
$p_ds->InsertElementBySig("(300a,00b0)[0]>(300a,0111)[0]>(300a,0122)",
    $pat_sup_ang_1);
$p_ds->InsertElementBySig("(300a,00b0)[0]>(300a,0111)[0]>(300a,0123)",
    $pat_sup_rot_1);
$p_ds->InsertElementBySig("(300a,00b0)[0]>(300a,0111)[0]>(300a,012c)",
    $iso_cent_pos_1);
$p_ds->InsertElementBySig("(300a,00b0)[0]>(300a,0111)[0]>(300a,0134)",
    $cum_met_wgt_1);
#               control point 1
$p_ds->InsertElementBySig("(300a,00b0)[0]>(300a,0111)[1]>(300a,0112)",
    $cnt_pt_index_2);
$p_ds->InsertElementBySig("(300a,00b0)[0]>(300a,0111)[1]>(300a,0114)",
    $nom_bm_eng_2);
$p_ds->InsertElementBySig("(300a,00b0)[0]>(300a,0111)[1]>(300a,011a)",
    $bm_lim_dev_pos_seq_2);
$p_ds->InsertElementBySig("(300a,00b0)[0]>(300a,0111)[1]>(300a,011e)",
    $gan_ang_2);
$p_ds->InsertElementBySig("(300a,00b0)[0]>(300a,0111)[1]>(300a,011f)",
    $gan_rot_2);
$p_ds->InsertElementBySig("(300a,00b0)[0]>(300a,0111)[1]>(300a,0120)",
    $pat_sup_ang_2);
$p_ds->InsertElementBySig("(300a,00b0)[0]>(300a,0111)[1]>(300a,0121)",
    $pat_sup_rot_2);
$p_ds->InsertElementBySig("(300a,00b0)[0]>(300a,0111)[1]>(300a,0122)",
    $pat_sup_ang_2);
$p_ds->InsertElementBySig("(300a,00b0)[0]>(300a,0111)[1]>(300a,0123)",
    $pat_sup_rot_2);
$p_ds->InsertElementBySig("(300a,00b0)[0]>(300a,0111)[1]>(300a,012c)",
    $iso_cent_pos_2);
$p_ds->InsertElementBySig("(300a,00b0)[0]>(300a,0111)[1]>(300a,0134)",
    $cum_met_wgt_2);
#Debug::GenPrint($dbg, $p_ds, 1);
$p_ds->WritePart10($ARGV[2], $xfr_stx1, "FUBAR", undef, undef);

# Now make Dose Reference Plan
$ds2->InsertElementBySig("(300c,0002)[0]>(0008,1150)",
  "1.2.840.10008.5.1.4.1.1.481.5");
$ds2->InsertElementBySig("(300c,0002)[0]>(0008,1155)",
  $sop_inst);
$ds2->WritePart10($ARGV[3], $xfr_stx1, "FUBAR", undef, undef);
#Debug::GenPrint($dbg, $ds2, 1);

print "\nmade it to end\n";
