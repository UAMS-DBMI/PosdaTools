/*
#$Source: /home/bbennett/pass/archive/Posda/c_source/ContourToBitmap.c,v $
#$Date: 2014/05/14 15:43:21 $
#$Revision: 1.13 $
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
#  rows=<number of rows in bitmap output>
#  cols=<number of cols in bitmap output>
#  ulx=<x coordinate of upper left point>
#  uly=<y coordinate of upper left point>
#  ulz=<z coordinate of upper left point>
#  rowspc=<spacing between columns>
#  colspc=<spacing between rows>
#
# On the input socket, the format of the contours is the following:
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
#include <stdarg.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>

char *prog_name;
int input_fh;
int output_fh;
int status_fh;
int rows;
int cols;
int debug = 0;
float ulx;
float uly;
float ulz;
float rowspc;
float colspc;
char *error_message;
FILE *contour_file;
FILE *output_fp;
char *contour_buffer;

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

point_list *point_list_first = NULL;
point_list *point_list_last = NULL;
int point_list_count;

point_list *contours[1024 * 4]; /* only allows 1024 * 4 contours per slice */
int contour_length[1024 * 4];
int contour_i;
line *all_lines;
int line_i;
float intersections[65536 * 4]; /* only allows 65535 * 4 intersections per row */
int int_i, c_i;
/* loop variables */
float x, y, x_1, x_2, y_1, y_2;
int o_polarity, bit_count, count;
int l_polarity;
char output_data;

int total_ones_sent = 0;
int total_zeros_sent = 0;
int total_bits_sent = 0;
int loop_count = 0;

/* Define debug_print to be no op for production */
#define debug_print(args...)
void debug_print_unused(const char* format, ...){
  va_list argptr;
  va_start(argptr, format);
  if (! debug) return;
  fprintf(stderr, "%s (%f): ", prog_name, ulz);
  vfprintf(stderr, format, argptr);
  va_end(argptr);
}

int cmpfloat(const void *a, const void *b){
  if(*(float *)a == *(float *)b)return 0;
  if(*(float *)a < *(float *)b) return -1;
  return 1;
}
int main(int argc, char *argv[]){
  int i, j, ii;
  char *v, *k;
  int scan_mode;
  point_list *p;
  float n;
  prog_name = argv[0];
  for (i = 1; i < argc; i++){
    k = strtok(argv[i], "=");
    v = strtok(NULL, "\n");
    if(strcmp(k, "in") == 0){
      input_fh = atoi(v);
    } else if (strcmp(k, "out") == 0){
      output_fh = atoi(v);
    } else if (strcmp(k, "status") == 0){
      status_fh = atoi(v);
    } else if (strcmp(k, "rows") == 0){
      rows = atoi(v);
    } else if (strcmp(k, "cols") == 0){
      cols = atoi(v);
    } else if (strcmp(k, "ulx") == 0){
      ulx = atof(v);
    } else if (strcmp(k, "uly") == 0){
      uly = atof(v);
    } else if (strcmp(k, "ulz") == 0){
      ulz = atof(v);
    } else if (strcmp(k, "rowspc") == 0){
      rowspc = atof(v);
    } else if (strcmp(k, "colspc") == 0){
      colspc = atof(v);
    } else if (strcmp(k, "debug") == 0){
      debug = atoi(v);
    } else {
      fprintf(stderr, "%s: unknown param: %s\n", prog_name, k);
      exit(-1);
    }
  }

  debug_print("parsing of params is complete\n", prog_name);
  debug_print("%s = %d\n", "in", input_fh);
  debug_print("%s = %d\n", "out", output_fh);
  debug_print("%s = %d\n", "status", status_fh);
  debug_print("%s = %d\n", "rows", rows);
  debug_print("%s = %d\n", "cols", cols);
  debug_print("%s = %f\n", "ulx", ulx); 
  debug_print("%s = %f\n", "uly", uly);
  debug_print("%s = %f\n", "ulz", ulz);
  debug_print("%s = %f\n", "rowspc", rowspc);
  debug_print("%s = %f\n", "colspc", colspc);
  debug_print("%s = %d\n", "debug", debug);

  contour_i = 0;
  contour_buffer = calloc(65536 * 4, 1); /* Parent needs to insure this is 
                                       long enough */
  contour_file = fdopen(input_fh, "r");
  if(contour_file == NULL){
    i = asprintf(&error_message, 
      "%s: can't fdopen input_fh (%d)", prog_name, input_fh);
    perror(error_message);
    exit(-1);
  }
  output_fp = fdopen(output_fh, "w");
  if(output_fp == NULL){
    i = asprintf(&error_message, 
      "%s: can't fdopen output_fh (%d)", prog_name, output_fh);
    perror(error_message);
    exit(-1);
  }
  scan_mode = 0; /* scanning for a contour */
  debug_print("Start scanning\n");
  while(1){
    v = fgets(contour_buffer, 65536 * 4, contour_file);
    if(v != NULL){
      debug_print("Data read, len: %d\n", strlen(v));
    } else {
      debug_print("At EOF\n");
    }
    if(v == NULL) break;
    if(scan_mode == 0 ){
      if(strncmp(v, "BEGIN CONTOUR", 13) != 0) continue;
      debug_print("BEGIN CONTOUR\n");
      scan_mode = 1; /* in countour */
      point_list_first = NULL;
      point_list_last = NULL;
      point_list_count = 0;
      continue;
    }
    if(strncmp(v, "END CONTOUR", 11) == 0){
      /* here's where you close the contour and add it to the list*/
      debug_print("END CONTOUR\n");
      if(
        point_list_first->this.x != point_list_last->this.x ||
        point_list_first->this.y != point_list_last->this.y
      ){
        p = calloc(sizeof(point_list), 1);
        p->this.x = point_list_first->this.x;
        p->this.y = point_list_first->this.y;
        point_list_last->next = p;
        point_list_last = p;
        point_list_count += 1;
      }
      /* push this contour onto the list and look for the next */
      contours[contour_i] = point_list_first;
      contour_length[contour_i] = point_list_count;
      point_list_first = NULL;
      point_list_last = NULL;
      point_list_count = 0;
      contour_i += 1;
      scan_mode = 0;
      continue;
    }
    debug_print("Data read, len: %d\n", strlen(v));
    v = strtok(v, "\\");
    while(v != NULL){
      k = strtok(NULL, "\\");
      if(k == NULL){
        fprintf(stderr, 
          "%s: odd number of numbers in contour", prog_name);
        exit(-1);
      }
      p = calloc(sizeof(point_list), 1);
      p->this.x = atof(v);
      p->this.y = atof(k);
      debug_print("Point: %f,%f\n", p->this.x, p->this.y);

      if(point_list_first == NULL){
        point_list_first = p;
        point_list_last = p;
      } else if (point_list_last == NULL){
        i = asprintf(&error_message, 
          "%s: first is not null and last is null", prog_name);
        perror(error_message);
        exit(-1);
      } else {
        point_list_last->next = p;
        point_list_last = p;
      }
      point_list_count += 1;
      v = strtok(NULL, "\\");
    }
  }
  debug_print("End scanning\n");
  /* here we count up the number of line segments total in all contours */
  for (i = 0, j = 0; i < contour_i; i++){
    j += contour_length[i] - 1;
  }
  /* Now make a list of all line segments */
  all_lines = calloc(sizeof(line), j);
  for(i = 0, line_i = 0; i < j; i++){
    point_list_first = contours[i];
    for(j = 0; j < contour_length[i] - 1; j++, line_i++){
      all_lines[line_i].from.x = point_list_first->this.x;
      all_lines[line_i].from.y = point_list_first->this.y;
      point_list_first = point_list_first->next;
      if(point_list_first == NULL){
        fprintf(stderr, 
          "%s odd number of points in contour when collecting segments\n",
          prog_name);
        exit(-1);
      }
      all_lines[line_i].to.x = point_list_first->this.x;
      all_lines[line_i].to.y = point_list_first->this.y;
    }
  }
  /* Outer loop starts here */
  for(
    i = 0, o_polarity = 0, bit_count = 0, y = uly;
    i < rows;
    i++, y += rowspc
  ){
    /* build array of all crossing points for this row */
    for(
      ii = 0, int_i = 0;
      ii < line_i;
      ii++ 
    ){
      if(all_lines[ii].from.y < all_lines[ii].to.y){
        x_1 = all_lines[ii].from.x;
        y_1 = all_lines[ii].from.y;
        x_2 = all_lines[ii].to.x;
        y_2 = all_lines[ii].to.y;
      } else {
        x_2 = all_lines[ii].from.x;
        y_2 = all_lines[ii].from.y;
        x_1 = all_lines[ii].to.x;
        y_1 = all_lines[ii].to.y;
      }
      if(y_1 < y && y_2 >= y){
        /* calculate and add intersection */
        intersections[int_i] = x_1 + (x_2 - x_1) * ((y - y_1)/(y_2 - y_1));
        int_i += 1;
      } else {

      }
    }
    /* for debug, see that we have an even number of intersections */
    if((int_i & 1) == 1){
      fprintf(stderr, "%s odd number of intersections\n", prog_name);
    }
    /* sort the intersections */
    qsort(intersections, int_i, sizeof(float), cmpfloat);
    /* Inner loop starts here */
    for(
      j = 0, x = ulx, c_i = 0, l_polarity = 0;
      j < cols;
      j++, x += colspc
    ){
      loop_count += 1;
      while(intersections[c_i] < x && c_i < int_i){
        l_polarity = !l_polarity;
        c_i += 1;
      }
      if(l_polarity != o_polarity){
        while(bit_count > 0){
          if(bit_count > 127){
            bit_count -= 127;
            count = 127;
          } else {
            count = bit_count;
            bit_count = 0;
          }
          if(o_polarity){
            output_data = 0x80 + count;
          } else {
            output_data = count;
          }
          if (fputc(output_data, output_fp) == EOF) {
            i = asprintf(&error_message, 
              "%s: Error writing binned data", prog_name);
            perror(error_message);
            exit(-1);
          }
        }
      }
      o_polarity = l_polarity;
      bit_count += 1;
      if(bit_count > 127){
        bit_count = 1;
        count = 127;
        if(o_polarity){
          output_data = 0x80 + count;
        } else {
          output_data = count;
        }
        if (fputc(output_data, output_fp) == EOF) {
          i = asprintf(&error_message, 
            "%s: Error writing binned data", prog_name);
          perror(error_message);
          exit(-1);
        }
      }
    }
  }
  if(bit_count){
        while(bit_count > 0){
          if(bit_count > 127){
            bit_count -= 127;
            count = 127;
          } else {
            count = bit_count;
            bit_count = 0;
          }
          if(o_polarity){
            output_data = 0x80 + count;
          } else {
            output_data = count;
          }
          if (fputc(output_data, output_fp) == EOF) {
            i = asprintf(&error_message, 
              "%s: Error writing binned data", prog_name);
            perror(error_message);
            exit(-1);
          }
        }
  }
  fclose(contour_file);
  fclose(output_fp);
  /* inform parent we're done */
  i = asprintf(&v, "OK\n");
  write(status_fh, (void *) v, i);
  free(v);
}
