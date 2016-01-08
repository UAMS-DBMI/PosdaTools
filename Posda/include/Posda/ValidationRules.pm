#!/usr/bin/perl -w
#$Source: /home/bbennett/pass/archive/Posda/include/Posda/ValidationRules.pm,v $
#$Date: 2015/12/15 14:06:03 $
#$Revision: 1.18 $
package Posda::ValidationRules;
use vars qw( @rules @consistent_series @consistent_study @consistent_patient);
my $basic_sop_rules = [ "list", 
  # must have a SOP Instance UID
  {
    pattern => "(0008,0018)",
    invoke_no_match => "Basic SOP:\n" .
      "\telement (0008,0018)\n" .
      "\tSOP Instance UID is not present",
  },
  # must have an Instance Creation Date
  {
    pattern => "(0008,0012)",
    invoke_no_match => "Basic SOP:\n" .
      "\telement (0008,0012)\n" .
      "\tInstance Creation Date is not present",
  },
];
my $for_rules = [ "list",
  # must have a Frame of Reference UID
  {
    pattern => "(0020,0052)",
    invoke_no_match => "Frame of Reference:\n" .
      "\telement (0020,0052)\n" .
      "\tFrame of Reference UID is not present",
  },
  # must have a Position Reference Indication
  {
    pattern => "(0020,1040)",
    invoke_no_match => "Frame of Reference:\n" .
      "\telement (0020,1040)\n" .
      "\tPosition Reference Indicator is not present",
  },
];
##  Structure Set Rules
##  invoke if SOP_ClassUID eq "1.2.840.10008.5.1.4.1.1.481.3"
my $ss_rules = [ "list",
  # Modality must be "RTSTRUCT"
  {
    pattern => "(0008,0060)",
    value => "RTSTRUCT",
    invoke_no_match => "RT Structure Set:\n" .
      "\telement (0008,0060)\n" .
      "\tModality (<v>) is not RTSTRUCT",
  },
  # ROI Numbers must be unique
  {
    pattern => "(3006,0020)[<0>](3006,0022)",
    constraint => "unique",
    violation => "Uniqueness of ROI number in Structure Set ROI sequence:" .
      "\n<v>",
  },
  # ROI Names must be unique
  {
    pattern => "(3006,0020)[<0>](3006,0026)",
    constraint => "unique",
    violation => "Uniqueness of ROI name in Structure Set ROI Sequence:" .
      "\n<v>",
  },
  # ROI Observation numbers must be unique
  {
    pattern => "(3006,0080)[<0>](3006,0082)",
    constraint => "unique",
    violation => "Uniqueness of Observation Number in " .
      "RT ROI Observation Sequence:\n<v>",
  },
  # ROI Interpreted type is type 1 in ROI Observations
  {
    pattern => "(3006,0080)[<0>]",
    invoke_each_match => {
      pattern => "(3006,0080)[<i0>](3006,00a4)",
      invoke_no_match =>
        "RT ROI Observations Sequence:\n" .
        "\telement (3006,0080)[<i0>](3006,00a6)\n" .
        "\tROI Interpreted type is not present",
    },
  },
  # ROI Interpreter is type 2 in ROI Observations
  {
    pattern => "(3006,0080)[<0>]",
    invoke_each_match => {
      pattern => "(3006,0080)[<i0>](3006,00a6)",
      invoke_no_match =>
        "RT ROI Observations Sequence:\n" .
        "\telement (3006,0080)[<i0>](3006,00a6)\n" .
        "\tROI Interpreter is not present",
    },
  },
  # ROI Contours may only referenced defined ROI Numbers
  {
    pattern => "(3006,0039)[<0>](3006,0084)",
    invoke_each_match => {
      pattern => "(3006,0020)[<0>](3006,0022)",
      value => "<v>",
      invoke_no_match =>
        "ROI Contour Sequence:\n" .
        "\telement (3006,0039[<i0>](3006,0084)\n" .
        "\tROI Number (<v>) doesn't appear in Structure Set ROI sequence",
    },
  },
  # ROI Observations may only referenced defined ROI Numbers
  {
    pattern => "(3006,0080)[<0>](3006,0084)",
    invoke_each_match => {
      pattern => "(3006,0020)[<0>](3006,0022)",
      value => "<v>",
      invoke_no_match =>
        "RT ROI Observations Sequence:\n" .
        "\telement (3006,0080)[<i0>](3006,0084)\n" .
        "\tROI Number (<v>) doesn't appear in Structure Set ROI sequence",
    },
  },
  # Images referenced by Contours must also be in Ref FOR Sequence
  {
    pattern =>
      "(3006,0039)[<0>](3006,0040)[<1>](3006,0016)[0](0008,1155)",
    invoke_each_match => {
      pattern => "(3006,0010)[<0>](3006,0012)[<1>]" .
                 "(3006,0014)[<2>](3006,0016)[<3>](0008,1155)",
      value => "<v>",
      invoke_no_match =>
        "ROI Contour Sequence::Contour Sequence::Contour Image Sequence\n" .
        "\telement (3006,0039)[<i0>](3006,0040)[<i1>](3006,0016[0]" .
        "(0008,1155)\n" .
        "\treference to image (<v>)\n" .
        "\tnot found in referenced frame of reference sequence",
    },
  },
  # CLOSED_PLANAR Contours must be associated with an image
  {
    pattern => "(3006,0039)[<0>](3006,0040)[<1>](3006,0042)",
    value => "CLOSED_PLANAR",
    invoke_each_match => {
      pattern =>
        "(3006,0039)[<i0>](3006,0040)[<i1>](3006,0016)[0](0008,1155)",
      invoke_no_match =>
        "ROI Contour Sequence::Contour Sequence\n" .
        "\telement (3006,0039)[<i0>](3006,0040)[<i1>](3006,0042)\n" .
        "\tCLOSED_PLANAR contour which doesn't reference an image",
    },
  },
  # All ROI's must have FOR UID
  {
    pattern => "(3006,0020)[<0>](3006,0022)",
    invoke_each_match => {
      pattern =>
        "(3006,0020)[<i0>](3006,0024)",
      invoke_no_match =>
        "Structure Set ROI Sequence:\n" .
        "\telement (3006,0020)[<i0>](3006,0022)\n" .
        "\tReferenced Frame of Reference (3006,0020)[<i0>](3006,0024) " . 
        "not present",
    },
  },
  # Referenced FOR UID must also be in Ref FOR Seq
  {
    pattern => "(3006,0020)[<0>](3006,0024)",
    invoke_each_match => {
      pattern =>
        "(3006,0010)[<0>](0020,0052)",
      value => "<v>",
      invoke_no_match =>
        "Structure Set ROI Sequence:\n" .
        "\telement (3006,0020)[<i0>](3006,0024)\n" .
        "\tReferenced Frame of Reference (<v>)\n" . 
        "\tnot in Ref FOR Sequence",
    },
  },
  # Referenced Image must be in same FOR as ROI
  {
    pattern => "(3006,0039)[<0>](3006,0040)[<1>](3006,0016)[<2>](0008,1155)",
    eval_each_match => [
      "prog_sub",
      [ "set", "a", [ "get_unique_index",
          "(3006,0010)[<0>](3006,0012)[<1>](3006,0014)[<2>]" .
          "(3006,0016)[<3>](0008,1155)",
          "<v>",
        ],
      ],
      [ "set", "image_for", [ "get_value", "(3006,0010)[<a1>](0020,0052)" ]],
      [ "set", "roi_num", [ "get_value", "(3006,0039)[<i0>](3006,0084)" ]],
      [ "set", "roi_index", 
        [ "get_unique_index", "(3006,0020)[<0>](3006,0022)", "<roi_num>" ]],
      [ "set", "roi_for", 
        [ "get_value", "(3006,0020)[<roi_index0>](3006,0024)", ],
      ],
      [ "unless", 
        [ "and",
          ["notnull", "<roi_for>" ], ["notnull", "<image_for>"], 
          ["eq", "<roi_for>", "<image_for>"],
        ],
        [
          "invoke",
          "Image Reference:\n" .
          "\telement (3006,0039)[<i0>](3006,0040)[<i1>]" .
          "(3006,0016)[<i2>](0008,1155)\n" .
          "\treferences image in FOR <image_for>\n" .
          "\tfor ROI in FOR <roi_for>",
        ],
      ],
    ],
  },
];
my $beam_rules = [
  "list",
  # some constraints per beam sequence item
  {
    pattern => "(300a,00b0)[<0>]",
    invoke => [
      "list",
      # beam number is type 1 in beam_sequence
      {
        pattern => "(300a,00b0)[<0>]",
        invoke_each_match => {
          pattern => "(300a,00b0)[<i0>](300a,00c0)",
          invoke_no_match => "Beam number is type 1 in Beam Sequence\n " .
            "\telement: (300a,00b0)[<i0>](300a,00c0) doesn't exist",
        },
      },
      # beam number is unique within beam sequence
      {
        pattern => "(300a,00b0)[<0>](300a,00c0)",
        constraint => "unique",
        violation => "Uniquenes of beam_number in beam sequence: <v>",
      },
      # beam type is type 1 in Beam Seq
      {
        pattern => "(300a,00b0)[<0>]",
        invoke_each_match => {
          pattern => "(300a,00b0)[<i0>](300a,00c4)",
          invoke_no_match => "Beam type is Type 1 in Beam Sequence\n" .
            "\telement: (300a,00b0)[<i0>](300a,00c4)\n" .
            "\tnot present",
        },
      },
      # beam type must be either "STATIC" or "DYNAMIC"
      {
        pattern => "(300a,00b0)[<0>](300a,00c4)",
        eval_each_match => ["prog_sub", ["unless",
          ["or", ["eq", "<v>", "STATIC"], ["eq", "<v>", "DYNAMIC"] ],
          [ "invoke", "Error: Bad value for Beam Type " .
            "not in enumerated value list\n" .
            "\t element: (300a,00b0)[<i0>](300a,00c4)\n" .
            "\t Value (<v>) should be either \"STATIC\" or \"DYNAMIC\""
          ],
        ], ],
      },
      # radiation type is type 2 in Beam Sequence
      {
        pattern => "(300a,00b0)[<0>]",
        invoke_each_match => {
          pattern => "(300a,00b0)[<i0>](300a,00c6)",
          invoke_no_match => "Radiation type is Type 2 in Beam Sequence\n" .
            "\telement: (300a,00b0)[<i0>](300a,00c6)\n" .
            "\tnot present",
        },
      },
      # radiation type has defined terms
      {
        pattern => "(300a,00b0)[<0>](300a,00c6)",
        eval_each_match => ["prog_sub", ["unless",
          ["or", 
            ["eq", "<v>", "PHOTON"], ["eq", "<v>", "ELECTRON"],
            ["eq", "<v>", "NEUTRON"], ["eq", "<v>", "PROTON"],
          ],
          [ "invoke", "Warning: unknown value for Radiation Type\n" .
            "\telement: (300a,00b0)[<i0>](300a,00c4)\n" .
            "\tValue (<v>). Defined terms:\n" .
            "\t\t\"PHOTON\", \"ELECTRON\", \"NEUTRON\", \"PROTON\""
          ],
        ], ],
      },
      # Beam Limiting Device type has enumerated values in 
      # Beam Limiting Device Sequence
      {
        pattern => "(300a,00b0)[<0>](300a,00b6)[<1>](300a,00b8)",
        eval_each_match => ["prog_sub", ["unless",
          ["or", 
            ["eq", "<v>", "X"], ["eq", "<v>", "Y"],
            ["eq", "<v>", "ASYMX"], ["eq", "<v>", "ASYMY"],
            ["eq", "<v>", "MLCX"], ["eq", "<v>", "MLCY"],
          ],
          [ "invoke", "Error: bad value for Beam Limiting Device Type\n" .
            "\telement: (300a,00b0)[<i0>](300a,00b6)[<i1>](300a,00b8)\n" .
            "\tValue (<v>). Enumerated Values:\n" .
            "\t\t \"X\", \"Y\", \"ASYMX\", \"ASYMY\", \"MLCX\", \"MLCY\""
          ],
        ],],
      },
      # Beam Limiting Device type has enumerated values in 
      # Beam Limiting Device Sequence
      {
        pattern => 
          "(300a,00b0)[<0>](300a,0111)[<1>](300a,011a)[<2>](300a,00b8)",
        eval_each_match => ["prog_sub", ["unless",
          ["or", 
            ["eq", "<v>", "X"], ["eq", "<v>", "Y"],
            ["eq", "<v>", "ASYMX"], ["eq", "<v>", "ASYMY"],
            ["eq", "<v>", "MLCX"], ["eq", "<v>", "MLCY"],
          ],
          [ "invoke", "Error: bad value for Beam Limiting Device Type\n" .
            "\telement: " .
            "(300a,00b0)[<i0>](300a,0111)[<i1>]" .
            "(300a,011a)[<i2>](300a,00b8)\n" .
            "\tValue (<v>). Enumerated Values:\n" .
            "\t\t \"X\", \"Y\", \"ASYMX\", \"ASYMY\", \"MLCX\", \"MLCY\""
          ],
        ],],
      },
      # Treatment Machine Name is type 2 in Beam Sequence
      {
        pattern => "(300a,00b0)[<0>]",
        invoke_each_match => {
          pattern => "(300a,00b0)[<i0>](300a,00b2)",
          invoke_no_match => "Treatment Machine Name is Type 2 in " .
            "Beam Sequence\n" .
            "\telement: (300a,00b0)[<i0>](300a,0b2)\n" .
            "\tnot present",
        },
      },
      # High-Dose Technique is type 1C  in Beam Sequence
      {
        pattern => "(300a,00b0)[<0>]",
        invoke_each_match => {
          pattern => "(300a,00b0)[<i0>](300a,00c7)",
          eval_no_match => [
            "prog_sub",
            [ "set", "beam_num", 
              ["get_value", "(300a,00b0)[<i0>](3001,00c0)" ]],
            ["invoke", 
              "Observation " .
              "\telement: (300a,00b0)[<i0>](300a,00c7)\n" .
              "\tnot present\n" .
              "\ttherefore no high-dose technique for beam: <beam_num>",
            ],
          ],
        }
      },
      # High-Dose Technique is type 1C  in Beam Sequence
      # continued
      {
        pattern => "(300a,00b0)[<0>]",
        invoke_each_match => {
          pattern => "(300a,00b0)[<i0>](300a,00c7)",
          eval_each_match => [
            "prog_sub",
            [ "set", "beam_num", 
              ["get_value", "(300a,00b0)[<i0>](3001,00c0)" ]],
            ["invoke", 
              "Observation " .
              "\telement: (300a,00b0)[<i0>](300a,00c7)\n" .
              "\thigh-dose technique (<v>) for beam: <beam_num>",
            ],
          ],
        }
      },
      # High-Dose Technique is has defined terms
      {
        pattern => "(300a,00b0)[<0>](300a,00c7)",
        eval_each_match => [
          "unless", [ "or",
            ["eq", "<v>", "TBI"], ["eq", "<v>", "HDI"],
          ],
          ["invoke", 
            "Warning " .
            "\telement: (300a,00b0)[<i0>](300a,00c7)\n" .
            "\thigh-dose technique (<v>) is not among defined terms\n" .
            "\t\tHDR, TBI",
          ],
        ],
      },
      # Beam Limiting Device Sequnce is type 1  in Beam Sequence
      {
        pattern => "(300a,00b0)[<0>]",
        invoke_each_match => {
        pattern => "(300a,00b0)[<i0>](300a,00b6)",
          invoke_no_match => "Beam Limiting Device Sequence is type 1 " .
            "in Beam Sequence\n" .
            "\telement: (300a,00b0)[<i0>](300a,00b6)\n" .
            "\tnot present",
        },
      },
      # Beam Limiting Device type is type 1 in Beam Limiting Device Sequence
      {
        pattern => "(300a,00b0)[<0>](300a,00b6)[<1>]",
        invoke_each_match => {
          pattern => "(300a,00b0)[<i0>](300a,00b6)[<i1>](300a,00B8)",
          invoke_no_match => "Beam Limiting Device Type is required in " .
            "Beam Limiting Device Sequence\n" .
            "\telement (300a,00b0)[<i0>](300a,00b6)[<i1>](300a,00B8)" .
            " is not present",
        },
      },
      # A number of elements occur only in item zero or in all items
      #   of control point sequence
      #   These elements are type 1C or 3, but are all treated as 1C
      {
        pattern => "(300a,00b0)[<0>](300a,0111)",
        invoke_each_match => {
          pattern => "(300a,00b0)[<i0>](300a,0111)",
          constraint => "only_zero_unless_changing",
          elements => [
            "(300a,011a)",
            "(300a,011e)",
            "(300a,011f)",
            "(300a,0120)",
            "(300a,0121)",
            "(300a,0122)",
            "(300a,0123)",
            "(300a,0125)",
            "(300a,0126)",
##            "(300a,0128)",   ## 2C, not 1C or 3
##            "(300a,0129)",   ## 2C, not 1C or 3
##            "(300a,012a)",   ## 2C, not 1C or 3
            "(300a,0140)",
            "(300a,0142)",
            "(300a,0144)",
            "(300a,0146)",
          ],
          violations => "The following violations of " .
            "only_zero_unless_changing constraint were found in \n" .
            "the control point sequence of the <i0>'th item of " .
            "the beam sequence\n" .
            "(300a,00b0)[<i0>](300a,0111): ",
        }
      },
    ],
  },
];
my $plan_rules = [
  "list",
  # Modality must be "RTPLAN"
  {
    pattern => "(0008,0060)",
    value => "RTPLAN",
    invoke_no_match => "RT Plan:\n" .
      "\telement (0008,0060)\n" .
      "\tModality (<v>) is not RTPLAN",
  },
  #  If beam sequence present, invoke beam rules
  {
    pattern => "(300a,00b0)",
    invoke  => $beam_rules,
  },
];
my $dose_rules = [
  "list",
];
my $CT_rules = [
  "list",
];
my $REG_rules = [
  "list",
];
@rules = (
  "list", 
  $basic_sop_rules,
  {
    pattern => "(0008,0016)",
    value => "1.2.840.10008.5.1.4.1.1.481.3",
    invoke => $ss_rules,
  },
  {
    pattern => "(0008,0016)",
    value => "1.2.840.10008.5.1.4.1.1.481.5",
    invoke => $plan_rules,
  },
  {
    pattern => "(0008,0016)",
    value => "1.2.840.10008.5.1.4.1.1.481.2",
    invoke => $dose_rules,
  },
  {
    pattern => "(0008,0016)",
    value => "1.2.840.10008.5.1.4.1.1.2",
    invoke => $CT_rules,
  },
  {
    pattern => "(0008,0016)",
    value => "1.2.840.10008.5.1.4.1.1.66.1",
    invoke => $REG_rules,
  },
);

@consistent_series = (
  {
    name => "Modality",
    ele => "(0008,0060)",
    type => "text",
  },
  {
    name => "Series Instance UID",
    ele => "(0020,000e)",
    type => "text",
  },
  {
    name => "Series Date",
    ele => "(0008,0021)",
    type => "text",
  },
  {
    name => "Protocol Name",
    ele => "(0018,1030)",
    type => "text",
  },
  {
    name => "Series Description",
    ele => "(0008,103e)",
    type => "text",
  },
  {
    name => "Body Part Examined",
    ele => "(0018,0015)",
    type => "text",
  },
  {
    name => "Study Date",
    ele => "(0008,0020)",
    type => "text",
  },
  {
    name => "Study Description",
    ele => "(0008,1030)",
    type => "text",
  },
  {
    name => "Admitting Diagnosis Description",
    ele => "(0008,1080)",
    type => "text",
  },
  {
    name => "Patient's Age",
    ele => "(0010,1010)",
    type => "text",
  },
  {
    name => "Patient's Sex",
    ele => "(0010,0040)",
    type => "text",
  },
  {
    name => "Patient's Weight",
    ele => "(0010,1030)",
    type => "text",
  },
  {
    name => "Series Number",
    ele => "(0020,0011)",
    type => "text",
  },
  {
    name => "Synchronization Frame of Reference UID",
    ele => "(0020,0200)",
    type => "text",
  },
  {
    name => "Patient ID",
    ele => "(0010,0020)",
    type => "text",
  },
  {
    name => "Frame of Reference UID",
    ele => "(0020,0052)",
    type => "text",
  },
  {
    name => "Study Instance UID",
    ele => "(0020,000d)",
    type => "text",
  },
  {
    name => "Manufacturer",
    ele => "(0008,0070)",
    type => "text",
  },
  {
    name => "Institution Name",
    ele => "(0008,0080)",
    type => "text",
  },
  {
    name => "Manufacturer Model Name",
    ele => "(0008,1090)",
    type => "text",
  },
  {
    name => "Software Version(s)",
    ele => "(0018,1020)",
    type => "text",
  },
  {
    name => "Institution Address",
    ele => "(0008,0081)",
    type => "text",
  },
  {
    name => "Station Name",
    ele => "(0008,1010)",
    type => "text",
  },
  {
    name => "Device Serial Number",
    ele => "(0018,1000)",
    type => "text",
  },
  {
    name => "Patient's Name",
    ele => "(0010,0010)",
    type => "text",
  },
  {
    name => "Patient's Birth Date",
    ele => "(0010,0030)",
    type => "text",
  },
  {
    name => "Ethnic Group",
    ele => "(0010,2160)",
    type => "text",
  },
);

@consistent_study = (
  {
    name => "Study Date",
    ele => "(0008,0020)",
    type => "text",
  },
  {
    name => "Study Description",
    ele => "(0008,1030)",
    type => "text",
  },
  {
    name => "Admitting Diagnosis Description",
    ele => "(0008,1080)",
    type => "text",
  },
  {
    name => "Patient's Age",
    ele => "(0010,0010)",
    type => "text",
  },
  {
    name => "Patient's Sex",
    ele => "(0010,0040)",
    type => "text",
  },
  {
    name => "Patient's Weight",
    ele => "(0010,1030)",
    type => "text",
  },
  {
    name => "Patient ID",
    ele => "(0010,0020)",
    type => "text",
  },
  {
    name => "Patient's Name",
    ele => "(0010,0010)",
    type => "text",
  },
  {
    name => "Patient's Birth Date",
    ele => "(0010,0030)",
    type => "text",
  },
  {
    name => "Ethnic Group",
    ele => "(0010,2160)",
    type => "text",
  },
  {
    name => "Study Id",
    ele => "(0020,0010)",
    type => "text",
  },
  {
    name => "Accession Number",
    ele => "(0008,0050)",
    type => "text",
  },
);

@consistent_patient = (
  {
    name => "Patient's Age",
    ele => "(0010,0010)",
    type => "text",
  },
  {
    name => "Patient's Sex",
    ele => "(0010,0040)",
    type => "text",
  },
  {
    name => "Patient ID",
    ele => "(0010,0020)",
    type => "text",
  },
  {
    name => "Patient's Name",
    ele => "(0010,0010)",
    type => "text",
  },
  {
    name => "Patient's Birth Date",
    ele => "(0010,0030)",
    type => "text",
  },
  {
    name => "Ethnic Group",
    ele => "(0010,2160)",
    type => "text",
  },
);

1;

