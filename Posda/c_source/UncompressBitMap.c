/*
#$Source: /home/bbennett/pass/archive/Posda/c_source/UncompressBitMap.c,v $
#$Date: 2014/05/14 15:43:21 $
#$Revision: 1.5 $
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#

# Take a compressed bitmap and uncompress it
# 
# All of the parameters on the command line are of the form:
#  <name>=<value> (no spaces)
# parameter order does not matter.
# Here are the possible parameters:
#  None...
#
*/
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdarg.h>
#include <errno.h>

int debug = 0;

char *prog_name;

/* Define debug_print to be no op for production */
/*
#define debug_print(args...)
*/
void debug_print(const char* format, ...){
  va_list argptr;
  va_start(argptr, format);
  if (! debug) return;
  fprintf(stderr, "%s: ", prog_name);
  vfprintf(stderr, format, argptr);
  va_end(argptr);
}

int main(int argc, char *argv[]){
  int c;
  int i, j;
  int iv;
  int mask;
  int polarity;
  int count;
  int current_count = 0;
  int sub_count = 0;
  int new_current = 0;
  int constr_byte = 0;
  char *k;
  char *v;
  char *error_message;

  prog_name = argv[0];

  /* Here we parse the command line parameters */
  for (i = 1; i < argc; i++){
    k = strtok(argv[i], "=");
    v = strtok(NULL, "\n");
    if (strcmp(k, "debug") == 0){
      debug = atoi(v);
    } else {
      fprintf(stderr, "%s: unexpected arg: %s = %s.\n", prog_name, k, v);
    }
  }

  debug_print("parsing of params is complete\n"); 
  debug_print("%s = %d\n\n", "debug", debug); 

  debug_print("Start reading bitmap socket.\n"); 
  while ((c = fgetc(stdin)) != EOF){
    count = c & 0x7f;
    if (count == 0) {
      debug_print("bitmap count zero.\n"); 
      continue;
    }
    polarity = (c & 0x80) ? 0x01 : 0x00;
    while ((count + current_count) >= 8) {
      mask = polarity;
      if (current_count) {
        sub_count = 8 - current_count;
        mask <<= current_count;
        for (i = 0; i <= sub_count; i++) {
          constr_byte |= mask;
          mask <<= 1;
        }
        count -= sub_count;
        current_count = 0;
        if (fputc(constr_byte, stdout) == EOF) {
          asprintf(&error_message,
            "%s: Error on write of uncompressed bitmap", prog_name);
          perror(error_message);
          exit(-1);
        }
      } else {
        count -= 8;
        j = polarity ? 0xff : 0x00;
        if (fputc(j, stdout) == EOF) {
          asprintf(&error_message,
            "%s: Error on write of uncompressed bitmap", prog_name);
          perror(error_message);
          exit(-1);
        }
      }
    }
    new_current = current_count + count;
    mask = polarity;
    if (current_count) {
      for  (i = 0; i <= current_count-1; i++) {
        mask <<= 1;
      }
    } else {
      constr_byte = 0;
    }
    for  (i = 0; i <= count-1; i++) {
      constr_byte |= mask;
      mask <<= 1;
    }
    current_count = new_current;
  }

  debug_print("Done reading bitmap socket.\n"); 
  exit(0);
}
