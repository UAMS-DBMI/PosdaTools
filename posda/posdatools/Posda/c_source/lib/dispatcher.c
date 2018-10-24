#ifndef LINT

#endif
extern	char	libRelease[];
static	char	*LibRelease = libRelease;
/*.
***************************************************************

dispatcher.c -- Dispatcher subsystem module

DATA ABSTRACTION:

This module represents the dispatcher subsystem which monitors and controls
three list.  The select list is a list of devices to be served whenever 
they are ready to receive input or produce ouput.  The timer list is a list
of routines to be activated at a given time.  The default list is a list of
routines to be activated if there is nothing else to do. 

OPERATIONS:
	
	dispatcher_init	-- Initialize the dispatcher subsystem.
	dispatcher_loop	-- Wait for input and serve the input.
	
	dispatcher_add_sel_full -- Add a routine to the select list, read/write/except.

	dispatcher_add_sel	-- Add a routine to the select list, read/write.
	dispatcher_rmv_sel	-- Remove a routine from the select list.
	dispatcher_act_sel	-- Activate an entry on the select list.
	dispatcher_dct_sel	-- Deactivate an entry on the select list.
	
	dispatcher_add_sel_r	-- Add a read routine to the select list.
	dispatcher_rmv_sel_r	-- Remove a read routine from the select list.
	dispatcher_act_sel_r	-- Activate a read entry on the select list.
	dispatcher_dct_sel_r	-- Deactivate a read entry on the select list.
	
	dispatcher_add_sel_w	-- Add a write routine to the select list.
	dispatcher_rmv_sel_w	-- Remove a write routine from the select list.
	dispatcher_act_sel_w	-- Activate a write entry on the select list.
	dispatcher_dct_sel_w	-- Deactivate a write entry on the select list.
	
	dispatcher_add_sel_e	-- Add an exception routine to the select list.
	dispatcher_rmv_sel_e	-- Remove an exception routine from the select list.
	dispatcher_act_sel_e	-- Activate an exception entry on the select list.
	dispatcher_dct_sel_e	-- Deactivate an exception entry on the select list.

	dispatcher_add_tim	-- Add a routine to the timer list.
	dispatcher_rmv_tim	-- Remove a routine from the timer list.

	dispatcher_init_event		-- Initialize an event data structure.
	dispatcher_wait_event		-- Wait until the occurance of an event.
	dispatcher_rmv_event		-- Cancel waiting on an event.
	dispatcher_cancel_event	-- Cancel all processes waiting on current event.
	dispatcher_signal_event	-- Signal the occurance on an event.

    dispatcher_init_sig_handling -- initialize the entire dpt signal handling facility
	dispatcher_init_signal		-- Initialize an UNIX signal data structure.
	dispatcher_wait_signal		-- Handle the occurance of a signal.
	dispatcher_catch_signal	-- Start collecting a signal.
	dispatcher_act_signal		-- Also start handling a collected a signal.
	dispatcher_dct_signal		-- Cancel handling a collected a signal.
	dispatcher_drop_signal		-- Cancel collecting a signal.
	dispatcher_rmv_signal		-- Cancel waiting on a signal.
	dispatcher_cancel_signal	-- Cancel all processes waiting on current signal.
	dispatcher_signal_signal	-- Signal the occurance on an signal.
	
	dispatcher_add_def	-- Add a routine to the default list.
	dispatcher_rmv_def	-- Remove a routine from the default list.

	dispatcher_debug -- debug routine for dispatcher subsystem

LOCAL ROUTINES:

	dispatcher_tim_prio	-- determines the priority of two timer entries.
	dispatcher_check_for_timeout -- check if a routine has timed out, also compute
		the least timeout value (to be mapped over timer queue).
	dispatcher_find_routine -- find a routine entry (to be mapped over default
		queue or timer queue).
	dispatcher_execute_event -- Execute an event is mapped (queue_mapr) over the 
		queue of an event.  It executes the event routine with the event
		parm, and releases the event.

STATIC DATA:

	sel_list -- This is an array of up to 32 entries.  It is
		indexed by fd number.  Each element contains the following
		data:
			act_read -- indicates whether the device is active
				for read.
			act_write -- indicates whether the device is active
				for write.
			act_except -- indicates whether the device is active for exceptions
			reader -- a pointer to the reader routine.
			writer -- a pointer to the writer routine.
			except -- a pointer to the exception routine
	tim_list -- this is a queue of timers.  Each timer contains
		the following data:
			tim_timeout -- The time that this routine will timeout.
			tim_param -- a parameter to be supplied to the routine.
			tim_rout -- The routine to be called when the
				timer expires.
	def_queue -- this is a queue of default routines to be called
		in round robin order.  Each entry contains the following data:
			def_param -- a parameter to be supplied to the routine
			def_routine -- the routine to be called
	signal_array -- array of UNIX occurences/dpt handlings
	active_signal -- list of ACTIVE UNIX signals
			
***************************************************************
*/

/* Includes */
#include <values.h>
#include <sys/errno.h>
#include <ctype.h>
#include "global.h"
#include "errors.h"
#include "queue.h"
#include "dispatcher.h"
#include "log.h"

/* macros  */

#define timergtreq(t1,t2)						\
	( (t1).tv_sec  > (t2).tv_sec  ||			\
	  ( (t1).tv_sec  == (t2).tv_sec  &&			\
		(t1).tv_usec >= (t2).tv_usec     ) )
		
#define timergtr(t1,t2)							\
	( (t1).tv_sec  > (t2).tv_sec  ||			\
	  ( (t1).tv_sec  == (t2).tv_sec  &&			\
		(t1).tv_usec > (t2).tv_usec     ) )
		
#define timerclr(t)								\
	 (t).tv_sec = (t).tv_usec = 0

#define timercopy(t1,t2)						\
	{ (t1).tv_sec  = (t2).tv_sec;  (t1).tv_usec = (t2).tv_usec; }

#ifdef SYSV
#define	timerdelta(curr,timeout,delta)									\
	{	if ((timeout).tv_usec < (curr).tv_usec)							\
		{																\
			if ((timeout).tv_sec == 0)									\
				(timeout).tv_usec = 0;									\
			else														\
			{															\
				(timeout).tv_sec--;										\
				(timeout).tv_usec += 1000000;							\
			}															\
		}																\
		(delta).tv_sec  = ((timeout).tv_sec > (curr).tv_sec ? 			\
							(timeout).tv_sec  - (curr).tv_sec : 0);		\
		(delta).tv_usec = ((timeout).tv_usec > (curr).tv_usec ?			\
							(timeout).tv_usec - (curr).tv_usec : 0);	\
	}
#else
#define	timerdelta(curr,timeout,delta)							\
	{	if ((timeout).tv_usec < (curr).tv_usec)					\
		{														\
			(timeout).tv_sec--;									\
			(timeout).tv_usec += 1000000;						\
		}														\
		(delta).tv_sec  = (timeout).tv_sec  - (curr).tv_sec;	\
		(delta).tv_usec = (timeout).tv_usec - (curr).tv_usec;	\
		if ( (delta).tv_sec < 0 )								\
			timerclr(delta);									\
		else if ( (delta).tv_usec < 0 )							\
			(delta).tv_usec = 0;								\
	}

#endif

#define UPDATE_MAX(fd) if ((fd) >= max_fd) max_fd = (fd) + 1;

/*	external data */

extern int		errno;
extern short	MPaxError;
extern void 	*MPaxCurrRou;

/* Static data */

/* Select list*/
static int max_fd = 0;

static DPT_SEL_ENT sel_list[SEL_ENTRIES]
	= {
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0,
	0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0}
	;
static fd_set sel_read_mask;
static fd_set sel_write_mask;
static fd_set sel_except_mask;

static int dispatcher_alarm_flag;

typedef enum
{
	NOT_IN_DPT_CHK,
	PRE_SELECT,
	PROC_SELECT,
	PROC_TIMER,
	PROC_SIGNAL,
	PROC_EVENT,
	PROC_DEFAULT		/* removed comma after last et jrp */ 

} DPT_LOCATION;
#define LAST_DPT_LOCATION PROC_DEFAULT
static int dispatcher_location;
static char * dispatcher_loc_str[1 + LAST_DPT_LOCATION] =
{
	"outside dispatcher_chk()",
	"sitting in select()",
	"processing select routines",
	"processing timer routines",
	"processing signal routines",
	"processing event routines",
	"processing default routines",
};
static int dispatcher_index;

/* timer queues */
static QHD timer_q;
static struct timeval	current_time;
/* static struct timeval 	signal_timeout = {0, 250000}; */
	/* default 1/4 second */
static struct timeval 	signal_timeout = {3600, 0};
	/* default 1 hour */

static int expired;

/* Default queues */
static QHD default_q;
static QHD default_freeq;
static int *parm;
static QHD temp_q;
#ifdef SIGNAL_HANDLING
static QHD signal_freeq;
#endif
static void *search_param;

/* Event queue */
static QHD event_q;

#ifdef SIGNAL_HANDLING

#define NULL_SIGNAL -1

/* signal collection states */
#define UNINIT			0
#define NONE			1
#define COLLECTING		2
#define ACTIVE			3

/* Structure of a signal */
typedef struct dispatcher_signal
{
	QBF				qbf;
#ifdef ANSI_PROTO
	QUE_MAP_FUNC	r;
#else
	void			(*r)();
#endif
	void			*p;
	int			    signal;
} DPT_SIGNAL_ENT;

/* Signal array */
typedef struct {
	QHD             signal_q;           /* queue where signals routines lie when signal hndling is ACTIVE */
	void			(*debug)();			/* common signal debug routine */
	char    		state;				/* dpt state for signal */
	void			(*old_hndlr)();		/* old signal handler */
	int				sem;				/* signal occurence / handled "flag */
} SIGNAL_INFO;

#ifndef NSIG
#define NSIG	32
#endif
#define LAST_SIGNAL NSIG-1

SIGNAL_INFO signal_array[NSIG];
int active_signals[NSIG];
int num_active_signals = 0;

int signal_count = 0;
struct timeval dispatcher_std_signal_timeval = {3600, 0};

/* signal selection bitmask */
#ifdef SYSV
static ulong bits[] =
{
	0x0000000,
	0x0000001,
	0x0000002,
	0x0000004,
	0x0000008,
	0x0000010,
	0x0000020,
	0x0000040,
	0x0000080,
	0x0000100,
	0x0000200,
	0x0000400,
	0x0000800,
	0x0001000,
	0x0002000,
	0x0004000,
	0x0008000,
	0x0010000,
	0x0020000,
	0x0040000,
	0x0080000,
	0x0100000,
	0x0200000,
	0x0400000,
	0x0800000,
	0x1000000,
	0x2000000,
	0x4000000,
	0x8000000
};
#endif
#endif

#define IS_BSET(x, y) (((x) & bits[(y)]) != 0)
#define BSET(x, y) (x |= bits[(y)])

int	dispatcher_debug();

#ifndef SIGNAL_HANDLING
#endif

#ifdef SIGNAL_HANDLING
void dispatcher_signal_hndlr(s)
	int s;
{	
	char* fn = "dispatcher_signal_hndlr";
	
	MPaxCurrRou = (void *) dispatcher_signal_hndlr;
	if (signal_array[s].sem != MAXINT)
	{
		signal_array[s].sem++;
	}
		
	log_info3("%s: --> %d; sem: %d\n", fn, s, signal_array[s].sem);
	if (signal(s, dispatcher_signal_hndlr) == SIG_ERR)
	{
		MPaxError = errno;
		log_fatal2("%s: couldn't reregister sig hndlr for signal: %d", fn, s);
#ifndef SYSV
		sigblock(sigmask(s));
#endif
	}
	else
	{
		log_info2("%s: just reinstalled signal_hndlr for signal: %d", fn, s);
	}
} 
#endif


void dispatcher_sigalrm_hndlr(s)
    int s;
{
    FNC_ENTRY(dispatcher_sigalrm_hndlr);

    log_info1("%s: SIGALRM gen'ed by dpt caught", fn);
    dispatcher_alarm_flag = 1;
}


/*.
***************************************************************

dispatcher_init -- Initialize  routine for dispatcher subsystem

SYNOPSIS:
	
int dispatcher_init(t,d);
int t;
int d;

DESCRIPTION:

This routine is the initializiation routine for the dispatcher subsystem.
This routine must be called before any other routine of the dispatcher
subsystem are invoked.  This routine has the responsibilty of allocating
the active and free queues for the timer and default lists.

PARAMETERS:

	t -- This is the total number of timer routines that can be queued at
		one time.
	d -- This is the total number of default routines that can be queued at
		one time.

RETURNS:

	0 - if OK
	-1 - if initialization failed


SIDE EFFECTS:

	none.

***************************************************************
*/

int dispatcher_init(t, d)
register	int t;
register	int d;
{
	register	char *p;

	MPaxCurrRou = (void *) dispatcher_init;

	FD_ZERO(&sel_read_mask);
	FD_ZERO(&sel_write_mask);
	FD_ZERO(&sel_except_mask);

	queue_init( &default_freeq, NULL, NULL, NULL, NULL );
	queue_init( &default_q, NULL, NULL, NULL, NULL );
	queue_init( &timer_q, NULL, NULL, NULL, NULL );
	queue_init( &event_q, NULL, NULL, NULL, NULL );
	if ( (t+d) != 0 )
	{
		p = ( char * ) calloc( (t+d), sizeof( DPT_FREE_ENT ) );
		if ( p == NULL )
		{
			MPaxError = errno;
			log_fatal0("dispatcher_init: calloc of default free queue failed.");
			return( -1 );
		}
		queue_buf_init( &default_freeq, (t+d), sizeof(DPT_FREE_ENT), p);
	}

  /*
	if (pm_add_debug(dispatcher_debug,NULL) != 0)
	{
		log_fatal0("dispatcher_init: pm_add_debug failed");
		return(-1);
	}
  */

	return( 0 );
}

#ifdef SIGNAL_HANDLING
/*.
***************************************************************

dispatcher_init_sig_handling -- Initialize  routine for dispatcher
 							signal handling subsystem

SYNOPSIS:
	
int dispatcher_init_sig_handling(sighands,scan);
int 			sighands;
struct timeval 	*scan;

DESCRIPTION:

This routine is the initialization routine for the signal handling
portion of the dispatcher subsystem. This routine must be called
before any other routine of the dispatcher signal handling subsystem
are called.  This routine has the responsibilty of allocating the
the signal handler event free queue and the scan rate for handling
interrupts. Note that if scan == NULL, then the dispatcher (select)
defaults apply. This should be the norm as long as the host machine
supports wakeup of select for the handled interrupts (SGI is only
known offending maching thusfar). Note that this scan time will
be overriden if there exist one registered default or timer routine.

PARAMETERS:

	sighands -- The total number of signal handlers which can be
	    registered at one time.
	scan     -- pointer to interval of dispatcher check for collected
	    signals.

RETURNS:

	0 - if OK
	-1 - if initialization failed


SIDE EFFECTS:

	none.

NOTES:
	1. It is should be noted that the select() routine will be interrupted by
		the occurence of a signal. It this sense it reacts as though a driver
		select condition had been set. 

***************************************************************
*/

int dispatcher_init_sig_handling(sighands, scan)
register	int 			sighands;
register	struct timeval	*scan;
{
	char *p;
	int  i;
	char *fn = "dispatcher_init_sig_handling";

	MPaxCurrRou = (void *) dispatcher_init_sig_handling;

	queue_init(&signal_freeq, NULL, NULL, NULL, NULL);
	if (sighands > 0)
	{
		p = (char *) calloc(sighands, sizeof(DPT_SIGNAL_ENT));
		if ( p == NULL )
		{
			MPaxError = errno;
			log_fatal1("%s: calloc of default free queue failed.", fn);
			return( -1 );
		}
		queue_buf_init(&signal_freeq, sighands, sizeof(DPT_SIGNAL_ENT), p);
	}

	for (i=0; i < NSIG; i++)
	{
		signal_array[i].sem = 0;
		signal_array[i].state = UNINIT;
	} /* for */
	
	if (scan != NULL)
		signal_timeout = *scan;
	
	return( 0 );
}
#endif

/*.
***************************************************************

dispatcher_chk -- dispatcher routine check if any work needs to be done.

SYNOPSIS:

int dispatcher_chk();

DESCRIPTION:

This routine is called to check if any work need to be done.
This routine will poll the select list, and if any write device on
the select list is ready to receive data, it call the "writer" routine
specifed when the device was added to the select list.  If any read 
device has data available, it will call the "reader" routine specified
when the device was added to the select list.  If any exception device has
an exceptional condition pending, it will cal the "except" routine specified
when the device was added to the select list.  If a read device, a write
device, or an exception device is not available, then it calls the next
default routine if the default queue is non-empty.  If the default queue is
empty, then a timer is supplied to the select system call.  The wait interval
is derived from the time remaining until the next timer event.  Timer services 
provided are generally coarse, with a granularity provided in the tenths
of seconds.

Generally, devices are added to the select list at the time they are
opened.  Write devices are activated when there is data available to write
to them.  Read devices are activated when there is buffer space available
to read into from them. Exception devices are activated when there is an
exceptional condition pending.

The default routines are called in round robin fashion when none of the 
selectable devices are ready, and a timer routine is not timed out.  
Default routines generally will read and write disk files, which are 
not selectable.

PARAMETERS:

	none

RETURNS:

	none

SIDE EFFECTS:

When devices become ready, various routines will be called as specified
in add and activate operations, described below.


***************************************************************
*/

#ifdef SIGNAL_HANDLING
void dispatcher_execute_signal(q, b, sig_count)
QBF*			q;
DPT_SIGNAL_ENT	*b;
void			*sig_count;
{
	char*	fn = "dispatcher_execute_signal";
	void	(*r)() = b->r;
	
	MPaxCurrRou = (void *) dispatcher_execute_signal;
	if (r == NULL)
	{
		log_abnormal3("%s: null fnc in signal_q, 0x%lx; for sig: %d", fn, q, b->signal);
		MPaxError = ERRPARM;
		return;
	}
	else
	{
		MPaxCurrRou = (void *) r;
		(*r)(b->p, b->signal, *(int *)sig_count);
	}
}
#endif

int dispatcher_chk()
{
	register	DPT_DEF_ENT		*d;
#ifdef SIGNAL_HANDLING
	register	int				s;
	register	QHD				*q;
#endif


	register	long			 i, j, n, m;
	register	DPT_TIM_ENT		*t;
				fd_set			 r, w, e;
				struct timeval	 timeout, timer;
				int				sig_count;


	FNC_ENTRY(dispatcher_chk);
	
	if (!queue_empty(&default_q) || !queue_empty(&event_q) )
			timerclr(timeout);
	else if ((t = (DPT_TIM_ENT *) queue_mapi(&timer_q, NULL, NULL)) )
	{
		gettimeofday(&current_time,NULL);
		timer = t->timeout;
		timerdelta(current_time,timer,timeout);
	}
	else
	{
#ifdef SIGNAL_HANDLING
		if (num_active_signals > 0)
			timeout = signal_timeout;
		else
		{
			timeout.tv_sec  = DPT_MAX_TIME_SEC;
			timeout.tv_usec = DPT_MAX_TIME_USEC;
		}
#else
		timeout.tv_sec  = DPT_MAX_TIME_SEC;
		timeout.tv_usec = DPT_MAX_TIME_USEC;

#endif
	}

	if (timeout.tv_sec < 0)
	{	
		timeout.tv_sec = 0;
		timeout.tv_usec = 0;
	}
	else if (timeout.tv_usec < 0)
	{	
		timeout.tv_sec = 0;
		timeout.tv_usec = 0;
	}

	r = sel_read_mask;
	w = sel_write_mask;
	e = sel_except_mask;
/*
	log_abnormal2(
		"dispatcher_chk: timeout: {%d,%d}", timeout.tv_sec, timeout.tv_usec);
*/

#ifdef SIGNAL_HANDLING
	/* install our alarm handler */
	s = SIGALRM;
    if (signal(s, dispatcher_sigalrm_hndlr) == SIG_ERR)
    {
		MPaxError = errno;
        log_fatal1("%s: couldn't reregister dispatcher_sigalrm_hndlr", fn);
        pm_abort();
    }
	alarm(timeout.tv_sec + 15);
	dispatcher_alarm_flag = 0;
#endif

	dispatcher_location = PRE_SELECT;
	dispatcher_index = -1;
	n = select( (long) max_fd,&r,&w,&e,&timeout);
	dispatcher_location = PROC_SELECT;

	alarm(0);
#ifdef SIGNAL_HANDLING
	if (dispatcher_alarm_flag)
	{
		/* oops alarm() trapped out the select...this shouldn't have happened */
		log_internal2(
			"%s: oops alarm(%d) trapped out select()...this shouldn't have happened...contact  engineering", fn, DPT_MAX_TIME_SEC + 15);
		pm_debug();
		save_log();
	}
#endif
	if ( n > 0 )
	{
		for (i = 0, m = 0, j = 0 ; i < max_fd && j < n ; i++ , m++)
		{
			dispatcher_index = m;
			if ((FD_ISSET(m, &e) & FD_ISSET(m, &sel_except_mask)) != 0)
			{
				MPaxCurrRou = (void *) sel_list[i].se_except;
				log_info3("%s: fd: %d; except fn: 0x%lx", fn, i, sel_list[i].se_except);
				(*sel_list[i].se_except)(i,sel_list[i].se_except_param);
				j++;
			}
			if ((FD_ISSET(m, &r) & FD_ISSET(m, &sel_read_mask)) != 0)
			{
				MPaxCurrRou = (void *) sel_list[i].se_reader;
				log_info3("%s: fd: %d; reader fn: 0x%lx", fn, i, sel_list[i].se_reader);
				(*sel_list[i].se_reader)(i,sel_list[i].se_read_param);
				j++;
			}
			if ((FD_ISSET(m, &w) & FD_ISSET(m, &sel_write_mask)) != 0)
			{
				MPaxCurrRou = (void *) sel_list[i].se_writer;
				log_info3("%s: fd: %d; writer fn: 0x%lx", fn, i, sel_list[i].se_writer);
				(*sel_list[i].se_writer)(i,sel_list[i].se_write_param);
				j++;
			}
		}
	}
	dispatcher_index = -1;

	if ( n == -1  &&  errno != EINTR && (! dispatcher_alarm_flag))
		return(-1);

	expired = 0;
	if (!queue_empty(&timer_q))
	{
		gettimeofday(&current_time,NULL);
		dispatcher_location = PROC_TIMER;
		queue_mapi(&timer_q,(void *)dispatcher_check_for_timeout,NULL);
	}
	
#ifdef SIGNAL_HANDLING

	for (i=0; i<num_active_signals; i++)
	{
		dispatcher_index = i;
		s = active_signals[i];
		if (signal_array[s].sem == 0)
		{
			continue;
		}
		if (signal_array[s].sem > 1)
			log_debug3("%s: signal %d; sem %d", fn, s, signal_array[s].sem);		

		q = (QHD *)&signal_array[s].signal_q;
		
		if (! queue_empty(q))
		{
			sig_count = signal_array[s].sem;
			signal_array[s].sem -= sig_count;
		  	/* since signal handler running async, this could actually be > 0...and this is perfectly okay */
		}
		else
		{
			sig_count = 0;
		}

		dispatcher_location = PROC_SIGNAL;
#ifdef ANSI_PROTO
		 queue_map(q, (QUE_MAP_FUNC) dispatcher_execute_signal, &sig_count);
#else
		 queue_map(q, dispatcher_execute_signal, &sig_count);
#endif
	} /* loop */

#endif

	if(!queue_empty(&event_q))
	{
		dispatcher_location = PROC_EVENT;
#ifdef ANSI_PROTO
		queue_mapr(&event_q, (QUE_MAPR_FUNC) dispatcher_execute_event);
#else
		queue_mapr(&event_q, dispatcher_execute_event);
#endif
	}

	if (expired == 0  &&
			n == 0 && 
				(d = (DPT_DEF_ENT *)queue_get(&default_q)) != NULL)
	{
		queue_put(&default_q, &d->de_head);
		dispatcher_location = PROC_DEFAULT;
		MPaxCurrRou = (void *) d->de_r;
		log_info1("dispatcher_chk: default fn: 0x%lx", d->de_r);
		(*(d->de_r))(d->de_p);
	}

	dispatcher_location = NOT_IN_DPT_CHK;
	return(0);
}

/*.
***************************************************************

dispatcher_loop -- dispatcher main loop

SYNOPSIS:

void dispatcher_loop();
int time;

DESCRIPTION:

This routine is the main loop of the subsystem process.  It is called
after initialization, and exits only when the subsystem is to be shutdown.
This routine will call the dispatcher_chk routine to check if any work needs to 
be done (select true, timeout, default routines) in a 'forever' loop.

PARAMETERS:

	none

RETURNS:

	none

SIDE EFFECTS:


***************************************************************
*/

void dispatcher_loop()
{
	MPaxCurrRou = (void *) dispatcher_loop;
	while (dispatcher_chk() == 0 );
	log_internal1("dispatcher_loop: error %d on select",errno);
}

/*.
***************************************************************

dispatcher_add_sel_full -- Add a device to the select list, read/write/except

SYNOPSIS:

#include "dispatcher.h"

int dispatcher_add_sel_full(f, r,r_p, w,w_p, e,e_p);
int f;
void (*r)();
void *r_p;
void (*w)();
void *w_p;
void (*e)();
void *e_p;

DESCRIPTION:

Adds the device specified by f to the select list.  This device
should already be OPEN (although dispatcher_add will not check this fact).

PARAMETERS:

	f -- This is the file descriptor of the device to be added
		to the select list.  This determines the bit which
		will be set in the actual select system call.
	r -- This is a pointer to a routine to be called whenever
		the device is ready to read.  This routine will be called
		only after the device is activated for read with an 
		dispatcher_act operation.
	r_p -- This is a pointer to an unknown argument which is to be
	 	passed to the routine to be called.
	w -- This is a pointer to a routine to be called whenever
		the device is ready to write.  This routine will be called
		only after the device is activated for write with an
		dispatcher_act operation.
	w_p -- This is a pointer to an unknown argument which is to be
	 	passed to the routine to be called.
	e -- This is a pointer to a routine to be called whenever
		the device has received an exception.  This routine will be called
		only after the device is activated for exceptions with a
		dispatcher_act operation.
	e_p -- This is a pointer to an unknown argument which is to be passed
		to the routine to be called.
		

RETURNS:

	0 - if OK
	-1 - if f invalid

SIDE EFFECTS:

	none


***************************************************************
*/

int dispatcher_add_sel_full(f, r,r_p, w,w_p, e,e_p)
register	int f;
register	void (*r)();
register	void *r_p;
register	void (*w)();
register	void *w_p;
register	void (*e)();
register	void *e_p;
{

	FNC_ENTRY(dispatcher_add_sel_full);
	log_info2("%s: fd: %d", fn, f);
	if (!r && !w && !e)
	{
		MPaxError = ERRPARM;
		return(-1);
	}
	if (f < 0  ||  f >= SEL_ENTRIES)
	{
		MPaxError = ERRPARM;
		log_internal1("dispatcher_add_sel: Invalid file desc: %d.", f);
		return( -1 );
	}
	UPDATE_MAX(f);

	sel_list[f].se_reader = r;
	sel_list[f].se_read_param = r_p;
	sel_list[f].se_writer = w;
	sel_list[f].se_write_param = w_p;
	sel_list[f].se_except = e;
	sel_list[f].se_except_param = e_p;
	return(0);
}

/*.
***************************************************************

dispatcher_add_sel -- Add a device to the select list, read/write

SYNOPSIS:

#include "dispatcher.h"

int dispatcher_add_sel(f, r,r_p, w,w_p);
int f;
void (*r)();
void *r_p;
void (*w)();
void *w_p;

DESCRIPTION:

Adds the device specified by f to the select list.  This device
should already be OPEN (although dispatcher_add will not check this fact).

PARAMETERS:

	f -- This is the file descriptor of the device to be added
		to the select list.  This determines the bit which
		will be set in the actual select system call.
	r -- This is a pointer to a routine to be called whenever
		the device is ready to read.  This routine will be called
		only after the device is activated for read with an 
		dispatcher_act operation.
	r_p -- This is a pointer to an unknown argument which is to be
	 	passed to the routine to be called.
	w -- This is a pointer to a routine to be called whenever
		the device is ready to write.  This routine will be called
		only after the device is activated for write with an
		dispatcher_act operation.
	w_p -- This is a pointer to an unknown argument which is to be
	 	passed to the routine to be called.
		

RETURNS:

	0 - if OK
	-1 - if f invalid

SIDE EFFECTS:

	none


***************************************************************
*/

int dispatcher_add_sel(f, r,r_p, w,w_p)
register	int f;
register	void (*r)();
register	void *r_p;
register	void (*w)();
register	void *w_p;
{

	FNC_ENTRY(dispatcher_add_sel);
	log_info2("%s: fd: %d", fn, f);

	if (!r && !w)
	{
		MPaxError = ERRPARM;
		return(-1);
	}
	if (f < 0  ||  f >= SEL_ENTRIES)
	{
		MPaxError = ERRPARM;
		log_internal1("dispatcher_add_sel: Invalid file desc: %d.", f);
		return( -1 );
	}
	UPDATE_MAX(f);

	sel_list[f].se_reader = r;
	sel_list[f].se_read_param = r_p;
	sel_list[f].se_writer = w;
	sel_list[f].se_write_param = w_p;
	return(0);
}

/*.
***************************************************************

dispatcher_rmv_sel -- Remove a device from the select list.

SYNOPSIS:

#include "dispatcher.h"

int dispatcher_rmv_sel(fd);
int fd;

DESCRIPTION:

This routine removes a device from the select list.  The only action
taken is to NULL out the reader and writer slots in the array.  It is
not necessary, but is provided as a protection against accidentally
activating a non-open device.

PARAMETERS:

	fd -- This is the file descriptor of the device to be removed.

RETURNS:

	0 - if OK
	-1 - if f invalid

SIDE EFFECTS:

	none

***************************************************************
*/

int dispatcher_rmv_sel(f)
register	int f;
{
	if (f < 0  ||  f >= SEL_ENTRIES)
	{
		MPaxError = ERRPARM;
		log_internal1("dispatcher_rmv_sel: Invalid file desc: %d.", f);
		return( -1 );
	}
	FD_CLR(f, &sel_read_mask);
	FD_CLR(f, &sel_write_mask);
	FD_CLR(f, &sel_except_mask);
	sel_list[f].se_reader = NULL;
	sel_list[f].se_writer = NULL;
	sel_list[f].se_except = NULL;
	return(0);
}

/*.
***************************************************************

dispatcher_act_sel -- Activate an entry on the select list.

SYNOPSIS:

#include "dispatcher.h"

void dispatcher_act_sel(f);
int f;

DESCRIPTION:

The entry in the select list specifed by f is activated for read or
write as specifed by whether it has a reader or writer added.

PARAMETERS:

	f -- This specifes the device to be activated.

RETURNS:

	0 - if OK
	-1 - if f invalid

SIDE EFFECTS:

	none

***************************************************************
*/

int dispatcher_act_sel(f)
register	int f;
{
	if (f < 0  ||  f >= SEL_ENTRIES)
	{
		MPaxError = ERRPARM;
		log_internal1("dispatcher_act_sel: Invalid file desc: %d.", f);
		return( -1 );
	}
	if (sel_list[f].se_reader != NULL)
		FD_SET(f, &sel_read_mask);
	if (sel_list[f].se_writer != NULL)
		FD_SET(f, &sel_write_mask);
	if (sel_list[f].se_except != NULL)
		FD_SET(f, &sel_except_mask);
	return(0);
}

/*.
***************************************************************

dispatcher_dct_sel -- Deactivate an entry on the select list.

SYNOPSIS:

#include "dispatcher.h"

void dispatcher_dct_sel(f);
int f;

DESCRIPTION:

This routine deactivates the device specified by f.

PARAMETERS:

	f -- specifies the device to be deactivated.

RETURNS:

	0 - if OK
	-1 - if f invalid

SIDE EFFECTS:

	none

***************************************************************
*/

int dispatcher_dct_sel(f)
register	int f;
{
	if (f < 0  ||  f >= SEL_ENTRIES)
	{
		MPaxError = ERRPARM;
		log_internal1("dispatcher_dct_sel: Invalid file desc: %d.", f);
		return( -1 );
	}
	FD_CLR(f, &sel_read_mask);
	FD_CLR(f, &sel_write_mask);
	FD_CLR(f, &sel_except_mask);
	return(0);
}

/*.
***************************************************************

dispatcher_add_sel_r -- Add a read device to the select list

SYNOPSIS:

#include "dispatcher.h"

int dispatcher_add_sel_r(f, r,r_p);
int f;
void (*r)();
void *r_p;

DESCRIPTION:

Adds the read device specified by f to the select list.  This device
should already be OPEN (although dispatcher_add will not check this fact).

PARAMETERS:

	f -- This is the file descriptor of the device to be added
		to the select list.  This determines the bit which
		will be set in the actual select system call.
	r -- This is a pointer to a routine to be called whenever
		the device is ready to read.  This routine will be called
		only after the device is activated for read with an 
		dispatcher_act operation.
	r_p -- This is a pointer to an unknown argument which is to be
	 	passed to the routine to be called.
		

RETURNS:

	0 - if OK
	-1 - if f invalid

SIDE EFFECTS:

	none


***************************************************************
*/

int dispatcher_add_sel_r(f, r,r_p)
register	int f;
register	void (*r)();
register	void *r_p;
{

	FNC_ENTRY(dispatcher_add_sel_r);
	log_info2("%s: fd: %d", fn, f);
	if (!r)
	{
		MPaxError = ERRPARM;
		return(-1);
	}
	if (f < 0  ||  f >= SEL_ENTRIES)
	{
		MPaxError = ERRPARM;
		log_internal1("dispatcher_add_sel_r: Invalid file desc: %d.", f);
		return( -1 );
	}
	UPDATE_MAX(f);

	sel_list[f].se_reader = r;
	sel_list[f].se_read_param = r_p;
	return(0);
}

/*.
***************************************************************

dispatcher_rmv_sel_r -- Remove a read device from the select list.

SYNOPSIS:

#include "dispatcher.h"

int dispatcher_rmv_sel_r(fd);
int fd;

DESCRIPTION:

This routine removes a read device from the select list.  The only action
taken is to NULL out the reader slots in the array.  It is
not necessary, but is provided as a protection against accidentally
activating a non-open device.

PARAMETERS:

	fd -- This is the file descriptor of the device to be removed.

RETURNS:

	0 - if OK
	-1 - if f invalid

SIDE EFFECTS:

	none

***************************************************************
*/

int dispatcher_rmv_sel_r(f)
register	int f;
{
	if (f < 0  ||  f >= SEL_ENTRIES)
	{
		MPaxError = ERRPARM;
		log_internal1("dispatcher_rmv_sel_r: Invalid file desc: %d.", f);
		return( -1 );
	}
	FD_CLR(f, &sel_read_mask);
	sel_list[f].se_reader = NULL;
	return(0);
}

/*.
***************************************************************

dispatcher_act_sel_r -- Activate a read entry on the select list.

SYNOPSIS:

#include "dispatcher.h"

void dispatcher_act_sel_r(f);
int f;

DESCRIPTION:

The entry in the select list specifed by f is activated for read.
PARAMETERS:

	f -- This specifes the device to be activated.

RETURNS:

	0 - if OK
	-1 - if f invalid

SIDE EFFECTS:

	none

***************************************************************
*/

int dispatcher_act_sel_r(f)
register	int f;
{
	if (f < 0  ||  f >= SEL_ENTRIES)
	{
		MPaxError = ERRPARM;
		log_internal1("dispatcher_act_sel_r: Invalid file desc: %d.", f);
		return( -1 );
	}
	if (sel_list[f].se_reader != NULL)
		FD_SET(f, &sel_read_mask);
	return(0);
}

/*.
***************************************************************

dispatcher_dct_sel_r -- Deactivate a read entry on the select list.

SYNOPSIS:

#include "dispatcher.h"

void dispatcher_dct_sel_r(f);
int f;

DESCRIPTION:

This routine deactivates the read device specified by f.

PARAMETERS:

	f -- specifies the device to be deactivated.

RETURNS:

	0 - if OK
	-1 - if f invalid

SIDE EFFECTS:

	none

***************************************************************
*/

int dispatcher_dct_sel_r(f)
register	int f;
{
	if (f < 0  ||  f >= SEL_ENTRIES)
	{
		MPaxError = ERRPARM;
		log_internal1("dispatcher_dct_sel_r: Invalid file desc: %d.", f);
		return( -1 );
	}
	FD_CLR(f, &sel_read_mask);
	return(0);
}

/*.
***************************************************************

dispatcher_add_sel_w -- Add a write device to the select list

SYNOPSIS:

#include "dispatcher.h"

int dispatcher_add_sel(f,w,w_p);
int f;
void (*w)();
void *w_p;

DESCRIPTION:

Adds the write device specified by f to the select list.  This device
should already be OPEN (although dispatcher_add will not check this fact).

PARAMETERS:

	f -- This is the file descriptor of the device to be added
		to the select list.  This determines the bit which
		will be set in the actual select system call.
	w -- This is a pointer to a routine to be called whenever
		the device is ready to write.  This routine will be called
		only after the device is activated for write with an
		dispatcher_act operation.
	w_p -- This is a pointer to an unknown argument which is to be
	 	passed to the routine to be called.
		

RETURNS:

	0 - if OK
	-1 - if f invalid

SIDE EFFECTS:

	none


***************************************************************
*/

int dispatcher_add_sel_w(f, w,w_p)
register	int f;
register	void (*w)();
register	void *w_p;
{

	FNC_ENTRY(dispatcher_add_sel_w);
	log_info2("%s: fd: %d", fn, f);
	if (!w)
	{
		MPaxError = ERRPARM;
		return(-1);
	}
	if (f < 0  ||  f >= SEL_ENTRIES)
	{
		MPaxError = ERRPARM;
		log_internal1("dispatcher_add_sel_w: Invalid file desc: %d.", f);
		return( -1 );
	}
	UPDATE_MAX(f);

	sel_list[f].se_writer = w;
	sel_list[f].se_write_param = w_p;
	return(0);
}

/*.
***************************************************************

dispatcher_rmv_sel_w -- Remove a write device from the select list.

SYNOPSIS:

#include "dispatcher.h"

int dispatcher_rmv_sel_w(fd);
int fd;

DESCRIPTION:

This routine removes a write device from the select list.  The only action
taken is to NULL out the writer slots in the array.  It is
not necessary, but is provided as a protection against accidentally
activating a non-open device.

PARAMETERS:

	fd -- This is the file descriptor of the device to be removed.

RETURNS:

	0 - if OK
	-1 - if f invalid

SIDE EFFECTS:

	none

***************************************************************
*/

int dispatcher_rmv_sel_w(f)
register	int f;
{
	if (f < 0  ||  f >= SEL_ENTRIES)
	{
		MPaxError = ERRPARM;
		log_internal1("dispatcher_rmv_sel_w: Invalid file desc: %d.", f);
		return( -1 );
	}
	FD_CLR(f, &sel_write_mask);
	sel_list[f].se_writer = NULL;
	return(0);
}

/*.
***************************************************************

dispatcher_act_sel_w -- Activate a write entry on the select list.

SYNOPSIS:

#include "dispatcher.h"

void dispatcher_act_sel_w(f);
int f;

DESCRIPTION:

The entry in the select list specifed by f is activated for write.

PARAMETERS:

	f -- This specifes the device to be activated.

RETURNS:

	0 - if OK
	-1 - if f invalid

SIDE EFFECTS:

	none

***************************************************************
*/

int dispatcher_act_sel_w(f)
register	int f;
{
	if (f < 0  ||  f >= SEL_ENTRIES)
	{
		MPaxError = ERRPARM;
		log_internal1("dispatcher_act_sel_w: Invalid file desc: %d.", f);
		return( -1 );
	}
	if (sel_list[f].se_writer != NULL)
		FD_SET(f, &sel_write_mask);
	return(0);
}

/*.
***************************************************************

dispatcher_dct_sel_w -- Deactivate a write entry on the select list.

SYNOPSIS:

#include "dispatcher.h"

void dispatcher_dct_sel_w(f);
int f;

DESCRIPTION:

This routine deactivates the write device specified by f.

PARAMETERS:

	f -- specifies the device to be deactivated.

RETURNS:

	0 - if OK
	-1 - if f invalid

SIDE EFFECTS:

	none

***************************************************************
*/

int dispatcher_dct_sel_w(f)
register	int f;
{
	if (f < 0  ||  f >= SEL_ENTRIES)
	{
		MPaxError = ERRPARM;
		log_internal1("dispatcher_dct_sel_w: Invalid file desc: %d.", f);
		return( -1 );
	}
	FD_CLR(f, &sel_write_mask);
	return(0);
}

/*.
***************************************************************

dispatcher_add_sel_e -- Add an exception device to the select list

SYNOPSIS:

#include "dispatcher.h"

int dispatcher_add_sel_e(f, e,e_p);
int f;
void (*e)();
void *e_p;

DESCRIPTION:

Adds the except device specified by f to the select list.  This device
should already be OPEN (although dispatcher_add will not check this fact).

PARAMETERS:

	f -- This is the file descriptor of the device to be added
		to the select list.  This determines the bit which
		will be set in the actual select system call.
	e -- This is a pointer to a routine to be called whenever
		the device is ready for exceptions.  This routine will be called
		only after the device is activated for except with an 
		dispatcher_act operation.
	e_p -- This is a pointer to an unknown argument which is to be
	 	passed to the routine to be called.
		

RETURNS:

	0 - if OK
	-1 - if f invalid

SIDE EFFECTS:

	none


***************************************************************
*/

int dispatcher_add_sel_e(f, e,e_p)
register	int f;
register	void (*e)();
register	void *e_p;
{

	FNC_ENTRY(dispatcher_add_sel_e);
	log_info2("%s: fd: %d", fn, f);
	if (!e)
	{
		MPaxError = ERRPARM;
		return(-1);
	}
	if (f < 0  ||  f >= SEL_ENTRIES)
	{
		MPaxError = ERRPARM;
		log_internal1("dispatcher_add_sel_e: Invalid file desc: %d.", f);
		return( -1 );
	}
	UPDATE_MAX(f);

	sel_list[f].se_except = e;
	sel_list[f].se_except_param = e_p;
	return(0);
}

/*.
***************************************************************

dispatcher_rmv_sel_e -- Remove a exception device from the select list.

SYNOPSIS:

#include "dispatcher.h"

int dispatcher_rmv_sel_e(fd);
int fd;

DESCRIPTION:

This routine removes an exception device from the select list.  The only action
taken is to NULL out the exception slots in the array.  It is
not necessary, but is provided as a protection against accidentally
activating a non-open device.

PARAMETERS:

	fd -- This is the file descriptor of the device to be removed.

RETURNS:

	0 - if OK
	-1 - if f invalid

SIDE EFFECTS:

	none

***************************************************************
*/

int dispatcher_rmv_sel_e(f)
register	int f;
{
	if (f < 0  ||  f >= SEL_ENTRIES)
	{
		MPaxError = ERRPARM;
		log_internal1("dispatcher_rmv_sel_e: Invalid file desc: %d.", f);
		return( -1 );
	}
	FD_CLR(f, &sel_except_mask);
	sel_list[f].se_except = NULL;
	return(0);
}

/*.
***************************************************************

dispatcher_act_sel_e -- Activate a exception entry on the select list.

SYNOPSIS:

#include "dispatcher.h"

void dispatcher_act_sel_e(f);
int f;

DESCRIPTION:

The entry in the select list specifed by f is activated for exception.

PARAMETERS:

	f -- This specifes the device to be activated.

RETURNS:

	0 - if OK
	-1 - if f invalid

SIDE EFFECTS:

	none

***************************************************************
*/

int dispatcher_act_sel_e(f)
register	int f;
{
	if (f < 0  ||  f >= SEL_ENTRIES)
	{
		MPaxError = ERRPARM;
		log_internal1("dispatcher_act_sel_e: Invalid file desc: %d.", f);
		return( -1 );
	}
	if (sel_list[f].se_except != NULL)
		FD_SET(f, &sel_except_mask);
	return(0);
}

/*.
***************************************************************

dispatcher_dct_sel_e -- Deactivate a exception entry on the select list.

SYNOPSIS:

#include "dispatcher.h"

void dispatcher_dct_sel_e(f);
int f;

DESCRIPTION:

This routine deactivates the except device specified by f.

PARAMETERS:

	f -- specifies the device to be deactivated.

RETURNS:

	0 - if OK
	-1 - if f invalid

SIDE EFFECTS:

	none

***************************************************************
*/

int dispatcher_dct_sel_e(f)
register	int f;
{
	if (f < 0  ||  f >= SEL_ENTRIES)
	{
		MPaxError = ERRPARM;
		log_internal1("dispatcher_dct_sel_e: Invalid file desc: %d.", f);
		return( -1 );
	}
	FD_CLR(f, &sel_except_mask);
	return(0);
}

/*.
***************************************************************

dispatcher_add_tim -- add a routine to the timer list

SYNOPSIS:

#include "dispatcher.h"

void *dispatcher_add_tim(r,p,t);
void			(*r)();
void			*p;
struct timeval	t;

DESCRIPTION:

This will cause the routine pointed to by r to be called after
't' time has elapsed unless the timer is stopped by a dispatcher_rmv_tim 
system call specifying the same r.  If a timer with the same r and 
p has already been started, then it is overridden.

PARAMETERS:

	t -- this specifies the time to wait.
	r -- this is a pointer to a routine to be called after the time
		has elapsed.
	p -- This is a pointer to an unknown parameter to be supplied to the
		routine when called.


RETURNS:

	dispatcher_add_tim -- returns a pointer to the timer queue element, or
		NULL it there was no free buffer available

SIDE EFFECTS:

	updates the timer queue

***************************************************************
*/

void *dispatcher_add_tim(r, p, t)
register	void			(*r)();
register	void			*p;
register	struct timeval	*t;
{
	register	DPT_TIM_ENT		*e;
	register	char			*fn = "dispatcher_add_tim";

	if ( !r || t->tv_sec < 0  ||  t->tv_usec < 0 )
	{
		MPaxError = ERRPARM;
		log_internal4("%s: Invalid parms: fnc 0x%x, time %ld.%ld",
					fn, r, t->tv_sec, t->tv_usec);
		return (NULL);
	}
	search_param = p;
	if ((e = (DPT_TIM_ENT *) queue_mapi(&timer_q,(void *)dispatcher_find_routine,r)) != NULL)
		queue_remq(&timer_q, &e->te_head.de_head);
	else if ((e = (DPT_TIM_ENT *) queue_get(&default_freeq)) == NULL)
	{
		MPaxError = ERRQUEFUL;
		log_abnormal1("%s: Default timer queue empty", fn);
		return(NULL);
	}
	e->te_head.de_r = r;
	e->te_head.de_p = p;

	gettimeofday(&(e->timeout),NULL);
	e->timeout.tv_sec  += t->tv_sec;
	e->timeout.tv_usec += t->tv_usec;
	while ( e->timeout.tv_usec >= 1000000 )
	{
		e->timeout.tv_sec++;
		e->timeout.tv_usec -= 1000000;
	}
	
	if ( queue_put_prio(&timer_q, &e->te_head.de_head, dispatcher_tim_prio) != 0)
	{
		log_internal1("%s: Put to timer queue failed", fn);
		return(NULL);
	}
	return((void *) e);
}

/*.
***************************************************************

dispatcher_add_utim -- add a routine to the timer list

SYNOPSIS:

#include "dispatcher.h"

void *dispatcher_add_utim(r,p,t,u)
void			(*r)();
void			*p;
struct timeval	t;
DPT_TIM_ENT		*u;

DESCRIPTION:

This will cause the routine pointed to by r to be called after
't' time has elapsed unless the timer is stopped by a dispatcher_rmv_tim 
system call specifying the same r.  If a timer with the same r and 
p has already been started, then it is overridden.

PARAMETERS:

	t -- this specifies the time to wait.
	r -- this is a pointer to a routine to be called after the time
		has elapsed.
	p -- This is a pointer to an unknown parameter to be supplied to the
		routine when called.
	u -- This is a pointer to a DPT_TIM_ENT to be supplied by the
		caller (instead of using the default_freeq)


RETURNS:

	dispatcher_add_utim -- returns a pointer to the timer queue element, or
		NULL it there was no free buffer available

SIDE EFFECTS:

	updates the timer queue

***************************************************************
*/

void *dispatcher_add_utim(r, p, t, u)
register	void			(*r)();
register	void			*p;
register	struct timeval	*t;
DPT_TIM_ENT		*u;
{
	register	DPT_TIM_ENT		*e;
	register	char			*fn = "dispatcher_add_utim";

	if ( !u || !r || t->tv_sec < 0  ||  t->tv_usec < 0 )
	{
		MPaxError = ERRPARM;
		log_internal5("%s: Invalid parms: fnc 0x%x, ent 0x%x, time %ld.%ld",
					fn, r, u, t->tv_sec, t->tv_usec);
		return (NULL);
	}

	search_param = p;
	if (e = (DPT_TIM_ENT *)queue_mapi(&timer_q,dispatcher_find_routine,r))
	{
		queue_remq(&timer_q, &e->te_head.de_head);
		queue_rel(&e->te_head.de_head);
	}

	(e = u)->te_head.de_r = r;
	e->te_head.de_p = p;

	gettimeofday(&(e->timeout),NULL);
	e->timeout.tv_sec  += t->tv_sec;
	e->timeout.tv_usec += t->tv_usec;
	while ( e->timeout.tv_usec >= 1000000 )
	{
		e->timeout.tv_sec++;
		e->timeout.tv_usec -= 1000000;
	}
	
	if (queue_put_prio(&timer_q, &e->te_head.de_head, dispatcher_tim_prio))
	{
		log_internal1("%s: Put to timer queue failed", fn);
		return (NULL);
	}
	return((void *) e);
}

/*.
***************************************************************

dispatcher_rmv_tim -- Stop a timer

SYNOPSIS:

#include "dispatcher.h"

void dispatcher_rmv_tim(r,p);
void (*r)();
void *p;

DESCRIPTION:

This stops the timer associated with the function r.

PARAMETERS:

	r -- this specifies the routine for which a timer exists.
	p -- This is a pointer to an unknown parameter to be supplied to the
		routine when called.

RETURNS:

	none
	
SIDE EFFECTS:

	updates the timer queue
	
***************************************************************
*/

void *dispatcher_rmv_tim(r,p)
register	void (*r)();
register	void *p;
{
	DPT_TIM_ENT *e;

	search_param = p;
	e = (DPT_TIM_ENT *)queue_mapi(&timer_q,(void *)dispatcher_find_routine,r);
	if (e != NULL)
	{
		queue_remq(&timer_q, &e->te_head.de_head);
		queue_rel(&e->te_head.de_head);
	}
	return((void *) e);
}

/*.
***************************************************************

dispatcher_init_event -- Initialize an event

SYNOPSIS:

#include "dispatcher.h"

void dispatcher_init_event(e, f, d);
DPT_EVENT *e;
int f;
void (*d)();

DESCRIPTION:

Initialize the event e.

PARAMETERS:

	e -- this specifies the event data structure to be initialized.
	d -- This is a pointer to the debug routine for the event.

RETURNS:

	none
	
SIDE EFFECTS:

	
***************************************************************
*/

int	dispatcher_init_event(e, f, d)
register	DPT_EVENT *e;
int f;
register	void (*d)();
{
	if(f != 0)
	{
		log_abnormal1("Unsupported event type: %d", f);
		return(-1);
	}
	queue_init(&e->queue, NULL, NULL, NULL, NULL);
	e->debug = d;
	return(0);
}


/*.
***************************************************************

dispatcher_wait_event -- Enters a routine to wait for the occurance of
					an event.  

SYNOPSIS:

#include "dispatcher.h"

void dispatcher_wait_event(r,p,e);
void (*r)(p, e);
void *p;
DPT_EVENT *e;

DESCRIPTION:

Enters a routine to wait on an event.  When the event occurs (i.e. is
signaled via dispatcher_signal_event), the routine will be called once.

PARAMETERS:

	r -- this specifies the routine to be called when the event occurs.
	e -- Is a pointer to the event.
	p -- This is a pointer to an unknown parameter to be supplied to the
		routine when called.

RETURNS:

	-1	-- on error
	0	-- Otherwise
	
SIDE EFFECTS:
	
***************************************************************
*/

static void (*dispatcher_chk_dup_event_rou)();
static	void *dispatcher_chk_dup_event(q, b, p)
void *q;
DPT_EVENT_ENT *b;
void *p;
{
	log_fnc_entry1("dispatcher_chk_dup_event: q: 0x%lx", q);
	if (b->ee_head.de_r == dispatcher_chk_dup_event_rou && b->ee_head.de_p == p)
		return((void *)b);
	else
		return(NULL);
}

static	int dispatcher_wait_uevent_low(r,p,e,u)
void (*r)();
void *p;
register	DPT_EVENT	*e;
register	DPT_EVENT_ENT	*u;
{
	register	QHD		*q;

	if (!r || !u)
	{
		MPaxError = ERRPARM;
		return(-1);
	}
    u->ee_head.de_r = r;
    u->ee_head.de_p = p;
	q = (u->e = e) ? &e->queue : &event_q;

	if ( !queue_valid(q))
	{
		MPaxError = ERRQUEINV;
		return(-1);
	}

	if ( queue_put(q, &u->ee_head.de_head) != 0)
	{
		log_abnormal0("dispatcher_wait_uevent_low: Put to event queue failed.");
		return(-1);
	}
	return(0);
}

int dispatcher_wait_event(r,p,e)
void (*r)();
void *p;
register	DPT_EVENT	*e;
{
	register	DPT_EVENT_ENT	*d;
	
	dispatcher_chk_dup_event_rou = r;
    if (queue_mapi((e ? &e->queue : &event_q), dispatcher_chk_dup_event, p))
		return(0);
	if ((d = (DPT_EVENT_ENT *)queue_get(&default_freeq)) == NULL)
    {
		MPaxError = ERRQUEFUL;
		log_abnormal0("dispatcher_wait_event: No Event buffers.");
		return(-1);
    }
	if (dispatcher_wait_uevent(r,p,e,d))
	{
		queue_rel(&d->ee_head.de_head);
		return(-1);
	}
	return(0);
}


/*.
***************************************************************

dispatcher_wait_uevent -- Enters a routine to wait for the occurance of
					an event.  

SYNOPSIS:

#include "dispatcher.h"

int dispatcher_wait_uevent(r,p,e,u);
void (*r)(p, e);
void *p;
DPT_EVENT *e;
DPT_EVENT_ENT *u;

DESCRIPTION:

Enters a routine to wait on an event.  When the event occurs (i.e. is
signaled via dispatcher_signal_event), the routine will be called once.

PARAMETERS:

	r -- this specifies the routine to be called when the event occurs.
	e -- Is a pointer to the event.
	p -- This is a pointer to an unknown parameter to be supplied to the
		routine when called.
	u -- This is a pointer to a DPT_EVENT_ENT to be supplied by the
		caller (instead of using the default_freeq)

RETURNS:

	-1	-- on error
	0	-- Otherwise
	
SIDE EFFECTS:
	
***************************************************************
*/

int dispatcher_wait_uevent(r,p,e,u)
void (*r)();
void *p;
DPT_EVENT	*e;
DPT_EVENT_ENT	*u;
{
	dispatcher_chk_dup_event_rou = r;
    if (queue_mapi((e ? &e->queue : &event_q), dispatcher_chk_dup_event, p))
		return(0);
	return(dispatcher_wait_uevent_low(r,p,e,u));
}

/*.
***************************************************************

dispatcher_rmv_event -- Remove a routine from an event.

SYNOPSIS:


#include "dispatcher.h"

int dispatcher_rmv_event(r,p,e);
void (*r)();
void *p;
DPT_EVENT *e;

DESCRIPTION:

This routine removes a routine from the queue of routines waiting
for the specified event.

PARAMETERS:


	r -- This is a pointer to the routine.
	e -- This is a pointer to the event.
	p -- This is a pointer parameter to be supplied to the routine
		when called.

RETURNS:

	none

SIDE EFFECTS:


***************************************************************
*/

int dispatcher_rmv_event(r,p,e)
register	void (*r)();
register	void *p;
register	DPT_EVENT *e;
{
	register	DPT_EVENT_ENT *d;

	search_param = p;
	d = (DPT_EVENT_ENT *)queue_mapi(&e->queue,dispatcher_find_routine,r);
	if (d != NULL)
	{
		queue_remq(&e->queue, &d->ee_head.de_head);
		queue_rel(&d->ee_head.de_head);
	}
	return(0);
}

/*.
***************************************************************

dispatcher_cancel_event -- Remove all routines from an event.

SYNOPSIS:


#include "dispatcher.h"

void dispatcher_cancel_event(e);
DPT_EVENT *e;

DESCRIPTION:

This routine removes all routines waiting for an event.

PARAMETERS:

	e -- Is a pointer to the event

RETURNS:

	-1	-- If error
	0	-- Otherwise

SIDE EFFECTS:


***************************************************************
*/

dispatcher_cancel_event(e)
DPT_EVENT *e;
{

    if ( !queue_valid(&e->queue))
    {
        MPaxError = ERRQUEINV;
        return(-1);
    }
	queue_purge(&e->queue);

return 0;			
		/* This return is being added to accomodate the changes in the
		    the 'C' complier from SunOs 4.0.3 to to SunOs 4.1.1

		    For a complete discussion of the see bug: VDIlu00863.
		*/

}

/*.
***************************************************************

dispatcher_signal_event -- Signal the occurance of an event.

SYNOPSIS:


#include "dispatcher.h"

void dispatcher_signal_event(e);
DPT_EVENT *e;

DESCRIPTION:

This routine signals the occurance of an event -- All routines associated
with the event are placed on the event queue, where they will be called
next time through dispatcher_loop.

PARAMETERS:

	e -- Is a pointer to the event

RETURNS:

	-1	-- If error
	0	-- Otherwise

SIDE EFFECTS:


***************************************************************
*/

void dispatcher_move_event(b)
DPT_EVENT_ENT *b;
{
 	queue_put(&event_q, &b->ee_head.de_head);
}
dispatcher_signal_event(e)
DPT_EVENT *e;
{

    if ( !queue_valid(&e->queue))
    {
        MPaxError = ERRQUEINV;
        return(-1);
    }
#ifdef ANSI_PROTO
	queue_mapr(&e->queue, (QUE_MAPR_FUNC) dispatcher_move_event);
#else
	queue_mapr(&e->queue, dispatcher_move_event);
#endif

	return 0;			
		/* This return is being added to accomodate the changes in the
		    the 'C' complier from SunOs 4.0.3 to to SunOs 4.1.1

		    For a complete discussion of the see bug: VDIlu00863.
		*/

}

void dispatcher_unmove_event(b)
DPT_EVENT_ENT *b;
{
	if ((DPT_EVENT *)parm == b->e)
	{
		if (!(b->e->flags & DPT_EVENT_FLAGS__DONT_UNMOVE))
			queue_put(&b->e->queue, (QBF *)b);
		else
			queue_rel(b);
	}
	else
	{
		queue_put(&temp_q, (QBF *)&b->ee_head.de_head);
	}
}
dispatcher_unsignal_event(e)
DPT_EVENT *e;
{

    if ( !queue_valid(&e->queue))
    {
        MPaxError = ERRQUEINV;
        return(-1);
    }
	parm = (int *)e;
	queue_init(&temp_q, NULL, NULL, NULL, NULL );

#ifdef ANSI_PROTO
	queue_mapr(&event_q, (QUE_MAPR_FUNC) dispatcher_unmove_event);
#else
	queue_mapr(&event_q, dispatcher_unmove_event);
#endif

	queue_move(&temp_q, &event_q);

	return 0;			
		/* This return is being added to accomodate the changes in the
		    the 'C' complier from SunOs 4.0.3 to to SunOs 4.1.1

		    For a complete discussion of the see bug: VDIlu00863.
		*/

}

#ifdef SIGNAL_HANDLING
/*.
***************************************************************

dispatcher_init_signal -- Initialize a UNIX signal

SYNOPSIS:

	Initialize UNIX signal handling by the dispatcher.
	This handling is similar to events except that signals
	must be cought via dispatcher_catch_signal and then dpt signal
	handling activated via dispatcher_act_signal before signal handling
	actually occurs. Signal handling may only be changed when
	signal handling is inactive. Note that dispatcher_catch and dispatcher_wait
	are order-independant of each other !
	
	The semantics for UNIX signals via dpt is a bit different
	that standard UNIX signal handling. The semantics are assumed
	to mean "there's work to do...go try to do some work". In this
	sense, if a signal occurs before the work is done, it contributes
	no new information to overall processing. Specifically, if the
	signal is used for IO signaling, if a signal occurs (say N times
	beyond some initial occurence) before the scheduling to the IO,
	the scheduling of the IO will only occur once (not N times).

#include "dispatcher.h"

void dispatcher_init_signal(s, d);
int s;
void (*d)();

DESCRIPTION:

Initialize the signal s.
Note that the debug routine should be as follows:

void	d(sig,sem,p)
int	 sig; // signal #
int  sem; // corr. dpt semaphore cnt
void *p;  // user parm passed to dispatcher_debug()

PARAMETERS:

	s -- this specifies the signal to b initialized.
	d -- This is a pointer to the debug routine for the event.

RETURNS:

	none
	
SIDE EFFECTS:

	
***************************************************************
*/

int	dispatcher_init_signal(s, d)
register 	int s;
register	void (*d)();
{
	FNC_ENTRY(dispatcher_init_signal);
	
	MPaxCurrRou = (void *) dispatcher_init_signal;
	log_fnc_entry2("%s: entered for signal: %d", fn, s);
	
	if (s < 0 || s > LAST_SIGNAL)
	{
		log_abnormal2("%s: Unsupported signal type: %d", fn, s);
		FNC_RETURN(-1);
	}
	if (signal_array[s].state != UNINIT)
	{
		log_abnormal2("%s: already inited signal: %d", fn, s);
		FNC_RETURN(-1);
	}
		
	signal_array[s].state = NONE;
	signal_array[s].sem = 0L;
	signal_array[s].debug = d;
	queue_init(&signal_array[s].signal_q, NULL, NULL, NULL, NULL);
	FNC_RETURN(0);
;
}

/*.
***************************************************************

dispatcher_wait_signal -- Enters a routine to wait for the occurance of
					a UNIX signal.  

SYNOPSIS:

#include "dispatcher.h"

void dispatcher_wait_signal(r,p,s);
void (*r)(p,s,c);
void *p;
int s;
int c;

DESCRIPTION:

Enters a routine to wait on a UNIX signal.  When the signal occurs (i.e. is
signaled via kill()), the routine will be called once.

PARAMETERS:

	r -- this specifies the routine to be called when the signal occurs.
	s -- Is the signal.
	c -- Elapsed # of signal occurences in dpt.
	p -- This is a pointer to an unknown parameter to be supplied to the
		routine when called.

RETURNS:

	-1	-- on error
	0	-- Otherwise
	
SIDE EFFECTS:
	
***************************************************************
*/

DPT_SIGNAL_ENT *dispatcher_sfind_routine(q,b,r)
register	QHD *q;
register	DPT_SIGNAL_ENT *b;
register	void (*r)();
{
	log_fnc_entry1("dispatcher_sfind_routine: q: 0x%lx", q);
	if ((b->r == r) && (b->p == search_param))
		return(b);
	else
		return(NULL);
}

int dispatcher_wait_signal(r,p,s)
void 			(*r)();
void 			*p;
register	int s;
{
	DPT_SIGNAL_ENT*		d;

	FNC_ENTRY(dispatcher_wait_signal);
	MPaxCurrRou = (void *) dispatcher_wait_signal;
	log_fnc_entry2("%s: entered for signal: %d", fn, s);
	
	if (s < 0 || s > LAST_SIGNAL)
	{
		log_abnormal2("%s: Unsupported signal type: %d", fn, s);
		FNC_RETURN(-1);
	}
	if (signal_array[s].state == UNINIT)
	{
		log_abnormal2("%s: uinited signal: %d", fn, s);
		FNC_RETURN(-1);
	}
	if (signal_array[s].state == ACTIVE)
	{
		log_abnormal2(
			"%s: can't change %d signal hndling while ACTIVE", fn, s);
		FNC_RETURN(-1);
	}
	
	search_param = p;
	d = (DPT_SIGNAL_ENT *)queue_mapi(&signal_array[s].signal_q,dispatcher_sfind_routine,r);
	if (d != NULL)
		/* if previously registered go no further...*/
		FNC_RETURN(0);
	
	if ((d = (DPT_SIGNAL_ENT *)queue_get(&signal_freeq)) == NULL)
    {
		MPaxError = ERRQUEFUL;
		log_abnormal1("%s: No signal ent buffers.", fn);
		FNC_RETURN(-1);
    }
	
	d->r = r;
	d->p = p;
	d->signal = s;

	FNC_EXIT();
#ifdef ANSI_PROTO
	return (queue_put(&signal_array[s].signal_q, (QBF *)d));
#else
	return (queue_put(&signal_array[s].signal_q, d));
#endif
}

/*.
***************************************************************

dispatcher_catch_signal -- Activates dpt signal collection.  

SYNOPSIS:

#include "dispatcher.h"

int dispatcher_catch_signal(s,len);
int* s;
int  len;

DESCRIPTION:

Activate signal collection. Only collected signals can be handled.
This routine is used to prevent cases of handling spurious/ignorable
interrupts. This proc has a complement fnc, dispatcher_drop_signal.

PARAMETERS:

	s   -- signals array
	len -- signal array length 

RETURNS:

	-1	-- on error
	-2	-- sighold/sigrelse problem
	0	-- Otherwise
	
SIDE EFFECTS:

Signals are collected by dpt. If the 'signal' is active, dpt
can execute registered handlers for that signal if it has a
non-zero collected semaphore count.
	
***************************************************************
*/

int dispatcher_catch_signal(s, len)
register int* s;
register int len;
{
	int	mask, old_mask;
	int ss, i;
	
	FNC_ENTRY(dispatcher_catch_signal);
	MPaxCurrRou = (void *) dispatcher_catch_signal;
	log_fnc_entry2("%s: entered for signal array: 0x%lx", fn, s);
	
	mask = 0;
	
	for (i=0; i<len; i++)
	{
		ss = s[i];
		if (ss < 0 || ss > LAST_SIGNAL)
		{
			log_abnormal2("%s: Unsupported signal type: %d", fn, ss);
			FNC_RETURN(-1);
		}
		if (signal_array[ss].state == UNINIT)
		{
			log_abnormal2("%s: uinited signal: %d", fn, ss);
			FNC_RETURN(-1);
		}
		if (signal_array[ss].state == NONE)
		{
#ifndef SYSV
			mask |= sigmask(ss);
#else
			BSET(mask, ss);
#endif
			signal_array[ss].state = COLLECTING;
		}
	} /* for */
	
	/* hold specified signals */
#ifndef SYSV	
	old_mask = sigblock(mask);
#else
	for (i=0; i<len; i++)
		if (IS_BSET(mask, i))
			if (sighold(i) < 0)
			{
				MPaxError = errno;
				FNC_RETURN(-2);
			}
#endif
	log_info2("%s: sigblock with mask 0x%lx", fn, mask);
	
	for (i=0; i<len; i++)
	{
		ss = s[i];
		if (signal_array[ss].state == COLLECTING)
		{
			if ((signal_array[ss].old_hndlr = signal(ss, dispatcher_signal_hndlr)) == SIG_ERR)
			{
				log_abnormal2("%s: couldn't register signal hndlr for signal: %d", fn, ss);
				FNC_RETURN(-1);
			}
				
			log_state_chng2("%s: now COLLECTING signal: %d", fn, ss);
		}
	} /* for */
	
	/* now release those signals ! */
	
#ifndef SYSV	
	sigsetmask(old_mask);
#else
	for (i=0; i< len; i++)
		if (IS_BSET(mask, i))
			if (sigrelse(i) < 0)
			{
				MPaxError = errno;
				FNC_RETURN(-2);
			}
#endif
	log_info2("%s: sigsetmask with old_mask 0x%lx", fn, old_mask);
	FNC_RETURN(0);
}

/*.
***************************************************************

dispatcher_act_signal -- Activates dpt signal handling  

SYNOPSIS:

#include "dispatcher.h"

int dispatcher_act_signal(s,len);
int* s;
int  len;

DESCRIPTION:

Activate previously installed signal handling.
Further signal handling cannot be installed unless a dispatcher_dct_signal
is performed. act & dct provides a mechanism to handle signals in a
'state' sensitive fashion. This proc has a complement fnc, dispatcher_dct_signal.


PARAMETERS:

	s   -- signal array
	len -- signal array length

RETURNS:

	-1	-- on error
	0	-- Otherwise
	
SIDE EFFECTS:

If the 'signal' is active, dpt can execute registered handlers for 
that signal if it has a non-zero collected semaphore count.
	
***************************************************************
*/

int dispatcher_act_signal(s, len)
int* s;
int len;
{
	register int ss, i;
	
	FNC_ENTRY(dispatcher_act_signal);;
	MPaxCurrRou = (void *) dispatcher_act_signal;
	log_fnc_entry2("%s: entered for signal array: 0x%lx", fn, s);
	
	for (i=0; i<len; i++)
	{
		ss = s[i];
	
		if (ss < 0 || ss > LAST_SIGNAL)
		{
			log_abnormal2("%s: Unsupported signal type: %d", fn, ss);
			FNC_RETURN(-1);
		}
		if (signal_array[ss].state == UNINIT)
		{
			log_abnormal2("%s: uinited signal: %d", fn, ss);
			FNC_RETURN(-1);
		}
		if (signal_array[ss].state == ACTIVE)
		{
			log_abnormal2("%s: can't reactive an ACTIVE signal: %d", fn, ss);
			return(-1);
		}
	
		if (signal_array[ss].state == COLLECTING)
			signal_array[ss].state = ACTIVE;
		else
		{
			log_abnormal2("%s: Curr. uncollected signal: %d", fn, ss);
			FNC_RETURN(-1);
		}
			
		active_signals[num_active_signals] = ss;
		num_active_signals++;
		
		log_state_chng2("%s: now ACTIVE for signal: %d", fn, ss);
		
	} /* for */
	
	for (i=0; i<num_active_signals; i++)
		log_debug4(
			"%s: signal_array[%d] = %d; sem = %d",
			 fn, i, active_signals[i], signal_array[active_signals[i]].sem);
	
	FNC_RETURN(0);
}

/*.
***************************************************************

dispatcher_dct_signal -- Deactivates dpt event handling..  

SYNOPSIS:

#include "dispatcher.h"

int dispatcher_dct_signal(s);
int* s;
int  len;

DESCRIPTION:

Deactivate previously installed signal handling.
Further signal handling cannot be installed unless this procedure
is called. This proc has a complement fnc, dispatcher_act_signal.


PARAMETERS:

	s   -- signal array.
	len -- signal array length.

RETURNS:

	-1	-- on error
	0	-- Otherwise
	
SIDE EFFECTS:
	
***************************************************************
*/

int dispatcher_dct_signal(s,len)
int* s;
int  len;
{
	register	int 	ss;
	register	int		i, j;
	
	FNC_ENTRY(dispatcher_dct_signal);
	MPaxCurrRou = (void *) dispatcher_dct_signal;
	log_fnc_entry2("%s: entered for signal array: 0x%lx", fn, s);
	
	for (i=0; i<len; i++)
	{
		ss = s[i];
		if (ss < 0 || ss > LAST_SIGNAL)
		{
			log_abnormal2("%s: Unsupported signal type: %d", fn, ss);
			FNC_RETURN(-1);
		}
		if (signal_array[ss].state == UNINIT)
		{
			log_abnormal2("%s: uinited signal: %d", fn, ss);
			FNC_RETURN(-1);
		}
		if (signal_array[ss].state != ACTIVE)
		{
			log_abnormal2("%s: can't deactivate a non-ACTIVE signal: %d", fn, ss);
			FNC_RETURN(-1);
		}
		else
		{
	    	signal_array[ss].state = COLLECTING;
		}
		
		for (j=num_active_signals-1; j>= -1; j--)
		{
			if (j == -1)
			{
				log_internal2("%s: couldn't find signal %d in list of active_signals", fn, ss);
				FNC_RETURN(-1);
			}
			if (active_signals[j] == ss)
			{
				active_signals[j] = NULL_SIGNAL;
				break;
			}
		} /* for */
		
		log_state_chng2("%s: now back to COLLECTING signal: %d", fn, ss);

	} /* for */
	
	/* cleanup/compact active_signals */

	if (len > 0 && num_active_signals > 0)
	{
	/* commented out and changed by Liming Yang - 5/24/94
		i = 0;
		j = 0;
		while (i<num_active_signals)
		{
			if (active_signals[j] == NULL_SIGNAL)
			{
				j++;
				num_active_signals--;
				if (j >= num_active_signals)
					break;
			}
			active_signals[i] = active_signals[j];
			i++; j++;
		} */ /* while */

		for (i=j=num_active_signals-1; i>=0; i--)
		{
			if (active_signals[i]==NULL_SIGNAL)
			{
				if (i<j) active_signals[i] = active_signals[j];
				j--;
			}
		}

		num_active_signals = j + 1;
	}
	
	for (i=0; i<num_active_signals; i++)
		log_debug4(
			"%s: signal_array[%d] = %d; sem = %d",
			 fn, i, active_signals[i], signal_array[active_signals[i]].sem);
	
	FNC_RETURN(0);
}

/*.
***************************************************************

dispatcher_drop_signal -- Deactivates dpt signal handling..  

SYNOPSIS:

#include "dispatcher.h"

int dispatcher_drop_signal(s,len);
int* s;
int  len;

DESCRIPTION:

Deactivate signal collecting.
Further signal handling cannot be installed unless this procedure
is called. This proc has a complement fnc, dispatcher_catch_signal.


PARAMETERS:

	s   -- the signal array
	len -- signal array length

RETURNS:

	-1	-- on error
	-2	-- sighold/sigrelse problem
	0	-- Otherwise
	
SIDE EFFECTS:
	
***************************************************************
*/

int dispatcher_drop_signal(s, len)
register int* s;
register int len;
{
	int	mask, old_mask;
	int ss, i;
	
	FNC_ENTRY(dispatcher_drop_signal);
	MPaxCurrRou = (void *) dispatcher_drop_signal;
	log_fnc_entry2("%s: entered for signal array: 0x%lx", fn, s);
	
	mask = 0;
#ifndef SYSV
	old_mask = sigblock(0);
#endif
	
	for (i=0; i<len; i++)
	{
		ss = s[i];
		if (ss < 0 || ss > LAST_SIGNAL)
		{
			log_abnormal2("%s: Unsupported signal type: %d", fn, ss);
			FNC_RETURN(-1);
		}
		if (signal_array[ss].state == UNINIT)
		{
			log_abnormal2("%s: uinited signal: %d", fn, ss);
			FNC_RETURN(-1);
		}
		if (signal_array[ss].state == COLLECTING)
		{
#ifndef SYSV
			mask |= sigmask(ss);
#else
			BSET(mask, ss);
#endif
		}
	} /* for */
	
	/* hold specified signals */
#ifndef SYSV	
	old_mask = sigblock(mask);
#else
	for (i=0; i<len; i++)
		if (IS_BSET(mask, i))
			if (sighold(i) < 0)
			{
				MPaxError = errno;
				FNC_RETURN(-2);
			}
#endif
	log_info2("%s: sigblock with mask 0x%lx", fn, mask);
	
	for (i=0; i<len; i++)
	{
		ss = s[i];
		if (signal_array[ss].state == COLLECTING)
		{
			if (signal(ss, signal_array[ss].old_hndlr) == SIG_ERR)
			{
				log_internal2("%s: couldn't register old signal hnldr for signal: %d", fn, ss);
				FNC_RETURN(-1);
			}
			signal_array[ss].state = NONE;
			
			log_state_chng2("%s: now INACTIVE for signal: %d", fn, ss);
		}
	} /* for */
	
	/* now release those signals ! */

#ifndef SYSV	
	sigsetmask(old_mask);
#else
	for (i=0; i< len; i++)
		if (IS_BSET(mask, i))
			if (sigrelse(i) < 0)
			{
				MPaxError = errno;
				FNC_RETURN(-2);    /* Liming Yang - 5/24/94 */
			}
#endif
	log_info2("%s: sigsetmask with old_mask 0x%lx", fn, old_mask);
	FNC_RETURN(0);
}

/*.
***************************************************************

dispatcher_rmv_signal -- Remove a routine from dpt signal handling.

SYNOPSIS:


#include "dispatcher.h"

int dispatcher_rmv_signal(r,p,s);
void (*r)();
void *p;
int s;

DESCRIPTION:

This routine removes a routine from the queue of routines waiting
for the specified UNIX signal.

PARAMETERS:


	r -- This is a pointer to the routine.
	s -- This is the signal.
	p -- This is a pointer parameter to be supplied to the routine
		when called.

RETURNS:

	none

SIDE EFFECTS:


***************************************************************
*/

int dispatcher_rmv_signal(r,p,s)
register	void (*r)();
register	void *p;
register	int s;
{
	DPT_SIGNAL_ENT				*d;
	
	FNC_ENTRY(dispatcher_rmv_signal);
	MPaxCurrRou = (void *) dispatcher_rmv_signal;
	log_fnc_entry2("%s: entered for signal array: 0x%lx", fn, s);
	
	if (s < 0 || s > LAST_SIGNAL)
	{
		log_abnormal2("%s: Unsupported signal type: %d", fn, s);
		FNC_RETURN(-1);
	}
	if (signal_array[s].state == UNINIT)
	{
		log_abnormal2("%s: uinited signal: %d", fn, s);
		FNC_RETURN(-1);
	}
	/* added by Liming Yang - 5/24/94 */
	if (signal_array[s].state == ACTIVE)
	{
		log_abnormal2("%s: can't change %d signal hndling while ACTIVE", fn, s);
		FNC_RETURN(-1);
	}

	search_param = p;
	d = (DPT_SIGNAL_ENT *)queue_mapi(&signal_array[s].signal_q,dispatcher_sfind_routine,r);
	if (d != NULL)
	{
#ifdef ANSI_PROTO
		if (queue_remq(&signal_array[s].signal_q, (QBF *) d) < 0)
#else
		if (queue_remq(&signal_array[s].signal_q, d) < 0)
#endif
		{
			log_internal2("%s: couldn't remove entry from queue for signal: %d", fn, s);
			FNC_RETURN(-1);
		}
#ifdef ANSI_PROTO
		if (queue_rel((QBF *)d) < 0)
#else
		if (queue_rel(d) < 0)
#endif
		{
			log_internal2("%s: couldn't release entry for signal: %d", fn, s);
			FNC_RETURN(-1);
		}
	}
	return(0);
}

/*.
***************************************************************

dispatcher_cancel_signal -- Remove all routines from dpt signal handling.

SYNOPSIS:


#include "dispatcher.h"

void dispatcher_cancel_signal(s);
int s;

DESCRIPTION:

This routine removes all routines waiting for a UNIX signal.

PARAMETERS:

	s -- Is the signal

RETURNS:

	-1	-- If error
	0	-- Otherwise

SIDE EFFECTS:


***************************************************************
*/

dispatcher_cancel_signal(s)
int s;
{
	int	status;
	
	FNC_ENTRY(dispatcher_cancel_signal);
	MPaxCurrRou = (void *) dispatcher_cancel_signal;
	log_fnc_entry2("%s: entered for signal: %d", fn, s);
	if (s < 0 || s > LAST_SIGNAL)
	{
		log_abnormal2("%s: Unsupported signal type: %d", fn, s);
		FNC_RETURN(-1);
	}
	if (signal_array[s].state == UNINIT)
	{
		log_abnormal2("%s: uinited signal: %d", fn, s);
		FNC_RETURN(-1);
	}
	
	if ((status=dispatcher_dct_signal((int*)&s, 1)) < 0)
		FNC_RETURN(status);
	
	FNC_RETURN(queue_purge(&signal_array[s].signal_q));
}
#endif

/*.
***************************************************************

dispatcher_add_def -- Adds a default routine to the default queue.

SYNOPSIS:

#include "dispatcher.h"

void dispatcher_add_def(r,p);
void (*r)();
void *p;

DESCRIPTION:

This routine adds a default routine to the default queue.  Default
routines are called in round robin order whenever none of the active i/o
devices on the select list are ready.  If the specified routine and pointer
are allready on the default queue, it is left on the queue.

PARAMETERS:

	r -- This is a pointer to the default routine.
	p -- This is a pointer to an artibuary parameter to be supplied to the
		routine when called.

RETURNS:

	

SIDE EFFECTS:

	Updates the default queue

***************************************************************
*/

void *dispatcher_add_def(r,p)
register	void (*r)();
register	void *p;
{
	register	DPT_DEF_ENT *e;

	if (!r)
	{
		MPaxError = ERRPARM;
		return(NULL);
	}
	search_param = p;
	if ( (e = (DPT_DEF_ENT *) queue_mapi(&default_q,(void *)dispatcher_find_routine,r)) != NULL)
		return((void *) e);
		
	if ((e = (DPT_DEF_ENT *) queue_get(&default_freeq)) != NULL)
	{
		e->de_p = p;
		e->de_r = r;
		if ( queue_put(&default_q, &e->de_head) != 0)
		{
			log_abnormal0("dispatcher_add_def: Put to default queue failed.");
			return(NULL);
		}
		else
			return((void *) e);
	}
	MPaxError = ERRQUEFUL;
	log_abnormal0("dispatcher_add_def: Default queue full.");
	return(NULL);
}

/*.
***************************************************************

dispatcher_rmv_def -- Remove a routine from the default list.

SYNOPSIS:


#include "dispatcher.h"

void dispatcher_add_def(r,p);
void (*r)();
void *p;

DESCRIPTION:

This routine removes the default routine from the select list.

PARAMETERS:


	r -- This is a pointer to the default routine.
	p -- This is a pointer parameter to be supplied to the routine
		when called.

RETURNS:

	none

SIDE EFFECTS:

	updates the default queue

***************************************************************
*/

void *dispatcher_rmv_def(r,p)
register	void (*r)();
register	void *p;
{
	register	DPT_DEF_ENT *e;

	search_param = p;
	e = (DPT_DEF_ENT *)queue_mapi(&default_q,(void *)dispatcher_find_routine,r);
	if (e != NULL)
	{
		queue_remq(&default_q, &e->de_head);
		queue_rel(&e->de_head);
	}
	return((void *) e);
}

/*.
***************************************************************

dispatcher_check_for_timeout

SYNOPSIS:

#include "dispatcher.h"
#include "queue.h"

void dispatcher_check_for_timeout(q, b);
QHD *q;
QBF *b;

DESCRIPTION:

This routine is intended to be mapped over the timer queue.  It uses
the global variables current_time, least_timeout, and expired.
The value in current_time is compared to each timer.  If the time has 
elasped, then it is removed from the queue and its routine is invoked.
The number of timers which expired is left in expired, and the lowest timeout
remaining is left in least_timeout.

PARAMETERS:

	q -- is a pointer to the timer queue
	b -- is a pointer to the buffer under consideration

RETURNS:

	none

SIDE EFFECTS:

	leaves values in expired and least timeout.  May invoke timer routines
	and remove timers from the queue.

***************************************************************
*/

char *dispatcher_check_for_timeout(q, b, p)
register	QHD			*q;
register	DPT_TIM_ENT	*b;
register	void		*p;
{

	log_fnc_entry2("dispatcher_check_for_timeout: q: 0x%lx; p: 0x%lx", q, p);

	if ( timergtreq(current_time, b->timeout) )
	{
		queue_remq(q, &b->te_head.de_head);
		queue_rel(&b->te_head.de_head);
		MPaxCurrRou = (void *) b->te_head.de_r;
		(*b->te_head.de_r)(b->te_head.de_p);
		expired++;
		return(NULL);
	}
	return((char *) b);
}		

/*.
***************************************************************

dispatcher_execute_event

SYNOPSIS:

#include "dispatcher.h"
#include "queue.h"

void dispatcher_execute_event(b);
DPT_EVENT_ENT *b;

DESCRIPTION:

This routine is intended to be mapped over the event queue.  It is 
executes every event.

PARAMETERS:

	b -- is a pointer to the buffer under consideration

RETURNS:

	none

SIDE EFFECTS:

***************************************************************
*/

void dispatcher_execute_event(b)
register	DPT_EVENT_ENT	*b;
{
		MPaxCurrRou = (void *) b->ee_head.de_r;
		(*(b->ee_head.de_r))(b->ee_head.de_p, b->e);
		queue_rel(&b->ee_head.de_head);
}		

/*.
***************************************************************

dispatcher_tim_prio

SYNOPSIS:

#include "dispatcher.h"
#include "queue.h"

int dispatcher_tim_prio(c,a)
QBF *c, *a;

DESCRIPTION:

This routine is used when adding elements to the timer queue.  This routine
is passed two timer buffers and decides if the add 'a' buffer should be
before the current 'c' buffer.

PARAMETERS:

	c -- is a pointer to the current buffer in the queue
	a -- is a pointer to the buffer being added

RETURNS:

	dispatcher_tim_prio	-- returns true if the buffer should be added before 
					the current buffer, false otherwise.

SIDE EFFECTS:


***************************************************************
*/



int dispatcher_tim_prio(c,a)
register	QBF *c, *a;
{
	return( timergtr( ((DPT_TIM_ENT *) c)->timeout,
					  ((DPT_TIM_ENT *) a)->timeout) );
}

/*.
***************************************************************

dispatcher_find_routine -- Find a timer or default routine

SYNOPSIS:

#include "dispatcher.h"

DPT_DEF_ENT *dispatcher_find_routine(q,b,r);
QHD *q;
QBF *b;
void (*r)();

DESCRIPTION:

This routine finds a particular timer on the timer queue or default 
routine on the default queue.  It is intended to be mapped over the 
timer queue or the default queue using queue_mapi.

PARAMETERS:

	q -- is a pointer to the queue being mapped
	b -- is a pointer to the buffer
	r -- is a pointer to the routine being sought
	search_param -- is a global variable containing the parameter to
		be passed

RETURNS:

	dispatcher_find_routine -- returns a pointer to the queue buffer if
		the buffer matches, NULL otherwise

SIDE EFFECTS:

	none

***************************************************************
*/

DPT_DEF_ENT *dispatcher_find_routine(q,b,r)
register	QHD *q;
register	DPT_DEF_ENT *b;
register	void (*r)();
{
	log_fnc_entry2("dispatcher_find_routine: q: 0x%lx; r: 0x%lx", q, r);
	if ((b->de_r == r) && (b->de_p == search_param))
		return(b);
	else
		return(NULL);
}

/*.
***************************************************************

dispatcher_debug -- debug routine for dispatcher subsystem

SYNOPSIS:
	
void dispatcher_debug();

DESCRIPTION:

This routine is the debug routine for the dispatcher subsystem.
This routine will perform a formated dump of the dispatcher module level
data to the loging routines.

PARAMETERS:

	arg	- not used.

RETURNS:

	NONE

SIDE EFFECTS:

	none.

***************************************************************
*/

void dispatcher_disp_default(q, d, a)
QHD	*q;
register	DPT_DEF_ENT	*d;
void	*a;
{
	log_fnc_entry2("dispatcher_disp_default: q: 0x%lx; a: 0x%lx", q, a);
	log_internal3(
		"\tDefault entry: 0x%lx, rou 0x%lx, arg 0x%lx",
		d,d->de_r, d->de_p);
}
void dispatcher_disp_time(q, t, a)
QHD	*q;
register	DPT_TIM_ENT	*t;
void	*a;
{
	struct timeval	 timeout;

	log_fnc_entry2("dispatcher_disp_time: q: 0x%lx; a: 0x%lx", q, a);
	timerdelta(current_time,t->timeout,timeout);
	log_internal7(
		"\tTimer entry: 0x%lx, rou 0x%lx, arg 0x%lx time: %d,%d timeout: %d,%d",
		t,t->te_head.de_r, t->te_head.de_p,
		t->timeout.tv_sec, t->timeout.tv_usec,
		timeout.tv_sec, timeout.tv_usec);
}
void dispatcher_disp_event_ent(q, e, a)
QHD	*q;
register	DPT_EVENT_ENT	*e;
void	*a;
{
	log_fnc_entry2("dispatcher_disp_event_ent: q: 0x%lx; a: 0x%lx", q, a);
	log_internal4(
		"\tEvent entry: 0x%lx, rou 0x%lx, arg 0x%lx, event 0x%lx",
		e,e->ee_head.de_r, e->ee_head.de_p, e->e);
}

#ifdef SIGNAL_HANDLING
void dispatcher_disp_signal_ent(q, b, a)
QBF*			q;
DPT_SIGNAL_ENT	*b;
void			*a;
{
	int s = b->signal;

	log_fnc_entry1("dispatcher_disp_signal_ent: q: 0x%lx", q);	
	log_internal3("\t Signal entry: sig %d, rou 0x%lx, sem cnt %d",
		s, b->r, signal_array[s].sem);
	if (signal_array[s].debug)
		(*signal_array[s].debug)(s, signal_array[s].sem, a);
}
#endif

int dispatcher_debug(arg)
void	*arg;
{

	register	int				i;
	register	long			m,n;
				fd_set			a, r, w, e;
				struct timeval	timeout;

#ifdef SIGNAL_HANDLING
				int				s;
#endif

	switch (dispatcher_location)
	{
		case PROC_SELECT :
			log_internal2(
				"dispatcher_debug: %s and working on fd %d", dispatcher_loc_str[dispatcher_location], dispatcher_index);
			break;
		case PROC_SIGNAL :
			log_internal2(
				"dispatcher_debug: %s and working on signal %d", dispatcher_loc_str[dispatcher_location], dispatcher_index);
			break;
		default :
			log_internal1(
				"dispatcher_debug: %s", dispatcher_loc_str[dispatcher_location]);
			break;
	}
	log_internal2(
		"dispatcher_debug: MPaxCurrRou: %p, MPaxError: %d", MPaxCurrRou, MPaxError);
	MPaxCurrRou = (void *) dispatcher_debug;
	MPaxError = 0;

	gettimeofday(&current_time,NULL);
	timerclr(timeout);
	r = sel_read_mask;
	w = sel_write_mask;
	e = sel_except_mask;
	n = select( (long) max_fd,&r,&w,&e,&timeout);
	FD_ZERO(&a);
	for (m=0; m < sizeof(r)/sizeof(r.fds_bits[0]); m++)
		a.fds_bits[m] = 	sel_read_mask.fds_bits[m] 		|
						 	sel_write_mask.fds_bits[m]		|
							sel_except_mask.fds_bits[m]		|
							r.fds_bits[m]					|
							w.fds_bits[m]					|
							e.fds_bits[m];

	for (m=0; m < sizeof(r)/sizeof(r.fds_bits[0]); m++)
	{
		log_internal3(
			"dispatcher_debug: select mask: r: 0x%lx, w: 0x%lx, e: 0x%lx",
			sel_read_mask.fds_bits[m], sel_write_mask.fds_bits[m], sel_except_mask.fds_bits[m]);
		log_internal4(
			"dispatcher_debug: select resp: r: 0x%lx, w: 0x%lx, e: 0x%lx, num: %d",
			r.fds_bits[m], w.fds_bits[m], e.fds_bits[m], n);
	}

	for (i = 0, m = 0; i < max_fd; i++, m++)
	{
		if ( FD_ISSET(m, &a)  ||
			 sel_list[i].se_reader  ||
			 sel_list[i].se_writer  ||
			 sel_list[i].se_except )
		{
			log_internal7(
			"\tFD: %d, dpt flag: r %s, w %s, e %s, select: r %s, w %s, e %s",i,
				(FD_ISSET(m, &sel_read_mask) ? "TRUE": "FALSE"),
				(FD_ISSET(m, &sel_write_mask) ? "TRUE": "FALSE"),
				(FD_ISSET(m, &sel_except_mask) ? "TRUE": "FALSE"),
				(FD_ISSET(m, &r) ? "TRUE": "FALSE"),
				(FD_ISSET(m, &w) ? "TRUE": "FALSE"),
				(FD_ISSET(m, &e) ? "TRUE": "FALSE"));

			if ( sel_list[i].se_reader )
			{
				log_internal2(
					"\t\tread: rou 0x%lx arg 0x%lx",
					sel_list[i].se_reader, sel_list[i].se_read_param);
			}
			if ( sel_list[i].se_writer )
			{
				log_internal2(
					"\t\twrite: rou 0x%lx arg 0x%lx",
					sel_list[i].se_writer, sel_list[i].se_write_param);
			}
			if ( sel_list[i].se_except )
			{
				log_internal2(
					"\t\texecpt: rou 0x%lx arg 0x%lx",
					sel_list[i].se_except, sel_list[i].se_except_param);
			}
		}
	}

	log_internal2("\t: default free queue size: init %d, curr %d",
		queue_owned(&default_freeq), queue_size(&default_freeq));
	log_internal1("\t: Null Event queue size %d", queue_size(&event_q));
	queue_map( &event_q, dispatcher_disp_event_ent, NULL);
	log_internal1("\t: timer queue size %d", queue_size(&timer_q));
	queue_map( &timer_q, dispatcher_disp_time, NULL);
#ifdef SIGNAL_HANDLING
	log_internal1("\t: signal free queue size %d", queue_size(&signal_freeq));
	for (i=0; i<num_active_signals; i++)
	{
		s = active_signals[i];
		queue_map(&signal_array[s].signal_q, dispatcher_disp_signal_ent, arg);
	}
#endif
	log_internal1("\t: default queue size %d", queue_size(&default_q));
	queue_map( &default_q, dispatcher_disp_default, NULL);
	return(0);
}


#ifdef STUB_VER

/*
select and gettimeofday stub for dpt module
*/

static struct timeval global_time = { 0, 0 } ;


change_global_time_stub()
{
	long	sec,usec;
	char	inbuf[128];

	printf("Current time: %lu sec, %lu usec.\n",
			global_time.tv_sec, global_time.tv_usec);
	printf("Enter: Add inc, New time, other char = timeok: ");
	gets(inbuf);
	switch ( inbuf[0] )
	{
	case 'A':
		printf("dd inc.\nEnter seconds and micro seconds increment: ");
		scanf ("%lu %lu",&sec, &usec );
		global_time.tv_sec  += sec;
		global_time.tv_usec += usec;
		break;
	case 'N':
		printf("ew time.\nEnter new seconds and micro seconds: ");
		scanf ("%lu %lu",&sec, &usec );
		global_time.tv_sec  = sec;
		global_time.tv_usec = usec;
		break;
	default:
		printf(" time ok.\n");
		break;
	}
}


/*.
*****************************************************
gettimeofday -- Stub for get the time
*****************************************************
*/
gettimeofday_stub(t,tz)
register	struct timeval *t; 
register	struct timezone *tz;
{
	printf("Get time of day called; ");
	change_global_time_stub();
	t->tv_sec  = global_time.tv_sec;
	t->tv_usec = global_time.tv_usec;

	return 0;			
		/* This return is being added to accomodate the changes in the
		    the 'C' complier from SunOs 4.0.3 to to SunOs 4.1.1

		    For a complete discussion of the see bug: VDIlu00863.
		*/

}


/*.
***********************************************
select.c -- stub for select system call
***********************************************
*/

long select_stub(n, r ,w ,e ,t)
register	long n, *r, *w, *e;
register	struct timeval *t;
{
	long i, m, j;
	char	inbuf[128];
	static	int	read_time	= FALSE;

	if ( !queue_empty(&timer_q) )
	{
		printf("In the select stub; timeout: %lu sec, %lu usec; ",
				t->tv_sec, t->tv_usec);
		printf("Current time: %lu sec, %lu usec.\n",
				global_time.tv_sec, global_time.tv_usec);
	}
	
	for (i = 0, m = 1, j = 0; i < n ; m <<= 1, i++)
	{
		if ((*r & m) != 0)
		{
			if ( read_time )
			{
				printf("Device %ld ready to read?",i);
				gets(inbuf);
				if ( inbuf[0] == 'y'  ||  inbuf[0] == 'Y' )
					j++;
				else
					*r ^= m;
			}
			else 
				*r ^= m;
		}
		if ((*w & m) != 0)
		{
			if ( !read_time )
			{
				j++;
			}
			else 
				*w ^= m;
		}
		if ((*e & m) != 0)
		{
			printf("Device %ld has exception?",i);
			gets(inbuf);
			if ( inbuf[0] == 'y'  ||  inbuf[0] == 'Y' )
				j++;
			else
				*e ^= m;
		}
	}
	read_time = !read_time;
	
	if ( queue_empty(&timer_q) )
	{
		global_time.tv_sec  += t->tv_sec;
		global_time.tv_usec += t->tv_usec;
	}
	else
	{
		if ( j == 0 )
		{
			global_time.tv_sec  += t->tv_sec;
			global_time.tv_usec += t->tv_usec;
	        while ( global_time.tv_usec >= 1000000 )
	        {
		      global_time.tv_sec++;
		      global_time.tv_usec -= 1000000;
	        }
			printf("Timeout occurred; current time: %lu sec, %lu usec.\n",
					global_time.tv_sec, global_time.tv_usec);
		}
		else
		{
			do {
				printf("Enter seconds and micro seconds elasped: ");
				scanf ("%ld %ld",&i, &m );
			} while ( i > t->tv_sec || (i == t->tv_sec && m > t->tv_usec));
			global_time.tv_sec  += i;
			global_time.tv_usec += m;
			printf("Current time: %lu sec, %lu usec.\n",
					global_time.tv_sec, global_time.tv_usec);
		}
	}
	return(j);
}

#endif

