/*
 ******************************************************************************
 *			dispatcher.h
 *
 *	Micro-PAX Application subsystem service - Dispatcher
 *
 *	This include file requires the include files:
 *		queue.h
 *

 *
 ******************************************************************************
 */


#ifndef _DPT_
#define _DPT_

#ifdef SYSV
#ifndef _TIME_
#define _TIME_
#include <sys/time.h>
#endif
#ifndef _SIGNAL_
#define _SIGNAL_
#ifdef SGI
#define _BSD_SIGNALS
#endif
#include <signal.h>
#endif
#else
#include <sys/time.h>
#include <signal.h>
#endif

#ifdef STUB_VER
#define	gettimeofday(t,tz)	gettimeofday_stub(t,tz)
#define select(n,r,w,e,t) select_stub(n,r,w,e,t)
#endif



/* structure for the select list */

typedef struct sel_ent
{
	QBF		se_head;
	void	(*se_reader)();
	void	*se_read_param;
	void	(*se_writer)();
	void	*se_write_param;
	void	(*se_except)();
	void	*se_except_param;
} DPT_SEL_ENT;

/* Common structure for timer and default queue buffers */

typedef struct def_ent
{
	QBF		de_head;
	void	(*de_r)();
	void	*de_p;
} DPT_DEF_ENT;
#define	DPT_INIT_DEF_ENT(e,r,p)		{ QUE_BUF_INIT(e), r, p }

/* structure of timer queue entry */

typedef struct tim_ent
{
	DPT_DEF_ENT		te_head;
	struct timeval	timeout;
} DPT_TIM_ENT;

#define	DPT_INIT_TIM_ENT(e,r,p,s,u)		\
	{ DPT_INIT_DEF_ENT( e, r, p), s, u }

/* Structure of an event */
typedef struct dispatcher_event
{
	QHD				queue;
	void			(*debug)();
	short			flags;
} DPT_EVENT;

#define DPT_EVENT_FLAGS__DONT_UNMOVE	0x0001
	/* set above if don't want unsignal to re-register on original event */
	
#define	DPT_INIT_EVENT(e,f,d)		\
	{ QUE_INIT( e, NULL, NULL, NULL, NULL), d }

/* structure of an event queue entry */

typedef struct event_ent
{
	DPT_DEF_ENT		ee_head;
	DPT_EVENT		*e;
} DPT_EVENT_ENT;
#define	DPT_INIT_EVENT_ENT(e,r,p,event)		\
		{ DPT_INIT_DEF_ENT(e,r,p), event }
		
typedef union free_ent
{
	DPT_EVENT_ENT	e;
	DPT_DEF_ENT		d;
	DPT_TIM_ENT		t;
} DPT_FREE_ENT;
#define SEL_ENTRIES 256

#define DPT_MAX_TIME_SEC	10
#define DPT_MAX_TIME_USEC	 0

#ifdef ANSI_PROTO
int		 dispatcher_init(int t, int d);
int		 dispatcher_init_sig_handling(int sigs, struct timeval* scan);
int		 dispatcher_chk(void);
void	 dispatcher_loop(void);
int		 dispatcher_add_sel_full(int f, void (*r)(), void *r_p, void (*w)(), void *w_p, void (*e)(), void *e_p);
int		 dispatcher_add_sel(int f, void (*r)(), void *r_p, void (*w)(), void *w_p);
int		 dispatcher_rmv_sel(int f);
int		 dispatcher_act_sel(int f);
int		 dispatcher_dct_sel(int f);
int		 dispatcher_add_sel_r(int f, void (*r)(), void *r_p);
int		 dispatcher_rmv_sel_r(int f);
int		 dispatcher_act_sel_r(int f);
int		 dispatcher_dct_sel_r(int f);
int		 dispatcher_add_sel_w(int f, void (*w)(), void *w_p);
int		 dispatcher_rmv_sel_w(int f);
int		 dispatcher_act_sel_w(int f);
int		 dispatcher_dct_sel_w(int f);
int		 dispatcher_add_sel_e(int f, void (*e)(), void *e_p);
int		 dispatcher_rmv_sel_e(int f);
int		 dispatcher_act_sel_e(int f);
int		 dispatcher_dct_sel_e(int f);
void	*dispatcher_add_tim(void (*r)(), void *arg, struct timeval  *t);
void	*dispatcher_add_utim(void (*r)(), void *arg, struct timeval  *t, DPT_TIM_ENT *u);
void	*dispatcher_rmv_tim(void (*r)(), void *arg);
int		 dispatcher_init_event(DPT_EVENT *e, int f, void (*d)());
int		 dispatcher_wait_event(void (*r)(), void *arg, DPT_EVENT *e);
int		 dispatcher_wait_uevent(void (*r)(), void *arg, DPT_EVENT *e, DPT_EVENT_ENT *u);
int		 dispatcher_rmv_event(void (*r)(), void *arg, DPT_EVENT *e);
int		 dispatcher_cancel_event(DPT_EVENT *e);
int		 dispatcher_signal_event(DPT_EVENT *e);
int		 dispatcher_unsignal_event(DPT_EVENT *e);
int		 dispatcher_init_signal(int s, void (*d)());
int		 dispatcher_wait_signal(void (*r)(), void *arg, int s);
int		 dispatcher_catch_signal(int* s,int len);
int		 dispatcher_act_signal(int* s, int len);
int		 dispatcher_dct_signal(int* s, int len);
int		 dispatcher_drop_signal(int* s, int len);
int		 dispatcher_rmv_signal(void (*r)(), void *arg, int s);
int		 dispatcher_cancel_signal(int s);
void	*dispatcher_add_def(void (*r)(), void *arg);
void	*dispatcher_rmv_def(void (*r)(), void *arg);
int		 dispatcher_debug(void *arg);

char	*dispatcher_check_for_timeout(QHD *q, DPT_TIM_ENT *b, void *arg);
void	 dispatcher_execute_event(DPT_EVENT_ENT *e);
int 	 dispatcher_tim_prio(QBF *c, QBF *a);	/* wrp - 2cd param was void * */
DPT_DEF_ENT *dispatcher_find_routine(QHD *q, DPT_DEF_ENT *b, void (*r)());
DPT_DEF_ENT	*dispatcher_find_routine();

#else
int			 dispatcher_init();
int		 	 dispatcher_init_sig_handling();
int			 dispatcher_chk();
void		 dispatcher_loop();
int			 dispatcher_add_sel_full();
int			 dispatcher_add_sel();
int			 dispatcher_rmv_sel();
int			 dispatcher_act_sel();
int			 dispatcher_dct_sel();
int			 dispatcher_add_sel_r();
int			 dispatcher_rmv_sel_r();
int			 dispatcher_act_sel_r();
int			 dispatcher_dct_sel_r();
int			 dispatcher_add_sel_w();
int			 dispatcher_rmv_sel_w();
int			 dispatcher_act_sel_w();
int			 dispatcher_dct_sel_w();
int			 dispatcher_add_sel_e();
int			 dispatcher_rmv_sel_e();
int			 dispatcher_act_sel_e();
int			 dispatcher_dct_sel_e();
void		*dispatcher_add_tim();
void		*dispatcher_rmv_tim();
int			dispatcher_init_event();
int			dispatcher_wait_event();
int			dispatcher_rmv_event();
int			dispatcher_cancel_event();
int			dispatcher_signal_event();
int			dispatcher_init_signal();
int			dispatcher_wait_signal();
int			dispatcher_catch_signal();
int			dispatcher_act_signal();
int			dispatcher_dct_signal();
int			dispatcher_drop_signal();
int			dispatcher_rmv_signal();
int			dispatcher_cancel_signal();
int			dispatcher_signal_signal();
int			dispatcher_unsignal_signal();
void		*dispatcher_add_def();
void		*dispatcher_rmv_def();

void		dispatcher_execute_event();
int 		 dispatcher_tim_prio();
char		*dispatcher_check_for_timeout();
DPT_DEF_ENT	*dispatcher_find_routine();
#endif

#endif


