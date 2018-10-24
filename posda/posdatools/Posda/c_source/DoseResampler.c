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
#include <stdint.h>
#include <errno.h>
#include <sys/types.h>
#include <sys/stat.h>
#include <fcntl.h>
#include <unistd.h>

char *prog_name;
int output_fh;
int status_fh;
char *file_name;
int s_rows;
int s_cols;
float s_rowspc;
float s_colspc;
int s_pix_offset;
int s_gfov_offset;
int s_gfov_length;
int s_bits_alloc;
char *s_dose_units;
float s_dose_scaling;
float r_ulx;
float r_uly;
float r_ulz;
int r_rows;
int r_cols;
int r_frames;
float r_spc, r_spc_x, r_spc_y, r_spc_z;
int r_bits_alloc;
char *r_dose_units;
float r_dose_scaling;

int s_bytes_per_pixel;
int r_bytes_per_pixel;
int r_plane_size;
int s_plane_size;
int row_size;
int total_pix_writen = 0;
char *empty_p;
char *gfov_text;
int *gfov;
int dose_fh;
FILE *dose_fp;
char *error_message;
int s_written;
int debug = 0;

/* grid frame offset vector */
typedef struct gfov_entry {
  float offset;
  int index;
  void *next;
}gfov_entry;
gfov_entry *gfov_start = NULL;
gfov_entry *gfov_last = NULL;
float *gfov_array;
float *gfov_swap;
int gfov_array_size;
int backwards_frames = 0;
int f_pix_plane_offset;
int t_pix_plane_offset;
int pix_value;
int pix_ovvset;

/* loop variables */
float plane_z, c_plane_z, n_plane_z, l_plane_z;
int s_plane_i, n_plane_i;
float row_y_b, row_y, row_inc, col_x_b, col_x, col_inc;
int row_i_f, row_i_t, col_i_f, col_i_t;
float row_int_frac, col_int_frac, p_int_frac;
int row_i, col_i, plane_i;
int r1c1_i, r1c2_i, r2c1_i, r2c2_i;
char *f_pix_plane, *t_pix_plane;
uint32_t *f_pix_plane_l, *t_pix_plane_l;
uint16_t *f_pix_plane_s, *t_pix_plane_s;
uint32_t lfff, ltff, lftf, lttf, lffn, ltfn, lftn, lttn;
float vfff, vtff, vftf, vttf, vffn, vtfn, vftn, vttn;
float viff, vitf, vifn, vitn;
float viif, viin;
float value;
float value_units_scaling = 1.0;
uint16_t s_v;
uint32_t l_v;
uint16_t outbuff_s;
uint32_t outbuff_l;

void *get_pixel_plane(int ip){
  off_t fp;
  if(ip == -1) return NULL;
  char *pix_p;
  int i, j;
  int offset;
  if(backwards_frames){
    offset = s_pix_offset + ((gfov_array_size - 1 - ip) * s_plane_size);
  } else {
    offset = s_pix_offset + (ip * s_plane_size);
  }
  fp = fseek(dose_fp, offset, SEEK_SET);
  if(fp < 0){
    i = asprintf(&error_message,
      "%s Couldn't seek dose file %s to start of pixel data (%d)",
      prog_name, file_name, ip);
    perror(error_message);
    free(error_message);
    exit(-1);
  }
  pix_p = calloc(s_plane_size, 1);
  if(pix_p == NULL) {
    j = asprintf(&error_message,
      "%s unable to calloc %d bytes for plane %d",
      prog_name, s_plane_size, ip);
    perror(error_message);
    free(error_message);
    exit(-1);
  }
  i = fread(pix_p,  (size_t) 1, (size_t) s_plane_size, dose_fp);
  if(i != s_plane_size){
    j = asprintf(&error_message,
      "%s read %d vs %d bytes for pix_data(%d) in dose file %s",
      prog_name, i, s_plane_size, ip, file_name);
    perror(error_message);
    free(error_message);
    exit(-1);
  }
  return pix_p;
}

int main(int argc, char *argv[]){
  int i, j;
  char *v, *k;
  off_t fp;
  char *off;
  gfov_entry *noff;
  FILE *output_fp;

  /* Here we parse the command line parameters */
  r_spc = r_spc_x = r_spc_y = r_spc_z = -1;
  prog_name = argv[0];
  for (i = 1; i < argc; i++){
    k = strtok(argv[i], "=");
    v = strtok(NULL, "\n");
    if(strcmp(k, "source_dose_file_name") == 0){
      file_name = v;
    } else if(strcmp(k, "out") == 0){
      output_fh = atoi(v);
    } else if (strcmp(k, "status") == 0){
      status_fh = atoi(v);
    } else if (strcmp(k, "source_rows") == 0){
      s_rows = atoi(v);
    } else if (strcmp(k, "source_cols") == 0){
      s_cols = atoi(v);
    } else if (strcmp(k, "source_rowspc") == 0){
      s_rowspc = atof(v);
    } else if (strcmp(k, "source_colspc") == 0){
      s_colspc = atof(v);
    } else if (strcmp(k, "source_pixel_offset") == 0){
      s_pix_offset = atoi(v);
    } else if (strcmp(k, "source_gfov_offset") == 0){
      s_gfov_offset = atoi(v);
    } else if (strcmp(k, "source_gfov_length") == 0){
      s_gfov_length = atoi(v);
    } else if (strcmp(k, "source_bits_alloc") == 0){
      s_bits_alloc = atoi(v);
    } else if (strcmp(k, "source_dose_scaling") == 0){
      s_dose_scaling = atof(v);
    } else if (strcmp(k, "source_dose_units") == 0){
      s_dose_units = v;
    } else if (strcmp(k, "resamp_rows") == 0){
      r_rows = atoi(v);
    } else if (strcmp(k, "resamp_cols") == 0){
      r_cols = atoi(v);
    } else if (strcmp(k, "resamp_frames") == 0){
      r_frames = atoi(v);
    } else if (strcmp(k, "resamp_ulx") == 0){
      r_ulx = atof(v);
    } else if (strcmp(k, "resamp_uly") == 0){
      r_uly = atof(v);
    } else if (strcmp(k, "resamp_ulz") == 0){
      r_ulz = atof(v);
    } else if (strcmp(k, "resamp_spc") == 0){
      r_spc = atof(v);
    } else if (strcmp(k, "r_spc_x") == 0){
      r_spc_x = atof(v);
    } else if (strcmp(k, "r_spc_y") == 0){
      r_spc_y = atof(v);
    } else if (strcmp(k, "r_spc_z") == 0){
      r_spc_z = atof(v);
    } else if (strcmp(k, "resamp_bits_alloc") == 0){
      r_bits_alloc = atoi(v);
    } else if (strcmp(k, "resamp_dose_units") == 0){
      r_dose_units = v;
    } else if (strcmp(k, "resamp_dose_scaling") == 0){
      r_dose_scaling = atof(v);
    } else {
      printf("%s unhandled param - key: %s, value: %s\n", prog_name, k, v);
    }
  }
  if(strcmp(s_dose_units, r_dose_units) != 0){
    if(
      strcmp(s_dose_units, "GRAY") == 0 &&
      strcmp(r_dose_units, "CGRAY") == 0
    ){
      value_units_scaling = 100.0;
    } else if(
      strcmp(r_dose_units, "GRAY") == 0 &&
      strcmp(s_dose_units, "CGRAY") == 0
    ){
      value_units_scaling = 0.01;
    } else {
      fprintf(stderr, "%s: Unknown dose units source: %s resamp: %s\n",
        prog_name, s_dose_units, r_dose_units);
      exit(-1);
    }
  }
/* debug param parsing
printf("%s parsing of params is complete\n", prog_name);
printf("%s %s = %s\n", prog_name, "file_name", file_name);
printf("%s %s = %d\n", prog_name, "out", output_fh);
printf("%s %s = %d\n", prog_name, "status", status_fh);
printf("%s %s = %d\n", prog_name, "source_rows", s_rows);
printf("%s %s = %d\n", prog_name, "source_cols", s_cols);
printf("%s %s = %f\n", prog_name, "source_rowspc", s_rowspc);
printf("%s %s = %f\n", prog_name, "source_colspc", s_colspc);
printf("%s %s = %d\n", prog_name, "source_pixel_offset", s_pix_offset);
printf("%s %s = %d\n", prog_name, "source_gfov_offset", s_gfov_offset);
printf("%s %s = %d\n", prog_name, "source_gfov_length", s_gfov_length);
printf("%s %s = %d\n", prog_name, "source_bits_alloc", s_bits_alloc);
printf("%s %s = %f\n", prog_name, "source_dose_scaling", s_dose_scaling);
printf("%s %s = %s\n", prog_name, "source_dose_units", s_dose_units);
printf("%s %s = %d\n", prog_name, "resamp_rows", r_rows);
printf("%s %s = %d\n", prog_name, "resamp_cols", r_cols);
printf("%s %s = %d\n", prog_name, "resamp_frames", r_frames);
printf("%s %s = %f\n", prog_name, "resamp_ulx", r_ulx);
printf("%s %s = %f\n", prog_name, "resamp_uly", r_uly);
printf("%s %s = %f\n", prog_name, "resamp_ulz", r_ulz);
if(r_spc != -1){
  printf("%s %s = %f\n", prog_name, "resamp_spc", r_spc);
} else {
  printf("%s resamp_spc undefined\n", prog_name);
}
if(r_spc_x != -1){
  printf("%s %s = %f\n", prog_name, "r_spc_x", r_spc_x);
} else {
  printf("%s r_spc_x undefined\n", prog_name);
}
if(r_spc_y != -1){
  printf("%s %s = %f\n", prog_name, "r_spc_y", r_spc_y);
} else {
  printf("%s r_spc_y undefined\n", prog_name);
}
if(r_spc_z != -1){
  printf("%s %s = %f\n", prog_name, "r_spc_z", r_spc_z);
} else {
  printf("%s r_spc_z undefined\n", prog_name);
}
printf("%s %s = %d\n", prog_name, "resamp_bits_alloc", r_bits_alloc);
printf("%s %s = %s\n", prog_name, "resamp_dose_units", r_dose_units);
printf("%s %s = %f\n", prog_name, "resamp_dose_scaling", r_dose_scaling);
printf("%s %s = %f\n", prog_name, "value_units_scaling", value_units_scaling);
end debug */
  /* bits alloc to bytes per pixel */
  if(s_bits_alloc == 16) s_bytes_per_pixel = 2;
  else if(s_bits_alloc == 32) s_bytes_per_pixel = 4;
  else {
    fprintf(stderr, "%s: I don't handle %d bits per pixel (source)\n",
      prog_name,
      s_bits_alloc);
    exit(-1);
  }
  if(r_bits_alloc == 16) r_bytes_per_pixel = 2;
  else if(r_bits_alloc == 32) r_bytes_per_pixel = 4;
  else {
    fprintf(stderr, "%s: I don't handle %d bits per pixel (resampled)\n",
      prog_name,
      r_bits_alloc);
    exit(-1);
  }
  /* calculate plane size  and calloc empty plane */
  row_size = r_cols * r_bytes_per_pixel;
  r_plane_size = r_rows * row_size;
  s_plane_size = s_rows * s_cols * s_bytes_per_pixel;
  empty_p = calloc(r_plane_size, 1);

  /* open the dose file */
  dose_fh = open(file_name, O_RDONLY);
  if(dose_fh < 0){
    i = asprintf(&error_message, "%s Couldn't open dose file %s",
      prog_name, file_name);
    perror(error_message);
    free(error_message);
    exit(-1);
  }
  dose_fp = fdopen(dose_fh,"r");
  if(dose_fp == NULL){
    i = asprintf(&error_message, "%s Couldn't fopen dose file %s",
      prog_name, file_name);
    perror(error_message);
    free(error_message);
    exit(-1);
  }
  output_fp = fdopen(output_fh, "w");
  if (output_fp == NULL){
    asprintf(&error_message,
      "%s: can't fdopen output_fh (%d)", prog_name, output_fh);
    perror(error_message);
    exit(-1);
  }
  
  /* allocate space for gfov_text and read in the text */
  gfov_text = calloc(s_gfov_length + 1, 1);
  fp = fseek(dose_fp, s_gfov_offset, SEEK_SET);
  if(fp < 0){
    i = asprintf(&error_message,
      "%s Couldn't seek dose file %s to start of gfov (%d)",
      prog_name, file_name, s_gfov_offset);
    perror(error_message);
    free(error_message);
    exit(-1);
  }
  i = fread(gfov_text,  (size_t) 1, (size_t) s_gfov_length, dose_fp);
  if(i != s_gfov_length){
    j = asprintf(&error_message,
      "%s read %d vs %d bytes for gfov in dose file %s",
      prog_name, i, s_gfov_length, file_name);
    perror(error_message);
    free(error_message);
    exit(-1);
  }
  /* build the grid frame offset_vector */
  off = strtok(gfov_text, "\\");
  i = 0;
  while(off != NULL){
    noff = calloc(sizeof(gfov_entry), 1);
    noff->offset = atof(off);
    noff->index = i++;
    if(gfov_start == NULL){
      gfov_start = noff;
      gfov_last = noff;
    } else {
      gfov_last->next = noff;
      gfov_last = noff;
    }
    off = strtok(NULL, "\\");
  }
  gfov_array_size = gfov_last->index + 1;
  gfov_array = calloc(sizeof(float), gfov_array_size);
  while(gfov_start != NULL){
    gfov_array[gfov_start->index] = gfov_start->offset;
    noff = gfov_start;
    gfov_start = gfov_start->next;
    free(noff);
    noff = NULL;
  }
  /* reverse the gfov if last entry is negative */
  if(gfov_array[gfov_array_size - 1] < gfov_array[0]){
    gfov_swap = calloc(sizeof(float), gfov_array_size);
    for( i = 0; i < gfov_array_size; i++){
      gfov_swap[i] = gfov_array[(gfov_array_size - 1) - i];
    } 
    free(gfov_array);
    gfov_array = gfov_swap;
    gfov_swap = NULL;
    r_ulz += gfov_array[0];
    backwards_frames = 1;
  }
  if(r_spc != -1){
    if(r_spc_x == -1) r_spc_x = r_spc;
    if(r_spc_y == -1) r_spc_y = r_spc;
    if(r_spc_z == -1) r_spc_z = r_spc;
  }
  if(
    (r_spc_x == -1) ||
    (r_spc_y == -1) ||
    (r_spc_z == -1)
  ){
    fprintf(stderr, "%s: resampling intervals not properly defined\n",
      prog_name);
    exit(-1);
  }
  /* resample */
  row_y_b = r_uly/s_rowspc;
  row_inc = r_spc_y/s_rowspc;
  col_x_b = r_ulx/s_colspc;
  col_inc = r_spc_x/s_colspc;
  for ( /* outer loop */
    plane_i = 0, 
      plane_z = r_ulz,
      s_plane_i = 0, 
      n_plane_i = 1, 
      c_plane_z = gfov_array[0],
      n_plane_z = gfov_array[1],
      l_plane_z = gfov_array[gfov_array_size - 1];
    plane_i < r_frames;
    plane_i++, plane_z += r_spc_z
   ){
      /* get current planes */
     if(
       plane_z < c_plane_z ||
       plane_z > l_plane_z
     ){
        s_written = 
          fwrite(empty_p, (size_t) r_plane_size, (size_t) 1, output_fp); 
        total_pix_writen += 
        ((size_t) r_plane_size)/
        ((r_bytes_per_pixel == 2)?
          ((size_t) sizeof(uint16_t)):((size_t) sizeof(uint32_t))
        );
        if (s_written != 1) {
          asprintf(&error_message, "%s: Error on write (1) %d vs %d", 
            prog_name, s_written, 1);
          perror(error_message);
          exit(-1);
        }
        continue;
     }
     while(plane_z > n_plane_z){
       s_plane_i += 1;
       c_plane_z = gfov_array[s_plane_i];
       n_plane_i = s_plane_i + 1;
       n_plane_z = (n_plane_i < gfov_array_size) ? gfov_array[n_plane_i] : -1;
       f_pix_plane = t_pix_plane;
       t_pix_plane = NULL;
     }
     if(plane_z > l_plane_z){
        s_written = 
          fwrite(empty_p, (size_t) r_plane_size, (size_t) 1, output_fp); 
        total_pix_writen += 
        ((size_t) r_plane_size)/
        ((r_bytes_per_pixel == 2)?
          ((size_t) sizeof(uint16_t)):((size_t) sizeof(uint32_t))
        );
        if (s_written != 1) {
          asprintf(&error_message, "%s: Error on write (2)", prog_name);
          perror(error_message);
          exit(-1);
        }
        continue;
     }
     if(f_pix_plane == NULL) f_pix_plane = get_pixel_plane(s_plane_i);
     if(t_pix_plane == NULL) t_pix_plane = get_pixel_plane(n_plane_i);
     f_pix_plane_s = (uint16_t *) f_pix_plane;
     f_pix_plane_l = (uint32_t *) f_pix_plane;
     t_pix_plane_s = (uint16_t *) t_pix_plane;
     t_pix_plane_l = (uint32_t *) t_pix_plane;
     p_int_frac = (plane_z - c_plane_z) / (n_plane_z - c_plane_z);

     for (  /* middle loop */
       row_y = row_y_b, row_i = 0;
       row_i < r_rows;
       row_i++, row_y += row_inc
     ){
       if(row_y >= 0){
         row_i_f = row_y;
         row_int_frac = row_y - row_i_f;
         if(row_i_f +1 < s_rows){
           row_i_t = row_i_f + 1;
         } else {
           row_i_t = -1;
         }
         if(row_i_f >= s_rows){
           row_i_f = -1;
         }
       } else {
         row_i_f = -1;
         if(row_y + row_inc >= 0){
           row_i_t = 0;
         } else {
           row_i_t = -1;
         }
       }
       for ( /* inner loop */
         col_x = col_x_b, col_i = 0;
         col_i < r_cols;
         col_i++, col_x += col_inc
       ){
/*
if(total_pix_writen == 0x2e5eee){
  debug = 1;
  fprintf(stderr, "#######################\n%d setting debug\n", status_fh);
} else if (debug){
  debug = 0;
  fprintf(stderr, "#######################\n%d clearing debug\n", status_fh);
} else {
  debug = 0;
}
*/
         col_int_frac = 0;
         if(col_x >= 0){
           col_i_f = col_x;
           col_int_frac = col_x - col_i_f;
           if(col_i_f + 1 < s_cols){
             col_i_t = col_i_f + 1;
           } else {
             col_i_t = -1;
           }
         } else {
           col_i_f = -1;
           if(col_x + col_inc <= 0){
             col_i_t = -1;
           } else {
             col_i_t = 0;
           }
         }
         if(col_i_f >= s_cols){
           col_i_f = -1;
         }
         if(col_i_f >= 0) r1c1_i = (row_i_f * s_cols) + col_i_f;
         else r1c1_i = -1;
         if(col_i_t >= 0) r1c2_i = (row_i_f * s_cols) + col_i_t;
         else r1c2_i = -1;
         if(row_i_t >= 0 &&col_i_t >= 0) r2c1_i = (row_i_t * s_cols) + col_i_f;
         else r2c1_i = -1;
         if(row_i_t >= 0 &&col_i_t >= 0) r2c2_i = (row_i_t * s_cols) + col_i_t;
         else r2c2_i = -1;
/*
if(debug){
if(backwards_frames){
  f_pix_plane_offset = 
    ((gfov_array_size - 1 - s_plane_i) * s_plane_size);
} else {
  f_pix_plane_offset = (s_plane_i * s_plane_size);
}
if(backwards_frames){
  t_pix_plane_offset = 
    ((gfov_array_size - 1 - n_plane_i) * s_plane_size);
} else {
  t_pix_plane_offset = s_pix_offset + (n_plane_i * s_plane_size);
}
fprintf(stderr, "%d - row_i: %d\n", status_fh, row_i);
fprintf(stderr, "%d - col_i: %d\n", status_fh, col_i);
fprintf(stderr, "%d - s_plane_i: %d\n", status_fh, s_plane_i);
fprintf(stderr, "%d - c_plane_z: %f\n", status_fh, c_plane_z);
fprintf(stderr, "%d - n_plane_i: %d\n", status_fh, n_plane_i);
fprintf(stderr, "%d - n_plane_z: %f\n", status_fh, n_plane_z);
fprintf(stderr, "%d - s_plane_size: %d\n", status_fh, s_plane_size);
fprintf(stderr, "%d - col_x: %f\n", status_fh, col_x);
fprintf(stderr, "%d - col_x_b: %f\n", status_fh, col_x_b);
fprintf(stderr, "%d - r1c1_i: %d (%d, %d) (%06x, %06x)\n", 
  status_fh, r1c1_i, row_i_f, col_i_f,
  (r1c1_i * 2) + f_pix_plane_offset,
  (r1c1_i * 2) + t_pix_plane_offset);
fprintf(stderr, "%d - r2c1_i: %d (%d, %d)\n", 
  status_fh, r2c1_i, row_i_f, col_i_t);
fprintf(stderr, "%d - r1c2_i: %d (%d, %d)\n",
  status_fh, r1c2_i, row_i_t, col_i_f);
fprintf(stderr, "%d - r2c2_i: %d (%d, %d)\n", 
  status_fh, r2c2_i, row_i_t, col_i_t);
}
*/
         vfff = 0.0;
         if(s_bytes_per_pixel == 2){
           if(r1c1_i >= 0) vfff = f_pix_plane_s[r1c1_i];
         } else {
           if(r1c1_i >= 0) vfff = f_pix_plane_l[r1c1_i]; 
         }
         vtff = 0.0;
         if(s_bytes_per_pixel == 2){
           if(r2c1_i >= 0) vtff = f_pix_plane_s[r2c1_i];
         } else {
           if(r2c1_i >= 0) vtff = f_pix_plane_l[r2c1_i];
         }
         vftf = 0.0;
         if(s_bytes_per_pixel == 2){
           if(r1c2_i >= 0) vftf = f_pix_plane_s[r1c2_i];

         } else {
           if(r1c2_i >= 0) vftf = f_pix_plane_l[r1c2_i];
         }
         vttf = 0.0;
         if(s_bytes_per_pixel == 2){
           if(r2c2_i >= 0) vttf = f_pix_plane_s[r2c2_i];
         } else {
           if(r2c2_i >= 0) vttf = f_pix_plane_l[r2c2_i];
         }
         vffn = 0.0;
         if(s_bytes_per_pixel == 2){
           if(r1c1_i >= 0) vffn = t_pix_plane_s[r1c1_i];
         } else {
           if(r1c1_i >= 0) vffn = t_pix_plane_l[r1c1_i];
         }
         vtfn = 0.0;
         if(s_bytes_per_pixel == 2){
           if(r2c1_i >= 0) vtfn = t_pix_plane_s[r2c1_i];
         } else {
           if(r2c1_i >= 0) vtfn = t_pix_plane_l[r2c1_i];
         }
         vftn = 0.0;
         if(s_bytes_per_pixel == 2){
           if(r1c2_i >= 0) vftn = t_pix_plane_s[r1c2_i];
         } else {
           if(r1c2_i >= 0) vftn = t_pix_plane_l[r1c2_i];
         }
         vttn = 0.0;
         if(s_bytes_per_pixel == 2){
           if(r2c2_i >= 0) vttn = t_pix_plane_s[r2c2_i];
         } else {
           if(r2c2_i >= 0) vttn = t_pix_plane_l[r2c2_i];
         }
/*
if(debug){
pix_value = vtff;
pix_ovvset =  (r2c1_i * 2) + f_pix_plane_offset,
fprintf(stderr, "%d - vtff: %06x: %04x (%d)\n",
  status_fh, pix_ovvset, pix_value, pix_value);
pix_value = vfff;
pix_ovvset =  (r1c1_i * 2) + f_pix_plane_offset,
fprintf(stderr, "%d - vfff: %06x: %04x (%d)\n",
  status_fh, pix_ovvset, pix_value, pix_value);
pix_value = vttf;
pix_ovvset =  (r2c2_i * 2) + f_pix_plane_offset,
fprintf(stderr, "%d - vttf: %06x: %04x (%d)\n", 
  status_fh, pix_ovvset, pix_value, pix_value);
pix_value = vftf;
pix_ovvset =  (r1c2_i * 2) + f_pix_plane_offset,
fprintf(stderr, "%d - vftf: %06x: %04x (%d)\n", 
  status_fh, pix_ovvset, pix_value, pix_value);
pix_value = vtfn;
pix_ovvset =  (r2c1_i * 2) + t_pix_plane_offset,
fprintf(stderr, "%d - vtfn: %06x: %04x (%d)\n", 
  status_fh, pix_ovvset, pix_value, pix_value);
pix_value = vffn;
pix_ovvset =  (r1c1_i * 2) + t_pix_plane_offset,
fprintf(stderr, "%d - vffn: %06x: %04x (%d)\n", 
  status_fh, pix_ovvset, pix_value, pix_value);
pix_value = vttn;
pix_ovvset =  (r2c2_i * 2) + t_pix_plane_offset,
fprintf(stderr, "%d - vttn: %06x: %04x (%d)\n", 
  status_fh, pix_ovvset, pix_value, pix_value);
pix_value = vftn;
pix_ovvset =  (r2c1_i * 2) + t_pix_plane_offset,
fprintf(stderr, "%d - vftn: %06x: %04x (%d)\n", 
  status_fh, pix_ovvset, pix_value, pix_value);
fprintf(stderr, "%d - row_int_frac: %f\n", status_fh, row_int_frac);
fprintf(stderr, "%d - col_int_frac: %f\n", status_fh, col_int_frac);
fprintf(stderr, "%d - p_int_frac: %f\n", status_fh, p_int_frac);
}
*/
         viff = vfff + row_int_frac * (vtff - vfff);
         vitf = vftf + row_int_frac * (vttf - vftf);
         vifn = vffn + row_int_frac * (vtfn - vffn);
         vitn = vftn + row_int_frac * (vttn - vftn);
/*
if(debug){
fprintf(stderr, "%d - viff = (vfff + %f * (vtff - vfff)) = %f\n",
  status_fh, row_int_frac, viff);
fprintf(stderr, "%d - vitf = (vftf + %f * (vttf - vftf)) = %f\n",
  status_fh, row_int_frac, vitf);
fprintf(stderr, "%d - vifn = (vffn + %f * (vtfn - vffn)) = %f\n",
  status_fh, row_int_frac, vifn);
fprintf(stderr, "%d - vitn = (vftn + %f * (vttn - vftn)) = %f\n",
  status_fh, row_int_frac, vitn);
}
*/
         viif = viff + col_int_frac * (vitf - viff);
         viin = vifn + col_int_frac * (vitn - vifn);
/*
if(debug){
fprintf(stderr, "%d - viif = (viff + %f * (vitf - viff)) = %f\n",
  status_fh, col_int_frac, viif);
fprintf(stderr, "%d - viin = (vifn + %f * (vitn - vifn)) = %f\n",
  status_fh, col_int_frac, viin);
}
*/
         value = viif + p_int_frac * (viin - viif);
/*
if(debug){
fprintf(stderr, "%d - value = (viif + %f * (viin - viif)) = %f\n",
  status_fh, p_int_frac, value);
}
*/
         if(s_dose_scaling != r_dose_scaling){
           value = value * (s_dose_scaling / r_dose_scaling);
         }
         value = value * value_units_scaling;
/*
if(debug){
fprintf(stderr, "%d scaling - value *= %f = %f\n",
  status_fh, (s_dose_scaling / r_dose_scaling) * value_units_scaling, value);
}
*/
         if(r_bytes_per_pixel == 2){
           outbuff_s = value + 0.5;
           if (fwrite(&outbuff_s, (size_t) sizeof(uint16_t), 
                   (size_t) 1, output_fp) != 1) {
             asprintf(&error_message, "%s: Error on write (3)", prog_name);
             perror(error_message);
             exit(-1);
           }
         } else {
           outbuff_l = value + 0.5;
/*
if(debug){
  fprintf(stderr, "%d: %06x: %08x (%d)\n", 
    status_fh, total_pix_writen, outbuff_l, outbuff_l);
}
*/
           if (fwrite(&outbuff_l, (size_t) sizeof(uint32_t), 
                   (size_t) 1, output_fp) != 1) {
             asprintf(&error_message, "%s: Error on write (4)", prog_name);
             perror(error_message);
             exit(-1);
           }
         }
         total_pix_writen++;
       } /* end inner loop */
     } /* end middle loop */
   } /* end outer loop */
  fclose(output_fp);
  /* fprintf(stderr, "%s: total_pix_writen: %d.\n", prog_name, 
          total_pix_writen); */
  /* inform parent we're done */
  i = asprintf(&v, "OK\n");
  write(status_fh, (void *) v, i);
  free(v);
}
