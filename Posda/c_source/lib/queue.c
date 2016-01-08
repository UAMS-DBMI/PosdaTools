#ifndef LINT

#endif
extern	char	libRelease[];
static	char	*LibRelease = libRelease;
/*.
***********************************************************************

queue.c -- queuing module

DATA ABSTRACTION:

This module represents the operations on queues.  There are
two types of queues which this can be used to represent: free queues, and
hold queues.   Buffers are owned by free queues.  
Hold queues own no buffers, but hold buffers which are owned by 
free queues.   Queue can also have procedures to be called when they make
a transition from or to the empty state.

OPERATIONS:

	queue_init -- initializes the queue.
	queue_buf_alloc -- allocate and initialize one buffer not owned by any queue.
	queue_buf_init -- initialize buffers owned by a nice queue (free queues only).
	queue_mbuf_init -- init buffers (QHD does not need to be at start of buffer).
	queue_buf_rel -- return and free all buffers owned by a nice queue to the system (free queues only).
    queue_buf_free -- free all buffers owned by a nice queue (free queues only).
	queue_purge -- release all the buffers on the queue (hold queues only).
	queue_get -- get a buffer.
	queue_get_tail -- get a buffer from the tail of a buffer queue.
	queue_put -- put a buffer on the tail of a queue.
	queue_put_head -- put a buffer on the head of a queue
	queue_look_head -- look at a buffer from the head of a buffer queue.
	queue_look_tail -- look at a buffer from the tail of a buffer queue.
	queue_look_next -- look at next buffer in a queue.
	queue_look_prev -- look at prev buffer in a queue.
	queue_rel -- release a buffer to its owner.
	queue_put_prio -- put a buffer on the queue in priority order
	queue_empty -- check if data available on queue
	queue_remq -- remove a buffer from a queue
	queue_mapr -- map a function to all elements of a queue (removing)
	queue_rmapr -- reverse map a function to all elements of a queue (removing)
	queue_map -- map a function to all elements of a queue (non-removing)
	queue_mapi -- map a function to a queue (user terminated)
	queue_bmapi -- map a function to a queue backwards (user terminated)
	queue_copy -- copy a queue onto another queue
	queue_dump -- dump a nice queue (free queues only).

LOCAL ROUTINES:

	queue_p -- insert a buffer in a queue

STATIC DATA:

	none -- a pointer to the static data (the queue head) is passed in
		with each call, so that one copy of the code can serve multiple
		queues.

**************************************************************************
*/

extern	short	MPaxError;

#include	"global.h"
#include	"mpax.h"
#include	"queue.h"
#include	"errors.h"
#include	"log.h"
void	*MPaxCurrRou = 0;

/*.
**************************************************************************

queue_init -- initialize a buffer queue

SYNOPSIS:

	#include "queue.h"

	void queue_init(q, s,s_a, e,e_a);
	QHD *q;
	void (*s)();
	void	*s_a;
	void (*e)();
	void	*e_a;

DESCRIPTION:

Initialize the queue pointed to by q.  Set the queue to be empty 
(qlk_prev = qlk_next = &qhd_chain) and store the procedure pointers into 
the appropriate locations in the QLK.
Set qhd_onq = qhd_owned = qhd_alloc = 0.

PARAMETERS:

	q -- a pointer to the queue to initialized.
	s--This is a pointer to a function which returns void.  The function
		will be called with two arguments, a pointer to the queue head and
		s_a, whenever a put is done to an empty queue.
	s_a -- This is an argument pointer to be passed to the start 's'
		function.
	e -- This is a pointer to a function which returns void.  The function
		will be called with two arguments, a pointer to the queue headand 
		e_a, whenever a get is done which causes a queue to become empty.
	e_a -- This is an argument pointer to be passed to the end 'e' function.

RETURNS:

	*q -- is modified to be an initialized queue head.
	
SIDE EFFECTS:

	none

NOTE:

	macro queue_empty_func(q,e,e_a) may be used to reset the end function 
		and it's argument.  
	macro queue_not_empty_func(q,s,s_a) may be used to reset the start 
		function and it's argument.  

WARNING:

Initializing a non-empty queue will cause the buffers on the queue to be 
lost forever.

*********************************************************************
*/

void queue_init(q, s,s_a, e,e_a)

register	QHD *q;
register	void (*s)();
register	void	*s_a;
register	void (*e)();
register	void	*e_a;

{
	if (!q)
	{
		MPaxError = ERRQUEINV;
		return;
	}
	q->qhd_chain.qlk_prev = q->qhd_chain.qlk_next = (char *) q;
	q->qhd_onq = q->qhd_owned = 0;
	q->qhd_start = s;
	q->qhd_start_arg = s_a;
	q->qhd_end = e;
	q->qhd_end_arg = e_a;
	q->qhd_chk_value = QUE_CHK_VALUE;
	q->qhd_buf_siz = 0;
	q->qhd_addr = NULL;
	q->qhd_nice = FALSE;
}

/*.
**********************************************************************

queue_mbuf_init -- initialize buffers owned by a queue

SYNOPSIS:

	#include "queue.h"

	void queue_mbuf_init(q, n, s, p, b);
	QHD *q;
	unsigned long n;
	unsigned long s;
	char *p;
	QBF	*b;

DESCRIPTION:

Allocate n buffers of size s (plus sizeof buffer header), and queue onto 
the queue specified by q.  The buffers are allocated out of the array p.
For each buffer, initialize its header to be owned by *q, queue it on 
q->buf_link, increment q->qhd_onq and qhd_owned.  If the queue had been 
empty, call *(q->qhd_start) with a pointer to this queue.

PARAMETERS:

	q -- is a pointer to the queue to be initialized.
	n -- is the number of buffers to be initialized.
	s -- is the size of the buffers to be initialized.  This should include
		the buffer header (QBF structure).
	p -- is a pointer to the area from which the buffers are initialized.  
		It is the caller's responsibility to allocate this area.

RETURNS:

	*q -- is modified to contain pointers to the first and last buffers in
		the queue, and to have an appropriate queue count.
	*p -- is modified by linking all of the buffers together.

SIDE EFFECTS:

	May cause the "start" routine specified at queue_init time to be called.

WARNING:

If the area pointed to by p isn't big enough, strange things may happen.

**********************************************************************
*/

void queue_mbuf_init(q, n, s, p, b)

register	QHD *q;
register	unsigned long n;
register	unsigned long s;
register	void *p;
register	QBF *b;

{
	register	unsigned long		i;
				ushort	offset;

	if ( q != NULL  &&  q->qhd_chk_value != QUE_CHK_VALUE )
	{
		MPaxError = ERRQUEINV;
		return;
	}

	if ( q != NULL )
		q->qhd_buf_siz = s;

	if (b == NULL)
		b = (QBF *) p;

	offset = ((char *) b) - ((char *) p);

	for (i = 0; i < n; i++)
	{
		if (b->buf_owner != (QHD *)QUE_BUF_STATICALLY_OWNED)
			b->buf_owner = q;
		b->buf_size = s - sizeof (struct qbf);
		b->buf_link.qlk_next = b->buf_link.qlk_prev = NULL;
		b->buf_offset = offset;
		if ( q != NULL )
		{
			queue_put(q, b);
			q->qhd_owned++;
		}
		b = (QBF *)(((char *) b) + s);
	}

	/*
	 * If there is no queue, we are through.
	 */
	if ( q == NULL )
		return;

	/*
	 *	Check to see if we are re-initing a nice queue. If so turn
	 *	the queue into a normal queue.
	 */
	if ((q != NULL) && q->qhd_addr || q->qhd_nice)
	{
		q->qhd_addr = NULL;
		q->qhd_nice = FALSE;
		return;
	}

	/*
	 *	Make the queue a "nice" queue.
	 */
	q->qhd_addr = p;
	q->qhd_nice = TRUE;
}

/*.
**********************************************************************

queue_buf_init -- initialize buffers owned by a queue

SYNOPSIS:

	#include "queue.h"

	void queue_buf_init(q, n, s, p);
	QHD *q;
	unsigned long n;
	unsigned long s;
	char *p;

DESCRIPTION:

Allocate n buffers of size s (plus sizeof buffer header), and queue onto 
the queue specified by q.  The buffers are allocated out of the array p.
For each buffer, initialize its header to be owned by *q, queue it on 
q->buf_link, increment q->qhd_onq and qhd_owned.  If the queue had been 
empty, call *(q->qhd_start) with a pointer to this queue.

PARAMETERS:

	q -- is a pointer to the queue to be initialized.
	n -- is the number of buffers to be initialized.
	s -- is the size of the buffers to be initialized.  This should include
		the buffer header (QBF structure).
	p -- is a pointer to the area from which the buffers are initialized.  
		It is the caller's responsibility to allocate this area.

RETURNS:

	*q -- is modified to contain pointers to the first and last buffers in
		the queue, and to have an appropriate queue count.
	*p -- is modified by linking all of the buffers together.

SIDE EFFECTS:

	May cause the "start" routine specified at queue_init time to be called.

WARNING:

If the area pointed to by p isn't big enough, strange things may happen.

**********************************************************************
*/

void queue_buf_init(q, n, s, p)

register	QHD *q;
register	unsigned long n;
register	unsigned long s;
register	void *p;

{
	queue_mbuf_init(q, n, s, p, (QBF *) p);
}

/*.
**********************************************************************

queue_buf_static_alloc -- initialize one buffer statically allocated.

SYNOPSIS:

	#include "queue.h"

	void queue_buf_static_alloc(b, s);
	QBF *b;
	int s;

DESCRIPTION:

Initialize a "static" buffer, b, of size, s (plus sizeof buffer header). The
buffer header is initialized similarly to queue_buf_init() above, except
b->buf_owner is set to QUE_BUF_STATICALLY_OWNED.

Static buffers set up in this way, do not get "free()"ed when queue_rel() is called,
instead they're the responsibility of the application to maintain.

PARAMETERS:

	b -- is the address of the pointer to the buffer to be initialized.
	s  -- is the size of the buffer  to be initialized. This should include
		  the buffer header (QBF structure).

RETURNS:

	**b -- is initialized, if successful. Otherwise returns NULL and
	       the external MPaxError is set to the error number:
		  
SIDE EFFECTS:

	none.

**********************************************************************
*/

void queue_buf_static_alloc(b, s)

register	QBF *b;  /** POINTER PASSED BY ADDRESS **/
register	unsigned long s;

{
    if (b == NULL) 
    	MPaxError = ERRQUEALLOC;
    else 
	{
		if (b->buf_owner != (QHD *)QUE_BUF_STATICALLY_OWNED)
		{
			b->buf_owner = (QHD *)QUE_BUF_STATICALLY_OWNED;
			b->buf_size = s - sizeof (struct qbf);
			b->buf_link.qlk_next = b->buf_link.qlk_prev = NULL;
		}
	}

}

/*.
**********************************************************************

queue_buf_alloc -- allocate and initialize one buffer not owned by any queue.

SYNOPSIS:

	#include "queue.h"

	void queue_buf_alloc(b, s);
	QBF **b;
	int s;

DESCRIPTION:

Allocate a "dynamic" buffer, b, of size, s (plus sizeof buffer header). The
buffer header is initialized similarly to queue_buf_init() above, except
b->buf_owner is set to NULL.

Dynamic buffers set up in this way, get "free()"ed when queue_rel() is called,
instead of being put back on the owner's free queue.

PARAMETERS:

	b -- is the address of the pointer to the buffer to be initialized.
	s  -- is the size of the buffer  to be initialized. This should include
		  the buffer header (QBF structure).

RETURNS:

     *b -- is allocated.
	**b -- is initialized, if successful. Otherwise returns NULL and
	       the external MPaxError is set to the error number:
		  
			ERRQUEALLOC -- malloc() failed when allocating new dynamic buffer.
	
SIDE EFFECTS:

	A page fault may occur on the malloc().

**********************************************************************
*/

void queue_buf_alloc(b, s)

register	QBF **b;  /** POINTER PASSED BY ADDRESS **/
register	unsigned long s;

{
    *b = (QBF *) calloc(1,s);

    if (*b == NULL) 
    	MPaxError = ERRQUEALLOC;
    else 
	{
		(*b)->buf_owner = (QHD *)-1L;
		(*b)->buf_size = s - sizeof (struct qbf);
		(*b)->buf_link.qlk_next = (*b)->buf_link.qlk_prev = NULL;
	}

}

/*.
**********************************************************************

queue_buf_rel -- return and free all buffers owned by a nice queue to the system.

SYNOPSIS:

	#include "queue.h"

	int queue_buf_rel(q);
	QHD *q;

DESCRIPTION:

Return all buffers owned by a nice queue and return all memory allocated to
the nice queue buffers to the system.

PARAMETERS:

	q -- is a pointer to the queue to be returned.

RETURNS:

	*q -- is modified to contain pointers to the first and last buffers in
		the queue, and to have an appropriate queue count.
	 0 -- if all is ok.
	-1 -- if an error occurs.

SIDE EFFECTS:

	May cause the "end" routine specified at queue_init time to be called.
	Any buffers leased to another queue will be removed from that queue.

**********************************************************************
*/
int queue_buf_rel(q)
QHD *q;
{
	QBF *p;
	int i;

	if (!q)
	{
		MPaxError = ERRQUEINV;
		return(-1);
	}
	/*
	 *	Return all buffers to the nice queue owning them.
	 */
	for (i = 0, p = (QBF *)q->qhd_addr ; i < q->qhd_owned;
		p = (QBF *) (((char *)p) + q->qhd_buf_siz), i++)
	{
		if (!queue_on_free_que(p))
		{

			if (queue_remq(p->buf_curr_owner, p) == NULL) return(-1);
			if (queue_rel(p)) return(-1);
		}
	}

	return(0);
}

/*.
**********************************************************************

queue_buf_free -- free all buffers owned by a nice queue to the system.

SYNOPSIS:

	#include "queue.h"

	int queue_buf_free(q);
	QHD *q;

DESCRIPTION:

Free all memory allocated to the nice queue buffers to the system.

PARAMETERS:

	q -- is a pointer to the queue to be freed.
	s -- is the size of the buffers to be freed.  This should include
		the buffer header (QBF structure).

RETURNS:

	*q -- is modified to contain pointers to the first and last buffers in
		the queue, and to have an appropriate queue count.
	 0 -- if all is ok.
	-1 -- if an error occurs.

SIDE EFFECTS:


**********************************************************************
*/
long queue_buf_free(q)
QHD *q;
{
	QBF *p;
	int i;

	if (!q)
	{
		MPaxError = ERRQUEINV;
		return(-1);
	}
	/*
	 *	Make sure we are freeing only buffers in the free queue.
	 */
	for (i = 0, p = (QBF *)q->qhd_addr ; i < q->qhd_owned;
		p = (QBF *) (((char *)p) + q->qhd_buf_siz), i++)
	{
		if (!queue_on_free_que(p))
		{
			return (-1);
		}
	}

	/*
	 *	Give the buffers back to the operating system and re-init the QHD.
	 */
	free (q->qhd_addr);
	queue_init(q, q->qhd_start, q->qhd_start_arg, q->qhd_end, q->qhd_end_arg);
	return(0);
}

/*.
**********************************************************************

queue_purge -- release all the buffers on a queue

SYNOPSIS:

	#include "queue.h"

	int queue_purge(q);
	QHD *q;

DESCRIPTION:

Any buffers on the queue are released to the owner of the queue.  Only 
hold queues may be purged.

PARAMETERS:

	q -- this is a pointer to the head of the queue to be purged.

RETURNS:

	queue_purge -- this is a zero if there is no error.  Otherwise it is a
		 -1 and the external MPaxError is set to the error number: 
			ERRQUEPFQ - Purge free queue.
	*q -- is now an empty queue.  An buffers which were on *q were released.

SIDE EFFECTS:

	Will cause the "end" routine specified at queue_init time to be called.
	May cause the "start" routine of the queue(s) which owns the buffers on
	the queue to be called.

***********************************************************************
*/

long queue_purge(q)

register	QHD *q;

{
	register	QBF *n;

	if ( q == NULL  ||  q->qhd_chk_value != QUE_CHK_VALUE )
	{
		MPaxError = ERRQUEINV;
		return(-1);
	}
	if (q->qhd_owned != 0)
	{
		MPaxError = ERRQUEPFQ;
		return(-1);
	}
	while (!queue_empty(q))
	{
		n = (QBF *) q->qhd_chain.qlk_next;
		queue_remq(q,n);
		queue_rel(n);
	}
	return(0);
}

/*.
***********************************************************************

queue_get -- get a buffer from a buffer queue.

SYNOPSIS:

	#include "queue.h"

	void *queue_get(q);
	QHD *q;

DESCRIPTION:

The next buffer is dequeued from the queue.  If this causes the queue to
become empty.  The procedure in the queue_end field of the queue is invoked.
If the queue was already empty, a NULL pointer is returned.

PARAMETERS:

	q -- this is a pointer to the head of the queue from which a buffer is
		to be dequeued.

RETURNS:

	queue_get -- either a NULL pointer (if the queue is empty) or a pointer
		to the buffer dequeued.
	*q -- is modified to no longer contain the buffer.
	*queue_get -- is modified to no longer be on a queue.

SIDE EFFECTS:

	May cause the "end" routine specified at queue_init time to be called.

**********************************************************************
*/

void *queue_get(q)

register	QHD *q;

{
	if ( q == NULL  ||  q->qhd_chk_value != QUE_CHK_VALUE )
	{
		MPaxError = ERRQUEINV;
		return(NULL);
	}
	if (queue_empty(q))
		return(NULL);
	else
		return(queue_remq(q,(QBF *) q->qhd_chain.qlk_next));
}

/*.
***********************************************************************

queue_get_tail -- get a buffer from the tail of a buffer queue.

SYNOPSIS:

	#include "queue.h"

	void *queue_get_tail(q);
	QHD *q;

DESCRIPTION:

The next buffer is dequeued from the tail of the queue.  If this
causes the queue to become empty.  The procedure in the queue_end
field of the queue is invoked.  If the queue was already empty,
a NULL pointer is returned.

PARAMETERS:

	q -- this is a pointer to the head of the queue from which a buffer is
		to be dequeued.

RETURNS:

	queue_get_tail -- either a NULL pointer (if the queue is empty) or
		a pointer to the buffer dequeued.
	*q -- is modified to no longer contain the buffer.
	*queue_get_tail -- is modified to no longer be on a queue.

SIDE EFFECTS:

	May cause the "end" routine specified at queue_init time to be called.

**********************************************************************
*/

void *queue_get_tail(q)

register	QHD *q;

{
	if ( q == NULL  ||  q->qhd_chk_value != QUE_CHK_VALUE )
	{
		MPaxError = ERRQUEINV;
		return(NULL);
	}
	if (queue_empty(q))
		return(NULL);
	else
		return(queue_remq(q,(QBF *) q->qhd_chain.qlk_prev));
}

/*.
***********************************************************************

queue_look_head -- look at a buffer from the head of a buffer queue.

SYNOPSIS:

	#include "queue.h"

	QBF *queue_look_head(q);
	QHD *q;

DESCRIPTION:

The buffer form the head of the queue is returned unless the queue
is empty, then NULL is returned.

PARAMETERS:

	q -- this is a pointer to the head of the queue from which a buffer is
		to be found.

RETURNS:

	queue_look_head -- either a NULL pointer (if the queue is empty) or
		a pointer to the first buffer.

**********************************************************************
*/

void *queue_look_head(q)

register	QHD *q;

{
	if ( q == NULL  ||  q->qhd_chk_value != QUE_CHK_VALUE )
	{
		MPaxError = ERRQUEINV;
		return(NULL);
	}
	if (queue_empty(q))
		return(NULL);
	else
		return(queue_str_addr((QBF *) q->qhd_chain.qlk_next));
}

/*.
***********************************************************************

queue_look_tail -- look at a buffer from the tail of a buffer queue.

SYNOPSIS:

	#include "queue.h"

	QBF *queue_look_tail(q);
	QHD *q;

DESCRIPTION:

The buffer from the tail of the queue is returned unless the
queue is empty, then NULL is returned.

PARAMETERS:

	q -- this is a pointer to the head of the queue from which a buffer is
		to be found.

RETURNS:

	queue_look_tail -- either a NULL pointer (if the queue is empty) or
		a pointer to the last buffer.

**********************************************************************
*/

void *queue_look_tail(q)

QHD *q;

{
	if ( q == NULL  ||  q->qhd_chk_value != QUE_CHK_VALUE )
	{
		MPaxError = ERRQUEINV;
		return(NULL);
	}
	if (queue_empty(q))
		return(NULL);
	else
		return(queue_str_addr((QBF *) q->qhd_chain.qlk_prev));
}

/*.
***********************************************************************

queue_look_next -- Look at the next buffer in a queue

SYNOPSIS:

	#include "queue.h"

	QBF *queue_look_next(q, b);
	QHD *q;
	QBF *b;

DESCRIPTION:

This routine takes a passed buffer on a queue and returns the next buffer
on the queue or NULL if the passed buffer was the last buffer on the queue
or if there was an error.

PARAMETERS:

	q -- This is a pointer to the queue which the buffer is on.
	b -- This is a pointer to a buffer.

RETURNS:

	queue_look_next -- either a NULL pointer
		(if this is the last buffer in a queue)
		or a pointer to the next buffer in the queue.

**********************************************************************
*/

void *queue_look_next(q, b)

register	QHD	*q;
register	QBF *b;

{
	register	QBF *t;

	if ( q == NULL  ||  q->qhd_chk_value != QUE_CHK_VALUE )
	{
		MPaxError = ERRQUEINV;
		return(NULL);
	}
	if ( b == NULL )
	{
		MPaxError = ERRQUEPNB;
		return(NULL);
	}
	if ( (QHD *) (b->buf_curr_owner) != q  ||
		 b->buf_link.qlk_next == NULL )
	{
		MPaxError = ERRPARM;
		return(NULL);
	}
	if ( (QHD *) (t = (QBF *)b->buf_link.qlk_next) == q )
		return(NULL);
	return(queue_str_addr(t));
}

/*.
***********************************************************************

queue_look_prev -- Look at the next buffer in a queue

SYNOPSIS:

	#include "queue.h"

	QBF *queue_look_prev(q, b);
	QHD *q;
	QBF *b;

DESCRIPTION:

This routine takes a passed buffer on a queue and returns the next buffer
on the queue or NULL if the passed buffer was the last buffer on the queue
or if there was an error.

PARAMETERS:

	q -- This is a pointer to the queue which the buffer is on.
	b -- This is a pointer to a buffer.

RETURNS:

	queue_look_prev -- either a NULL pointer
		(if this is the last buffer in a queue)
		or a pointer to the next buffer in the queue.

**********************************************************************
*/

void *queue_look_prev(q, b)

register	QHD	*q;
register	QBF *b;

{
	register	QBF *t;

	if ( q == NULL  ||  q->qhd_chk_value != QUE_CHK_VALUE )
	{
		MPaxError = ERRQUEINV;
		return(NULL);
	}
	if ( b == NULL )
	{
		MPaxError = ERRQUEPNB;
		return(NULL);
	}
	if ( (QHD *) (b->buf_curr_owner) != q  ||
		 b->buf_link.qlk_prev == NULL )
	{
		MPaxError = ERRPARM;
		return(NULL);
	}
	if ( (QHD *) (t = (QBF *) b->buf_link.qlk_prev) == q )
		return(NULL);
	return(queue_str_addr(t));
}

/*.
**********************************************************************

queue_put -- put a buffer on the tail of a queue

SYNOPSIS:

	#include "queue.h"

	void queue_put(q, b)
	QHD *q;
	QBF *b;

DESCRIPTION:

The buffer pointed to by b is queued at the tail of the q pointed to by q.
If the queue had been empty, then the routine specified by the queue_end 
field of the queue is called.  Normally queue_put is called to put the 
buffer on a hold queue.  It can be called to release a buffer to a free 
queue, but this is normally done using queue_rel.  buffers can be put on a 
free queue to which they do not belong, but this is not normally done.

PARAMETERS:

	q-- this is a pointer to the queue on which the buffer is to be placed.
	b -- this is a pointer to a buffer to be queued.

RETURNS:

	queue_put -- returns 0 it the put was done ok.  Otherwise returns a -1
		and the external MPaxError will be set to the error number:
			ERRQUEPNB -- attempt to put a null buffer on a queue.
			ERRQUEBOQ -- attempt to put a buffer which was already on a 
							queue.
	*q -- The queue header and last buffer on the queue are modified to
		contain pointers to the buffer.
	*b -- The buffer is modified to contain pointers to the queue header
		and next previous buffer in the queue.

SIDE EFFECTS:

	May cause the "start" routine specified at queue_init time to be called.

**********************************************************************
*/

long queue_put(q, b)

register	QHD *q;
register	QBF *b;

{
	if ( q == NULL  ||  q->qhd_chk_value != QUE_CHK_VALUE )
	{
		MPaxError = ERRQUEINV;
		return(-1);
	}
	if (b == NULL)
	{
		MPaxError = ERRQUEPNB;
		return(-1);
	}
	if (b->buf_link.qlk_next != NULL)
	{
		MPaxError = ERRQUEBOQ;
		return(-1);
	}
	queue_p(q, b, &q->qhd_chain);
	return(0);
}

/*.
**********************************************************************

queue_put_head -- put a buffer on the head of a queue

SYNOPSIS:

	#include "queue.h"

	int queue_put_head(q, b)
	QHD *q;
	QBF *b;

DESCRIPTION:

The buffer pointed to by b is queued at the head of the q pointed to by q.
If the queue had been empty, then the routine specified by the queue_end 
field of the queue is called.  Normally queue_put is called to put the buffer
on a hold queue.  It can be called to  release a buffer to a free queue, 
but this is normally done using queue_rel.  buffers can be put on a free 
queue to which they do not belong, but this is not normally done.

PARAMETERS:

	q-- this is a pointer to the queue on which the buffer is to be placed.
	b -- this is a pointer to a buffer to be queued.

RETURNS:

	queue_put_head -- returns 0 it the put was done ok.  Otherwise returns a
		-1 and the external MPaxError is set to the error number:
			ERRQUEPNB -- attempt to put a null buffer on a queue.
			ERRQUEBOQ -- attempt to put a buffer which was already on a 
						queue.
	*q -- The queue header and first buffer on the queue are modified to
		contain pointers to the buffer.
	*b -- The buffer is modified to contain pointers to the queue header
		and next buffer in the queue.

SIDE EFFECTS:

	May cause the "start" routine specified at queue_init time to be called.

***********************************************************************
*/

long queue_put_head(q, b)

register	QHD *q;
register	QBF *b;

{
	if (q == NULL  || q->qhd_chk_value != QUE_CHK_VALUE)
	{
		MPaxError = ERRQUEINV;
		return(-1);
	}
	
	if (b == NULL)
	{
		MPaxError = ERRQUEPNB;
		return(-1);
	}
	if (b->buf_link.qlk_next != NULL)
	{
		MPaxError = ERRQUEBOQ;
		return(-1);
	}
	queue_p(q, b, (QLK *) q->qhd_chain.qlk_next);
	return(0);
}

/*.
**********************************************************************

queue_rel - release a buffer to its owner, or
           free it if there is no owner.

SYNOPSIS:

	#include "queue.h"

	long queue_rel(b);
	QBF *b;

DESCRIPTION:

Release the buffer specified by b to its owner (which is a free queue) --
if the owner pointer is non-NULL.  A pointer to the owning free queue is
contained in the QBF structure and is initialized at queue_init time.

If the owner pointer is NULL, return it to heap using the 'C' free() routine.

PARAMETERS:

	b -- is a pointer to the buffer to be released.

RETURNS:

	queue_rel -- returns 0 it the release was done ok.  Otherwise returns a
		-1 and the external MPaxError is set to the error number:
			ERRQUEPNB -- attempt to release a null buffer.
			ERRQUEBOQ -- attempt to release a buffer which was on a queue.
	*(b->buf_owner) -- (i.e. owning queue) The queue header and first 
		buffer on the queue are modified to contain pointers to the buffer.
	*b -- The buffer is modified to contain pointers to the owning queue 
		header and next buffer in the queue.

SIDE EFFECTS:

	The "start" routine specified at queue_init time may be called.

**********************************************************************
*/

long queue_rel(b)
register	QBF *b;
{
    if (!b  ||  !b->buf_owner)
	{
		MPaxError = ERRPARM;
		return(-1);
	}

	if (b->buf_owner == QUE_BUF_STATICALLY_OWNED)
	{
		b->buf_link.qlk_prev = NULL;
		b->buf_curr_owner = (void *) b->buf_owner;
		b->buf_link.qlk_next = NULL;
		
		return (0);
	}
	
	if (b->buf_owner != (QHD *)-1L)
		return(queue_put_head(b->buf_owner, b));
	
	free(b);
	return(0);
}

/*.
**********************************************************************

queue_put_prio -- put a buffer on a queue in priority order

SYNOPSIS:

	#include "queue.h"

	long queue_put_prio(q, b, o)
	QHD q;
	QBF b;
	int (*o)();

DESCRIPTION:

Puts a buffer in the queue in priority order.  That is the buffer is queued 
after all buffers with a priority less than or equal to the priority of this 
buffer.  Therefore, within a priority, the queue is FIFO.  The priorities of 
two buffers are compared by calling the order procedure.

PARAMETERS:

	q -- this is a pointer to the queue on which the buffer is to be placed.
	b -- this is a pointer to a buffer to be queued.
	o -- o SYNOPSIS:
		
		int	o(n,b);
		QBF	*n,*b;
		
		DECRIPTION:	This is a procedure used to order the buffers in the 
		queue.  If buffer pointed to by 'b' should be inserted before 
		buffer pointed to by 'n', o returns TRUE, else returns FALSE;
		The buffer pointer 'b' is the same buffer ptr as passed to func
		queue_put_prio.

RETURNS:

	queue_put_prio -- returns 0 it the put was done ok.  Otherwise returns a
		-1 and the external MPaxError is set to the error number:
			ERRQUEPNB -- attempt to put a null buffer.
			ERRQUEBOQ -- attempt to put a buffer which was on a queue.
	*q -- The queue is modified to contain the buffer
	*b -- The buffer is chained on the queue.

SIDE EFFECTS:

	May cause the "start" routine specified at queue_init to be called.

**********************************************************************
*/

long queue_put_prio(q,b,o)

register	QHD *q;
register	QBF *b;
register	int (*o)();

{
	register	QLK *n;

	if ( q == NULL  ||  q->qhd_chk_value != QUE_CHK_VALUE )
	{
		MPaxError = ERRQUEINV;
		return(-1);
	}
	if (b == NULL)
	{
		MPaxError = ERRQUEPNB;
		return(-1);
	}
	if (b->buf_link.qlk_next != NULL)
	{
		MPaxError = ERRQUEBOQ;
		return(-1);
	}
	if (queue_empty(q))
		return(queue_put(q, b));
	for 
		(n = (QLK *) q->qhd_chain.qlk_next;
		 n != (QLK *) q;
		 n = (QLK *) n->qlk_next)
	{
		if ((*o)(queue_str_addr((QBF *)n),queue_str_addr(b)))
		{
			queue_p(q, b, n);
			return(0);
		} 
	}
	queue_p(q, b, &q->qhd_chain);
	return(0);
}

/*.
**********************************************************************

queue_empty -- determine if a queue is empty.

SYNOPSIS:

	#include "queue.h"

	int queue_empty(q);
	QHD *q;

DESCRIPTION:

Determine if the queue is empty.

PARAMETERS;

	q -- points to the queue in question.

RETURNS:

	queue_empty -- returns TRUE is the queue is empty.

SIDE EFFECTS:

	none

**********************************************************************
*/


/* queue_empty is implemented as a macro */

/*.
**********************************************************************

queue_remq -- remove a buffer from a queue.

SYNOPSIS:

	#include "queue.h"

	QBF *queue_remq(q,b);
	QHD *q;
	QBF *b;

DESCRIPTION:

Remove a specified buffer from a queue and update the queue header counts.

PARAMETERS;

	q -- points to the queue in question
	b -- points to the buffer in question.

RETURNS:

	queue_remq -- -1 if error, else returns the buffer.
	*b -- the queue is modified to no longer contain the buffer and
		the buffer is modified to have NULL pointers in its queue links.
	*q -- the counts in the queue head are modified.

SIDE EFFECTS:

	if the queue becomes empty, then the "end" routine specified at 
	queue_init time may be called.

**********************************************************************
*/

void *queue_remq(q,b)

register	QBF *b;
register	QHD *q;

{
	if ( q == NULL  ||  q->qhd_chk_value != QUE_CHK_VALUE )
	{
		MPaxError = ERRQUEINV;
		return(NULL);
	}
	if ( b == NULL )
	{
		MPaxError = ERRQUEPNB;
		return(NULL);
	}
	if ( (QHD *) (b->buf_curr_owner) != q  ||
		 (QLK *)  b->buf_link.qlk_next == NULL  ||
		 (QLK *)  b->buf_link.qlk_prev == NULL )
	{
		MPaxError = ERRPARM;
		return(NULL);
	}
	(((QLK *)b->buf_link.qlk_next)->qlk_prev) = b->buf_link.qlk_prev;
	(((QLK *)b->buf_link.qlk_prev)->qlk_next) = b->buf_link.qlk_next;
	b->buf_link.qlk_next = b->buf_link.qlk_prev = NULL;
	b->buf_curr_owner = MPaxCurrRou;
	q->qhd_onq--;
	if (queue_empty(q) && (q->qhd_end != NULL))
		(*q->qhd_end)(q,q->qhd_end_arg);
	return(queue_str_addr(b));
}

/*.
**********************************************************************

queue_mapr -- map a function over a queue (removing).

SYNOPSIS:

	#include "queue.h"

	QBF *queue_mapr(q, f);
	QHD *q;
	void (*f)();

DESCRIPTION:

Dequeues every element of a queue, in order and calls a specified function
for each element.

PARAMETERS;

	q -- points to the queue to be maped over.
	f -- the function to be mapped.

RETURNS:

	none.

SIDE EFFECTS:

	Will cause the "end" functions specified for the queue being purged
	to be called.  May cause the "start" function for the free queue(s)
	owning the buffers to be called.

**********************************************************************
*/

void queue_mapr(q,f)

register	QHD *q;
void (*f)();

{
	register	QBF *n;

	if ( q == NULL  ||  q->qhd_chk_value != QUE_CHK_VALUE )
	{
		MPaxError = ERRQUEINV;
		return;
	}
	if (!f)
	{
		MPaxError = ERRPARM;
		return;
	}
	while (!queue_empty(q))
	{
		n = queue_get(q);
		(*f)(queue_str_addr(n));
	}
}

void queue_rmapr(q,f)
 
 register    QHD *q;
 void (*f)();
  
  {
	  register    QBF *n;
	   
   if ( q == NULL  ||  q->qhd_chk_value != QUE_CHK_VALUE )
	   {
		   MPaxError = ERRQUEINV;
		   return;
	   }
   if (!f)
   {
   MPaxError = ERRPARM;
   return;
   }
   while (!queue_empty(q))
	   {
   		/* n = queue_get_head(q); */
   		n = queue_look_head(q);
		n = queue_remq(q,n);
	   (*f)(queue_str_addr(n));
   }
 }


/*.
**********************************************************************

queue_map -- map a function over a queue (non removing).

SYNOPSIS:

	#include "queue.h"

	void queue_map(q, f, a);
	QHD *q;
	void (*f)();
	void *a;

DESCRIPTION:

Call the specified function for every element of a queue.  The 
function must have three parameters, the first being a pointer to the 
queue head, the second being a pointer to the queue element, and the
third must be a pointer to the arg struct.  The function may dequeue 
the buffer from the queue, but should use queue_remq to do so in order to 
preserve sanity of the queue head.

PARAMETERS;

	q -- points to the queue in question.
	f -- the function to be mapped.
	a -- an arbituary argument ptr.

RETURNS:

	none.

SIDE EFFECTS:

	May vary according to the functions being called.

**********************************************************************
*/

void queue_map(q,f,a)

register	QHD *q;
register	void (*f)();
register	void *a;

{
	register	QBF *n,*m;

	if ( q == NULL  ||  q->qhd_chk_value != QUE_CHK_VALUE )
	{
		MPaxError = ERRQUEINV;
		return;
	}
	if (!f)
	{
		MPaxError = ERRPARM;
		return;
	}
	for (n =  (QBF *) q->qhd_chain.qlk_next ;
		n && n != (QBF *) q &&  n->buf_curr_owner == (void *) q; 
		m = n,
		n = (QBF *) n->buf_link.qlk_next,
		(*f)(q, queue_str_addr(m), a)  )
		;
	
}

/*.
**********************************************************************

queue_mapi -- map a function over a queue (user terminating).

SYNOPSIS:

	#include "queue.h"

	char *queue_mapi(q, f, a);
	QHD *q;
	char *(*f)();
	void *a;

DESCRIPTION:

Call the specified function for every element of a queue, until the 
specified function returns a non NULL value.  The value returned by the 
function is returned by queue_mapi.  The function must have three parameters,
the first being a pointer to the queue head, the second being a pointer 
to the queue element, and the third being the 'a' parameter to queu_mapi.
The function may dequeue the buffer from the queue, but should use queue_remq
to do so in order to preserve sanity of the queue head.

PARAMETERS;

	q -- points to the queue in question.
	f -- the function to be mapped.
	a -- an arbitrary pointer to be passed to the function.

RETURNS:

	queue_mapi -- The first non-NULL value returned by f, or NULL if the
		end of the queue is reached without f ever returning a non-NULL.

SIDE EFFECTS:

	May vary according to the functions being called.

**********************************************************************
*/

void *queue_mapi_from(q,f,a,s)

register	QHD *q;
register	void *(*f)();
register	void *a;
register	QBF	 *s;

{
	register	QBF *m;
	register	void *i;

	if ( q == NULL  ||  q->qhd_chk_value != QUE_CHK_VALUE )
	{
		MPaxError = ERRQUEINV;
		return(NULL);
	}
	if ( f == NULL ) return( s == (QBF *)q ? NULL : (char *) s);
	while (s  &&  s != (QBF *) q  &&  s->buf_curr_owner == (void *) q)
	{
		m = s;
		s = (QBF *) s->buf_link.qlk_next;
		if((i = (*f)(q, queue_str_addr(m), a)) != NULL)
			return(i);
	}
	return(NULL);
	
}
void *queue_mapi(q,f,a)

register	QHD *q;
register	void *(*f)();
register	void *a;

{
	if ( q == NULL )
	{
		MPaxError = ERRQUEINV;
		return(NULL);
	}
	return(queue_mapi_from(q,f,a,q->qhd_chain.qlk_next));
}

/*.
**********************************************************************

queue_bmapi -- map a function over a queue backwards (user terminating).

SYNOPSIS:

    #include "queue.h"

    char *queue_bmapi(q, f, a);
    QHD *q;
    char *(*f)();
    void *a;

DESCRIPTION:

Same as queue_mapi, except it goes through the que backwards (i.e. from
tail to head.

PARAMETERS;

    q -- points to the queue in question.
    f -- the function to be mapped.
    a -- an arbitrary pointer to be passed to the function.

RETURNS:

    queue_bmapi -- The first non-NULL value returned by f, or NULL if the
        beginning of the queue is reached without f ever returning a non-NULL.

SIDE EFFECTS:

    May vary according to the functions being called.

**********************************************************************
*/

void *queue_bmapi(q,f,a)

register    QHD *q;
register    char *(*f)();
register    void *a;

{
    register    QBF *n,*m;
    register    char *i;

    if ( q == NULL  ||  q->qhd_chk_value != QUE_CHK_VALUE )
    {
        MPaxError = ERRQUEINV;
        return(NULL);
    }
    n =  (QBF *) q->qhd_chain.qlk_prev ;
    if ( f == NULL ) return( n == (QBF *)q ? NULL : (char *) n);
    while (n  &&  n != (QBF *) q  &&  n->buf_curr_owner == (void *) q)
    {
        m = n;
        n = (QBF *) n->buf_link.qlk_prev;
		if((i = (*f)(q, queue_str_addr(m), a)) != NULL)
            return(i);
    }
    return(NULL);

}

/*.
**********************************************************************

queue_p -- insert a buffer in a queue

SYNOPSIS:

	#include "queue.h"

	void queue_p(q, b, l);
	QHD *q;
	QLK *b;
	QLK *l;

DESCRIPTION:

Link the QLK field pointed to by b in the chain before l in queue q.
This routine is called by queue_put and queue_put_prio.

PARAMETERS:

	q -- this is the queue to perform this function on.
	b -- this is a normally a pointer to a buffer to be queued.
	l -- this is a pointer to the place in the queue where the buffer 
		is to be placed.

RETURNS:

	*l -- is modified to contain a link to the buffer
	*(q->buf_link.qlk_prev) -- is modified to contain a link to 
		the buffer.
	*b -- is modified to contain links to q and *(q->buf_link.qlk_prev).

SIDE EFFECTS:

	none

**********************************************************************
*/

void queue_p(q, b, l)

register	QHD *q;
register	QBF *b;
register	QLK *l;

{
	register	int	empty;

	if ( q == NULL  || q->qhd_chk_value != QUE_CHK_VALUE ) 
	{
		MPaxError = ERRQUEINV;
		return;
	}
	
	if (!b)
	{
		MPaxError = ERRQUEPNB;
		return;
	}
	if ( q->qhd_nice && b->buf_owner != q && b->buf_owner != QUE_BUF_STATICALLY_OWNED )
	{
		MPaxError = ERRQUEINV;
		return;
	}
	empty = FALSE;
	if (queue_empty(q))
		empty = TRUE;
	b->buf_link.qlk_prev = l->qlk_prev;
	b->buf_curr_owner = (void *) q;
	((QLK *)l->qlk_prev)->qlk_next = (char *) b;
	l->qlk_prev = (char *) b;
	b->buf_link.qlk_next = (char *) l;
	q->qhd_onq++;
	if (empty && (q->qhd_start != NULL))
		(*(q->qhd_start))(q,q->qhd_start_arg);
}

/*.
***********************************************************************

queue_set_owner -- Look at the next buffer in a queue

SYNOPSIS:

	#include "queue.h"

	int queue_set_owner(b, p);
	QBF *b;
	void *p;

DESCRIPTION:

This routine sets the current owner for this buffer.

PARAMETERS:

	b -- This is a pointer to a buffer.
	p -- This is a pointer to the new owner of the buffer.

RETURNS:

	queue_set_owner -- return 0 if no errors, -1 otherwise.

**********************************************************************
*/

long queue_set_owner(b, p)

register	QBF *b;
register	void *p;

{
	if ( b == NULL )
	{
		MPaxError = ERRQUEPNB;
		return(-1);
	}
	if ( b->buf_link.qlk_next != NULL ||
		 b->buf_link.qlk_prev != NULL )
	{
		MPaxError = ERRPARM;
		return(-1);
	}
	b->buf_curr_owner = p;
	return(0);
}

/*.
***********************************************************************

queue_copy -- copy a queue to another queue

SYNOPSIS:

	#include "queue.h"

	int queue_copy(fq, src, dest)
	QBF *fq,
		*src,
		*dest;

DESCRIPTION:

This routine copies all the entries from the source queue to the destination
queue.  New entries for the destination queue are taken from the free
queue.

PARAMETERS:

	fq	-- This is a pointer to the free queue
	src	-- This is a pointer to the source queue
	dest -- This is a pointer to the destination queue;

RETURNS:

	queue_copy -- returns 0 if no errors, -1 otherwise.

**********************************************************************
*/

long queue_copy(fq, src, dest)
QHD	*fq,
	*src,
	*dest;
{
	QBF	*get_b,
		*put_b;

	if (!fq  ||  !src  ||  !dest)
	{
		MPaxError = ERRPARM;
		return(-1);
	}

	get_b = (QBF *)queue_look_head(src);
	put_b = NULL;
	while(get_b != NULL)
	{
		if((put_b  = (QBF *) queue_get(fq)) == NULL)
		{
			queue_purge(dest);
			return(-1);
		}

		if(get_b->buf_size > put_b->buf_size)
		{
			MPaxError = ERRQUEINV;
			queue_purge(dest);
			return(-1);
		}

		memcpy(((char *)put_b + sizeof(QBF)), ((char *)get_b + sizeof(QBF)),
			get_b->buf_size - sizeof(QBF));

		if(queue_put(dest, put_b) != 0)
		{
			queue_purge(dest);
			return(-1);
		}

		put_b = NULL;

		get_b = (QBF *) queue_look_next(src, get_b);
	}
	return(0);
}

/*.
***********************************************************************

queue_move -- move the buffers off one queue to the tail of another queue.

SYNOPSIS:

	#include "queue.h"

	int queue_move(src, dest)
	QBF *src,
		*dest;

DESCRIPTION:

This routine moves all the entries from the source queue to the destination
queue.

PARAMETERS:

	src	-- This is a pointer to the source queue
	dest -- This is a pointer to the destination queue;

RETURNS:

	queue_move -- returns 0 if no errors, -1 otherwise.

**********************************************************************
*/
long queue_move(src, dest)
QHD *src, *dest;
{
	register	QBF	*qbf;
	
	while (qbf = (QBF *) queue_get(src))
		queue_put(dest, qbf);
	return(0);


/*
	register	int	empty;

	if ( src == NULL   ||  src->qhd_chk_value  != QUE_CHK_VALUE  ||
		 dest == NULL  ||  dest->qhd_chk_value != QUE_CHK_VALUE)
	{
		MPaxError = ERRQUEINV;
		return(-1);
	}
	
	if (!queue_empty(src))
	{
		dest->qhd_onq += src->qhd_onq;
		src->qhd_onq = 0;
		empty = queue_empty(dest);
		((QLK *)dest->qhd_chain.qlk_prev)->qlk_next = (char *) src->qhd_chain.qlk_next;
		((QLK *)src->qhd_chain.qlk_next)->qlk_prev = (char *) dest->qhd_chain.qlk_prev;
		((QLK *)src->qhd_chain.qlk_prev)->qlk_next = (char *) dest;
		dest->qhd_chain.qlk_prev = src->qhd_chain.qlk_prev;
		src->qhd_chain.qlk_next = src->qhd_chain.qlk_prev = (char *) src;
		if (empty && (dest->qhd_start != NULL))
			(*(dest->qhd_start))(dest,dest->qhd_start_arg);
		if (queue_empty(src) && (src->qhd_end != NULL))
			(*(src->qhd_end))(src,src->qhd_end_arg);
	}
	return(0);
*/	
}

/*.
**********************************************************************

queue_dump -- dump the nice queue.

SYNOPSIS:

	#include "queue.h"

	void queue_dump(q, f);
	QHD *q;
	void *f();

DESCRIPTION:

Dump all buffer elements in the nice queue and call a user specified
function to allow them to display what they wish to see.

PARAMETERS:

	q -- is a pointer to the queue to be dumped.
	f -- is a function specified by the user to dump elements in the buffer.

RETURNS:

	none.

SIDE EFFECTS:

	Invokes the function specified by the user if it exists. Note that
	the user function has the synopsis:

		void my_dump_routine(q, p)
		QHD *q;
		MY_BUF_TYPE *p;

**********************************************************************
*/
void queue_dump(q, f)
QHD *q;
void (*f)();
{
	QBF *p;
	char *routine = "queue_dump";
	long i;

	log_debug2("%s: activated dump for QHD: %u", routine, q);
	if (!q)
	{
		log_debug1("%s: Queue is NULL ", routine);
		return;
	}
	log_debug1("\t# owned : %d", q->qhd_owned);
	log_debug1("\t# on que: %d", q->qhd_onq);
	log_debug1("\tbuf addr: %u", q->qhd_addr);
	log_debug1("\tbuf size: %u", q->qhd_buf_siz);

	if (!q  ||  !q->qhd_addr || !q->qhd_nice)
	{
		log_debug1("%s: Queue is not a nice queue -- aborting dump", routine);
		return;
	}

	/*
	 *	Dump all buffers in the nice queue.
	 */
	for (i = 0, p = (QBF *)q->qhd_addr ; i < q->qhd_owned;
		p = (QBF *) (((char *)p) + q->qhd_buf_siz), i++)
	{
		log_debug1("Buf QBF : %u", p);
		log_debug2("\tLinks : Prev = %u, Next = %u",
			p->buf_link.qlk_prev, p->buf_link.qlk_next);
		log_debug2("\tOwners: Buff = %u, Curr = %u",
			p->buf_owner, p->buf_curr_owner);
		log_debug1("\tRecsiz: %u", p->buf_size);
		if (f != NULL) (*f)(q, p);
	}
}

