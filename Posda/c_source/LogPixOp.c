/*
#
#Copyright 2008, Bill Bennett
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
# Streamed Compressed Bitmap operations
#
# This program accepts (presumably) compressed bitmaps on multiple
# fds, performs bitwise logical operations on the streams, and
# outputs the results to another stream.
# The fd's have been opened by the parent process...
#
# What to do is specified on the command line.
# All of the parameters on the command line are of the form:
#  <name>=<value> (no spaces)
# The operands are a reverse polish specification of the operations
# to perform.
#
#
# Here are the possible parameters which make up the rp specification:
#  in[<n>]=<number of an input fd>
#  op=<AND,<n>|OR,<n>|NOT|XOR|MINUS>
#     AND,<n> means logical AND of <n> of args (aka intersection)
#     OR,<n> means logical OR of <n> of args (aka union)
#     XOR means logical XOR of two args (aka exclusive or)
#     NOT means logical negation of single arg (aka complement)
#     MINUS takes two args (a,b) and means "a intersect (not b)"
#
#  Any number of these operations are allowed, but the order is important, and
#  nothing can be "left on the stack" at the end of these operations. e.g.
#  The following specification:
#  "LogPixOp.pl in=1 in=2 in=3 op=XOR"
#  is illegal because it leaves the first operand (n=1) on the stack.
#
#  The following args follow the reverse polish spec and can appear in either
#  order:
#  out=<number of output fd>
#  status=<number of status fd> app will write status to this fd when finished
#
# Examples:
#  "LogPixOp in=3 in=4 in=5 op=OR,3 in=6 in=7 op=OR,2 op=AND,2 out=8" means:
#     "Take the union of the bits streaming in on fds 3, 4, and 5, 
#      and intersect it with the union of the bits streaming in on
#      fds 6 and 7; write the results on fd 8"
#      (3 or 4 or 5) and (6 or 7)
#  "LogPixOp in=3 in=4 op=OR,2 in=5 op=MINUS out=6" means:
#     "Take the union of 3 and 4 and exclude 5; write results on 6"
#     (3 or 4) minus 5
#
#  Warning:  Each fd can only be used once in an expression.  For example,
#  the following command is not allowed:
#
#LogPixOp in=3 op=NOT in=4 op=AND,2 in=3 in=4 op=NOT op=AND,2 op=OR,2 out=5
#
#  If this were legal it would define "((not a) and b) or (a and (not b))"
#  but ITS NOT LEGAL (and will cause a crash).
#

*/
#include <stdio.h>
#include <string.h>
#include <stdlib.h>
#include <unistd.h>

#define E_STREAM 1
#define E_AND 2
#define E_OR 3
#define E_MINUS 4
#define E_NOT 5
#define E_XOR 6

int output_fh;
int status_fh;
float binwidth;

typedef struct{
  char *op;
  int opi;
  void *a;
  void *b;
  void *operands;
  int op_count;
  int fh;
  FILE *fp;
  int open;
  int initialized;
  int polarity;
  int count;
  unsigned char next_byte;
  int total_bits;
} expression;

typedef struct{
  void *next;
  expression *operand;
} opchain;

expression *expr = NULL;

opchain *stack = NULL;

char *prog_name;

void print_expression(expression *e, int depth){
  int i;
  opchain *op;
  for(i = 0; i < depth; i++){
    printf("   ");
  }
  printf("%s", e->op);
  if(
    (strcmp(e->op, "AND") == 0) ||
    (strcmp(e->op, "OR") == 0)
  ){
    printf("\n");
    op = e->operands;
    while(op != NULL){
      print_expression(op->operand, depth + 1);
      printf("\n");
      op = op->next;
    }
  } else if (
    (strcmp(e->op, "XOR") == 0) ||
    (strcmp(e->op, "MINUS") == 0)
  ){ 
    printf("\n");
    print_expression(e->a, depth + 1);
    print_expression(e->b, depth + 1);
  } else if (strcmp(e->op, "NOT") == 0){
    printf("\n");
    print_expression(e->a, depth + 1);
  } else if (strcmp(e->op, "input_stream") == 0){
    printf("%d (%d)\n", e->fh, e->total_bits);
  }
}
void ReadStream(expression *stream){
  /* read bytes until polarity change */
  int n;
  int pol;
  while(stream->open && stream->next_byte == 0){
    stream->next_byte = getc(stream->fp);
    if (feof(stream->fp)) {
      stream->open = 0;
      stream->next_byte = 0;
      continue;
    }
    if (ferror(stream->fp)) {
      fprintf(stderr, "%s: stream %d error on read\n",
        prog_name, stream->fh);
      exit(-1);
    }
    pol = (stream->next_byte & 0x80) >> 7;
    if(stream->count == 0){
      stream->polarity = pol;
      stream->count = stream->next_byte & 0x7f;
      stream->next_byte = 0;
      continue;
    }
    if(stream->polarity == pol){
      stream->count += stream->next_byte & 0x7f;
      stream->next_byte = 0;
      continue;
    }
  }
}
void InitStream(expression *stream){
  /* initialize a stream here */
  stream->polarity = 0;
  stream->count = 0;
  stream->next_byte = 0;
  stream->initialized = 1;
  stream->open = 1;
  stream->total_bits = 0;
  ReadStream(stream);
}
void EvalCount(expression *stream, int *polarity, int *count, int remove_count){
  /* recursive evaluation routine */
  int n;
  int max_zeros, min_zeros, max_ones, min_ones;
  opchain *op;
  int s_pol, s_count;
  int s_pol1, s_count1;
  if(stream->opi == E_STREAM){
    if(stream->initialized == 0) InitStream(stream);
    if(remove_count > 0){
      if(remove_count > stream->count && stream->next_byte == 0){
        fprintf(stderr, 
          "%s: stream %d removing more bits than we have %d %d\n",
          prog_name, stream->fh, remove_count, stream->total_bits);
        exit(-1);
      } else if (remove_count < stream->count){
        stream->count -= remove_count;
        stream->total_bits += remove_count;
      } else if (remove_count == stream->count){
        stream->total_bits += remove_count;
        if(stream->next_byte != 0){
          stream->polarity = (stream->next_byte & 0x80) >> 7;
          stream->count = stream->next_byte & 0x7f;
          stream->next_byte = 0;
          if(stream->open) ReadStream(stream);
        } else {
          stream->count = 0;
        }
      } else {
        while(remove_count > stream->count){
          remove_count -= stream->count;
          stream->total_bits += stream->count;
          stream->polarity = (stream->next_byte & 0x80) >> 7;
          stream->count = stream->next_byte & 0x7f;
          stream->next_byte = 0;
          if(stream->open) ReadStream(stream);
        }
        stream->count -= remove_count;
        stream->total_bits += remove_count;
        if(stream->count == 0){
          if(stream->next_byte != 0){
            stream->polarity = (stream->next_byte & 0x80) >> 7;
            stream->count = stream->next_byte & 0x7f;
            stream->next_byte = 0;
            if(stream->open) ReadStream(stream);
          } else {
            stream->count = 0;
          }
        }
      }
    }
    *polarity = stream->polarity;
    *count = stream->count;
  } else if (stream->opi == E_AND){
    max_zeros = 0;
    min_ones = -1;
    op = stream->operands;
    while(op != NULL){
      EvalCount(op->operand, &s_pol, &s_count, remove_count);
      if(s_pol == 1){
        if(min_ones < 0 || s_count < min_ones) min_ones = s_count; 
      } else {
        if(s_count > max_zeros) max_zeros = s_count; 
      }
      if(max_zeros > 0){
        *polarity = 0;
        *count = max_zeros;
      } else if (min_ones > 0){
        *polarity = 1;
        *count = min_ones;
      } else {
        *polarity = 0;
        *count = 0;
      }
      op = op->next;
    }
  } else if (stream->opi == E_OR){
    max_ones = 0;
    min_zeros = -1;
    op = stream->operands;
    while(op != NULL){
      EvalCount(op->operand, &s_pol, &s_count, remove_count);
      if(s_pol == 0){
        if(min_zeros < 0 || s_count < min_zeros) min_zeros = s_count; 
      } else {
        if(s_count > max_ones) max_ones = s_count; 
      }
      if(max_ones > 0){
        *polarity = 1;
        *count = max_ones;
      } else if (min_zeros > 0){
        *polarity = 0;
        *count = min_zeros;
      } else {
        *polarity = 0;
        *count = 0;
      }
      op = op->next;
    }
  } else if (stream->opi == E_XOR){
    EvalCount(stream->a, &s_pol, &s_count, remove_count);
    EvalCount(stream->b, &s_pol1, &s_count1, remove_count);
    if(s_count < s_count1) n = s_count;
    else n = s_count1;
    *count = n;
    *polarity = s_pol ^ s_pol1;
  } else if (stream->opi == E_MINUS){
    EvalCount(stream->a, &s_pol, &s_count, remove_count);
    EvalCount(stream->b, &s_pol1, &s_count1, remove_count);
    if(s_count < s_count1) n = s_count;
    else n = s_count1;
    *count = n;
    *polarity = !s_pol && s_pol1;
  } else if (stream->opi == E_NOT){
    EvalCount(stream->a, &s_pol, &s_count, remove_count);
    *count = s_count;
    *polarity = !s_pol;
  } else {
    fprintf(stderr, "%s: unknown operation %s (%d) in EvalCount\n",
      prog_name, stream->op, stream->opi);
    exit(-1);
  }
}
int main(int argc, char *argv[]){
  int i, j;
  char *k;
  char *v;
  int iv;
  int ipi;
  char *lo;
  char *oc;
  opchain *op;
  int InPolish = 1;
  opchain *cp;
  int strip_count = 0;
  int current_polarity = 0;
  int current_count = 0;
  int total_bits = 0;
  int outchar;
  char *error_message;
  FILE *output_fp;

  prog_name = argv[0];
  /* Here we parse the command line parameters */
  for (i = 1; i < argc; i++){
    k = strtok(argv[i], "=");
    v = strtok(NULL, "\n");
    if(strcmp(k, "in") == 0){
      cp = calloc(sizeof(opchain), 1);
      cp->operand = calloc(sizeof(expression), 1);
      cp->operand->op = "input_stream";
      cp->operand->opi = E_STREAM;
      cp->operand->initialized = 0;
      cp->operand->fh = atoi(v);
      cp->operand->fp = fdopen(cp->operand->fh,"r");
      if(cp->operand->fp == NULL){
        printf( "%s Error opening fd: %d", prog_name, cp->operand->fh);
        exit(-1);
      }
      cp->next = stack;
      stack = cp;
    } else if(
      (strcmp(k, "op") == 0) && (
        (strncmp(v, "AND", 3) == 0) ||
        (strncmp(v, "OR", 2) == 0)
      )
    ){
      lo = strtok(v, ",");
      oc = strtok(NULL, ",");
      cp = calloc(sizeof(opchain), 1);
      cp->operand = calloc(sizeof(expression), 1);
      cp->operand->op = lo;
      cp->operand->opi = (strcmp(lo, "AND") == 0) ? E_AND : E_OR; 
      cp->operand->op_count = atoi(oc);
      for(j = 0; j < cp->operand->op_count; j++){
        op = stack;
        stack = stack->next;
        op->next = (opchain *)cp->operand->operands;
        cp->operand->operands = op;
      }
      cp->next = stack;
      stack = cp;
    } else if(
      (strcmp(k, "op") == 0) && (
        (strcmp(v, "XOR") == 0) ||
        (strcmp(v, "MINUS") == 0)
      )
    ){
      cp = calloc(sizeof(opchain), 1);
      cp->operand = calloc(sizeof(expression), 1);
      cp->operand->op = v;
      cp->operand->opi = (strcmp(v, "XOR") == 0)? E_XOR : E_MINUS;
      cp->operand->a = stack->operand;
      stack = stack->next;
      cp->operand->b = stack->operand;
      stack = stack->next;
      cp->next = stack;
      stack = cp;
    } else if(
      (strcmp(k, "op") == 0) &&
      (strcmp(v, "NOT") == 0)
    ){
      cp = calloc(sizeof(opchain), 1);
      cp->operand = calloc(sizeof(expression), 1);
      cp->operand->op = v;
      cp->operand->opi = E_NOT;
      cp->operand->a = stack->operand;
      stack = stack->next;
      cp->next = stack;
      stack = cp;
    } else if(strcmp(k, "out") == 0){
      output_fh = atoi(v);
    } else if (strcmp(k, "status") == 0){
      iv = atoi(v);
      status_fh = atoi(v);
    } else {
      printf("key: %s, value: %s\n", k, v);
    }
  }
  if(stack == NULL){
    fprintf(stderr, "%s: stack is NULL\n", prog_name);
    exit(-1);
  }
  expr = stack->operand;
  stack = stack->next;
  if(stack != NULL){
    printf( "%s stack in not empty after parsing expression", prog_name);
    exit(-1);
  }
  /* Debug - Lets print the expression
  print_expression(expr, 1);
  end debug print of expression*/

  output_fp = fdopen(output_fh, "w");
  if (output_fp == NULL){
    asprintf(&error_message,
      "%s: can't fdopen out_fh (%d)", prog_name, output_fh);
    perror(error_message);
    exit(-1);
  }

  /* loop goes here */
  while(1){
    EvalCount(expr, &current_polarity, &current_count, strip_count);
    strip_count = current_count;
    total_bits += strip_count;
    if(current_count == 0) break;
    while(current_count > 0){
      if(current_count > 127){
        if(current_polarity){
          outchar = 0x80 | 127;
        } else {
          outchar = 127;
        }
        current_count -= 127;
      } else {
        if(current_polarity){
          outchar = 0x80 | current_count;
        } else {
          outchar = current_count;
        }
        current_count = 0;
      }
      if (fputc(outchar, output_fp) == EOF) {
        asprintf(&error_message, "%s: Error on write", prog_name);
        perror(error_message);
        exit(-1);
      }
    }
  }
  fclose(output_fp);
  /*
  print_expression(expr, 1);
  */
  /* inform parent we're done */
  iv = asprintf(&v, "OK\n");
  write(status_fh, (void *) v, iv);
  free(v);
}
