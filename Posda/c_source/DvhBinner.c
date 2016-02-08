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
#  in0=<number of input fd>      on which the Resampled Dose is read
#  in1=<number of input fd>      on which the ROI bitmap is read
#  out1=<number of output fd>    to which the histogram is written
#  status=<number of output fd>  to which the status is written
#  binwidth = <bin_width>        in cGy
#
*/
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdarg.h>
#include <errno.h>
#include <unistd.h>

int debug = 0;
int dose_in_fh = 0;
int bitmap_in_fh = 0;
int histogram_out_fh = 0;
int status_fh = 0;
int bytes_per_pix;
float binwidth = 1.0;
float voxel_volume = 1.0;

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
  int iv;
  int ec;
  int dose_data = 1;
  int bits_expanded = 0;
  int dose_points_read = 0;
  int sum;
  int blkcnt = 0;
  int highest_bin = 0;
  int largest_dose = -1;
  int smallest_dose = -1;
  int pix, bin;
  int vol = 0;
  unsigned long l_pix;
  unsigned short s_pix;
  int *bins;
  char *k;
  char *v;
  char *p;
  char *error_message;
  FILE *dose_in_fp = NULL;
  FILE *bitmap_in_fp = NULL;
  FILE *histogram_out_fp = NULL;

  prog_name = argv[0];

  /* Here we parse the command line parameters */
  for (i = 1; i < argc; i++){
    k = strtok(argv[i], "=");
    v = strtok(NULL, "\n");
    if(strcmp(k, "binwidth") == 0){
      binwidth = atof(v);  /* in cGy */
    } else if(strcmp(k, "voxelvolume") == 0){
      voxel_volume = atof(v);
    } else if(strcmp(k, "bytesperpix") == 0){
      bytes_per_pix = atoi(v);
    } else if (strcmp(k, "status") == 0){
      status_fh = atoi(v);
    } else if (strcmp(k, "in0") == 0){
      dose_in_fh = atoi(v);
    } else if (strcmp(k, "in1") == 0){
      bitmap_in_fh = atoi(v);
    } else if (strcmp(k, "out1") == 0){
      histogram_out_fh = atoi(v);
    } else if (strcmp(k, "debug") == 0){
      debug = atoi(v);
    } else {
      fprintf(stderr, "%s: unexpected arg: %s = %s.\n", prog_name, k, v);
    }
  }

  debug_print("parsing of params is complete\n"); 
  debug_print("%s = %f\n", "binwidth", binwidth); 
  debug_print("%s = %f\n", "voxelvolume", voxel_volume); 
  debug_print("%s = %d\n", "bytesperpix", bytes_per_pix); 
  debug_print("%s = %d\n", "in0/dose_in_fh", dose_in_fh); 
  debug_print("%s = %d\n", "in1/bitmap_in_fh", bitmap_in_fh); 
  debug_print("%s = %d\n", "out1/histogram_out_fh", histogram_out_fh); 
  debug_print("%s = %d\n", "status", status_fh); 
  debug_print("%s = %d\n\n", "debug", debug); 

  bins = (int *) calloc(sizeof(int), 65536);
  if (bins == NULL) {
    asprintf(&error_message,
      "%s: Error on alloc of 65536 bytes ", prog_name);
    perror(error_message);
    exit(-1);
  }

  dose_in_fp = fdopen(dose_in_fh, "r");
  if (dose_in_fp == NULL){
    asprintf(&error_message,
      "%s: can't fdopen dose_in_fh (%d)", prog_name, dose_in_fh);
    perror(error_message);
    exit(-1);
  }
  bitmap_in_fp = fdopen(bitmap_in_fh, "r");
  if (bitmap_in_fp == NULL){
    asprintf(&error_message,
      "%s: can't fdopen bitmap_in_fh (%d)", prog_name, bitmap_in_fh);
    perror(error_message);
    exit(-1);
  }
  histogram_out_fp = fdopen(histogram_out_fh, "w");
  if (histogram_out_fp == NULL){
    asprintf(&error_message,
      "%s: can't fdopen histogram_out_fh (%d)", 
      prog_name, histogram_out_fh);
    perror(error_message);
    exit(-1);
  }

  while (dose_data) {
    if ((c = getc(bitmap_in_fp)) == EOF){
      /* c = 0xff; */
      debug_print("EOF on bitmap socket.\n"); 
      break;
    }
    ec = c & 0x7f;
    if (ec == 0) {
      debug_print("bitmap count zero.\n"); 
      continue;
    }
    /* Process ec points */
    bits_expanded += ec;
    /*
debug_print("Reading %d dose values, process flag: %d\n", 
      ec, (c & 0x80) ? 1 : 0); 
      */
    for (j = 0; j < ec; j++){
      if (bytes_per_pix == 2){
        if (fread(&s_pix,(size_t) 1, sizeof(s_pix), dose_in_fp) 
            != sizeof(s_pix)) {
          asprintf(&error_message,
            "%s: Error on dose read, but bit map data available", 
            prog_name);
          perror(error_message);
debug_print("Error on dose input during read, bytes: %d\n", sizeof(s_pix)); 
debug_print("\tRead %d dose points of %d expected, process flag: %d.\n", 
            j, ec, (c & 0x80) ? 1 : 0);
          dose_data = 0;
          break;
        }
        pix = s_pix;
      } else {
        if (fread(&l_pix,(size_t) 1, sizeof(l_pix), dose_in_fp) 
            != sizeof(l_pix)) {
          asprintf(&error_message,
            "%s: Error on dose read, but bit map data available", 
            prog_name);
          perror(error_message);
debug_print("Error on dose input during read, bytes: %d\n", sizeof(l_pix)); 
debug_print("\tRead %d dose points of %d expected.\n", j, ec);
          dose_data = 0;
          break;
        }
        pix = l_pix;
      }
      dose_points_read += 1;
      if (c & 0x80) {
        bin = pix/binwidth;
        if(smallest_dose < 0)
          smallest_dose = pix;
        if(smallest_dose > pix)
          smallest_dose = pix;
        if(largest_dose < 0)
          largest_dose = pix;
        if(largest_dose < pix)
          largest_dose = pix;
        if(bin > highest_bin)
          highest_bin = bin;
        bins[bin] += 1;
        vol += 1;
      }
    }
  }
  debug_print("Done reading bitmap socket.\n"); 

  if (!feof(bitmap_in_fp)) {
    asprintf(&error_message,
      "%s: EOF on dose, but bit map data available", prog_name);
    perror(error_message);
  }
  if (!feof(dose_in_fp)) {
    if (bytes_per_pix == 2){
      if (fread(&s_pix,(size_t) 1, sizeof(s_pix), dose_in_fp) 
          == sizeof(s_pix)
      ) {
        asprintf(&error_message,
          "%s: EOF on bit map, but dose data available", prog_name);
        perror(error_message);
      }
    } else {
      if (fread(&l_pix,(size_t) 1, sizeof(l_pix), dose_in_fp) 
          == sizeof(l_pix)
      ){
        asprintf(&error_message,
          "%s: EOF on bit map, but dose data available", prog_name);
        perror(error_message);
      }
    }
  }
  highest_bin += 1;
/* process and output bins here */
  sum = 0;
  for (j = highest_bin; j >= 0; j--){
    sum += bins[j];
    bins[j] = sum;
  }
  fprintf(histogram_out_fp, "Number of bins: %d\n", highest_bin + 1);
  fprintf(histogram_out_fp, "Number of pixmap bits read: %d\n", 
    bits_expanded);
  fprintf(histogram_out_fp, "Voxel Volume: %f\n", voxel_volume);
  fprintf(histogram_out_fp, "Total Volume: %f\n", 
    ((float) vol * voxel_volume));
  fprintf(histogram_out_fp, "Smallest Dose: %d, largest: %d\n", 
    smallest_dose, largest_dose);
  fprintf(histogram_out_fp, "Bin Width: %f\n", binwidth);
  for(j = 0; j <= highest_bin; j++){
    fprintf(histogram_out_fp, "%d %.5f %.2f\n", 
      j, (((float) bins[j]) * voxel_volume),
      ( 100.0 * (((float) bins[j]) / ((float) vol))));
  }
  fclose(histogram_out_fp);

  debug_print("Number of bins: %d\n", highest_bin);
  debug_print("Number of pixmap bits read: %d\n", bits_expanded);
  debug_print("Number of dose_points read: %d\n", dose_points_read);
  debug_print("Voxel Volume: %f\n", voxel_volume);
  debug_print("Total Volume: %f\n", ((float) vol * voxel_volume));
  debug_print("Smallest Dose: %d, largest: %d\n",
       smallest_dose, largest_dose);
  debug_print("Bin Width: %f\n", binwidth);

  /* inform parent we're done */
  iv = asprintf(&v, "OK\n");
  write(status_fh, (void *) v, iv);
  free(v);
}
