/*
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
#
# Streamed Pixel operations
# This program accepts contours on an fd and writes a bitmap
# on another fd of the points contained within the contours
# The fd's have been opened by the parent process...

# What to do is specified on the command line.
# All of the parameters on the command line are of the form:
#  <name>=<value> (no spaces)
# parameter order does not matter.
# Here are the possible parameters:
#  in=<number of first input fd>
#  out=<number of output fd>
#  status=<number of status fd>
#  rows=<number of rows in bitmap output>
#  cols=<number of cols in bitmap output>
#  slices=<number of slices in bitmap output>
#  ulx=<x coordinate of upper left point>
#  uly=<y coordinate of upper left point>
#  ulz=<z coordinate of upper left point>
#  rowspc=<spacing between columns>
#  colspc=<spacing between rows>
#  slicespc=<spacing between slices>
#
# On the input socket, the format of the contours is the following:
# BEGIN CONTOUR at z        - marks the beginning of a contour at offset z
# x1,y1,z                   - first point in contour
# x2,y2,y2                  - next point
# ...                       - and so on
# xn,yn,zn                  - last point
# END CONTOUR
# ...                       - repeat for as many contours as you have
#
# This script uses ContourToBitMap.pl for each slice, passing it the
# contours on the nearest slice.  If the nearest slice has no contours
# you need to tell ContourToBitMap3d.pl by having a "BEGIN CONTOUR at z"
# followed immediately by an "END CONTOUR".  Otherwise, it will use the
# nearest slice it knows about (which might be far away)...
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
#include <sys/wait.h>
#include <sys/socket.h>
#include <fcntl.h>
#include <unistd.h>
#include <limits.h>
#include <math.h>

#define BUFFER_SIZE (65536 * 5)
#define MAX_CHILDREN 3

int in_fh = 0;
int out_fh = 0;
int status_fh = 0;
int rows = 0;
int cols = 0;
int num_slices = 0;
int debug = 0;
float ulx = 0.0;
float uly = 0.0;
float ulz = 0.0;
float rowspc = 0.0;
float colspc = 0.0;
float slicespc = 0.0;

char *prog_name;
char *error_message;
FILE *i_fp;

int num_children = 0;

typedef struct {
  void *next;
  char *data;
} contour_buff, *contour_buff_ptr;

typedef struct {
  void *next;
  contour_buff_ptr buff;
} contour_entry, *contour_entry_ptr;

typedef struct {
  contour_entry_ptr contour_entries;
  void *next;
  float z;
} contour, *contour_ptr;

typedef struct {
  contour_ptr contour;
  FILE *to_fp;
  FILE *from_fp;
  FILE *status_fp;
  void *next;
  float z;
  pid_t pid;
} slice, *slice_ptr;

contour_ptr contours = NULL;
slice_ptr slices = NULL;

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

int MakeSocketPair(int fd[2]) {
  /* on return, Write to fd[0] and read from fd[1] */
  int rc;
  rc = socketpair( AF_UNIX, SOCK_STREAM, PF_UNSPEC, fd );
  if ( rc < 0 ) {
    asprintf(&error_message, 
      "%s: Error %d making socketpair", prog_name, rc);
    perror(error_message);
    return(rc);
  } 
  /*
  struct linger linger;
  linger.l_onoff = 1;
  linger.l_linger = 5;
  setsockopt( fd[0], SOL_SOCKET, SO_LINGER, &linger, sizeof(linger));
  setsockopt( fd[1], SOL_SOCKET, SO_LINGER, &linger, sizeof(linger));
  */
  rc = shutdown(fd[0],SHUT_RD); /* disables reads from socket */
  if ( rc < 0 ) {
    asprintf(&error_message, 
      "%s: Error %d on shutdown SHUT_RD", prog_name, rc);
    perror(error_message);
    return(rc);
  } 
  rc = shutdown(fd[1],SHUT_WR); /* disables writes to socket */
  if ( rc < 0 ) {
    asprintf(&error_message, 
      "%s: Error %d on shutdown SHUT_WR", prog_name, rc);
    perror(error_message);
    exit(rc);
  } 
  return(0);
}

int set_cloexec_flag (int desc, int value) {
  int oldflags = fcntl (desc, F_GETFD, 0);
  /* If reading the flags failed, return error indication now. */
  if (oldflags < 0)
    return oldflags;
  /* Set just the flag we want to set. */
  if (value != 0)
    oldflags |= FD_CLOEXEC;
  else
    oldflags &= ~FD_CLOEXEC;
  /* Store modified flag word in the descriptor. */
  return fcntl (desc, F_SETFD, oldflags);
}

void StartNextChild(slice_ptr s_ptr){
  int to_fd[2] = {0,0}, from_fd[2] = {0,0}, status_fd[2] = {0,0};
  int rc;
  contour_buff_ptr c_b_ptr = NULL;
  contour_entry_ptr c_e_ptr = NULL;
  contour_ptr c_ptr = NULL;
  char arg[11][64];
  char *args[12];

  while (s_ptr != NULL) 
  {
    if (s_ptr->pid == 0  &&  
        s_ptr->contour != NULL)
      { break; }
    s_ptr = s_ptr->next;
  }
  if (s_ptr == NULL) {
    num_children = 9999;
    return;
  }

  debug_print("StartNextChild: Z = %f, pid: %d, contour %08x\n",
    s_ptr->z, s_ptr->pid, s_ptr->contour);

  /* open 3 socket pairs: to & from child & child status. */
  rc = MakeSocketPair(to_fd);
  if ( rc < 0 ) {
    asprintf(&error_message, 
      "%s: Error %d making to child socketpair", prog_name, rc);
    perror(error_message);
    exit(rc);
  } 
  debug_print("StartNextChild: to_fd: %d(w), %d(r)\n", to_fd[0], to_fd[1]);
  rc = MakeSocketPair(from_fd);
  if ( rc < 0 ) {
    asprintf(&error_message, 
      "%s: Error %d making from child socketpair", prog_name, rc);
    perror(error_message);
    exit(rc);
  } 
  debug_print("StartNextChild: from_fd: %d(w), %d(r)\n", from_fd[0], from_fd[1]);
  rc = MakeSocketPair(status_fd);
  if ( rc < 0 ) {
    asprintf(&error_message, 
      "%s: Error %d making status child socketpair", prog_name, rc);
    perror(error_message);
    exit(rc);
  } 
  debug_print("StartNextChild: status_fd: %d(w), %d(r)\n", 
    status_fd[0], status_fd[1]);
  /* Parent should Write to child using to_fd[0] */
  /* Parent should Read from child using from_fd[1] */
  /* Parent should Read status from child using status_fd[1] */

  /* Child should write to from_fd[0] */
  /* Child should write status to status_fd[0] */
  /* Child should read from to_fd[1] */

  debug_print("StartNextChild: Ready to fork... Z = %f\n", s_ptr->z);
  s_ptr->pid = fork();
  if (s_ptr->pid < 0) {
    asprintf(&error_message, 
      "%s: Fork failed: %d", prog_name, s_ptr->pid);
    perror(error_message);
    exit(-1);
  }
  if (s_ptr->pid == 0) { 
    /* We are in child now...  */
    /*
    close (to_fd[0]);
    close (from_fd[1]);
    close (status_fd[1]);
    debug_print("In Child: Closed FDs: %d, %d, %d\n", 
      to_fd[0],from_fd[1],status_fd[1]);
    */
    set_cloexec_flag(to_fd[0],1);
    set_cloexec_flag(from_fd[1],1);
    set_cloexec_flag(status_fd[1],1);
    set_cloexec_flag(to_fd[1],0);
    set_cloexec_flag(from_fd[0],0);
    set_cloexec_flag(status_fd[0],0);

    strcpy(arg[ 0],"ContourToBitmap");
    sprintf(arg[ 1], "in=%d",     to_fd[1]);
    sprintf(arg[ 2], "out=%d",    from_fd[0]);
    sprintf(arg[ 3], "status=%d", status_fd[0]);
    sprintf(arg[ 4], "rows=%d",   rows);
    sprintf(arg[ 5], "cols=%d",   cols);
    sprintf(arg[ 6], "ulx=%f",    ulx);
    sprintf(arg[ 7], "uly=%f",    uly);
    sprintf(arg[ 8], "ulz=%f",    s_ptr->z);
    sprintf(arg[ 9], "rowspc=%f", rowspc);
    sprintf(arg[10], "colspc=%f",  colspc);

    debug_print("In Child: arg 0 to execlp: '%s'\n", arg[ 0]);
    debug_print("In Child: arg 1 to execlp: '%s'\n", arg[ 1]);
    debug_print("In Child: arg 2 to execlp: '%s'\n", arg[ 2]);
    debug_print("In Child: arg 3 to execlp: '%s'\n", arg[ 3]);
    debug_print("In Child: arg 4 to execlp: '%s'\n", arg[ 4]);
    debug_print("In Child: arg 5 to execlp: '%s'\n", arg[ 5]);
    debug_print("In Child: arg 6 to execlp: '%s'\n", arg[ 6]);
    debug_print("In Child: arg 7 to execlp: '%s'\n", arg[ 7]);
    debug_print("In Child: arg 8 to execlp: '%s'\n", arg[ 8]);
    debug_print("In Child: arg 9 to execlp: '%s'\n", arg[ 9]);
    debug_print("In Child: arg 10 to execlp: '%s'\n", arg[10]);

    args[ 0] = arg[ 0];
    args[ 1] = arg[ 1];
    args[ 2] = arg[ 2];
    args[ 3] = arg[ 3];
    args[ 4] = arg[ 4];
    args[ 5] = arg[ 5];
    args[ 6] = arg[ 6];
    args[ 7] = arg[ 7];
    args[ 8] = arg[ 8];
    args[ 9] = arg[ 9];
    args[10] = arg[10];
    args[11] = NULL;

    rc = execvp("ContourToBitmap", args);
    if (rc < 0) {
      asprintf(&error_message, 
        "%s: execl failed: %d", prog_name, rc);
      perror(error_message);
      exit(-1);
    }
    debug_print("In Child: execvp OK: %s (%fi)\n", arg[ 0], s_ptr->z);
    exit(0);
  }
  /* We are in Parent now...  */
  num_children++;
  close (to_fd[1]);
  close (from_fd[0]);
  close (status_fd[0]);
  debug_print("In parent: Closed FDs: %d, %d, %d\n", 
    to_fd[1],from_fd[0],status_fd[0]);

  s_ptr->to_fp = fdopen(to_fd[0], "w");
  if (s_ptr->to_fp == NULL) {
    asprintf(&error_message, 
      "%s: can't fdopen to_fh (%d)", prog_name, to_fd[0]);
    perror(error_message);
    exit(-1);
  } 
  s_ptr->from_fp = fdopen(from_fd[1], "r");
  if (s_ptr->from_fp == NULL) {
    asprintf(&error_message, 
      "%s: can't fdopen from_fh (%d)", prog_name, from_fd[1]);
    perror(error_message);
    exit(-1);
  } 
  s_ptr->status_fp = fdopen(status_fd[1], "r");
  if (s_ptr->status_fp == NULL) {
    asprintf(&error_message, 
      "%s: can't fdopen status_fh (%d)", prog_name, status_fd[1]);
    perror(error_message);
    exit(-1);
  } 
  c_ptr = s_ptr->contour; 
  if (c_ptr->contour_entries != NULL) 
  {
    /* loop through contour_entries writing to child using s_ptr->to_fp */
    for (c_e_ptr = c_ptr->contour_entries; 
         c_e_ptr != NULL;
         c_e_ptr = c_e_ptr->next) {
      if (c_e_ptr->buff == NULL) continue;
  debug_print("Printing BEGIN CONTOUR to child\n");
      if (fputs("BEGIN CONTOUR\n", s_ptr->to_fp) < 0){
        asprintf(&error_message, 
          "%s: Error writing data to child, FD %d", prog_name, to_fd[0]);
        perror(error_message);
        exit(-1);
      }
      for (c_b_ptr = c_e_ptr->buff; 
           c_b_ptr != NULL;
           c_b_ptr = c_b_ptr->next) {
/*   debug_print("Data written to child: \"%s\"\n", c_b_ptr->data); */
        if (fputs(c_b_ptr->data, s_ptr->to_fp) < 0){
          asprintf(&error_message, 
            "%s: Error writing data to child, FD %d", prog_name, to_fd[0]);
          perror(error_message);
          exit(-1);
        }
        debug_print("In parent: wrote %d bytes to child\n", 
          strlen(c_b_ptr->data));
      }
  debug_print("Printing END CONTOUR to child\n");
      if (fputs("END CONTOUR\n", s_ptr->to_fp) < 0){
        asprintf(&error_message, 
          "%s: Error writing data to child, FD %d", prog_name, to_fd[0]);
        perror(error_message);
        exit(-1);
      }
    }
  }
  if (ferror(s_ptr->to_fp)){
    asprintf(&error_message, 
      "%s: Error writing data to child where Z = %f",
        prog_name, s_ptr->z);
    perror(error_message);
    exit(-1);
  }
  fclose(s_ptr->to_fp);
  debug_print("In parent: Closed FD: %d\n", to_fd[0]);
  debug_print("In parent: Done writing to child where Z = %f\n", s_ptr->z);
}

int main(int argc, char *argv[]){
  int i, j, ii;
  char *v, *k, *f, *o;
  char *buffer;
  prog_name = argv[0];
  FILE *i_fp;
  FILE *o_fp;
  float x,y,z;
  int scanning;
  int len = 0;
  int slice_num;
  int bits_to_generate;
  contour_buff_ptr  c_b_ptr, *contour_buff_ptr_ptr;
  contour_entry_ptr c_e_ptr, *contour_entry_ptr_ptr;
  contour_ptr c_ptr, contour_being_read, *contour_ptr_ptr;
  contour_ptr nearest, lower, higher;
  slice_ptr s_ptr, *slices_ptr_ptr;
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
    } else if (strcmp(k, "rows") == 0){
      rows = atoi(v);
    } else if (strcmp(k, "cols") == 0){
      cols = atoi(v);
    } else if (strcmp(k, "slices") == 0){
      num_slices = atoi(v);
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
    } else if (strcmp(k, "slicespc") == 0){
      slicespc = atof(v);
    } else if (strcmp(k, "debug") == 0){
      debug = atoi(v);
    } else {
      fprintf(stderr, "%s: unknown param: %s\n", prog_name, k);
      exit(-1);
    }
  }

  debug_print("%s parsing of params is complete\n", prog_name); 
  debug_print("%s %s = %d\n", prog_name, "out", out_fh); 
  debug_print("%s %s = %d\n", prog_name, "status", status_fh); 
  debug_print("%s %s = %d\n", prog_name, "rows", rows); 
  debug_print("%s %s = %d\n", prog_name, "cols", cols); 
  debug_print("%s %s = %d\n", prog_name, "slices", num_slices); 
  debug_print("%s %s = %f\n", prog_name, "ulx", ulx); 
  debug_print("%s %s = %f\n", prog_name, "uly", uly); 
  debug_print("%s %s = %f\n", prog_name, "ulz", ulz); 
  debug_print("%s %s = %f\n", prog_name, "rowspc", rowspc); 
  debug_print("%s %s = %f\n", prog_name, "colspc", colspc); 
  debug_print("%s %s = %f\n", prog_name, "slicespc", slicespc); 
  debug_print("%s %s = %d\n", prog_name, "debug", debug); 

  i_fp = fdopen(in_fh, "r");
  if(i_fp == NULL){
    asprintf(&error_message, 
      "%s: can't fdopen in_fh (%d)", prog_name, in_fh);
    perror(error_message);
    exit(-1);
  }
  o_fp = fdopen(out_fh, "w");
  if(o_fp == NULL){
    asprintf(&error_message, 
      "%s: can't fdopen out_fh (%d)", prog_name, out_fh);
    perror(error_message);
    exit(-1);
  }

  buffer = calloc(1, BUFFER_SIZE); 
  /* contour_file = fdopen(input_fh, "r"); */
  if (buffer == NULL){
    asprintf(&error_message, 
      "%s: can't alloc buffer (size %d)", prog_name, BUFFER_SIZE);
    perror(error_message);
    exit(-1);
  }
  /* Loop to read in all contours and save data per Z */
  scanning = 1; /* scanning for a contour */
  debug_print("Main: Starting scanning input.\n");
  while ((v = fgets(buffer, BUFFER_SIZE-1, i_fp)) != NULL) {
    /* debug_print("Main: Read data >>>> %s\n", v); */
    v[BUFFER_SIZE-1] = 0;
/* debug_print("Read in: %s\n", v); */
    if (scanning){
      if(strncmp(v, "BEGIN CONTOUR at", 16) != 0) continue;
      /***** BEGIN CONTOUR *****/
      scanning = 0; /* in countour */
      /* 
      debug_print("Main: Read: Dumping tree...%08x\n", contours);
      for (c_ptr = contours; 
           c_ptr != NULL; 
           c_ptr = (contour_ptr) c_ptr->next) {
        debug_print("Main: Read: tree entry: Z: %f\n", c_ptr->z);
      }
      debug_print("Main: Read: Done dumping tree...%08x\n", contours);
      */
      k = v + 16;
      z = atof(k);
      debug_print("Main: Read: BEGIN CONTOUR, Z: %f\n", z);
      c_ptr = contours;
      contour_ptr_ptr = &contours;
      while (c_ptr != NULL) {
        /* debug_print("Main: Read: cmp to Z: %f\n", c_ptr->z); */
        if (c_ptr->z >= z) break;
        contour_ptr_ptr = (contour_ptr *) &c_ptr->next;
        c_ptr = (contour_ptr) c_ptr->next;
      }
      if (c_ptr != NULL  &&  c_ptr->z == z) {
 debug_print("Main: Read: Adding contour entry to existing contour\n"); 
        contour_being_read = c_ptr;
        for (c_e_ptr = contour_being_read->contour_entries;
             c_e_ptr != NULL;
             c_e_ptr = c_e_ptr->next) 
        {
          contour_entry_ptr_ptr = (contour_entry_ptr *) &(c_e_ptr->next);
        }
      } else {
 debug_print("Main: Read: Adding new contour entry\n"); 
        if ((contour_being_read = calloc(1,sizeof(contour))) == NULL){
          asprintf(&error_message, 
            "%s: can't calloc contour structure (%d)", 
              prog_name, (int) sizeof(contour));
          perror(error_message);
          exit(-1);
        }
        contour_being_read->z = z;
        *contour_ptr_ptr = contour_being_read;
        contour_being_read->next = c_ptr;
        contour_entry_ptr_ptr = &(contour_being_read->contour_entries);
      }
      if ((c_e_ptr = calloc(1,sizeof(contour_entry))) == NULL){
        asprintf(&error_message, 
          "%s: can't calloc contour_entry structure (%d)", 
            prog_name, (int) sizeof(contour_entry));
        perror(error_message);
        exit(-1);
      }
      *contour_entry_ptr_ptr = c_e_ptr;
      contour_entry_ptr_ptr = (contour_entry_ptr *) &c_e_ptr->next;
      contour_buff_ptr_ptr = (contour_buff_ptr *) &c_e_ptr->buff;
      debug_print("Main: Read: Done inserting in tree...\n");
      continue;
    }
    if(strncmp(v, "END CONTOUR", 11) == 0){
      /***** END CONTOUR *****/
      /*  We no longer close the contour in this routine.               */
      /*    the child that receives this data closes the contour,       */
      /*    and we do not process the points, just leave them as ascii  */
      /*    in the buffer...                                            */
      debug_print("Main: Read: END CONTOUR, Z: %f\n", 
        contour_being_read->z);
      scanning = 1;
      contour_ptr_ptr = NULL;
      contour_entry_ptr_ptr = NULL;
      contour_buff_ptr_ptr = NULL;
      continue;
    }
    /***** CONTOUR DATA *****/
    if ((c_b_ptr = calloc(1,sizeof(contour_buff))) == NULL){
      asprintf(&error_message, 
        "%s: can't calloc contour_entry structure (%d)", 
          prog_name, (int) sizeof(contour_entry));
      perror(error_message);
      exit(-1);
    }
    len = strlen(v);
    debug_print("Main: Read: Contoure data read, size: %d\n", len);
    if ((k = calloc(1,len+1)) == NULL){
      asprintf(&error_message, 
        "%s: can't calloc contour data buffer (%d)", prog_name, len);
      perror(error_message);
      exit(-1);
    }
    strcpy(k,v);
    c_b_ptr->data = k;
    *contour_buff_ptr_ptr = c_b_ptr;
    contour_buff_ptr_ptr = (contour_buff_ptr *) &c_b_ptr->next;
  }
  fclose(i_fp);
  debug_print("Main: Read: Done reading from input socket, Dumping tree...%08x\n", contours);
  for (c_ptr = contours; 
       c_ptr != NULL; 
       c_ptr = (contour_ptr) c_ptr->next) {
    debug_print("Main: Read: contour entry: Z: %f\n", c_ptr->z);
    if (c_ptr->contour_entries == NULL) {
      debug_print("Main: Read: contour contour_entries is NULL.\n");
      continue;
    }
    for (c_e_ptr = c_ptr->contour_entries; 
         c_e_ptr != NULL;
         c_e_ptr = c_e_ptr->next)
    {
      debug_print("Main: Read: Next contour_entry...\n");
      if (c_e_ptr->buff == NULL) {
        debug_print("Main: Read: contour_entry buff is NULL.\n");
        continue;
      }
      for (c_b_ptr = c_e_ptr->buff; 
           c_b_ptr != NULL;
           c_b_ptr = c_b_ptr->next)
      {
        if (c_b_ptr->data == NULL) {
          debug_print(
           "Main: Read: <<<< Error: Contor_buffer data ptr is NULL >>>>\n");
          continue;
        }
        debug_print("Main: Read: Next Contor_buffer: size: %d...\n",
          strlen(c_b_ptr->data));
      }
    }
  }
  debug_print("Main: Read: Done dumping tree...%08x\n", contours);

  debug_print("Main: Building Slice linked list.\n");
  /* Loop through all needed slice_num and make slices linked list */
  for (slice_num = 0; slice_num < num_slices; slice_num++) {
    if ((s_ptr = calloc(1,sizeof(slice))) == NULL){
      asprintf(&error_message, 
        "%s: can't calloc slice structure (%d)", 
          prog_name, (int) sizeof(slice));
      perror(error_message);
      exit(-1);
    }
    s_ptr->z = ulz + (slice_num * slicespc);
    if (slices == NULL) {
      slices = s_ptr;
      slices_ptr_ptr = (slice_ptr *) &s_ptr->next;
      /* debug_print("Main: Read: Inserted as head of tree...\n"); */
    } else {
      *slices_ptr_ptr = s_ptr;
      slices_ptr_ptr = (slice_ptr *) &s_ptr->next;
    }
    lower = contours;
    higher = NULL;
    nearest = NULL;
    /* walk the contours linked list and find the closest z value */
    for (c_ptr = contours; c_ptr != NULL; c_ptr = c_ptr->next) {
      lower = c_ptr;
      higher = c_ptr->next;
      if (higher == NULL  ||  (s_ptr->z <= higher->z)) break;
    }
    if (s_ptr->z < contours->z) {
      nearest = contours;
    } else if (c_ptr == NULL){
      nearest = lower;
    } else if (higher == NULL){
      nearest = lower;
    } else if ((higher->z - s_ptr->z ) > (s_ptr->z - lower->z)) {
      nearest = lower;
    } else {
      nearest = higher;
    }
    if (nearest->contour_entries) {
      s_ptr->contour = nearest;
      debug_print(
        "Main: Added slice_num # %d, Z: %f, using contour at Z:%f\n", 
        slice_num, s_ptr->z, nearest->z);
    } else {
      debug_print("Main: Added slice_num # %d, Z: %f as empty slice\n", 
        slice_num, s_ptr->z);
    }
  }
  debug_print("Main: Done building Slice linked list.\n");

  while (num_children < MAX_CHILDREN)
    { StartNextChild(slices); }

  /* Loop through all slices and output contour bit map */
  /*   If a slice_num has contours, send to child, read back in & send  */
  /*   If not, send empty contour data */
  debug_print("Main: Travirse Slices linked list & generate data.\n");
  for (s_ptr = slices; s_ptr; s_ptr = s_ptr->next) {
    if (s_ptr->contour == NULL) {
      /* generate empty slice_num */
      debug_print("Main: Need to generate empty slice.\n");
      bits_to_generate = rows * cols;
      while (bits_to_generate > 0) {
        if (bits_to_generate > 127) {
          fputc((int) 127, o_fp);
          bits_to_generate -= 127;
        } else {
          fputc((int) bits_to_generate, o_fp);
          bits_to_generate = 0;
        }
      }
    } else {
      /* read from slice contour data */
      while (num_children < MAX_CHILDREN)
        { StartNextChild(s_ptr); }
      if (s_ptr->pid == 0) {
        StartNextChild(s_ptr);
      }
      if (s_ptr->pid == 0) {
        asprintf(&error_message, 
          "%s: StartNextChild did not start nearest contour",
            prog_name);
        perror(error_message);
        exit(-1);
      }
      /* loop reading from nearest->i_fp and writing to o_ip */
      while ((fgets( buffer, BUFFER_SIZE, s_ptr->from_fp)) != NULL) {
        fputs( buffer, o_fp );
        debug_print("Main: wrote %d bytes for Z = %f\n", 
           strlen(buffer), s_ptr->z);
      }
      if (ferror(s_ptr->from_fp)){
        asprintf(&error_message, 
          "%s: Error reading data from child where Z = %f",
            prog_name, s_ptr->z);
        perror(error_message);
        exit(-1);
      }
      fclose(s_ptr->from_fp);
      if ((fgets( buffer, BUFFER_SIZE, s_ptr->status_fp )) == NULL) {
        asprintf(&error_message, 
          "%s: Error reading status from child where Z = %f",
            prog_name, s_ptr->z);
        perror(error_message);
        exit(-1);
      }
      if (strncmp(buffer, "OK\n", 3) != 0) {
        asprintf(&error_message, 
          "%s: Status from child where Z = %f was: '%s'",
            prog_name, s_ptr->z, buffer);
        perror(error_message);
        exit(-1);
      }
      fgets( buffer, BUFFER_SIZE, s_ptr->status_fp );
      fclose(s_ptr->status_fp);
      if (ferror(o_fp)){
        asprintf(&error_message, 
          "%s: Error writing out data where Z = %f",
            prog_name, s_ptr->z);
        perror(error_message);
        exit(-1);
      }
      debug_print("Main: Waiting for Child for Z = %f\n", s_ptr->z);
      waitpid(s_ptr->pid, NULL, 0);
      s_ptr->pid = 0;
      num_children--;
      debug_print("Main: Child done for Z = %f\n", s_ptr->z);
    }
  }

  fclose(o_fp);
  debug_print("Main: We are done...\n");
  /* inform parent we're done */
  /*
  write(status_fh, "OK\n", 4);
  close(status_fh);
  */
  i = asprintf(&v, "OK\n");
  write(status_fh, (void *) v, i);
  free(v);
  exit(0);
}

