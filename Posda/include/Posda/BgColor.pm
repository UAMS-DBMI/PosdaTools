#$Source: /home/bbennett/pass/archive/Posda/include/Posda/BgColor.pm,v $
#$Date: 2012/12/19 16:07:35 $
#$Revision: 1.1 $
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
use strict;
package Posda::BgColor;
use vars qw(@_sess_avail_colors %_sess_color_map);
@_sess_avail_colors = ( );
%_sess_color_map = (
     beige        => 'FFFFF9',
     light_pea    => 'FCFEF7',
     light_pink   => 'FFF8F9',
     light_mint   => 'F8FFFA',
     light_violet => 'FEF9FF',
     light_royal  => 'F9F9FF',
     light_teal   => 'F9FFFF',
     light_orange => 'FFFDFA',
     light_blue   => 'F9FCFF',
     light_green  => 'FCFFFA',
);

sub GetUnusedColor{
  if (scalar (@_sess_avail_colors) == 0)
    { @_sess_avail_colors = sort keys %_sess_color_map; }
  # print STDERR "GetUnusedColor: # " . scalar (@_sess_avail_colors) . ".\n";
  my $i = int(rand(scalar (@_sess_avail_colors)));
  # my $color = $_color_map_keys[$index];
  my $color = splice(@_sess_avail_colors,$i,1);
  my $hcolor = uc $_sess_color_map{$color};
  # print STDERR "GetUnusedColor: i: $i, using color: $hcolor.\n";
  return "#" . $hcolor;
}

1;
