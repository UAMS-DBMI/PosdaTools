#!/usr/bin/perl -w
use strict;
my @pat_list = (
 "ProstateX-0038",
 "W50",
 "ProstateX-0042",
 "ProstateX-0039",
 "ProstateX-0062",
 "ProstateX-0049",
 "W42",
 "ProstateX-0064",
 "ProstateX-0018",
 "ProstateX-0054",
 "ProstateX-0050",
 "W6",
 "W26",
 "ProstateX-0025",
 "ProstateX-0022",
 "W16",
 "TT3a-016438",
 "ProstateX-0033",
 "ProstateX-0040",
 "W29",
 "ProstateX-0006",
 "W7",
 "ProstateX-0045",
 "ProstateX-0057",
 "ProstateX-0041",
 "ProstateX-0015",
 "ProstateX-0060",
 "W38",
 "ProstateX-0008",
 "ProstateX-0058",
 "W45",
 "W20",
 "W34",
 "ProstateX-0059",
 "W30",
 "ProstateX-0019",
 "ProstateX-0021",
 "ProstateX-0003",
 "ProstateX-0005",
 "PROSTATEx-junk-9999",
 "ProstateX-0010",
 "ProstateX-0046",
 "ProstateX-0011",
 "W22",
 "TT3a-016333",
 "ProstateX-0016",
 "ProstateX-0044",
 "W32",
 "ProstateX-0007",
 "ProstateX-0030",
 "ProstateX-0036",
 "W55",
 "PROSTATEx-9999",
 "W19",
 "W48",
 "ProstateX-0043",
 "ProstateX-0048",
 "ProstateX-0002",
 "ProstateX-0051",
 "ProstateX-0034",
 "TT3a-016464",
 "W36",
 "W39",
 "ProstateX-0001",
 "W10",
 "W9",
 "W43",
 "ProstateX-0017",
 "ProstateX-0024",
 "W11",
 "W40",
 "ProstateX-0028",
 "PROSTATEx-Test-0001",
 "ProstateX-0052",
 "ProstateX-0026",
 "ProstateX-0004",
 "ProstateX-0035",
 "W31",
 "ProstateX-0065",
 "ProstateX-0031",
 "PROSTATEx-8888",
 "ProstateX-0000",
 "ProstateX-0009",
 "ProstateX-0014",
 "ProstateX-0013",
 "ProstateX-0053",
 "ProstateX-0020",
 "ProstateX-0037",
 "ProstateX-0055",
 "W35",
 "W53",
 "ProstateX-0027",
 "ProstateX-0029",
 "W13",
 "ProstateX-0032",
 "W12",
 "ProstateX-0061",
 "ProstateX-0056",
 "W8",
 "ProstateX-0023",
 "ProstateX-0047",
 "TT3a-016462",
 "W54",
 "ProstateX-0063",
 "W18",
 "ProstateX-0012",
);
for my $i (@pat_list) {
  print "insert into patient_import_status(patient_id, patient_import_status) ".
    "values('$i', 'Unknown');\n";
}
