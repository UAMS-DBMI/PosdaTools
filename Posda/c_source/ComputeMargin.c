/*
#$Source: /home/bbennett/pass/archive/Posda/c_source/ComputeMargin.c,v $
#$Date: 2014/05/14 15:43:21 $
#$Revision: 1.4 $
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#

# Streamed Pixel operations
# This program accepts contours on an fd and writes a bitmap
# on another fd of the points contained within the contours
# The fd's have been opened by the parent process...

# What to do is specified on the command line.
# All of the parameters on the command line are of the form:
#  <name>=<value> (no spaces)
# parameter order does not matter.
# Here are the possible parameters:
#  in=<number of input fd>
#  out=<number of output fd>
#  status=<number of status fd>
#  rows=<number of rows in bitmap output>
#  cols=<number of cols in bitmap output>
#  rowspc=<spacing between columns>
#  colspc=<spacing between rows>
#  slicespc=<spacing between rows>
#  margin=<margin value>
#
#

# Here's the analysis for actually calculating margins
#  For each input bit, if its a zero, do nothing, if its a 1, then
#  look at the 6 adjoining bits (top, bottom, anterior, posterior, left, right)
#  there are 64 possibilities, each of which corresponds to one of the
#  following types of bit:
#    bare point (1 way)
#    inside solid (1 way)
#    inside line (3 ways, orientation of line)
#    inside plane (3 ways, orientation of plane)
#    tip of line (6 ways, orientation of line, and which end)
#    edge of plane (12 ways, orientation of plane and which edge)
#    corner of plane (12 ways, orientation of plane and which corner)
#    face of solid (6 ways, orientation of face and direction of normal);
#    edge of solid (12, orientation of edge and direction of normal)
#    corner of solid (8, which corner)
# Heres the table:
#  indx tbaplr                            shape        dim  orientation
#     0 000000 - bare point            sphere            3     N/A
#     1 000001 - tip of line           hemisphere        3     l
#     2 000010 - tip of line           hemisphere        3     r
#     3 000011 - inside line           circle            2     nlr
#     4 000100 - tip of line           hemisphere        3     a
#     5 000101 - corner of plane       quartersphere     3     al
#     6 000110 - corner of plane       quartersphere     3     ar
#     7 000111 - edge of plane         semicircle        2     tab
#     8 001000 - tip of line           hemisphere        3     p
#     9 001001 - corner of plane       quartersphere     3     pl
#    10 001010 - corner of plane       quartersphere     3     pr
#    11 001011 - edge of plane         semicircle        2     tpb
#    12 001100 - inside line           circle            2     nap
#    13 001101 - edge of plane         semicircle        2     tlb
#    14 001110 - edge of plane         semicircle        2     trb
#    15 001111 - inside plane          diameter          1     tb
#    16 010000 - tip of line           hemisphere        3     t
#    17 010001 - corner of plane       quartersphere     3     tl
#    18 010010 - corner of plane       quartersphere     3     tr
#    19 010011 - edge of plane         semicircle        2     atp
#    20 010100 - corner of plane       quartersphere     3     ta
#    21 010101 - corner of solid       quadrant          3     tal
#    22 010110 - corner of solid       quadrant          3     tar
#    23 010111 - edge of solid         quartercircle     2     ta
#    24 011000 - corner of plane       quartersphere     3     tp
#    25 011001 - corner of solid       quadrant          3     tpl
#    26 011010 - corner of solid       quadrant          3     tpr
#    27 011011 - edge of solid         quartercircle     2     tp
#    28 011100 - edge of plane         semicircle        2     ltr
#    29 011101 - edge of solid         quartercircle     2     tr
#    30 011110 - edge of solid         quartercircle     2     tl
#    31 011111 - face of a solid       radius            1     t
#    32 100000 - tip of line           hemisphere        3     b
#    33 100001 - corner of plane       quartersphere     3     bl
#    34 100010 - corner of plane       quartersphere     3     br
#    35 100011 - edge of plane         semicircle        2     abp
#    36 100100 - corner of plane       quartersphere     3     ba
#    37 100101 - corner of solid       quadrant          3     bal
#    38 100110 - corner of solid       quadrant          3     bar
#    39 100111 - edge of solid         quartercircle     2     ba
#    40 101000 - corner of plane       quartersphere     3     bp
#    41 101001 - corner of solid       quadrant          3     bpl
#    42 101010 - corner of solid       quadrant          3     bpr
#    43 101011 - edge of solid         quartercircle     2     bp
#    44 101100 - edge of plane         semicircle        2     lbr
#    45 101101 - edge of solid         quartercircle     2     bl
#    46 101110 - edge of solid         quartercircle     2     br
#    47 101111 - face of a solid       radius            1     b
#    48 110000 - inside line           circle            2     ntb
#    49 110001 - edge of plane         semicircle        2     alp
#    50 110010 - edge of plane         semicircle        2     arp
#    51 110011 - inside plane          diameter          1     ap
#    52 110100 - edge of plane         semicircle        2     lar
#    53 110101 - edge of solid         quartercircle     2     al
#    54 110110 - edge of solid         quartercircle     2     ar
#    55 110111 - face of a solid       radius            1     a
#    56 111000 - edge of plane         semicircle        2     lpr
#    57 111001 - edge of solid         quartercircle     2     pl
#    58 111010 - edge of solid         quartercircle     2     pr
#    59 111011 - face of a solid       radius            1     p
#    60 111100 - inside plane          diameter          1     lr
#    61 111101 - face of a solid       radius            1     r
#    62 111110 - face of a solid       radius            1     l
#    63 111111 - inside of solid       point            N/A
#
#    type of shape         number of transforms
#    sphere                        1  : identity
#    hemisphere                    6  : identity
#                                     :  90 lr
#                                     : 180 lr
#                                     : 270 lr
#                                     :  90 ap
#                                     :  90 ap, 180 tb
#    circle                        3  : identity
#                                     :  90 lr
#                                     :  90 ap
#    semicircle                   12  : identity
#                                     :  90 lr
#                                     : 180 lr
#                                     : 270 lr
#                                     :  90 ap
#                                     :  90 ap,  90 tb
#                                     :  90 ap, 180 tb
#                                     :  90 ap, 270 tb
#                                     :  90 tb
#                                     :  90 tb,  90 lr
#                                     :  90 tb, 180 lr
#                                     :  90 tb, 270 lr
#    quartersphere                12  : identity
#                                     :  90 lr
#                                     : 180 lr
#                                     : 270 lr
#                                     :  90 ap
#                                     :  90 ap,  90 tb
#                                     :  90 ap, 180 tb
#                                     :  90 ap, 270 tb
#                                     :  90 tb
#                                     :  90 tb,  90 lr
#                                     :  90 tb, 180 lr
#                                     :  90 tb, 270 lr
#    quartercircle                12  : identity
#                                     :  90 lr
#                                     : 180 lr
#                                     : 270 lr
#                                     :  90 ap
#                                     :  90 ap,  90 tb
#                                     :  90 ap, 180 tb
#                                     :  90 ap, 270 tb
#                                     :  90 tb
#                                     :  90 tb,  90 lr
#                                     :  90 tb, 180 lr
#                                     :  90 tb, 270 lr
#    quadrant                      8  : identity
#                                     :  90 lr
#                                     : 180 lr
#                                     : 270 lr
#                                     :  90 tb
#                                     :  90 tb,  90 lr
#                                     :  90 tb, 180 lr
#                                     :  90 tb, 270 lr
#    radius                        6  : identity
#                                     :  90 lr
#                                     : 180 lr
#                                     : 270 lr
#                                     :  90 ap
#                                     :  90 ap, 180 tb
#    diameter                      3  : identity
#                                     :  90 lr
#                                     :  90 ap
#
#
*/
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdint.h>
#include <stdarg.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <limits.h>
#include <math.h>

/* 
 *  Start of generated code from program: /home/estrom/Posda/bin/test/ComputeRotations.pl
 *    (dir Posda/bin/test/  )
 */

enum rotations_types { 
  r100010,
  r100001,
  r1000m0,
  r10000m,
  rm00010,
  rm00001,
  rm000m0,
  rm0000m,
  r010100,
  r010001,
  r010m00,
  r01000m,
  r0m0100,
  r0m0001,
  r0m0m00,
  r0m000m,
  r001100,
  r001010,
  r001m00,
  r0010m0,
  r00m100,
  r00m010,
  r00mm00,
  r00m0m0,
  rotations_types_max
};


static const int rotations[rotations_types_max][3][3] = { 
  [r100010] = {{1,0,0}, {0,1,0}, {0,0,1}},
  [r100001] = {{1,0,0}, {0,0,1}, {0,-1,0}},
  [r1000m0] = {{1,0,0}, {0,-1,0}, {0,0,-1}},
  [r10000m] = {{1,0,0}, {0,0,-1}, {0,1,0}},
  [rm00010] = {{-1,0,0}, {0,1,0}, {0,0,-1}},
  [rm00001] = {{-1,0,0}, {0,0,1}, {0,1,0}},
  [rm000m0] = {{-1,0,0}, {0,-1,0}, {0,0,1}},
  [rm0000m] = {{-1,0,0}, {0,0,-1}, {0,-1,0}},
  [r010100] = {{0,1,0}, {1,0,0}, {0,0,-1}},
  [r010001] = {{0,1,0}, {0,0,1}, {1,0,0}},
  [r010m00] = {{0,1,0}, {-1,0,0}, {0,0,1}},
  [r01000m] = {{0,1,0}, {0,0,-1}, {-1,0,0}},
  [r0m0100] = {{0,-1,0}, {1,0,0}, {0,0,1}},
  [r0m0001] = {{0,-1,0}, {0,0,1}, {-1,0,0}},
  [r0m0m00] = {{0,-1,0}, {-1,0,0}, {0,0,-1}},
  [r0m000m] = {{0,-1,0}, {0,0,-1}, {1,0,0}},
  [r001100] = {{0,0,1}, {1,0,0}, {0,1,0}},
  [r001010] = {{0,0,1}, {0,1,0}, {-1,0,0}},
  [r001m00] = {{0,0,1}, {-1,0,0}, {0,-1,0}},
  [r0010m0] = {{0,0,1}, {0,-1,0}, {1,0,0}},
  [r00m100] = {{0,0,-1}, {1,0,0}, {0,-1,0}},
  [r00m010] = {{0,0,-1}, {0,1,0}, {1,0,0}},
  [r00mm00] = {{0,0,-1}, {-1,0,0}, {0,1,0}},
  [r00m0m0] = {{0,0,-1}, {0,-1,0}, {-1,0,0}},
};


enum geometric_types {
  geometric_type_circle,
  geometric_type_diameter,
  geometric_type_hemisphere,
  geometric_type_point,
  geometric_type_quadrant,
  geometric_type_quartercircle,
  geometric_type_quartersphere,
  geometric_type_radius,
  geometric_type_semicircle,
  geometric_type_sphere,
  geometric_types_max
};

static const char *geometric_types_description[geometric_types_max] = {
  [geometric_type_circle] = "circle",
  [geometric_type_diameter] = "diameter",
  [geometric_type_hemisphere] = "hemisphere",
  [geometric_type_point] = "point",
  [geometric_type_quadrant] = "quadrant",
  [geometric_type_quartercircle] = "quartercircle",
  [geometric_type_quartersphere] = "quartersphere",
  [geometric_type_radius] = "radius",
  [geometric_type_semicircle] = "semicircle",
  [geometric_type_sphere] = "sphere",
};

static const char *types_description[64] = {
 "bare point",
 "tip of line",
 "tip of line",
 "inside line",
 "tip of line",
 "corner of plane",
 "corner of plane",
 "edge of plane",
 "tip of line",
 "corner of plane",
 "corner of plane",
 "edge of plane",
 "inside line",
 "edge of plane",
 "edge of plane",
 "inside plane",
 "tip of line",
 "corner of plane",
 "corner of plane",
 "edge of plane",
 "corner of plane",
 "corner of solid",
 "corner of solid",
 "edge of solid",
 "corner of plane",
 "corner of solid",
 "corner of solid",
 "edge of solid",
 "edge of plane",
 "edge of solid",
 "edge of solid",
 "face of solid",
 "tip of line",
 "corner of plane",
 "corner of plane",
 "edge of plane",
 "corner of plane",
 "corner of solid",
 "corner of solid",
 "edge of solid",
 "corner of plane",
 "corner of solid",
 "corner of solid",
 "edge of solid",
 "edge of plane",
 "edge of solid",
 "edge of solid",
 "face of solid",
 "inside line",
 "edge of plane",
 "edge of plane",
 "inside plane",
 "edge of plane",
 "edge of solid",
 "edge of solid",
 "face of solid",
 "edge of plane",
 "edge of solid",
 "edge of solid",
 "face of solid",
 "inside plane",
 "face of solid",
 "face of solid",
 "inside solid",
};

static const int types_geometric_value[64] = {
 geometric_type_sphere,
 geometric_type_hemisphere,
 geometric_type_hemisphere,
 geometric_type_circle,
 geometric_type_hemisphere,
 geometric_type_quartersphere,
 geometric_type_quartersphere,
 geometric_type_semicircle,
 geometric_type_hemisphere,
 geometric_type_quartersphere,
 geometric_type_quartersphere,
 geometric_type_semicircle,
 geometric_type_circle,
 geometric_type_semicircle,
 geometric_type_semicircle,
 geometric_type_diameter,
 geometric_type_hemisphere,
 geometric_type_quartersphere,
 geometric_type_quartersphere,
 geometric_type_semicircle,
 geometric_type_quartersphere,
 geometric_type_quadrant,
 geometric_type_quadrant,
 geometric_type_quartercircle,
 geometric_type_quartersphere,
 geometric_type_quadrant,
 geometric_type_quadrant,
 geometric_type_quartercircle,
 geometric_type_semicircle,
 geometric_type_quartercircle,
 geometric_type_quartercircle,
 geometric_type_radius,
 geometric_type_hemisphere,
 geometric_type_quartersphere,
 geometric_type_quartersphere,
 geometric_type_semicircle,
 geometric_type_quartersphere,
 geometric_type_quadrant,
 geometric_type_quadrant,
 geometric_type_quartercircle,
 geometric_type_quartersphere,
 geometric_type_quadrant,
 geometric_type_quadrant,
 geometric_type_quartercircle,
 geometric_type_semicircle,
 geometric_type_quartercircle,
 geometric_type_quartercircle,
 geometric_type_radius,
 geometric_type_circle,
 geometric_type_semicircle,
 geometric_type_semicircle,
 geometric_type_diameter,
 geometric_type_semicircle,
 geometric_type_quartercircle,
 geometric_type_quartercircle,
 geometric_type_radius,
 geometric_type_semicircle,
 geometric_type_quartercircle,
 geometric_type_quartercircle,
 geometric_type_radius,
 geometric_type_diameter,
 geometric_type_radius,
 geometric_type_radius,
 geometric_type_point,
};

static const char *types_geometric_string_value[64] = {
 "sphere",
 "hemisphere",
 "hemisphere",
 "circle",
 "hemisphere",
 "quartersphere",
 "quartersphere",
 "semicircle",
 "hemisphere",
 "quartersphere",
 "quartersphere",
 "semicircle",
 "circle",
 "semicircle",
 "semicircle",
 "diameter",
 "hemisphere",
 "quartersphere",
 "quartersphere",
 "semicircle",
 "quartersphere",
 "quadrant",
 "quadrant",
 "quartercircle",
 "quartersphere",
 "quadrant",
 "quadrant",
 "quartercircle",
 "semicircle",
 "quartercircle",
 "quartercircle",
 "radius",
 "hemisphere",
 "quartersphere",
 "quartersphere",
 "semicircle",
 "quartersphere",
 "quadrant",
 "quadrant",
 "quartercircle",
 "quartersphere",
 "quadrant",
 "quadrant",
 "quartercircle",
 "semicircle",
 "quartercircle",
 "quartercircle",
 "radius",
 "circle",
 "semicircle",
 "semicircle",
 "diameter",
 "semicircle",
 "quartercircle",
 "quartercircle",
 "radius",
 "semicircle",
 "quartercircle",
 "quartercircle",
 "radius",
 "diameter",
 "radius",
 "radius",
 "point",
};

static const int types_rotation[64] = {
 r001010,
 r010001,
 r0m0001,
 r010001,
 r001100,
 r010001,
 r0m000m,
 r001m00,
 r001m00,
 r01000m,
 r0m0001,
 r001100,
 r001100,
 r0m0100,
 r010100,
 r001010,
 r001010,
 r010100,
 r0m0100,
 r0010m0,
 r001100,
 r00m0m0,
 r001m00,
 r100010,
 r001010,
 r00mm00,
 r0010m0,
 r100001,
 r1000m0,
 r001010,
 r00m010,
 r0010m0,
 r0010m0,
 r010m00,
 r0m0m00,
 r001010,
 r0010m0,
 r00m100,
 r001010,
 r10000m,
 r001m00,
 r00m010,
 r001100,
 r1000m0,
 r100010,
 r0010m0,
 r00m0m0,
 r001010,
 r001010,
 r0m0001,
 r010001,
 r001100,
 r100001,
 r001100,
 r00mm00,
 r001m00,
 r10000m,
 r001m00,
 r00m100,
 r001100,
 r010001,
 r0m0001,
 r010001,
 r001010,
};


/* 
 *  End of generated code from program: /home/estrom/Posda/bin/test/ComputeRotations.pl
 *    (dir Posda/bin/test/  )
 */

int geometric_types_count[geometric_types_max] = { 0 };

typedef struct int_point{
  int x;
  int y;
  int z;
} int_point;

typedef struct point{
  float x;
  float y;
  float z;
} point;

typedef struct point_list{
  point this;
  void *next;
} point_list;


int in_fh = 0;
int out_fh = 0;
int status_fh = 0;
int rows = 0;
int cols = 0;
int num_slices = 0;
int debug = 0;
float margin = 0.0;
float int_margin = 0;
float sampspc = 0.0;
point_list *KernalTable[64];

char *prog_name;
char *error_message;
FILE *i_fp;
FILE *o_fp;

/* Define debug_print to be no op for production  */
#define debug_print(args...)
/*
debug_print(const char* format, ...){
  va_list argptr;
  va_start(argptr, format);
  if (! debug) return;
  fprintf(stderr, "%s: ", prog_name);
  vfprintf(stderr, format, argptr);
  va_end(argptr);
}
*/

void AddPointXYZ(point_list **list_ptr_ptr, float x, float y, float z) {
  point_list *p;
  p = calloc(sizeof(point_list),1);
  if (p == NULL) {
    asprintf(&error_message,
      "%s: Error point structure", prog_name);
    perror(error_message);
    exit(-1);
  }
  p->this.x = x; p->this.y = y; p->this.z = z;
  p->next = *list_ptr_ptr;
  *list_ptr_ptr = p;
}
void AddPoint(point_list **list_ptr_ptr, point *p) {
  AddPointXYZ(list_ptr_ptr, p->x, p->y, p->z);
}
void AddIntPoint(point_list **list_ptr_ptr, int_point *p) {
  AddPointXYZ(list_ptr_ptr, (float) p->x, (float) p->y, (float) p->z);
}

typedef int rotation[3][3];
typedef rotation *rotation_ptr;

/* Rot3D(rotation_ptr rot, int_point *p){ */
void Rot3D(const int rot[3][3], int_point *p){ 
  int x,y,z;
  x = (p->x * rot[0][0]) + (p->y * rot[0][1]) + (p->z * rot[0][2]);
  y = (p->x * rot[1][0]) + (p->y * rot[1][1]) + (p->z * rot[1][2]);
  z = (p->x * rot[2][0]) + (p->y * rot[2][1]) + (p->z * rot[2][2]);
  p->x = x; p->y = y; p->z = z;
}

void BuildSphere(int index) {
  int i, j, k;
  for (i = -int_margin; i <= int_margin; i++){
    for (j = -int_margin; j <= int_margin; j++){
      for (k = -int_margin; k <= int_margin; k++){
        if (sqrtf((float) ((i * i) + (j * j) + (k * k)))
               <= (float) (margin/sampspc)){
          AddPointXYZ(&(KernalTable[index]),
            (float) i, (float) j, (float) k);
        }
      }
    }
  }
}

void BuildHemisphere(int index) {
  /*  Hemisphere above
   *  t010000
   */
  int i, j, k;
  int_point p;
  for (i = -int_margin; i <= 0; i++){
    for (j = -int_margin; j <= int_margin; j++){
      for (k = -int_margin; k <= int_margin; k++){
        if (sqrtf((float) ((i * i) + (j * j) + (k * k)))
               <= (float) (margin/sampspc)){
          p.x = i; p.y = j; p.z = k;
          Rot3D(rotations[types_rotation[index]], &p);
          AddIntPoint(&(KernalTable[index]), &p);
        }
      }
    }
  }
}

void BuildQuartersphere(int index){
  /* Quartersphere top and left
   * t010001
   */
  int i, j, k;
  int_point p;
  for (i = -int_margin; i <= 0; i++){
    for (j = -int_margin; j <= 0; j++){
      for (k = -int_margin; k <= int_margin; k++){
        if (sqrtf((float) ((i * i) + (j * j) + (k * k)))
               <= (float) (margin/sampspc)){
          p.x = i; p.y = j; p.z = k;
          Rot3D(rotations[types_rotation[index]], &p);
          AddIntPoint(&(KernalTable[index]), &p);
        }
      }
    }
  }
}

void BuildQuadrant(int index){
  /* Quadrant below, right, posterior
   * t101010
   */
  int i, j, k;
  int_point p;
  for (i = 0; i <= int_margin; i++){
    for (j = 0; j <= int_margin; j++){
      for (k = 0; k <= int_margin; k++){
        if (sqrtf((float) ((i * i) + (j * j) + (k * k)))
               <= (float) (margin/sampspc)){
          p.x = i; p.y = j; p.z = k;
          Rot3D(rotations[types_rotation[index]], &p);
          AddIntPoint(&(KernalTable[index]), &p);
        }
      }
    }
  }
}


void BuildCircle(int index){
  /* Circle right left anterior posterior
   * t110000
   */
  int i, j, k;
  int_point p;
  for (i = -int_margin; i <= int_margin; i++){
    for (k = -int_margin; k <= int_margin; k++){
      if (sqrtf((float) ((i * i) + (k * k)))
             <= (float) (margin/sampspc)){
        p.x = i; p.y = 0; p.z = k;
        Rot3D(rotations[types_rotation[index]], &p);
        AddIntPoint(&(KernalTable[index]), &p);
      }
    }
  }
}

void BuildSemicircle(int index){
  /* Semicircle below left right
   * t101100
   */
  int i, j, k;
  int_point p;
  for (i = -int_margin; i <= int_margin; i++){
    for (j = 0; j <= int_margin; j++){
        if (sqrtf((float) ((i * i) + (j * j)))
               <= (float) (margin/sampspc)){
          p.x = i; p.y = j; p.z = 0;
          Rot3D(rotations[types_rotation[index]], &p);
          AddIntPoint(&(KernalTable[index]), &p);
        }
    }
  }
}

void BuildQuartercircle(int index){
  /* Quartercircle top anterior
   * t010111
   */
  int i, j, k;
  int_point p;
    for (j = -int_margin; j <= 0; j++){
      for (k = -int_margin; k <= 0; k++){
        if (sqrtf((float) ((j * j) + (k * k)))
               <= (float) (margin/sampspc)){
          p.x = 0; p.y = j; p.z = k;
          Rot3D(rotations[types_rotation[index]], &p);
          AddIntPoint(&(KernalTable[index]), &p);
        }
      }
  }
}

void BuildDiameter(int index){
  /* Diameter above and below
   * t001111
   */
  int i, j, k;
  int_point p;
  for (j = -int_margin; j <= int_margin; j++){
    if (sqrtf((float) (j * j))
           <= (float) (margin/sampspc)){
      p.x = 0; p.y = j; p.z = 0;
      Rot3D(rotations[types_rotation[index]], &p);
      AddIntPoint(&(KernalTable[index]), &p);
    }
  }
}

void BuildRadius(int index){
  /* Radius below
   * t101111
   */
  int i, j, k;
  int_point p;
  for (j = 0; j <= int_margin; j++){
    if (sqrtf((float) (j * j))
           <= (float) (margin/sampspc)){
      p.x = 0; p.y = j; p.z = 0;
      Rot3D(rotations[types_rotation[index]], &p);
      AddIntPoint(&(KernalTable[index]), &p);
    }
  }
}

void BuildIdentity(int index){
  AddPointXYZ(&(KernalTable[index]), 0.0, 0.0, 0.0);
}

int main(int argc, char *argv[]){
  int i, j, k, ii;
  char *a_v, *a_k;
  int c;

  int num_planes;
  int center_plane;
  int bits_per_plane;
  int in_polarity = 0;
  int in_count = 0;
  int out_polarity = 0;
  int out_count = 0;
  int num_out_planes = 0;
  int plane_being_filled_i = 0;
  int frames_filled = 0;
  int frames_written;
  int type, t, b, a, p, l, r;
  char **out_planes = NULL;
  char *plane_being_filled = NULL;
  char *prior_plane = NULL;
  char *current_frame = NULL;
  char *next_plane = NULL;
  char *this_frame = NULL;
  int this_index = 0;
  point_list *k_point;
  int nj, nk, ni;
  int index;
  int byte;
  int num_zeros = 0;

  FILE *i_fp;
  FILE *o_fp;
  float x,y,z;


  prog_name = argv[0];
  /* printf("%s parsing of params started\n", prog_name); */
  for (i = 1; i < argc; i++){
    a_k = strtok(argv[i], "=");
    a_v = strtok(NULL, "\n");
    if(strcmp(a_k, "in") == 0){
      in_fh = atoi(a_v);
    } else if (strcmp(a_k, "out") == 0){
      out_fh = atoi(a_v);
    } else if (strcmp(a_k, "status") == 0){
      status_fh = atoi(a_v);
    } else if (strcmp(a_k, "rows") == 0){
      rows = atoi(a_v);
    } else if (strcmp(a_k, "cols") == 0){
      cols = atoi(a_v);
    } else if (strcmp(a_k, "slices") == 0){
      num_slices = atoi(a_v);
    } else if (strcmp(a_k, "sampspc") == 0){
      sampspc = atof(a_v);
    } else if (strcmp(a_k, "margin") == 0){
      margin = atof(a_v);
    } else if (strcmp(a_k, "debug") == 0){
      debug = atoi(a_v);
    } else {
      fprintf(stderr, "%s: unknown param: %s\n", prog_name, a_k);
      exit(-1);
    }
  }

  debug_print("parsing of params is complete\n"); 
  debug_print("%s = %d\n", "out", out_fh); 
  debug_print("%s = %d\n", "status", status_fh); 
  debug_print("%s = %d\n", "rows", rows); 
  debug_print("%s = %d\n", "cols", cols); 
  debug_print("%s = %d\n", "slices", num_slices); 
  debug_print("%s = %f\n", "margin", margin); 
  debug_print("%s = %d\n", "debug", debug); 

  i_fp = fdopen(in_fh, "r");
  if(i_fp == NULL){
    asprintf(&error_message, 
      "%s: can't fdopen in_fh (%d)", prog_name, in_fh);
    perror(error_message);
    exit(-1);
  }
  o_fp = fdopen(out_fh, "w");
  if(o_fp == NULL){
    asprintf(&error_message, 
      "%s: can't fdopen out_fh (%d)", prog_name, out_fh);
    perror(error_message);
    exit(-1);
  }

  int_margin = ( int ) ((margin+(sampspc/2))/sampspc);
  num_planes = (2 * int_margin) + 1;
  center_plane = int_margin + 1;
  bits_per_plane = rows * cols;

  /* populate KernalTable based on margin size */
  debug_print("Start populating KernalTable\n"); 
  for (i = 0; i < (sizeof(KernalTable)/sizeof(KernalTable[0])); i++){
    if (types_geometric_value[i] == geometric_type_sphere) {
      BuildSphere(i);
    } else if (types_geometric_value[i] == geometric_type_hemisphere) {
      BuildHemisphere(i);
    } else if (types_geometric_value[i] == geometric_type_quartersphere) {
      BuildQuartersphere(i);
    } else if (types_geometric_value[i] == geometric_type_quadrant) {
      BuildQuadrant(i);
    } else if (types_geometric_value[i] == geometric_type_circle) {
      BuildCircle(i);
    } else if (types_geometric_value[i] == geometric_type_semicircle) {
      BuildSemicircle(i);
    } else if (types_geometric_value[i] == geometric_type_quartercircle) {
      BuildQuartercircle(i);
    } else if (types_geometric_value[i] == geometric_type_diameter) {
      BuildDiameter(i);
    } else if (types_geometric_value[i] == geometric_type_radius) {
      BuildRadius(i);
    } else if (types_geometric_value[i] == geometric_type_point) {
      BuildIdentity(i);
    } else {
      fprintf(stderr, "%s: Unknown geometric type value: %d, index: %d\n", 
        prog_name, types_geometric_value[i], i);
      exit(-1);
    }
  }
  debug_print("Done populating KernalTable\n"); 

  frames_written = -int_margin;
  prior_plane = calloc(1,bits_per_plane); 
  if (prior_plane == NULL){
    asprintf(&error_message, 
      "%s: can't alloc empty prior plane (size %d)", prog_name, 
      bits_per_plane);
    perror(error_message);
    exit(-1);
  }
  num_out_planes = (2 * int_margin) + 2;
  out_planes = malloc(sizeof(char *) * num_out_planes); 
  if (out_planes == NULL){
    asprintf(&error_message, 
      "%s: can't alloc out_plans array (size %d)", prog_name, 
      num_out_planes * (int) sizeof(char *));
    perror(error_message);
    exit(-1);
  }
  for (i = 0; i < num_out_planes; i++) 
  {
    out_planes[i] = calloc(1,bits_per_plane); 
    if (out_planes[i] == NULL){
      asprintf(&error_message, 
        "%s: can't alloc out plane (size %d)", prog_name, 
        bits_per_plane);
      perror(error_message);
      exit(-1);
    }
    debug_print("Created out plane: %d\n", i); 
  }

  while (frames_written < num_slices) {
    /*  make sure you have 3 frames to process */
    /* process first or middle frame */
    /* write oldest frame if not needed & delete - shift frames.. */
    plane_group:
    while( plane_being_filled_i < bits_per_plane  &&
           (prior_plane == NULL || 
            current_frame == NULL || 
            next_plane == NULL) )
    {
      if (plane_being_filled == NULL) {
        debug_print("allocing new plane_being_filled buffer\n");
        plane_being_filled_i = 0; 
        plane_being_filled = malloc(bits_per_plane); 
        if (plane_being_filled == NULL){
          asprintf(&error_message, 
            "%s: can't alloc buffer (size %d)", prog_name, bits_per_plane);
          perror(error_message);
          exit(-1);
        }
      }
      if (in_count > 0){
        for (i = 0; 
             i < in_count && plane_being_filled_i < bits_per_plane; 
             i++)
        {
          plane_being_filled[plane_being_filled_i++] = in_polarity;
          in_count--;
        }
        if (plane_being_filled_i < bits_per_plane)
          { continue; }  /* ????  will this do what I want: next plane_group */
      } else {
        if ((c = fgetc(i_fp)) == EOF){
          debug_print("EOF on input\n");
        } else {
          in_count = c & 0x7f;
          in_polarity = (c & 0x80) ? 0x01 : 0x00;
          continue;
        }
      }
      if (plane_being_filled_i == bits_per_plane) {
        debug_print("plane_being_filled is full.\n");
        if (current_frame == NULL) {
          current_frame = plane_being_filled;
        } else if (next_plane == NULL) {
          next_plane = plane_being_filled;
        } else {
          fprintf(stderr, 
            "%s: Full buffer, but no where to put it ???\n", prog_name);
        }
        plane_being_filled = NULL;
        plane_being_filled_i = 0;
      } else {
        /* This should happen when at EOF on input, and next_plane is NULL */
        if (next_plane == NULL  &&  
            current_frame != NULL  &&  
            prior_plane != NULL)
        {
          debug_print("Creating final next_plane.\n");
          next_plane = calloc(1,bits_per_plane); 
          if (next_plane == NULL){
            asprintf(&error_message, 
              "%s: can't alloc buffer (size %d)", prog_name, bits_per_plane);
            perror(error_message);
            exit(-1);
          }
        } else {
          fprintf(stderr, 
            "%s: EOF on input, buffer not full, ???\n", prog_name);
        }
      }
      frames_filled++;
    }
    /* have a full plane group  */

    if (frames_written < num_slices){
      if (frames_filled <= num_slices + 1){
        debug_print("Frame being processed: %d.\n", 
          frames_filled);
        /* calculate the margin into output */
        /* op_frame = out_planes[center_plane]; */
        for (j = 0; j < rows; j++) {
          for (k = 0; k < cols; k++) {
            index = (j * cols) + k;
            if (current_frame[index]){
              /*  Here is where you expand the margin based on the
               * table (see analysis above)
               */
              if(j == 0){
                t = 0;
                b = current_frame[((j + 1) * cols)+ k];
              } else if (j == rows - 1){
                b = 0;
                t = current_frame[((j - 1) * cols) + k];
              } else {
                b = current_frame[((j + 1) * cols) + k];
                t = current_frame[((j - 1) * cols) + k];
              }
              if(k == 0) {
                l = 0;
                r = current_frame[(j * cols) + k + 1];
              } else if(k == cols - 1) {
                r = 0;
                l = current_frame[(j * cols) + k - 1];
              } else {
                r = current_frame[(j * cols) + k + 1];
                l = current_frame[(j * cols) + k - 1];
              }
              a = prior_plane[index];
              p = next_plane[index];
              /*   indx tbaplr */
              type = 
                (t ? 0x20 : 0) +
                (b ? 0x10 : 0) +
                (a ? 0x08 : 0) +
                (p ? 0x04 : 0) +
                (l ? 0x02 : 0) +
                (r ? 0x01 : 0);
              /* debug_print("Type is: %d for [%d,%d,%d].\n", 
                type,j,k,frames_filled); */
              if (type >= (sizeof(KernalTable)/sizeof(KernalTable[0])))
              { 
                fprintf(stderr, 
                  "%s: Error: type %d >= %d kernal table size\n", prog_name, 
                  type, (int) (sizeof(KernalTable)/sizeof(KernalTable[0])));
                exit (-1);
              }
              for (k_point = KernalTable[type];
                   k_point != NULL;
                   k_point = (point_list *) k_point->next)
              {
                nj = k_point->this.y + j;
                nk = k_point->this.x + k;
                ni = k_point->this.z;
                if(
                  nj >= 0 && nj < rows &&
                  nk >= 0 && nk < cols &&
                  abs(ni) <= int_margin)
                {
                 /* debug_print("setting point at: %d.\n", 
                  this_index);  */
                  if (center_plane + ni >= num_out_planes  ||
                      center_plane + ni < 0) {
                    fprintf(stderr, 
                      "%s: Error: Margin point to set(%d) outside of " 
                      "output sliding window buffer size [0,%d].\n", 
                      prog_name, 
                      center_plane + ni, num_out_planes - 1);
                    exit(-1);
                  } else {
                    this_frame = out_planes[center_plane + ni];
                    this_index = (nj * cols) + nk;
                    this_frame[this_index] = 1;
                  }
                }
              } 
              geometric_types_count[types_geometric_value[type]]++;
              /* end expand margin */
            } else {
              num_zeros++;
            }
          }
        }
        /* end of margin calculation */
      }
      /*  write a plane and cause another to be slid in
       *  my $output_frame = $out_planes[0];
       */
      if (frames_written >= 0){
        for (i = 0; i < bits_per_plane; i++)
        {
          byte = out_planes[0][i];
          if (byte == out_polarity) 
            { out_count++; } 
          else {
            c = (out_polarity ? 0x80 : 0) + out_count;
            if (fputc(c, o_fp) == EOF) {
              asprintf(&error_message, "%s: Error on write", prog_name);
              perror(error_message);
              exit(-1);
            }
            out_polarity = byte;
            out_count = 1;
          }
          if (out_count > 127){
            c = (out_polarity ? 0x80 : 0) | 127;
            if (fputc(c, o_fp) == EOF) {
              asprintf(&error_message, "%s: Error on write", prog_name);
              perror(error_message);
              exit(-1);
            }
            out_count -= 127;
          }
        }
      }
      frames_written++;
      debug_print("Frames written: %d.\n",
        frames_written);
      /* shift in planes by one */
      free (prior_plane);
      prior_plane = current_frame;
      current_frame = next_plane;
      next_plane = NULL;
      /* shift out planes by one */
      a_v = out_planes[0];
      for (i = 0; i < num_out_planes-1; i++)
        { out_planes[i] = out_planes[i+1]; }
      out_planes[num_out_planes-1] = a_v;
      bzero(a_v,bits_per_plane);
    }
  }
  if (out_count > 0){
    c = (out_polarity ? 0x80 : 0) | out_count;
    if (fputc(c, o_fp) == EOF) {
      asprintf(&error_message, "%s: Error on write", prog_name);
      perror(error_message);
      exit(-1);
    }
  }

  fclose(i_fp);
  fclose(o_fp);
  debug_print("Main: We are done...\n");
  /* inform parent we're done */
  write(status_fh, "OK\n", 4);
  close(status_fh);
  for (i = 0; 
     i < (sizeof(geometric_types_count)/sizeof(geometric_types_count[0]));
       i++) 
  {
    if (geometric_types_count[i] > 0) 
    {
      debug_print("Type: %s, Count: %d\n", 
        geometric_types_description[i], geometric_types_count[i]);
    }
  }
  debug_print("Num zeros: %d\n", num_zeros); 
  exit(0);
}

