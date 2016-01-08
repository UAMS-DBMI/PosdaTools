/*
#$Source: /home/bbennett/pass/archive/Posda/c_source/RtogTextToNum.c,v $
#$Date: 2014/05/14 15:43:21 $
#$Revision: 1.2 $
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
*/
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <stdarg.h>
#include <errno.h>

int debug = 0;
int skip_string_lines = 0;
#define BUFFER_SIZE 4096

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

int is_digit(const char c) {
  if (c >= '0'  &&  c <= '9') return 1;
  if (c == '+'  || c == '-' || c == '.') return 1;
  return 0;
}

int main(int argc, char *argv[]){
  int c;
  int i, j;
  char *k;
  char *v;
  char *b;
  char *s;
  char *error_message;

  prog_name = argv[0];

  /* Here we parse the command line parameters */
  for (i = 1; i < argc; i++){
    k = strtok(argv[i], "=");
    v = strtok(NULL, "\n");
    if (strcmp(k, "debug") == 0){
      debug = atoi(v);
    } else if(strcmp(k, "skipstringlines") == 0){
      skip_string_lines = atoi(v);
    } else {
      fprintf(stderr, "%s: unexpected arg: %s = %s.\n", prog_name, k, v);
    }
  }

  debug_print("parsing of params is complete\n"); 
  debug_print("%s = %f\n", "skipstringlines", skip_string_lines); 
  debug_print("%s = %d\n\n", "debug", debug); 

  b = (char *) calloc(sizeof(char), BUFFER_SIZE);
  if (b == NULL) {
    asprintf(&error_message,
      "%s: Error on alloc of buffer", prog_name);
    perror(error_message);
    exit(-1);
  }

  s = b;
  *s = '\0';
  while ((c = fgetc(stdin)) != EOF) {
    if (c == '\0') continue;
    if (c == '\"') {
      while ((c = fgetc(stdin)) != EOF) {
        if (c == '\0') continue;
        if (c == '\"') break; 
      }
      continue;
    }
    if (is_digit(c)) {
      *s++ = c;
    } else {
      if (strlen(b) > 0) {
        *s++ = '\0';
        fprintf(stdout,"%s\n",b);
        s = b; *s = '\0';
      }
    }
  }
  if (strlen(b) > 0) {
    fprintf(stdout,"%s\n",b);
  }

}
