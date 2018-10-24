#
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
package Posda::CmdDict;
use vars qw( $Dict );
$Dict = {
 "(0000,0000)" => {
    vr => "UL",
    name => "Group Length",
    type => "ulong"
 },
  "(0000,1005)" => {
    vr => "AT",
    name => "Attribute Identifier List",
    type => "ushort",
  },
  "(0000,0901)" => {
    vr => "AT",
    name => "Offending Element",
    type => "ushort",
  },
  "(0000,1001)" => {
    vr => "UI",
    name => "Requested SOP Instance UID",
    type => "text",
  },
  "(0000,1000)" => {
    vr => "UI",
    name => "Affected SOP Instance UID",
    type => "text",
  },
  "(0000,0003)" => {
    vr => "UI",
    name => "Requested SOP Class UID",
    type => "text",
  },
  "(0000,0002)" => {
    vr => "UI",
    name => "Affected SOP Class UID",
    type => "text",
  },
  "(0000,0902)" => {
    vr => "LO",
    name => "Error Comment",
    type => "text",
  },
  "(0000,1030)" => {
    vr => "AE",
    name => "Move Originator Application Entity Title",
    type => "text",
  },
  "(0000,0600)" => {
    vr => "AE",
    name => "Move Destination",
    type => "text",
  },
  "(0000,1023)" => {
    vr => "US",
    name => "Number of Warning Suboperations",
    type => "ushort",
  },
  "(0000,1022)" => {
    vr => "US",
    name => "Number of Failed Suboperations",
    type => "ushort",
  },
  "(0000,1021)" => {
    vr => "US",
    name => "Number of Completed Suboperations",
    type => "ushort",
  },
  "(0000,1020)" => {
    vr => "US",
    name => "Number of Remaining Suboperations",
    type => "ushort",
  },
  "(0000,1008)" => {
    vr => "US",
    name => "Action Type ID",
    type => "ushort",
  },
  "(0000,1002)" => {
    vr => "US",
    name => "Event Type ID",
    type => "ushort",
  },
  "(0000,0903)" => {
    vr => "US",
    name => "Error ID",
    type => "ushort",
  },
  "(0000,0900)" => {
    vr => "US",
    name => "Status",
    type => "ushort",
  },
  "(0000,0800)" => {
    vr => "US",
    name => "Data Set Type",
    type => "ushort",
  },
  "(0000,0700)" => {
    vr => "US",
    name => "Priority",
    type => "ushort",
  },
  "(0000,0120)" => {
    vr => "US",
    name => "Message ID Being Responded To",
    type => "ushort",
  },
  "(0000,0110)" => {
    vr => "US",
    name => "Message ID",
    type => "ushort",
  },
  "(0000,0100)" => {
    vr => "US",
    name => "Command Field",
    type => "ushort",
  },
};
1;
