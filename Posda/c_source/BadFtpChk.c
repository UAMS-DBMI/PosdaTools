/*
#$Source: /home/bbennett/pass/archive/Posda/c_source/BadFtpChk.c,v $
#$Date: 2014/05/14 15:43:21 $
#$Revision: 1.2 $
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
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

char *prog_name;

int main(int argc, char *argv[]){
  int  c1,c2;
  int  crlfs = 0;
  FILE *i_fp;

  prog_name = argv[0];

  i_fp = fopen(argv[1], "r");
  if(i_fp == NULL){
    fprintf(stdout, " -1\n");
    exit(-1);
  }
  c1 = getc(i_fp);
  while ((c2 = getc(i_fp)) != EOF){
    if (c1 == 0x0d  &&  c2 == 0x0a) { crlfs++; }
    c1 = c2;
  }
  fprintf(stdout, " %d\n", crlfs);

  exit(0);
}

