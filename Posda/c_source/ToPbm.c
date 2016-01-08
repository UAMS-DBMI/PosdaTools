/*
#$Source: /home/bbennett/pass/archive/Posda/c_source/ToPbm.c,v $
#$Date: 2014/05/14 15:43:21 $
#$Revision: 1.5 $
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#

# Take a bitmap and turn it into a PBM based on args ...
# 
# All of the parameters on the command line are of the form:
#  <name>=<value> (no spaces)
# parameter order does not matter.
# Here are the possible parameters:
#  in=<number of input fd>
#  out=<number of output fd>
#  rows=<number of rows>
#  cols=<number of cols>
#
*/
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdarg.h>
#include <errno.h>
#include <unistd.h>

int debug = 0;
int in_fh = -1;
int out_fh = -1;
int status_fh = -1;
int rows = 0;
int cols = 0;

char *prog_name;

/* Define debug_print to be no op for production */
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

int main(int argc, char *argv[]){
  int c;
  int i, j;
  int in, im, out, outm;
  char *k;
  char *v;
  char *error_message;
  FILE *in_fp;
  FILE *out_fp;

  prog_name = argv[0];

  /* Here we parse the command line parameters */
  for (i = 1; i < argc; i++){
    k = strtok(argv[i], "=");
    v = strtok(NULL, "\n");
    if(strcmp(k, "in") == 0){
      in_fh = atoi(v);
    } else if(strcmp(k, "out") == 0){
      out_fh = atoi(v);
    } else if(strcmp(k, "status") == 0){
      status_fh = atoi(v);
    } else if (strcmp(k, "rows") == 0){
      rows = atoi(v);
    } else if (strcmp(k, "cols") == 0){
      cols = atoi(v);
    } else if (strcmp(k, "debug") == 0){
      debug = atoi(v);
    } else {
      fprintf(stderr, "%s: unexpected arg: %s = %s.\n", prog_name, k, v);
    }
  }

  debug_print("parsing of params is complete\n"); 
  debug_print("%s = %d\n", "in", in_fh); 
  debug_print("%s = %d\n", "out", out_fh); 
  debug_print("%s = %d\n", "status", status_fh); 
  debug_print("%s = %d\n", "rows", rows); 
  debug_print("%s = %d\n", "cols", cols); 
  debug_print("%s = %d\n\n", "debug", debug); 

  in_fp = fdopen(in_fh, "r");
  if (in_fp == NULL){
    asprintf(&error_message,
      "%s: can't fdopen in_fh (%d)", prog_name, in_fh);
    perror(error_message);
    exit(-1);
  }
  out_fp = fdopen(out_fh, "w");
  if (out_fp == NULL){
    asprintf(&error_message,
      "%s: can't fdopen out_fp (%d)", prog_name, out_fh);
    perror(error_message);
    exit(-1);
  }

  fprintf(out_fp, "P4 %d %d\n", cols, rows);

  debug_print("Start reading bitmap.\n"); 
  while ((in = fgetc(in_fp)) != EOF){
    out = 0;
    im = 0x01;
    outm = 0x80;
    for (i = 0; i < 8; i++) {
      if (in & im) {
        out |= outm;
      }
      im *= 2;
      outm /= 2;
    }
    if (fputc(out, out_fp) == EOF) {
      asprintf(&error_message, "%s: Error on write", prog_name);
      perror(error_message);
      exit(-1);
    }
  }
  debug_print("Done reading bitmap.\n"); 

  /* inform parent we're done */
  if (status_fh >= 0) {
    i = asprintf(&v, "OK\n");
    write(status_fh, (void *) v, i);
    free(v);
  }
}
