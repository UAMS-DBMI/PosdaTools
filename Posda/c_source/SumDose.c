/*
#$Source: /home/bbennett/pass/archive/Posda/c_source/SumDose.c,v $
#$Date: 2014/05/14 15:43:21 $
#$Revision: 1.5 $
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#

# Streamed Compressed Bitmap operations
#
# This program accepts pixel streams on multiple
# fds, scales and sums them, and
# outputs the results to another stream.
# The fd's have been opened by the parent process...
#
# What to do is specified on the command line.
# All of the parameters on the command line are of the form:
#  <name>=<value> (no spaces)
#
#
# Here are the possible parameters which make up the rp specification:
#  in=<number of an input fd>,<bits>,<scaling>,<units>,<weighting>
#  out=<number of output fd>,<bits>,<scaling>,<units>
#
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
#include <stdarg.h>

#define MAX_NUM_SUMMED_DOSES  256
int debug = 0;
char *prog_name;
char *error_message;

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

typedef struct in_stream{
  FILE *in_fp;
  float scale;
  float weight;
  int   in_fd;
  int   bits;
  int   open;
  int   bits_32;
  int   gray;
} in_stream;

int main(int argc, char *argv[]){
  int i, j;
  char *v, *k, *v2;

  FILE *out_fp;
  float out_scale;
  int   out_fd;
  int   out_bits;
  int   out_bits_32;
  int   out_cgray;
  int   status_fh = -1;

  int   num_in_streams = 0;
  /* in_stream  *streams = NULL; */
  in_stream  streams[MAX_NUM_SUMMED_DOSES];

  int   num_open;
  int   num_written = 0;
  float pix_value;
  float value;
  int   input_available = 1;
  uint16_t  s_pix;
  uint32_t  l_pix;
  int   dose;
  int pix_index = 0;


  /* Here we parse the command line parameters */
  prog_name = argv[0];
  /* 
  streams = calloc(num_in_streams, sizeof(in_stream));
  if (streams == NULL) {
    fprintf(stderr, "%s: Calloc failed on %d input streams.\n",
        prog_name, num_in_streams);
    exit(-1);
  }
  */
  for (i = 1; i < argc; i++){
    k = strtok(argv[i], "=");
    v = strtok(NULL, "\n");
    if (strcmp(k, "debug") == 0){
      debug = atoi(v);
    } else if(strcmp(k, "in") == 0){
      if (num_in_streams >= MAX_NUM_SUMMED_DOSES) {
        asprintf(&error_message, 
          "%s Invalid number of input streams: %d ( > %d).\n",
          prog_name, num_in_streams, MAX_NUM_SUMMED_DOSES);
        perror(error_message);
        exit(-1);
      }
      v2 = strtok(v,",");
      streams[num_in_streams].in_fd = atoi(v2);
      v2 = strtok(NULL,",");
      streams[num_in_streams].bits = atoi(v2);
      v2 = strtok(NULL,",");
      streams[num_in_streams].scale = atof(v2);
      v2 = strtok(NULL,",");
      if (strcmp(v2, "GRAY") == 0) {
        streams[num_in_streams].gray = 1;
      } else if (strcmp(v2, "CGRAY") == 0){
        streams[num_in_streams].gray = 0;
      } else {
        asprintf(&error_message, 
          "%s Invalid stream units: %s for input stream with file desc %d",
          prog_name, v2, streams[num_in_streams].in_fd);
        perror(error_message);
        exit(-1);
      }
      v2 = strtok(NULL,",");
      streams[num_in_streams].weight = atof(v2);
      debug_print(
       "In stream %d: fd: %d, bits: %d, scale: %f, gray: %d, weight: %f.\n",
        i,
        streams[num_in_streams].in_fd,
        streams[num_in_streams].bits,
        streams[num_in_streams].scale,
        streams[num_in_streams].gray,
        streams[num_in_streams].weight);
      num_in_streams++;
    } else if(strcmp(k, "out") == 0){
      v2 = strtok(v,",");
      out_fd = atoi(v2);
      v2 = strtok(NULL,",");
      out_bits = atoi(v2);
      v2 = strtok(NULL,",");
      out_scale = atof(v2);
      v2 = strtok(NULL,",");
      if (strcmp(v2, "CGRAY") == 0) {
        out_cgray = 1;
      } else if  (strcmp(v2, "GRAY") == 0) {
        out_cgray = 0;
      } else {
        asprintf(&error_message, 
          "%s Invalid stream units: %s for output stream with file desc %d",
          prog_name, v2, out_fd);
        perror(error_message);
        exit(-1);
      }
      debug_print(
       "Out stream: fd: %d, bits: %d, scale: %f, cgray: %d.\n",
        out_fd, out_bits, out_scale, out_cgray);
    } else if (strcmp(k, "status") == 0){
      status_fh = atoi(v);
    } else {
      printf("%s unhandled param - key: %s, value: %s\n", prog_name, k, v);
    }
  }
  debug_print("parsing of params is complete\n");

  /* Open all streams */
  for (i = 0; i < num_in_streams; i++) {
    streams[i].in_fp = fdopen(streams[i].in_fd,"r");
    if (streams[i].in_fp == NULL){
      i = asprintf(&error_message, "%s Couldn't fdopen input stream fd: %d",
        prog_name, streams[i].in_fd);
      perror(error_message);
      exit(-1);
    }
  }
  out_fp = fdopen(out_fd,"w");
  if (out_fp == NULL){
    i = asprintf(&error_message, "%s Couldn't fdopen output stream fd: %d",
      prog_name, out_fd);
    perror(error_message);
    exit(-1);
  }
  debug_print("All streams are open\n");

  /* args */
  for (i = 0; i < num_in_streams; i++) {
    if (streams[i].bits == 16) {
      streams[i].bits_32 = 0;
    } else if  (streams[i].bits == 32) {
      streams[i].bits_32 = 1;
    } else {
      asprintf(&error_message, 
        "%s Invalid num of bits %d for input stream with file desc %d",
        prog_name, streams[i].bits, streams[i].in_fd);
      perror(error_message);
      exit(-1);
    }
  }
  if (out_bits == 16) {
    out_bits_32 = 0;
  } else if  (out_bits == 32) {
    out_bits_32 = 1;
  } else {
    asprintf(&error_message, 
      "%s Invalid num of bits %d for output stream with file desc %d",
      prog_name, out_bits, out_fd);
    perror(error_message);
    exit(-1);
  }

  /* Main loop */
  debug_print("Starting main loop\n");
  while (input_available) {
    num_open = 0;
    pix_value = 0.0;
    for (i = 0; i < num_in_streams; i++) {
      if (streams[i].in_fp == NULL) { continue; }
      if (streams[i].bits_32) {
        if (fread(&l_pix, sizeof(l_pix), 1, streams[i].in_fp) != 1) {
          fclose(streams[i].in_fp);
          streams[i].in_fp = NULL;
          debug_print("In stream %d: fd: %d closed.\n",
            i, streams[i].in_fd);
          continue;
        }
        dose = l_pix;
      } else {
        if (fread(&s_pix, sizeof(s_pix), 1, streams[i].in_fp) != 1) {
          fclose(streams[i].in_fp);
          streams[i].in_fp = NULL;
          debug_print("In stream %d: fd: %d closed.\n",
            i, streams[i].in_fd);
          continue;
        }
        dose = s_pix;
      }
      num_open++;
      value = streams[i].scale * ((float) dose);
      if (streams[i].gray) { value *= 100.0; }
      pix_value += (value * streams[i].weight);
/*
if(pix_index >= 0x2e5eee && pix_index <= 0x2e5eee){
  fprintf(stderr, "xyzzy in pix at: %08x (%d): %04x, %f, %f\n", 
  pix_index, i, dose, value, pix_value);
}
*/
    }
    if (num_open == 0) { input_available = 0; continue; }
    pix_index += 1;
    if (num_open != num_in_streams) {
      asprintf(&error_message, "%s unbalanced inputs", prog_name);
      perror(error_message);
      exit(-1);
    }
    pix_value /= out_scale;
    if (!out_cgray) { pix_value /= 100.0; }
    if (out_bits_32) {
      l_pix = pix_value + 0.5;
      if (fwrite(&l_pix, (size_t) sizeof(l_pix),
          (size_t) 1, out_fp) != 1) {
        asprintf(&error_message, 
          "%s: Error on write (long pix value)", prog_name);
        perror(error_message);
        exit(-1); 
      }
    } else {
      s_pix = pix_value + 0.5;
      if (fwrite(&s_pix, (size_t) sizeof(s_pix),
          (size_t) 1, out_fp) != 1) {
        asprintf(&error_message, 
          "%s: Error on write (short pix value)", prog_name);
        perror(error_message);
        exit(-1); 
      }
    }
  }
  fclose(out_fp);
  debug_print("Main loop done\n");
  /* inform parent we're done */
  if (status_fh >= 0) {
    asprintf(&v, "OK\n");
    write(status_fh, (void *) v, i);
    free(v);
    close(status_fh);
    debug_print("Told parent were done.\n");
  }
  exit(0);
}
