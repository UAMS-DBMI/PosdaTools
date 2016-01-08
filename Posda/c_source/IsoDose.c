/*
#$Source: /home/bbennett/pass/archive/Posda/c_source/IsoDose.c,v $
#$Date: 2014/05/14 15:43:21 $
#$Revision: 1.5 $
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
#  in0=<number of input fd>      on which the Resampled Dose is read
#  in<n>=<number of input fd>    on which the ROI bitmap <n> is read
#                                (n >= 1)
#  out<n>=<number of output fd>  to which the histogram <n> is written
#                                (n >= 1 corresponds to ROI bitmap)
#  status=<number of output fd>  to which the status is written
#  binwidth = <bin_width>
#
*/
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>
#include <fcntl.h>

int input_fh;
int output_fh;
int status_fh;
int level;
int bytes;

char *prog_name;

int main(int argc, char *argv[]){
  int i, j;
  char *k;
  char *v;
  int iv;
  short s_dose;
  long l_dose;
  int dose;
  int polarity = 0;
  int count = 0;
  int d_pol;
  int rc;
  int outb;
  int flags;
  short s_pix;
  long l_pix;
  int tot_pix_read = 0;
  FILE *input_fp;
  FILE *output_fp;
  char *error_message;

  prog_name = argv[0];
  /* Here we parse the command line parameters */
  for (i = 1; i < argc; i++){
    k = strtok(argv[i], "=");
    v = strtok(NULL, "\n");
    if(strcmp(k, "level") == 0){
      level = atoi(v);
    } else if(strcmp(k, "bytes") == 0){
      bytes = atoi(v);
    } else if (strcmp(k, "status") == 0){
      status_fh = atoi(v);
    } else if (strcmp(k, "in") == 0){
      input_fh = atoi(v);
    } else if (strcmp(k, "out") == 0){
      output_fh = atoi(v);
    } else {
      iv = atoi(v);
      printf("key: %s, value: %d\n", k, iv);
    }
  }

  if (bytes != 2 && bytes != 4) {
    asprintf(&error_message,
      "%s: Value of bytes is invalid: %d (shoud be 2 or 4).", 
      prog_name, bytes);
    perror(error_message);
    exit(-1);
  }
  input_fp = fdopen(input_fh, "r");
  if (input_fp == NULL){
    asprintf(&error_message,
      "%s: can't fdopen input_fh (%d)", prog_name, input_fh);
    perror(error_message);
    exit(-1);
  }
  output_fp = fdopen(output_fh, "w");
  if (output_fp == NULL){
    asprintf(&error_message,
      "%s: can't fdopen output_fh (%d)", prog_name, output_fh);
    perror(error_message);
    exit(-1);
  }
  /* The main loop goes here */
  while(1){
    if(bytes == 2){
      if (fread(&s_pix, sizeof(s_pix), 1, input_fp) != 1) {
        break;
      }
      dose = s_pix;
    } else {
      if (fread(&l_pix, sizeof(l_pix), 1, input_fp) != 1) {
        break;
      }
      dose = l_pix;
    }
    tot_pix_read += 1;
    if (dose > level) d_pol = 1;
    else d_pol = 0;
    if (d_pol == polarity){ 
      count += 1;
      if(count > 127){
        outb = (polarity ? 0x80 : 0) | 127;
        /* write(output_fh, &outb, 1); */
        if (fputc(outb, output_fp) == EOF) {
          asprintf(&error_message, "%s: Error on write", prog_name);
          perror(error_message);
          exit(-1);
        }
        count -= 127;
      }
    } else {
      if(count > 0){
        outb = (polarity ? 0x80 : 0) + count;
        /* write(output_fh, &outb, 1); */
        if (fputc(outb, output_fp) == EOF) {
          asprintf(&error_message, "%s: Error on write", prog_name);
          perror(error_message);
          exit(-1);
        }
        count = 0;
      }
      polarity = d_pol;
      count = 1;
    }
  }
  if(count > 0){
    outb = (polarity ? 0x80 : 0) | count;
    /* write(output_fh, &outb, 1); */
    if (fputc(outb, output_fp) == EOF) {
      asprintf(&error_message, "%s: Error on write", prog_name);
      perror(error_message);
      exit(-1);
    }
  }
  fclose(input_fp);
  fclose(output_fp);
  fprintf(stderr, "%s: tot_pix_read: %d.\n", prog_name,
          tot_pix_read);
  /* inform parent we're done */
  iv = asprintf(&v, "OK\n");
  write(status_fh, (void *) v, iv);
  free(v);
}
