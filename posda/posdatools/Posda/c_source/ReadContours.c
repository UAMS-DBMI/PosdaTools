/*
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#

# 
# All of the parameters on the command line are of the form:
#  <name>=<value> (no spaces)
# parameter order does not matter.
# Here are the possible parameters:
#  in=<number of first input fd>
#  out=<number of output fd>
#  status=<number of status fd>
#  name=<name of contoure>
#  v_<x><y>=<normalizing_transform [4] [4]>
#
# On the input socket:
# <filename0>,<offset0>
# <filename1>,<offset1>
# ...
# <filenameN>,<offsetN>
# <EOF>
#
# On the output socket, the format of the contours is the following:
# BEGIN CONTOUR             - marks the beginning of a contour
# row1,col1                     - first point in contour
# row2,col2                     - next point
# ...                           - and so on
#                               -   not necessarily integer
#                               -   may be negative
# rown,coln                     - last point
# END CONTOUR
# ...                       - repeat for as many contours as you have
#
*/
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdint.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>
#include <limits.h>
#include <math.h>

char *prog_name;
int in_fh;
int out_fh;
int status_fh;
char *name;
float nt[4][4];

char *prog_name;
char *error_message;
FILE *i_fp;
char *input_buffer;

typedef struct point{
  float x;
  float y;
} point;

typedef struct point_list{
  point this;
  void *next;
} point_list;

typedef struct line{
  point from;
  point to;
} line;

int get_contour_num(FILE *c_fp, float *r){
  register int c,n;
  register char *v;
  char buff[256];

  v = buff;
  n = sizeof(buff)-1;
  /* fprintf(stderr, "%s: get_contour_num: start\n", prog_name); */

  while (--n > 0 && (c = getc(c_fp)) != EOF){
    if ((*v++ = c) == '\n') break;
    if (c == '\\') break;
  }
  *v = '\0';
  if (n <= 0) {
    asprintf(&error_message, 
      "%s: Contoure point > %d bytes", prog_name, (int) sizeof(buff));
    perror(error_message);
    free(error_message);
    exit(-1);
  }
  if (c == EOF && v == buff) 
    return -1;
  if (*buff == '\0') 
    return -1;
    /* return NaN; */
    /* return numeric_limits<float>::quiet_NaN(); */
  *r = atof(buff);
  /* fprintf(stderr, "%s: returning valid num: %f\n", prog_name, *r); */
  return 0;
}

int apply_transform(float x_form[4][4], float vec[3], float resp[3]) {
  float n_o;
  if (abs(x_form[3][0]) >= 0.0001  ||
      abs(x_form[3][1]) >= 0.0001  ||
      abs(x_form[3][2]) >= 0.0001  ||
      abs(x_form[3][3] - 1) >= 0.0001) {
    asprintf(&error_message, 
      "%s: This may not be a legal DICOM transform", prog_name);
    perror(error_message);
    free(error_message);
  }

  resp[0] = 
    (
       vec[0] * x_form[0][0] +
       vec[1] * x_form[0][1] +
       vec[2] * x_form[0][2] +
       1 * x_form[0][3]
    );
  resp[1] = 
    (
      vec[0] * x_form[1][0] +
      vec[1] * x_form[1][1] +
      vec[2] * x_form[1][2] +
      1 * x_form[1][3]
    );
  resp[2] = 
    (
      vec[0] * x_form[2][0] +
      vec[1] * x_form[2][1] +
      vec[2] * x_form[2][2] +
      1 * x_form[2][3]
    );
  n_o = 
    (
      vec[0] * x_form[3][0] +
      vec[1] * x_form[3][1] +
      vec[2] * x_form[3][2] +
      1 * x_form[3][3]
    );
  if (n_o != 1) {
    asprintf(&error_message, 
      "%s: Error applying x_form: $n_o should be 1", prog_name);
    perror(error_message);
    free(error_message);
    return -1;
  }
  return 0;

}

int main(int argc, char *argv[]){
  int i, j, ii;
  char *v, *k, *f, *o;
  char buf[16];
  prog_name = argv[0];
  int input_i;
  FILE *i_fp;
  char *input_buffer;
  FILE *o_fp;
  FILE *c_fp;
  float x,y,z;
  float vec[3], ret[3];
  int first;
  /* printf("%s parsing of params started\n", prog_name); */
  for (i = 1; i < argc; i++){
    k = strtok(argv[i], "=");
    v = strtok(NULL, "\n");
    if(strcmp(k, "in") == 0){
      in_fh = atoi(v);
    } else if (strcmp(k, "out") == 0){
      out_fh = atoi(v);
    } else if (strcmp(k, "status") == 0){
      status_fh = atoi(v);
    } else if (strcmp(k, "name") == 0){
      name = v;
    } else if (strncmp(k, "v_", 2) == 0){
      k +=2;
      strncpy(buf,k,1);
      ii = atoi(buf);
      k +=1;
      strncpy(buf,k,1);
      j = atoi(buf);
      nt[ii][j] = atof(v);
  /* printf("%s nt[%d][%d] = %f\n", prog_name, ii, j, nt[ii][j]); */
    } else {
      fprintf(stderr, "%s: unknown param: %s\n", prog_name, k);
      exit(-1);
    }
  }
  /* printf("%s parsing of params is complete\n", prog_name); */
  /* printf("%s %s = %d\n", prog_name, "out", out_fh); */
  /* printf("%s %s = %d\n", prog_name, "status", status_fh); */
  /* printf("%s %s = %s\n", prog_name, "name", name); */

  /* main loop here */
  input_i = 0;
  input_buffer = calloc(2048, 1); /* Parent needs to insure this is 
                                       long enough */
  i_fp = fdopen(in_fh, "r");
  if(i_fp == NULL){
    asprintf(&error_message, 
      "%s: can't fdopen in_fh (%d)", prog_name, in_fh);
    perror(error_message);
    free(error_message);
    exit(-1);
  }
  o_fp = fdopen(out_fh, "w");
  if(o_fp == NULL){
    asprintf(&error_message, 
      "%s: can't fdopen out_fh (%d)", prog_name, out_fh);
    perror(error_message);
    free(error_message);
    exit(-1);
  }
  while (1){
    first = 1;
    v = fgets(input_buffer, 2048, i_fp);
    if (v == NULL) break;
    o = strstr(v,"\n");
    if (o != NULL) *o = '\0';
    f = strtok(v, ",");
    o = strtok(NULL, ",");
    /* printf("%s file: '%s', offset: '%s'\n", prog_name, f, o); */
    fprintf(o_fp,"BEGIN CONTOUR at %s\n",o);
    /* fprintf(stderr, "%s: Sending: BEGIN CONTOUR\n", prog_name); */
    if (strcmp(f,"") == 0 || strcmp(f," ") == 0){
      fprintf(o_fp,"END CONTOUR\n");
      /* fprintf(stderr, "%s: Sending: END CONTOUR\n", prog_name); */
      continue;
    }
    c_fp = fopen(f,"r");
    if(c_fp == NULL){
      asprintf(&error_message, 
        "%s: can't open file %s", prog_name, f);
      perror(error_message);
      free(error_message);
      exit(-1);
    }
    while(1){
      /* fprintf(stderr, "%s: get X,Y,Z loop\n", prog_name); */
      if (get_contour_num(c_fp,&vec[0]) != 0) break;
      if (get_contour_num(c_fp,&vec[1]) != 0) {
        asprintf(&error_message, 
          "%s: Invalid contoure file: %s, line does not contain x,Y,z values.", prog_name, f);
        perror(error_message);
        free(error_message);
      }
      if (get_contour_num(c_fp,&vec[2]) != 0) {
        asprintf(&error_message, 
          "%s: Invalid contoure file: %s, line does not contain x,y,Z values.", prog_name, f);
        perror(error_message);
        free(error_message);
      }
      apply_transform(nt, vec, ret);
      if (first) {
        first = 0;
      } else {
        fprintf(o_fp,"\\");
      }
      fprintf(o_fp,"%f\\%f",ret[0],ret[1]);
      /* fprintf(stderr, "%s: Sending  %f, %f\n", prog_name, ret[0],ret[1]); */
    }
    fprintf(o_fp,"\nEND CONTOUR\n");
    /* fprintf(stderr, "%s: Sending: END CONTOUR\n", prog_name); */
  }

  /* inform parent we're done */
  asprintf(&v, "OK\n");
  write(status_fh, (void *) v, i);
  free(v);
  exit(0);
}

