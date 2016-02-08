/*
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

typedef struct {
  void *next;
  uint  count;
  uint  polarity;
} bm_entry, *bm_entry_ptr, *bm;

typedef struct {
  int   slice;
  int   pid;
  int   status_fd;
} slice_info, *slice_info_ptr;

typedef struct point{
  float x;
  float y;
} point;

typedef struct line{
  point from;
  point to;
} line;

typedef struct line_list{
  void *next;
  line line;
} line_list;

typedef struct points{
  void *next;
  point point;
} points;

typedef struct contours{
  void   *next;
  points *first;
  points *last;
  uint   count;
} contours;

int debug = 1;

char *prog_name;
char *error_message;

/* Define debug_print to be no op for production */
#define debug_print(args...)
#define debug_print_nh(args...)
/*
debug_print(const char* format, ...){
  va_list argptr;
  va_start(argptr, format);
  if (! debug) return;
  fprintf(stderr, "%s: ", prog_name);
  vfprintf(stderr, format, argptr);
  va_end(argptr);
}
debug_print_nh(const char* format, ...){
  va_list argptr;
  va_start(argptr, format);
  if (! debug) return;
  vfprintf(stderr, format, argptr);
  va_end(argptr);
}
*/
void log_print(const char* format, ...){
  va_list argptr;
  va_start(argptr, format);
  if (! debug) return;
  fprintf(stderr, "%s: ", prog_name);
  vfprintf(stderr, format, argptr);
  va_end(argptr);
}

uint get_bit(void *ptr, uint count){
  char *b;
  b = (char *) ptr;
  return  (uint) (b[count] ? 1 : 0);
}


void set_bits(void *ptr, uint start_bit, uint bit_count){
  char *b;
  b = (char *) ptr;
  while(bit_count-- > 0) {
    b[start_bit++] = 1;
  }
}

float cross(point *a, point *b){
  return(a->x*b->y - a->y*b->x);
}

point *vsub(point *a, point *b){
  point *d;
  d = calloc(1, sizeof(point));
  d->x = a->x - b->x;
  d->y = a->y - b->y;
  return d;
}

int collinear(point *a, point *b, point *c){
  point *d1 = vsub(a, b);
  point *d2 = vsub(b, c);
  float d = cross(d1, d2);
  free(d1);
  free(d2);
  if(abs(d) < .00001){ return 1; }
  return 0;
}

points *make_point(point point){
  points *p;
  p = calloc(1, sizeof(points));
  if (p) {
    p->point.x = point.x;
    p->point.y = point.y;
    return p;
  }
  asprintf(&error_message,
    "%s: calloc of point entry failed  (size needed %d)", 
    prog_name, (int) sizeof(points));
  perror(error_message);
  free(error_message);
  exit(-1);
  return NULL;
}

void dump_contours(contours **contours_root){
  points *p;
  contours *c;
  uint count;
  c = *contours_root;
  if (c == NULL) {
    debug_print("contour list empty...\n");
  }
  while (c) {
    if (c->first == NULL  || c->last  == NULL  || c->count == 0) {
      debug_print(
        "invalid contours entry: first: %p, last: %p, count: %d.\n",
        c->first, c->last, c->count);
      asprintf(&error_message,
        "%s: invalid contours entry: first: %p, last: %p, count: %d.\n",
        prog_name, c->first, c->last, c->count);
      perror(error_message);
      free(error_message);
      exit(-1);
    }
    debug_print("contour %p[%p]: count: %d, start: %p[%p] (%f,%f) ",
      c, c->next, c->count, c->first, c->first->next, 
      c->first->point.x, c->first->point.y);
    p = c->first->next;
    count = 2;
    while (p && p != c->last) {
      debug_print_nh("%d: %p[%p] (%f,%f) ", count, 
        p, p->next, p->point.x, p->point.y);
      count++;
      p = p->next;
    }
    if (p != c->last) {
      asprintf(&error_message,
        "\n%s: invalid contours entry, last in point list is not contours last: first: %p, last: %p, count: %d.\n",
        prog_name, c->first, c->last, c->count);
      perror(error_message);
      free(error_message);
      exit(-1);
    }
    if (count != c->count) {
      asprintf(&error_message,
        "\n%s: invalid contours entry, # points in list: %d does not match contours value: first: %p, last: %p, count: %d.\n",
        prog_name, count, c->first, c->last, c->count);
      perror(error_message);
      free(error_message);
      exit(-1);
    }
    debug_print_nh("Last: %p[%p] (%f,%f)\n", 
      p, p->next, p->point.x, p->point.y);
    c = (contours *) c->next;
  }
  // for my $c (@$contours){
  //   my $tot_pts = @$c;
  //   print "contour:\n";
  //   print "\tstart: ($c->[0]->[0], $c->[0]->[1])\n";
  //   if(@$c > 2){
  //     for my $i (1 .. $#{$c} - 1){
  //       print "\t$i: ($c->[$i]->[0], $c->[$i]->[1])\n";
  //     }
// #      my $num_pts = @$c - 2;
// #      print "\t... $num_pts pts\n";
  //   }
  //   print "\tend: ($c->[$#{$c}]->[0], $c->[$#{$c}]->[1])\n";
  // }
}

void log_contours(contours **contours_root){
  points *p;
  contours *c;
  uint count;
  c = *contours_root;
  if (c == NULL) {
    log_print("contour list empty...\n");
  }
  while (c) {
    if (c->first == NULL  || c->last  == NULL  || c->count == 0) {
      log_print(
        "invalid contours entry: first: %p, last: %p, count: %d.\n",
        c->first, c->last, c->count);
      asprintf(&error_message,
        "%s: invalid contours entry: first: %p, last: %p, count: %d.\n",
        prog_name, c->first, c->last, c->count);
      perror(error_message);
      free(error_message);
      exit(-1);
    }
    log_print("contour %p[%p]: count: %d, start: %p[%p] (%f,%f) ",
      c, c->next, c->count, c->first, c->first->next, 
      c->first->point.x, c->first->point.y);
    p = c->first->next;
    count = 2;
    while (p && p != c->last) {
      log_print("%d: %p[%p] (%f,%f) ", count, 
        p, p->next, p->point.x, p->point.y);
      count++;
      p = p->next;
    }
    if (p != c->last) {
      asprintf(&error_message,
        "\n%s: invalid contours entry, last in point list is not contours last: first: %p, last: %p, count: %d.\n",
        prog_name, c->first, c->last, c->count);
      perror(error_message);
      free(error_message);
      exit(-1);
    }
    if (count != c->count) {
      asprintf(&error_message,
        "\n%s: invalid contours entry, # points in list: %d does not match contours value: first: %p, last: %p, count: %d.\n",
        prog_name, count, c->first, c->last, c->count);
      perror(error_message);
      free(error_message);
      exit(-1);
    }
    log_print("Last: %p[%p] (%f,%f)\n", 
      p, p->next, p->point.x, p->point.y);
    c = (contours *) c->next;
  }
  // for my $c (@$contours){
  //   my $tot_pts = @$c;
  //   print "contour:\n";
  //   print "\tstart: ($c->[0]->[0], $c->[0]->[1])\n";
  //   if(@$c > 2){
  //     for my $i (1 .. $#{$c} - 1){
  //       print "\t$i: ($c->[$i]->[0], $c->[$i]->[1])\n";
  //     }
// #      my $num_pts = @$c - 2;
// #      print "\t... $num_pts pts\n";
  //   }
  //   print "\tend: ($c->[$#{$c}]->[0], $c->[$#{$c}]->[1])\n";
  // }
}

contours *make_contour(){
  contours *c;
  c = calloc(1, sizeof(contours));
  if (c) { return c; }
  asprintf(&error_message,
    "%s: calloc of contour entry failed (size needed %d)", 
    prog_name, (int) sizeof(contours));
  perror(error_message);
  free(error_message);
  exit(-1);
  return NULL;
}

void add_beginning(line seg, contours **contours_root){
  points *p;
  contours *c;
  debug_print("add_beginning: seg: (%f,%f) - (%f,%f).\n",
    seg.from.x, seg.from.y, seg.to.x, seg.to.y);
  c = *contours_root;
  while (c) {
    debug_print(
      "checking contour %p[%p]: count: %d, First: %p[%p] (%f,%f)\n",
      c, c->next, c->count, c->first, c->first->next, 
      c->first->point.x, c->first->point.y);
    if (c->first != NULL  &&
        c->first->point.x == seg.to.x  &&
        c->first->point.y == seg.to.y ) {
      p = make_point(seg.from);
      p->next = c->first;
      c->first = p;
      c->count++;
      return;
    }
    c = (contours *) c->next;
  }
  // for my $c (@$contours){
  //   if(
  //     $c->[0]->[0] == $seg->[1]->[0] &&
  //     $c->[0]->[1] == $seg->[1]->[1]
  //   ){
  //     unshift(@{$c}, $seg->[0]);
  //     return $contours;
  //   }
  dump_contours((contours **) *contours_root);
  asprintf(&error_message,
    "%s: add_beginning failed", prog_name);
  perror(error_message);
  free(error_message);
  exit(-1);
}

void add_end(line seg, contours **contours_root){
  points *p;
  contours *c;
  c = *contours_root;
  debug_print("add_end: seg: (%f,%f) - (%f,%f).\n",
    seg.from.x, seg.from.y, seg.to.x, seg.to.y);
  while (c) {
    debug_print(
      "checking contour %p[%p]: count: %d, Last: %p[%p] (%f,%f)\n",
      c, c->next, c->count, c->last, c->last->next, 
      c->last->point.x, c->last->point.y);
    if (c->last != NULL  &&
        c->last->point.x == seg.from.x  &&
        c->last->point.y == seg.from.y ) {
      p = make_point(seg.to);
      c->last->next = p;
      c->last = p;
      c->count++;
      return;
    }
    c = (contours *) c->next;
  }
  // for my $c (@$contours){
  //   if(
  //     $c->[$#{$c}]->[0] == $seg->[0]->[0] &&
  //     $c->[$#{$c}]->[1] == $seg->[0]->[1]
  //   ){
  //     push(@{$c}, $seg->[1]);
  //     return $contours;
  //   }
  // }
  dump_contours((contours **)*contours_root);
  asprintf(&error_message,
    "%s: add_end failed", prog_name);
  perror(error_message);
  free(error_message);
  exit(-1);
}

void close_or_connect(line seg, contours **contours_root){
  points *p;
  contours *c, *c_next, *temp;
  contours *re_cont = NULL;
  contours *aug_end = NULL;
  contours *aug_beg = NULL;

  debug_print("close_or_connect: seg: (%f,%f) - (%f,%f).\n",
    seg.from.x, seg.from.y, seg.to.x, seg.to.y);
  // my @re_cont;
  // my $aug_end;
  // my $aug_beg;
  // contour:
  c_next = *contours_root;
  while (1) { // while more contours...
    // Remove contour c from contours
    c = c_next;
    if (c == NULL) { break; }
    c_next = c->next;
    c->next = NULL;
  debug_print("checking contour %p[%p]: count: %d, start: %p[%p] (%f,%f)\n",
      c, c->next, c->count, c->first, c->first->next, 
      c->first->point.x, c->first->point.y);
    // check if line segment's end matches contoures beginning.
    if (c->first != NULL  &&
        c->first->point.x == seg.to.x  &&
        c->first->point.y == seg.to.y ) {
      debug_print("line segment's end matches contoures beginning.\n");
      // check if line segment's beginning matches contoures end.
      if (c->last != NULL  && 
          c->last->point.x == seg.from.x  &&
          c->last->point.y == seg.from.y ) {
        debug_print("Time to closing a contour.\n");
        // closing a contour: 
        //   add point to end to close, add to new contours re_cont.
          //       push(@$c, $seg->[1]);
          //       push(@re_cont, $c);
          //       next contour;
        // add segment.to point to end of this contour...
        p = make_point(seg.to);
        c->last->next = p;
        c->last = p;
        c->count++;
        // add contour list to re_cont 
        //   (Adding to front.. Perl was putting at end... shoud not matter)
        c->next = re_cont;
        re_cont = c;
        continue;
      } else {
        debug_print("Time to add contour to aug_end.\n");
        // adding to end of $c
        aug_end = c;
        continue;
      }
    // check if line segment's start matches contours end.
    } else if (c->last != NULL  && 
          c->last->point.x == seg.from.x  &&
          c->last->point.y == seg.from.y ) {
      debug_print("Time to add contour to aug_beg.\n");
      // adding to beginning of c
      aug_beg = c;
    } else {
      debug_print("Just put contour on new list.\n");
      //  c unaffected: just put c on re_cont...
      c->next = re_cont;
      re_cont = c;
      continue;
    }
  }
  if (aug_beg  &&  aug_end) {
    debug_print("connect list aug_beg & aug_end and add to new list.\n");
    debug_print("aug_beg: %p, aug_beg->last: %p, aug_beg->count: %d.\n",
      aug_beg, aug_beg->last, aug_beg->count);
    debug_print("aug_end: %p, aug_end->first: %p, aug_end->count: %d.\n",
      aug_end, aug_end->last, aug_end->count);

    // connect list aug_beg & aug_end and add to re_cont...
      // add aug_end to aub_beg
    aug_beg->last->next = aug_end->first;
    aug_beg->last = aug_end->last;
    aug_beg->count = aug_beg->count + aug_end->count;
      // add aub_beg to re_cont
    aug_beg->next = re_cont;
    re_cont = aug_beg;
      // del aug_end
    debug_print("free: aug_end: %p.\n",aug_end);
    // free(aug_end);
    aug_end = NULL;
      // reset root contours list..
    debug_print("aug_beg: %p, aug_beg->last: %p, aug_beg->count: %d.\n",
      aug_beg, aug_beg->last, aug_beg->count);
    debug_print("contours_root: %p.\n",contours_root);
    *contours_root = re_cont;
    debug_print("Returning *contours_root: %p.\n",re_cont);
    return;
  } else if (aug_end || aug_beg) {
    dump_contours((contours **) *contours_root);
    asprintf(&error_message,
      "%s: close or connect didn't", prog_name);
    perror(error_message);
    free(error_message);
    exit(-1);
  } else {
    debug_print("Just reset root contours list.\n");
    // just reset root contours list..
    *contours_root = re_cont;
    return;
  }
  // for my $c (@$contours){
  //   if(
  //     $c->[0]->[0] == $seg->[1]->[0] &&
  //     $c->[0]->[1] == $seg->[1]->[1]
  //   ){
  //     if(     
  //       $c->[$#{$c}]->[0] == $seg->[0]->[0] &&
  //       $c->[$#{$c}]->[1] == $seg->[0]->[1]
  //     ){ # closing a contour
  //       push(@$c, $seg->[1]);
  //       push(@re_cont, $c);
  //       next contour;
  //     } else { # adding to end of $c
  //       $aug_end = $c;
  //       next contour;
  //     }
  //   } else if  (
  //     $c->[$#{$c}]->[0] == $seg->[0]->[0] &&
  //     $c->[$#{$c}]->[1] == $seg->[0]->[1]
  //   ){ # adding to beginning of $c
  //     $aug_beg = $c;
  //     next contour;
  //   } else { # $c unaffected
  //     push(@re_cont, $c);
  //     next contour;
  //   }
  // }
  // if(defined($aug_end) && defined($aug_beg)){
  //   my @new_cont;
  //   for my $p (@$aug_beg) { push @new_cont, $p }
  //   for my $p (@$aug_end) { push @new_cont, $p }
  //   push(@re_cont, \@new_cont);
  //   return \@re_cont;
  // } else if  (defined($aug_end) || defined($aug_beg)){
  //   die "close or connect didn't";
  // } else {
  //   return \@re_cont;
  // }
}

void begin_new(line seg, contours **contours_root){
  points *f, *t;
  contours *c;
  debug_print("begin_new: seg: (%f,%f) - (%f,%f).\n",
    seg.from.x, seg.from.y, seg.to.x, seg.to.y);
  f = make_point(seg.from);
  t = make_point(seg.to);
  c = make_contour();
  f->next = t;
  c->first = f;
  c->last = t;
  c->count = 2;
  c->next = *contours_root;
  *contours_root = c;
  return;
  // push(@$contours, $seg);
  // return $contours;
}

void rm_to_point_from_contour(contours *c, points *f, points *t){
  if(f->next != t) {
    fprintf(stderr, "ERROR: non-adjacent points in rm_to_point_from_contour\n");
    return;
  }
  if(c->first == t){
    fprintf(stderr, 
      "ERROR: from is first points in rm_to_point_from_contour\n");
    return;
  } else if (c->last == t){
    c->last = f;
  } else {
    f->next = t->next;
  }
  c->count--;
  free(t);
}

void rm_first_point_from_contour(contours *c){
  if(c->count < 3){
    fprintf(stderr, "ERROR: non-adjacent points in rm_to_point_from_contour\n");
    return;
  }
  c->first = c->first->next;
  c->count--;
}

void cleanup_contours(contours *c){
  points *f;
  points *m;
  points *l;
  if(c == NULL) { return; }
  if(c->count <= 3) { return; }
  f = c->first;
  m = f->next;
  l = m->next;
  do {
    if(collinear(&(f->point), &(m->point), &(l->point))){
      rm_to_point_from_contour(c, f, m);
    } else {
      f = m;
    }
    m = l;
    l = l->next;
  } while (l != c->last);
  if(c->count <= 3) { return; }
  if(
    collinear(
      &(c->last->point),
      &(c->first->point),
      &(((points *) c->first->next)->point)
    )
  ){
    rm_first_point_from_contour(c);
  }
}
/*
cleanup_contours(contours *c){
  points *p1 = NULL, *p2 = NULL;
  debug_print("cleanup_contours...\n");
  while (c) {
    p1 = c->first;
    p2 = p1->next;
    while (p2){
      if (p1->point.x == p2->point.x  &&
          p1->point.y == p2->point.y) {
        p1->next = p2->next;
        free(p2);
        c->count--;
        debug_print("Removing redundent point: %f,%f.\n",
          p1->point.x, p1->point.y);
      } else {
        p1 = p2;
      }
      p2 = p1->next;
    }
    c = (contours *) c->next;
  }
}
*/

void write_contours(contours *c, FILE *out_fp, 
  float x_spc, float y_spc, float x, float y){
  points *p;
  float xi, yi;
  debug_print("write_contours...\n");
  while (c) {
    p = c->first;
    xi = (((p->point.x + 1.0) * x_spc) + x);
    yi = (((p->point.y ) * y_spc) + y);
    fprintf(out_fp,"BEGIN\n%f, %f\n", xi, yi);
    p = p->next;
    while (p) {
      xi = (((p->point.x + 1.0) * x_spc) + x);
      yi = (((p->point.y ) * y_spc) + y);
      fprintf(out_fp,"%f, %f\n", xi, yi);
      p = p->next;
    }
    fprintf(out_fp,"END\n");
    c = (contours *) c->next;
  }
}


int main(int argc, char *argv[]){
  int c;
  int i;
  /* from copied code /\ */

  float x = 0;
  float y = 0;
  float x_spc = 0;
  float y_spc = 0;
  int rows = 0;
  int cols = 0;
  int slice = 0;
  int slice_size = 0;
  int in_fh = 0;
  int out_fh = 0;
  int status_fh = 0;
  FILE *in_fp;
  FILE *out_fp;
  int slice_index;

  /* from copied code \/ */
  char *k;
  char *v, *v2;
  char *error_message;

  prog_name = argv[0];

  /* Here we parse the command line parameters */
  int arg_bit_map = 0;
  for (i = 1; i < argc; i++){
    k = strtok(argv[i], "=");
    v = strtok(NULL, "\n");
    if (strcmp(k, "debug") == 0){
      debug = atoi(v);
    } else if (strcmp(k, "in") == 0){
      arg_bit_map |= 0x0001;
      in_fh = atoi(v);
    } else if (strcmp(k, "out") == 0){
      arg_bit_map |= 0x0002;
      out_fh = atoi(v);
    } else if (strcmp(k, "x") == 0){
      arg_bit_map |= 0x0004;
      x = atof(v);
    } else if (strcmp(k, "y") == 0){
      arg_bit_map |= 0x0008;
      y = atof(v);
    } else if (strcmp(k, "x_spc") == 0){
      arg_bit_map |= 0x0010;
      x_spc = atof(v);
    } else if (strcmp(k, "y_spc") == 0){
      arg_bit_map |= 0x0020;
      y_spc = atof(v);
    } else if (strcmp(k, "status") == 0){
      arg_bit_map |= 0x0040;
      status_fh = atoi(v);
    } else if (strcmp(k, "rows") == 0){
      arg_bit_map |= 0x0080;
      rows = atoi(v);
    } else if (strcmp(k, "cols") == 0){
      arg_bit_map |= 0x0100;
      cols = atoi(v);
    } else if (strcmp(k, "slice_index") == 0){
      arg_bit_map |= 0x0200;
      slice = atoi(v);
    } else {
      fprintf(stderr, "%s: unexpected arg: %s = %s.\n", prog_name, k, v);
    }
  }

  debug_print("parsing of params is complete\n"); 
  debug_print("%s = %d\n\n", "debug", debug); 
  slice_size = rows * cols;
  debug_print("slice_size: %d\n", slice_size); 
  debug_print(" in = %d, out = %d, status = %d.\n", 
    in_fh, out_fh, status_fh);
  debug_print(" x = %f, y = %f, x_spc = %f, y_spc = %f.\n", 
    x, y, x_spc, y_spc);
  debug_print(" rows = %d, cols = %d, slice = %d.\n", 
    rows, cols, slice_index);

  if (arg_bit_map != 0x3ff) {
    asprintf(&error_message,
      "%s: Invalid arguments: missing args (0X%x)", prog_name, arg_bit_map);
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

  out_fp = fdopen(out_fh, "w");
  if (out_fp == NULL){
    asprintf(&error_message,
      "%s: can't fdopen out_fh (%d)", prog_name, out_fh);
    perror(error_message);
    free(error_message);
    exit(-1);
  }

  debug_print("Start main loop.\n"); 

/*
  ## read bitmap two rows at a time and construct contours using
  ## marching squares
  #######
*/
  int byte;
  uint cur_count = 0;
  uint cur_polarity;
  int constr_byte = 0;
  int partial_bits = 0;
  uint total_read = 0;
  uint bytes_in_row = 0;
  uint row, col;
  uint bits_in_next_row;
  uint bits_to_use;
  char *first_row = NULL;
  char *next_row = NULL;
  char *temp_ptr = NULL;
  contours *Contours = NULL;

  // bytes_in_row = (int) ((cols + 7) / 8);
  first_row = calloc(1, (cols + 2));
  next_row = calloc(1, (cols + 2));
  if (first_row == NULL  ||  next_row == NULL){
    asprintf(&error_message,
      "%s: Could not calloc bitmap buffer (2 X size: %d)", prog_name, 
      (cols + 2) );
    perror(error_message);
    free(error_message);
    exit(-1);
  }

  for (row = 0; row <= (rows + 1); row++) {
    debug_print("Processing row: %d (of %d).\n", row, rows);
    memset(next_row, 0, (bytes_in_row + 2));
    if (row < rows){
      bits_in_next_row = 0;
      while(bits_in_next_row < cols) {
        if (cur_count <= 0){
          if ((byte = getc(in_fp)) == EOF) {
            asprintf(&error_message, 
              "%s: premature end of file\n", prog_name);
            perror(error_message);
            free(error_message);
            asprintf(&error_message, 
            "\t: row: %d, rows: %d, cols: %d, after: %d, slice_index: %d.\n",
              i, rows, cols, total_read, slice_index);
            perror(error_message);
            free(error_message);
            exit(-1);
          }
          total_read++;
          cur_polarity = (byte & 0x80) >> 7;
          cur_count = (byte & 0x7f);
          debug_print("Read bit map byte: count: %d, polarity: %d.\n",
            cur_count, cur_polarity);
        }
        if (cur_count == 0) { continue; }
        if (bits_in_next_row + cur_count > cols) { // > or >= ???
          bits_to_use = cols - bits_in_next_row;
        } else {
          bits_to_use = cur_count;
        }
        if (cur_polarity) 
          { set_bits(next_row, (bits_in_next_row + 1), bits_to_use); }
        cur_count -= bits_to_use;
        bits_in_next_row += bits_to_use;
      }
      //  next_row = "\0" . $buff . "\0";
    }
    debug_print("Done reading row: %d (of %d).\n", row, rows);
    int l_b_x, r_b_x, f_r_i, l_r_i, f_c_i, l_c_i;
    uint ul, ur, ll, lr;
    int a, b;
    point t, f;
    line s, s1;
    uint cur_case;
    for (col = 0; col <= (cols + 1); col++) {
      l_b_x = col;
      r_b_x = 1 + col;
      ul = get_bit(first_row, l_b_x);
      ur = get_bit(first_row, r_b_x);
      ll = get_bit(next_row, l_b_x);
      lr = get_bit(next_row, r_b_x);
      f_r_i = row - 1;
      l_r_i = row;
      f_c_i = col - 2;
      l_c_i = col - 1;
      // cur_case = (ul * 8) + (ur * 4) +(ll * 2) + lr;
      cur_case = (ul << 3) | (ur << 2) | (ll << 1) | lr;
      debug_print(
        "Processing col: %d (of %d) for row: %d (of %d): case: %d.\n", 
        col, cols, row, rows, cur_case);
      debug_print(
     "\tl_b_x: %d, r_b_x: %d, f_r_i: %d, l_r_i: %d, f_c_i: %d, l_c_i: %d\n",
        l_b_x, r_b_x, f_r_i, l_r_i, f_c_i, l_c_i);

      debug_print(
        "\tul: 0x%x, ur: 0x%x, ll: 0x%x, lr: 0x%x\n",
        ul, ur, ll, lr);

      // dump_contours(&Contours);
      //# [l_c_i, (f_r_i + l_r_i)* 0.5];   # right
      //# [(f_c_i +l_c_i) * 0.5, l_r_i];  # bottom
      //# [(f_c_i +l_c_i) * 0.5, f_r_i];  # top
      //# [f_c_i, (f_r_i + l_r_i)* 0.5];   # left
      switch(cur_case) {
        case 0:
          break;
          //# 0 0
          //#
          //# 0 0
          //# nothing here
        case 1:
          //# 0 0
          //#   f
          //# 0t1
          //# one seg: f -> t (begins new)
          // f = [l_c_i, (f_r_i + l_r_i)* 0.5];   //# right
          s.from.x = l_c_i; s.from.y = (f_r_i + l_r_i) * 0.5;
          // t = [(f_c_i +l_c_i) * 0.5, l_r_i];  //# bottom
          s.to.x = (f_c_i +l_c_i) * 0.5; s.to.y = l_r_i;
          //s = [f, t];
          begin_new(s, &Contours);
          break;
        case 2:
          //# 0 0
          //# t
          //# 1f0
          //# one seg: f -> t (adds at beginning)
          // t = [f_c_i, (f_r_i + l_r_i)* 0.5];   //# left
          s.to.x = f_c_i; s.to.y = (f_r_i + l_r_i) * 0.5;
          // f = [(f_c_i +l_c_i) * 0.5, l_r_i];  //# bottom
          s.from.x = (f_c_i +l_c_i) * 0.5; s.from.y = l_r_i;
          add_beginning(s, &Contours);
          break;
        case 3:
          //# 0 0
          //# t f
          //# 1 1
          //# one seg: f -> t (adds at begining)
          // t = [f_c_i, (f_r_i + l_r_i)* 0.5];   //# left
          s.to.x = f_c_i; s.to.y = (f_r_i + l_r_i) * 0.5;
          // f = [l_c_i, (f_r_i + l_r_i)* 0.5];   //# right
          s.from.x = l_c_i; s.from.y = (f_r_i + l_r_i) * 0.5;
          add_beginning(s, &Contours);
          break;
        case 4:
          //# 0f1
          //#   t
          //# 0 0
          //# one seg: f -> t (adds at end)
          // f = [(f_c_i +l_c_i) * 0.5, f_r_i];  //# top
          s.from.x = (f_c_i +l_c_i) * 0.5; s.from.y = f_r_i;
          // t = [l_c_i, (f_r_i + l_r_i)* 0.5];   //# right
          s.to.x = l_c_i; s.to.y = (f_r_i + l_r_i) * 0.5;
          add_end(s, &Contours);
          break;
        case 5:
          //# 0f1
          //# 
          //# 0t1
          //# one seg: f -> t (adds at end)
          // f = [(f_c_i +l_c_i) * 0.5, f_r_i];  //# top
          s.from.x = (f_c_i +l_c_i) * 0.5; s.from.y = f_r_i;
          // t = [(f_c_i +l_c_i) * 0.5, l_r_i];  //# bottom
          s.to.x = (f_c_i +l_c_i) * 0.5; s.to.y = l_r_i;
          add_end(s, &Contours);
          break;
        case 6:
          //# 0f1
          //# t b
          //# 1a0
          //# two segs:
          //#   f->t (adds at end and beginning)
          //#        (close or connect)
          //#   a->b (begins new)
          // f = [(f_c_i +l_c_i) * 0.5, f_r_i];  //# top
          s.from.x = (f_c_i +l_c_i) * 0.5; s.from.y = f_r_i;
          // b = [l_c_i, (f_r_i + l_r_i)* 0.5];   //# right
          s1.to.x = l_c_i; s1.to.y = (f_r_i + l_r_i) * 0.5;
          // a = [(f_c_i +l_c_i) * 0.5, l_r_i];  //# bottom
          s1.from.x = (f_c_i +l_c_i) * 0.5; s1.from.y = l_r_i;
          // t = [f_c_i, (f_r_i + l_r_i)* 0.5];   //# left
          s.to.x = f_c_i; s.to.y = (f_r_i + l_r_i) * 0.5;
          // s = [f, t];
          close_or_connect(s, &Contours);
          // s1 = [a, b];
          begin_new(s1, &Contours);
          break;
        case 7:
          //# 0f1
          //# t
          //# 1 1
          //# one seg: f -> t (adds at end and beginning)
          //#        (close or connect)
          // f = [(f_c_i +l_c_i) * 0.5, f_r_i];  //# top
          s.from.x = (f_c_i +l_c_i) * 0.5; s.from.y = f_r_i;
          // t = [f_c_i, (f_r_i + l_r_i)* 0.5];   //# left
          s.to.x = f_c_i; s.to.y = (f_r_i + l_r_i) * 0.5;
          close_or_connect(s, &Contours);
          break;
        case 8:
          //# 1t0
          //# f
          //# 0 0
          //# one seg: f -> t (adds at beginning and end)
          //#                 (close or connect)
          // t = [(f_c_i +l_c_i) * 0.5, f_r_i];  //# top
          s.to.x = (f_c_i +l_c_i) * 0.5; s.to.y = f_r_i;
          // f = [f_c_i, (f_r_i + l_r_i)* 0.5];   //# left
          s.from.x = f_c_i; s.from.y = (f_r_i + l_r_i) * 0.5;
          close_or_connect(s, &Contours);
          break;
        case 9:
          //# 1b0
          //# f a
          //# 0t1
          //# two segs:
          //#   f->t (adds at end)
          //#   a->b (adds at beginning)
          // b (to) = [(f_c_i +l_c_i) * 0.5, f_r_i];  //# top
          s1.to.x = (f_c_i +l_c_i) * 0.5; s1.to.y = f_r_i;
          // a (from) = [l_c_i, (f_r_i + l_r_i)* 0.5];   //# right
          s1.from.x = l_c_i; s1.from.y = (f_r_i + l_r_i) * 0.5;
          // t = [(f_c_i +l_c_i) * 0.5, l_r_i];  //# bottom
          s.to.x = (f_c_i +l_c_i) * 0.5; s.to.y = l_r_i;
          // f = [f_c_i, (f_r_i + l_r_i)* 0.5];   //# left
          s.from.x = f_c_i; s.from.y =  (f_r_i + l_r_i) * 0.5;
          // s = [f, t];
          add_end(s, &Contours);
          // s1 = [a, b];
          add_beginning(s1, &Contours);
          break;
        case 10:
          //# 1t0
          //# 
          //# 1f0
          //# one seg: f -> t (adds at beginning)
          // t = [(f_c_i +l_c_i) * 0.5, f_r_i];  //# top
          s.to.x = (f_c_i +l_c_i) * 0.5; s.to.y = f_r_i;
          // f = [(f_c_i +l_c_i) * 0.5, l_r_i];  //# bottom
          s.from.x = (f_c_i +l_c_i) * 0.5; s.from.y = l_r_i;
          add_beginning(s, &Contours);
          break;
        case 11:
          //# 1t0
          //#   f
          //# 1 1
          //# one seg: f -> t (adds at beginning)
          // t = [(f_c_i +l_c_i) * 0.5, f_r_i];  //# top
          s.to.x = (f_c_i +l_c_i) * 0.5; s.to.y = f_r_i;
          // f = [l_c_i, (f_r_i + l_r_i)* 0.5];   //# right
          s.from.x = l_c_i; s.from.y = (f_r_i + l_r_i) * 0.5;
          add_beginning(s, &Contours);
          break;
        case 12:
          //# 1 1
          //# f t
          //# 0 0
          //# one seg: f -> t (adds at end)
          // f = [f_c_i, (f_r_i + l_r_i)* 0.5];   //# left
          s.from.x = f_c_i; s.from.y = (f_r_i + l_r_i) * 0.5;
          // t = [l_c_i, (f_r_i + l_r_i)* 0.5, l_c_i];   //# right
          s.to.x = l_c_i; s.to.y =  (f_r_i + l_r_i) * 0.5;
          add_end(s, &Contours);
          break;
        case 13:
          //# 1 1
          //# f
          //# 0t1
          //# one seg: f -> t (adds at end)
          // f = [f_c_i, (f_r_i + l_r_i)* 0.5];   //# left
          s.from.x = f_c_i; s.from.y = (f_r_i + l_r_i) * 0.5;
          // t = [(f_c_i +l_c_i) * 0.5, l_r_i];  //# bottom
          s.to.x = (f_c_i +l_c_i) * 0.5; s.to.y = l_r_i;
          add_end(s, &Contours);
          break;
        case 14:
          //# 1 1
          //#   t
          //# 1f0
          //# one seg: f -> t (begins new)
          // t = [l_c_i, (f_r_i + l_r_i)* 0.5];   //# right
          s.to.x = l_c_i; s.to.y = (f_r_i + l_r_i) * 0.5;
          // f = [(f_c_i +l_c_i) * 0.5, l_r_i];  //# bottom
          s.from.x = (f_c_i +l_c_i) * 0.5; s.from.y = l_r_i;
          begin_new(s, &Contours);
          break;
        case 15:
          //# 1 1
          //#    
          //# 1 1
          //# nothing here
          break;
        default:
          asprintf(&error_message,
            "%s: bad case: %d", prog_name, cur_case);
          perror(error_message);
          free(error_message);
          exit(-1);
          break;
      }
    }
    temp_ptr = first_row;
    first_row = next_row;
    next_row = temp_ptr;
    memset(next_row, 0, (cols + 2));
  }
  debug_print("Finished reading slice.\n");
  fclose(in_fp);

  // log_contours(&Contours);
/*
  cleanup_contours(Contours);
*/
  write_contours(Contours, out_fp, x_spc, y_spc, x, y);
  debug_print("Finished writing contoure file.\n");
  fclose(out_fp);

  debug_print("Done\n"); 
  write(status_fh, "OK\n", 4);
  close(status_fh);
  exit(0);
}
