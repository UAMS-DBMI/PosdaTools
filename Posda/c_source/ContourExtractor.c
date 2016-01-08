/*
#$Source: /home/bbennett/pass/archive/Posda/c_source/ContourExtractor.c,v $
#$Date: 2014/05/14 15:43:21 $
#$Revision: 1.7 $
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
#include <sys/types.h>
#include <sys/stat.h>
#include <sys/wait.h>
#include <sys/socket.h>
#include <fcntl.h>
#include <unistd.h>
#include <limits.h>

#define MAX_NUM_KIDS 4
#define MAX_NUM_SLICES_HANDLED 4096

typedef struct {
  void *next;
  int   count;
  int   polarity;
} bm_entry, *bm_entry_ptr, *bm;

typedef struct {
  int   slice;
  int   pid;
  int   status_fd;
  char *file;
} slice_info, *slice_info_ptr;

int debug = 0;

char *prog_name;
char *error_message;

int processed = 0;
int num_kids = 0;
int num_kids_started = 0;
int ignored_blank = 0;
int ignored_to_far = 0;
int completed = 0;
int queued = 0;
int errors = 0;

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

void AddBuffer(bm *bit_map_ptr, int polarity, int count) {
  while (*bit_map_ptr != NULL) {
    bit_map_ptr = (bm *) &((*bit_map_ptr)->next);
  }
  *bit_map_ptr = calloc(1,sizeof(bm_entry));
  (*bit_map_ptr)->polarity = polarity;
  (*bit_map_ptr)->count = count;
  return;
}

int BlankBufferCheck(bm bit_map) {
  bm *bit_map_ptr;
  int ones = 0;
  if (bit_map == NULL) { return 0; }
  bit_map_ptr = (bm * ) &(bit_map->next);
  ones = bit_map->polarity;
  while (*bit_map_ptr != NULL) {
    if ((*bit_map_ptr)->polarity) { ones++; }
    bit_map_ptr = (bm *) &((*bit_map_ptr)->next);
  }
  return ones;
}

static int current_count = 0;
static int current_polarity = 0;
static int total_bits_read = 0;

int ReadSlice(FILE *in_fp, int slice, int slice_size, bm *bit_map_ptr){

  int c;
  int cur_size = 0;     /* amount read for this buffer */

  int count;
  int polarity;
  int remaining;

  debug_print("Start reading Slice %d.\n", slice); 
  while (1) {
    if (current_count + cur_size >= slice_size) {
      remaining = slice_size - cur_size;
      AddBuffer(bit_map_ptr, current_polarity, remaining);
      current_count -= remaining;
      return 0;
    }
    if ((c = getc(in_fp)) == EOF){
      debug_print("EOF on input stream.\n");
      return 1;
    } 
    count = c & 0x7f;
    total_bits_read += count;
    if (count == 0) {
      debug_print("bitmap count zero.\n"); 
      continue;
    }
    polarity = (c & 0x80) ? 0x01 : 0x00;
    if (current_count > 0) {
      if (polarity != current_polarity) {
        AddBuffer(bit_map_ptr, current_polarity, current_count);
        cur_size += current_count;
        current_count = count;
        current_polarity = polarity;
      } else {
        current_count += count;
      }
    } else {
      current_count = count;
      current_polarity = polarity;
    }
  }
  exit(-1);
}

void SendBitMapData(FILE *fp, int polarity, int count){
  /* debug_print("Sending data to child: polarity: %d, count: %d.\n",
    polarity, count);  */
  int hi_bit = 0;
  if (polarity) { hi_bit = 0x80; }
  while (count > 0) {
    if (count > 0x7f) {
      fputc((int) (0x7f | hi_bit), fp);
      count -= 0x7f;
    } else {
      fputc((int) (count | hi_bit), fp);
      count = 0;
    }
  }
}
void EmptyBitMap(bm *bit_map){
  bm *bit_map_ptr;
  bm *bit_map_ptr_next;
  if (bit_map == NULL) { return; }
  bit_map_ptr = (bm *) *bit_map;
  *bit_map = NULL;
  while (*bit_map_ptr != NULL) {
    bit_map_ptr_next = (bm *) &((*bit_map_ptr)->next);
    free(*bit_map_ptr);
    bit_map_ptr = bit_map_ptr_next;
  }
}

void StartKid(slice_info_ptr slice, bm *bit_map, 
         char *x, char *y, int rows, int cols, 
         char *interval, char *base_file){
  int to_fd[2] = {0,0}, status_fd[2] = {0,0};
  int rc;
  char arg[11][64];
  char *args[12];
  int contour_fh;
  int i;

  debug_print("Start Kid for Slice %d.\n", slice->slice);
  if (asprintf(&(slice->file),"%s_%d", base_file, slice->slice) <= 0){
    i = asprintf(&error_message, "%s: Couldn't create file name, slice: %d",
    prog_name, slice->slice);
    perror(error_message);
    free(error_message);
    exit(-1);
  }
  contour_fh = open(slice->file, O_WRONLY | O_CREAT, 0664);
  if (contour_fh < 0){
    i = asprintf(&error_message, "%s: Couldn't open contour file %s",
    prog_name, slice->file);
    perror(error_message);
    free(error_message);
    exit(-1);
  }

  /* open 2 socket pairs: to child & child status. */
  rc = MakeSocketPair(to_fd);
  if ( rc < 0 ) {
    asprintf(&error_message, 
      "%s: Error %d making to child socketpair", prog_name, rc);
    perror(error_message);
    exit(rc);
  } 
  debug_print("StartNextChild: to_fd: %d(w), %d(r)\n", to_fd[0], to_fd[1]);
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

  debug_print("StartNextChild: Ready to fork... Slice %d.\n", slice->slice);
  slice->pid = fork();
  if (slice->pid < 0) {
    asprintf(&error_message, 
      "%s: Fork failed: %d", prog_name, slice->pid);
    perror(error_message);
    exit(-1);
  }
  if (slice->pid == 0) { 
    /* We are in child now...  */
    /*
    close (to_fd[0]);
    close (from_fd[1]);
    close (status_fd[1]);
    debug_print("In Child: Closed FDs: %d, %d, %d\n", 
      to_fd[0],from_fd[1],status_fd[1]);
    */
    set_cloexec_flag(to_fd[0],1);
    set_cloexec_flag(status_fd[1],1);
    set_cloexec_flag(to_fd[1],0);
    set_cloexec_flag(contour_fh,0);
    set_cloexec_flag(status_fd[0],0);

    // strcpy (arg[ 0],"CompressedPixBitMapToContour.pl");
    strcpy (arg[ 0],"CompressedPixBitMapToContour");
    sprintf(arg[ 1], "in=%d",           to_fd[1]);
    sprintf(arg[ 2], "out=%d",          contour_fh);
    sprintf(arg[ 3], "status=%d",       status_fd[0]);
    sprintf(arg[ 4], "x=%s",            x);
    sprintf(arg[ 5], "y=%s",            y);
    sprintf(arg[ 6], "x_spc=%s",        interval);
    sprintf(arg[ 7], "y_spc=%s",        interval);
    sprintf(arg[ 8], "rows=%d",         rows);
    sprintf(arg[ 9], "cols=%d",         cols);
    sprintf(arg[10], "slice_index=%d",  slice->slice);

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

    // rc = execvp("CompressedPixBitMapToContour.pl", args);
    rc = execvp("CompressedPixBitMapToContour", args);
    if (rc < 0) {
      asprintf(&error_message, 
        "%s: execl failed: %d", prog_name, rc);
      perror(error_message);
      exit(-1);
    }
    debug_print("In Child: execvp OK: %s (Slice: %d)\n", arg[ 0], 
      slice->slice);
    exit(0);
  }
  /* We are in Parent now...  */
  num_kids++;
  num_kids_started++;
  slice->status_fd = status_fd[1];
  close (to_fd[1]);
  close (status_fd[0]);
  close (contour_fh);
  debug_print("In parent: Closed FDs: %d, %d, %d\n", 
    to_fd[1],contour_fh,status_fd[0]);

  /* need to write compressed bit map to to_fd[0] 
     then wait on reading from status_fd[1] */
  int count = 0;
  int sent = 0;
  int polarity;
  FILE *fp;
  fp = fdopen(to_fd[0], "w");
  if (fp == NULL){
    asprintf(&error_message, 
      "%s: Error on fdopen of socket to child for slice: %d", 
      prog_name, slice->slice);
    perror(error_message);
    exit(-1);
  }
  debug_print("Sending data to child: Slice: %d\n", slice->slice);
  bm *bit_map_ptr;
  if (bit_map == NULL) { return; }
  bit_map_ptr = bit_map;
  while (*bit_map_ptr != NULL) {
    if (count  && polarity != (*bit_map_ptr)->polarity) {
      SendBitMapData(fp, polarity, count);
      sent += count;
      count = (*bit_map_ptr)->count;
      polarity = (*bit_map_ptr)->polarity;
    } else {
      count += (*bit_map_ptr)->count;
      polarity = (*bit_map_ptr)->polarity;
    }
    bit_map_ptr = (bm *) &((*bit_map_ptr)->next);
  }
  if (count > 0) {
    SendBitMapData(fp, polarity, count);
    sent += count;
  }
  fclose(fp);
  if (sent != (rows * cols)) {
    asprintf(&error_message, 
      "%s: Error on slice: %d, sent %d bits, rows: %d, cols: %d", 
      prog_name, slice->slice, sent, rows, cols);
    perror(error_message);
    exit(-1);
  }
}

void CheckKids(int status_fh, slice_info_ptr slices, int slices_max){
  int i,j;
  char *v;
  struct timeval selTimeout;
  int num_ready;
  int max_fd = 0;
  char buffer[16];

  debug_print("CheckKids called.\n");
  selTimeout.tv_sec = 2;       /* timeout (secs.) */
  selTimeout.tv_usec = 0;            /* 0 microseconds */
  fd_set readSet;
  FD_ZERO(&readSet);
  for (i = 0; i < slices_max; i++) {
    if (slices[i].pid == 0) { continue; }
    debug_print("checking fd: %d.\n", slices[i].status_fd);
    FD_SET(slices[i].status_fd, &readSet);
    if (slices[i].status_fd > max_fd) { max_fd = slices[i].status_fd; }
  }
  num_ready = select((max_fd + 1), &readSet, NULL, NULL, &selTimeout);
  debug_print("Num Ready: %d.\n", num_ready);
  if (num_ready < 0) {
    asprintf(&error_message, "%s: Error from select call: %d.\n",
      prog_name, num_ready);
    perror(error_message);
    exit(-1);
  }
  if (num_ready > 0){
    for (i = 0; i < slices_max; i++) {
      if (slices[i].pid == 0) { continue; }
      if (FD_ISSET(slices[i].status_fd,  &readSet)) {
        /*  slice i has written a response */
        debug_print("Socket has data: %d, Slice: %d.\n",
          slices[i].status_fd, slices[i].slice);
        buffer[0] = 0;
        if (read(slices[i].status_fd, buffer, 3) != 3  ||
            strncmp(buffer,"OK\n",3) != 0){
          asprintf(&error_message, 
"%s: Error, Invalid response: '%s' from child processing slice: %d.\n",
            prog_name, buffer, slices[i].slice);
          perror(error_message);
          errors++;
        } else {
          j = asprintf(&v, "ExtractContourFile: %d \"%s\"\n",
                slices[i].slice, slices[i].file);
          write(status_fh, (void *) v, j);
          debug_print("wrote contour file done: %s\n", v); 
          free(v);
          completed++;
        }
        waitpid(slices[i].pid, NULL, 0);
        slices[i].pid = 0;
        slices[i].status_fd = 0;
        num_kids--;
      }
    }
  }

}

void SendStatus(int status_fh){
  char *v;
  int i;
  i = asprintf(&v, "Status: %d %d %d %d %d %d %d\n",
    processed, 
    num_kids,
    ignored_blank,
    ignored_to_far,
    completed,
    queued,
    errors);
  write(status_fh, (void *) v, i);
  debug_print("wrote status: %s\n", v); 
  free(v);
}

int main(int argc, char *argv[]){
  int c;
  int i, j;
  int iv;
  /* from copied code /\ */

  int rows = 0;
  int cols = 0;
  int slice_size = 0;
  char *x = NULL;
  char *y = NULL;
  char *interval = NULL;
  char *base_file = NULL;
  int in_fh = 0;
  int status_fh = 0;
  FILE *in_fp;
  int slice = 0;
  bm  bit_map = NULL;
  slice_info slices[MAX_NUM_SLICES_HANDLED];
  int slices_max;
  int slice_index;

  /* from copied code \/ */
  char *k;
  char *v, *v2;
  char *error_message;

  prog_name = argv[0];

  /* Here we parse the command line parameters */
  for (i = 1; i < argc; i++){
    k = strtok(argv[i], "=");
    v = strtok(NULL, "\n");
    if (strcmp(k, "debug") == 0){
      debug = atoi(v);
    } else if (strcmp(k, "x") == 0){
      x = v;
    } else if (strcmp(k, "y") == 0){
      y = v;
    } else if (strcmp(k, "rows") == 0){
      rows = atoi(v);
    } else if (strcmp(k, "cols") == 0){
      cols = atoi(v);
    } else if (strcmp(k, "interval") == 0){
      interval = v;
    } else if (strcmp(k, "base_file") == 0){
      base_file = v;
    } else if (strcmp(k, "in") == 0){
      in_fh = atoi(v);
    } else if (strcmp(k, "status") == 0){
      status_fh = atoi(v);
    } else if (strcmp(k, "slices_needed") == 0){
      slices_max = 0;
      debug_print("Slices needed: %s.\n",v);
      v2 = strtok(v,",");
      slices[slices_max].slice = atoi(v2);
      slices[slices_max].pid = 0;
      slices_max++;
      while ((v2 = strtok(NULL,",")) != NULL) {
        slices[slices_max].slice = atoi(v2);
        slices[slices_max].pid = 0;
        slices_max++;
        if (slices_max >= MAX_NUM_SLICES_HANDLED) {
          asprintf(&error_message,
"%s: Error, more than %d slices to process, up MAX_NUM_SLICES_HANDLED in %s.c", 
            prog_name, MAX_NUM_SLICES_HANDLED, prog_name);
          perror(error_message);
          exit(-1);
        }
      }
      debug_print("Slices needed #: %d.\n",slices_max);
      for (j = 0; j < slices_max; j++) {
        debug_print("Slice needed: %d.\n",slices[j].slice);
      }
    } else {
      fprintf(stderr, "%s: unexpected arg: %s = %s.\n", prog_name, k, v);
    }
  }

  debug_print("parsing of params is complete\n"); 
  debug_print("%s = %d\n\n", "debug", debug); 
  slice_size = rows * cols;
  debug_print("slice_size: %d\n", slice_size); 
  debug_print("slices_max: %d\n", slices_max); 

  if (x == NULL || y == NULL  ||
      slice_size == 0 ||
      interval == NULL  ||
      base_file == NULL) {
    asprintf(&error_message,
      "%s: Invalid arguments", prog_name);
    perror(error_message);
    exit(-1);
  }

  in_fp = fdopen(in_fh, "r");
  if (in_fp == NULL){
    asprintf(&error_message,
      "%s: can't fdopen in_fh (%d)", prog_name, in_fh);
    perror(error_message);
    free(error_message);
    exit(-1);
  }

  debug_print("Start main loop.\n"); 
  while ((completed + errors + ignored_blank) < slices_max) {
    if ((num_kids_started + ignored_blank) < slices_max  &&  
         num_kids < MAX_NUM_KIDS) {
      if (ReadSlice(in_fp, slice, slice_size, &bit_map) != 0){
        debug_print("Total # bits read: %d, slice size: %d.\n",
          total_bits_read, slice_size);
        asprintf(&error_message,
          "%s: Could not read all contour bitmaps needed", prog_name);
        perror(error_message);
        free(error_message);
        exit(-1);
      }
      processed++;
      debug_print(
        "Total # bits read: %d, slice size: %d, # processed: %d.\n",
        total_bits_read, slice_size, processed);
      for (i = 0; i < slices_max; i++) {
        if (slices[i].slice == slice) { break; }
      }
      if (i >= slices_max) {
        EmptyBitMap(&bit_map);
        ignored_to_far++;
        debug_print("Unneeded slice: %d (total %d).\n", 
          slice, ignored_to_far);
        slice++;
        continue;
      }
      slice_index = i;
      if (BlankBufferCheck(bit_map) <= 0) {
        EmptyBitMap(&bit_map);
        ignored_blank++;
        debug_print("Blank slice: %d (total %d).\n", slice, ignored_blank);
        slice++;
        continue;
      }
      StartKid(&(slices[slice_index]), &bit_map, 
               x, y, rows, cols, interval, base_file);
      EmptyBitMap(&bit_map);
      slice++;
    } else {
      CheckKids(status_fh, slices, slices_max);
    }
    SendStatus(status_fh);
  }

  debug_print("Done, processed all slices: %d.\n", slices_max); 
  write(status_fh, "OK\n", 4);
  close(status_fh);
  exit(0);
}
