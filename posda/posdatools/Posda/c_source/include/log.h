/*.
 *********************************************************************
 *			log.h	MIG Log Macros and Defines
 *

 *
 *********************************************************************
 *
 *	Programs can be compiled and/or run at any log level from 0 thru 9.
 *	Compiling at a given log level (TRACE_LEVEL) forces all log
 *	statements issued for a higher log level to be NULL statements.
 *
 *	Compiling with -DNO_LOGGING converts all log statements to
 *	printf() calls.  These do not print date/time stamp, source line,
 *	source file, prog id, etc.  This is useful for some very early
 *	unit testing and also for compiling source into utilities that
 *	do not use the standard MIG startup environment (i.e, they
 *	don't call std_startup(), don't use $LOG files, etc.).
 *
 *	When using the NO_LOGGING option logging levels are honored and 
 *	converted to printf()'s as follows:
 *
 *		- log_fatal(), log_internal(), and log_abnormal() are ALWAYS
 *		converted and printed, no matter what the TRACE_LEVEL value.
 *
 *		- log_info() and log_fnc_entry() are NEVER converted or printed,
 *		no matter what the value.
 *
 *		- all other log/trace levels are honored, being converted and
 *		printed only if the log level is high enough.
 *
 *	There are two forms of the logerr() functions.  If -DLOGNOLINES
 *	is set logerr() is called, instead of logerrln() which includes 
 *	the source file name and line number where the log() function 
 *	was invoked.
 *
 *	LOGLINES is overidden if NO_LOGGING is defined.
 *
 *********************************************************************
 */

#ifndef _LOG_
#define _LOG_

/*
 *********************************************************************
 *			DEFINITION OF THE LOGGING LEVELS
 *********************************************************************
*/

#define TL_FATAL		0	/* 'Crash-and-Burn' errors				*/
#define TL_INTERNAL		1	/* Internal consistency check failed	*/
#define	TL_ABNORMAL		2	/* Non-fatal, but unexpected, erros 	*/
#define	TL_EXCEPTION	3	/* Exception condition					*/
#define TL_TRANSACTION	4	/* Start/end of major process xactn's 	*/
#define TL_STATE_CHNG	5	/* Major program internal state changes	*/
#define	TL_EVENT		6	/* Event								*/
#define	TL_DEBUG		7	/* most inclusive debugging log level	*/
#define	TL_INFO			8	/* General info, debugging msgs			*/
#define TL_FNC_ENTRY	9	/* Informational function entry/exit 	*/

/*
 *	If not overidden in the make or compile, the default is to
 *	compile in ALL logging levels
*/
#ifndef TRACE_LEVEL
#define TRACE_LEVEL		9
#endif


/*
 *********************************************************************
 *			DEFINITION OF THE LOGGING CLASSES
 *********************************************************************
*/

#define	TC_DEFAULT		0	/* use TraceLevel value	*/

/*	For debuging use.	*/
#define	TC_USER1		1
#define	TC_USER2		2
#define	TC_USER3		3
#define	TC_USER4		4
#define	TC_USER5		5
#define	TC_USER6		6
#define	TC_USER7		7
#define	TC_USER8		8
#define	TC_USER9		9
#define	TC_USER10		10
#define	TC_USER11		11
#define	TC_USER12		12
#define	TC_USER13		13
#define	TC_USER14		14
#define	TC_USER15		15
#define	TC_USER16		16

/*	Main line code for program	*/ 
#define	TC_MAIN			17

/*	Major libs	*/
#define	TC_START_LIBS	32

#define	TC_UTILITIES	50

#define	TC_END_LIBS		63


#define	TC_MAX			128

#ifndef TRACE_CLASS
#define TRACE_CLASS		TC_DEFAULT
#endif

typedef	struct _TraceClassMap
{
	long		class;
	char		*name;
}	TraceClassMap;

#define	TC_NAMES											\
	{	{	TC_DEFAULT,		"Default" 			},			\
		{	TC_MAIN,		"Main"				},			\
															\
															\
		{	TC_USER1,		"User1"				},			\
		{	TC_USER2,		"User2"				},			\
		{	TC_USER3,		"User3"				},			\
		{	TC_USER4,		"User4"				},			\
		{	TC_USER5,		"User5"				},			\
		{	TC_USER6,		"User6"				},			\
		{	TC_USER7,		"User7"				},			\
		{	TC_USER8,		"User8"				},			\
		{	TC_USER9,		"User9"				},			\
		{	TC_USER10,		"User10"			},			\
		{	TC_USER11,		"User11"			},			\
		{	TC_USER12,		"User12"			},			\
		{	TC_USER13,		"User13"			},			\
		{	TC_USER14,		"User14"			},			\
		{	TC_USER15,		"User15"			},			\
		{	TC_USER16,		"User16"			},			\
	}
	
extern void   *MPaxCurrRou;


void log_dump(int level, void *adr, int len);
void log_dump_with_class(int class, int level, void *adr, int len);
char *get_progname(void);
char *get_logname(void);
int get_tlevel( int procid, int tlevel);
void close_log(void);
void reset_log(void);
void save_log(void);
void set_logsize(long size);
int set_loglevel(long level, long startClass, long endClass);
int logerr(va_alist);
int logerrln(va_alist);
int _logerr(int tlevel, int errcode, char *str);


#ifndef NO_LOGGING

#define		FNC_ENTRY(S)	register char *fn = "S";								\
							logerr1(TL_FNC_ENTRY, ERRNONE, "%s: ENTRY", fn);	\
							MPaxCurrRou = (void *) S;

#define		FNC_EXIT()		logerr1(TL_FNC_ENTRY, ERRNONE, "%s: EXIT", fn)

#if TRACE_LEVEL < 9
#define		FNC_RETURN(R)	return(R)
#else
#define		FNC_RETURN(R)	return((log_fnc_entry2("%s: EXIT ret %d",fn,R)),R)
#endif

/*
 ********************************************************************
 *	Standard form for error log() calls; checks for 
 *	LOGLINES and TRACE_LEVEL
 ********************************************************************
*/

/* macros for loging errors */

#ifdef  LOGNOLINES

#define	logerr0(l,e,f)							\
	logerr(TRACE_CLASS,l,e,f)
#define	logerr1(l,e,f,a1)						\
	logerr(TRACE_CLASS,l,e,f,a1)
#define	logerr2(l,e,f,a1,a2)					\
	logerr(TRACE_CLASS,l,e,f,a1,a2)
#define	logerr3(l,e,f,a1,a2,a3)					\
	logerr(TRACE_CLASS,l,e,f,a1,a2,a3)
#define	logerr4(l,e,f,a1,a2,a3,a4)				\
	logerr(TRACE_CLASS,l,e,f,a1,a2,a3,a4)
#define	logerr5(l,e,f,a1,a2,a3,a4,a5)			\
	logerr(TRACE_CLASS,l,e,f,a1,a2,a3,a4,a5)
#define	logerr6(l,e,f,a1,a2,a3,a4,a5,a6)		\
	logerr(TRACE_CLASS,l,e,f,a1,a2,a3,a4,a5,a6)
#define	logerr7(l,e,f,a1,a2,a3,a4,a5,a6,a7)		\
	logerr(TRACE_CLASS,l,e,f,a1,a2,a3,a4,a5,a6,a7)

#ifndef	ITOOLS
#define	logerr8(l,e,f,a1,a2,a3,a4,a5,a6,a7,a8)	\
	logerr(TRACE_CLASS,l,e,f,a1,a2,a3,a4,a5,a6,a7,a8)
#define	logerr9(l,e,f,a1,a2,a3,a4,a5,a6,a7,a8,a9)	\
	logerr(TRACE_CLASS,l,e,f,a1,a2,a3,a4,a5,a6,a7,a8,a9)
#endif	/* ITOOLS */
	
#else	/*	LOGNOLINES  */

#define	logerr0(l,e,f)	\
	logerrln(TRACE_CLASS,l,e,__FILE__,__LINE__,f)
#define	logerr1(l,e,f,a1)						\
	logerrln(TRACE_CLASS,l,e,__FILE__,__LINE__,f,a1)
#define	logerr2(l,e,f,a1,a2)					\
	logerrln(TRACE_CLASS,l,e,__FILE__,__LINE__,f,a1,a2)
#define	logerr3(l,e,f,a1,a2,a3)					\
	logerrln(TRACE_CLASS,l,e,__FILE__,__LINE__,f,a1,a2,a3)
#define	logerr4(l,e,f,a1,a2,a3,a4)				\
	logerrln(TRACE_CLASS,l,e,__FILE__,__LINE__,f,a1,a2,a3,a4)
#define	logerr5(l,e,f,a1,a2,a3,a4,a5)			\
	logerrln(TRACE_CLASS,l,e,__FILE__,__LINE__,f,a1,a2,a3,a4,a5)
#define	logerr6(l,e,f,a1,a2,a3,a4,a5,a6)		\
	logerrln(TRACE_CLASS,l,e,__FILE__,__LINE__,f,a1,a2,a3,a4,a5,a6)
#define	logerr7(l,e,f,a1,a2,a3,a4,a5,a6,a7)		\
	logerrln(TRACE_CLASS,l,e,__FILE__,__LINE__,f,a1,a2,a3,a4,a5,a6,a7)

#ifndef	ITOOLS
#define	logerr8(l,e,f,a1,a2,a3,a4,a5,a6,a7,a8)	\
	logerrln(TRACE_CLASS,l,e,__FILE__,__LINE__,f,a1,a2,a3,a4,a5,a6,a7,a8)
#define	logerr9(l,e,f,a1,a2,a3,a4,a5,a6,a7,a8,a9)	\
	logerrln(TRACE_CLASS,l,e,__FILE__,__LINE__,f,a1,a2,a3,a4,a5,a6,a7,a8,a9)
#endif	/* ITOOLS */

#endif	/* LOGNOLINES */


/* log fatal errors  */

#if TRACE_LEVEL >= TL_FATAL

#define log_fatal0(f)							\
	logerr0(TL_FATAL, MPaxError, f)
	
#define log_fatal1(f,a1)						\
	logerr1(TL_FATAL, MPaxError, f, a1)

#define log_fatal2(f,a1,a2)						\
	logerr2(TL_FATAL, MPaxError, f, a1, a2)

#define log_fatal3(f,a1,a2,a3)					\
	logerr3(TL_FATAL, MPaxError, f, a1, a2, a3)

#define log_fatal4(f,a1,a2,a3,a4)				\
	logerr4(TL_FATAL, MPaxError, f, a1, a2, a3, a4)

#define log_fatal5(f,a1,a2,a3,a4,a5)			\
	logerr5(TL_FATAL, MPaxError, f, a1, a2, a3, a4, a5)

#define log_fatal6(f,a1,a2,a3,a4,a5,a6)			\
	logerr6(TL_FATAL, MPaxError, f, a1, a2, a3, a4, a5, a6)

#define log_fatal7(f,a1,a2,a3,a4,a5,a6,a7)			\
	logerr7(TL_FATAL, MPaxError, f, a1, a2, a3, a4, a5, a6, a7)

#define log_fatal8(f,a1,a2,a3,a4,a5,a6,a7,a8)			\
	logerr8(TL_FATAL, MPaxError, f, a1, a2, a3, a4, a5, a6, a7, a8)

#else

#define log_fatal0(f)
#define log_fatal1(f,a1)
#define log_fatal2(f,a1,a2)
#define log_fatal3(f,a1,a2,a3)
#define log_fatal4(f,a1,a2,a3,a4)
#define log_fatal5(f,a1,a2,a3,a4,a5)
#define log_fatal6(f,a1,a2,a3,a4,a5,a6)
#define log_fatal7(f,a1,a2,a3,a4,a5,a6,a7)
#define log_fatal8(f,a1,a2,a3,a4,a5,a6,a7,a8)
#endif		



/* log internal errors  */

#if TRACE_LEVEL >= TL_INTERNAL

#define log_internal0(f)							\
	logerr0(TL_INTERNAL, MPaxError, f)
	
#define log_internal1(f,a1)						\
	logerr1(TL_INTERNAL, MPaxError, f, a1)

#define log_internal2(f,a1,a2)						\
	logerr2(TL_INTERNAL, MPaxError, f, a1, a2)

#define log_internal3(f,a1,a2,a3)					\
	logerr3(TL_INTERNAL, MPaxError, f, a1, a2, a3)

#define log_internal4(f,a1,a2,a3,a4)				\
	logerr4(TL_INTERNAL, MPaxError, f, a1, a2, a3, a4)

#define log_internal5(f,a1,a2,a3,a4,a5)			\
	logerr5(TL_INTERNAL, MPaxError, f, a1, a2, a3, a4, a5)

#define log_internal6(f,a1,a2,a3,a4,a5,a6)			\
	logerr6(TL_INTERNAL, MPaxError, f, a1, a2, a3, a4, a5, a6)

#define log_internal7(f,a1,a2,a3,a4,a5,a6,a7)			\
	logerr7(TL_INTERNAL, MPaxError, f, a1, a2, a3, a4, a5, a6, a7)

#define log_internal8(f,a1,a2,a3,a4,a5,a6,a7,a8)			\
	logerr8(TL_INTERNAL, MPaxError, f, a1, a2, a3, a4, a5, a6, a7, a8)

#define log_internal9(f,a1,a2,a3,a4,a5,a6,a7,a8,a9)			\
	logerr9(TL_INTERNAL, MPaxError, f, a1, a2, a3, a4, a5, a6, a7, a8, a9)

#else

#define log_internal0(f)
#define log_internal1(f,a1)
#define log_internal2(f,a1,a2)
#define log_internal3(f,a1,a2,a3)
#define log_internal4(f,a1,a2,a3,a4)
#define log_internal5(f,a1,a2,a3,a4,a5)
#define log_internal6(f,a1,a2,a3,a4,a5,a6)
#define log_internal7(f,a1,a2,a3,a4,a5,a6,a7)
#define log_internal8(f,a1,a2,a3,a4,a5,a6,a7,a8)
#define log_internal9(f,a1,a2,a3,a4,a5,a6,a7,a8,a9)

#endif	



/* log abnormal errors  */

#if TRACE_LEVEL >= TL_ABNORMAL

#define log_abnormal0(f)							\
	logerr0(TL_ABNORMAL, MPaxError, f)
	
#define log_abnormal1(f,a1)						\
	logerr1(TL_ABNORMAL, MPaxError, f, a1)

#define log_abnormal2(f,a1,a2)						\
	logerr2(TL_ABNORMAL, MPaxError, f, a1, a2)

#define log_abnormal3(f,a1,a2,a3)					\
	logerr3(TL_ABNORMAL, MPaxError, f, a1, a2, a3)

#define log_abnormal4(f,a1,a2,a3,a4)				\
	logerr4(TL_ABNORMAL, MPaxError, f, a1, a2, a3, a4)

#define log_abnormal5(f,a1,a2,a3,a4,a5)			\
	logerr5(TL_ABNORMAL, MPaxError, f, a1, a2, a3, a4, a5)

#define log_abnormal6(f,a1,a2,a3,a4,a5,a6)			\
	logerr6(TL_ABNORMAL, MPaxError, f, a1, a2, a3, a4, a5, a6)

#define log_abnormal7(f,a1,a2,a3,a4,a5,a6,a7)			\
	logerr7(TL_ABNORMAL, MPaxError, f, a1, a2, a3, a4, a5, a6, a7)

#define log_abnormal8(f,a1,a2,a3,a4,a5,a6,a7,a8)			\
	logerr8(TL_ABNORMAL, MPaxError, f, a1, a2, a3, a4, a5, a6, a7, a8)

#define log_abnormal9(f,a1,a2,a3,a4,a5,a6,a7,a8,a9)			\
	logerr9(TL_ABNORMAL, MPaxError, f, a1, a2, a3, a4, a5, a6, a7, a8, a9)

#else

#define log_abnormal0(f)
#define log_abnormal1(f,a1)
#define log_abnormal2(f,a1,a2)
#define log_abnormal3(f,a1,a2,a3)
#define log_abnormal4(f,a1,a2,a3,a4)
#define log_abnormal5(f,a1,a2,a3,a4,a5)
#define log_abnormal6(f,a1,a2,a3,a4,a5,a6)
#define log_abnormal7(f,a1,a2,a3,a4,a5,a6,a7)
#define log_abnormal8(f,a1,a2,a3,a4,a5,a6,a7,a8)
#define log_abnormal9(f,a1,a2,a3,a4,a5,a6,a7,a8,a9)
#endif		


/* log event errors  */

#if TRACE_LEVEL >= TL_EXCEPTION

#define log_exception0(f)							\
	logerr0(TL_EXCEPTION, MPaxError, f)
	
#define log_exception1(f,a1)						\
	logerr1(TL_EXCEPTION, MPaxError, f, a1)

#define log_exception2(f,a1,a2)						\
	logerr2(TL_EXCEPTION, MPaxError, f, a1, a2)

#define log_exception3(f,a1,a2,a3)					\
	logerr3(TL_EXCEPTION, MPaxError, f, a1, a2, a3)

#define log_exception4(f,a1,a2,a3,a4)				\
	logerr4(TL_EXCEPTION, MPaxError, f, a1, a2, a3, a4)

#define log_exception5(f,a1,a2,a3,a4,a5)			\
	logerr5(TL_EXCEPTION, MPaxError, f, a1, a2, a3, a4, a5)

#define log_exception6(f,a1,a2,a3,a4,a5,a6)			\
	logerr6(TL_EXCEPTION, MPaxError, f, a1, a2, a3, a4, a5, a6)

#define log_exception7(f,a1,a2,a3,a4,a5,a6,a7)			\
	logerr7(TL_EXCEPTION, MPaxError, f, a1, a2, a3, a4, a5, a6, a7)

#define log_exception8(f,a1,a2,a3,a4,a5,a6,a7,a8)			\
	logerr8(TL_EXCEPTION, MPaxError, f, a1, a2, a3, a4, a5, a6, a7, a8)

#define log_exception9(f,a1,a2,a3,a4,a5,a6,a7,a8,a9)			\
	logerr9(TL_EXCEPTION, MPaxError, f, a1, a2, a3, a4, a5, a6, a7, a8, a9)

#else

#define log_exception0(f)
#define log_exception1(f,a1)
#define log_exception2(f,a1,a2)
#define log_exception3(f,a1,a2,a3)
#define log_exception4(f,a1,a2,a3,a4)
#define log_exception5(f,a1,a2,a3,a4,a5)
#define log_exception6(f,a1,a2,a3,a4,a5,a6)
#define log_exception7(f,a1,a2,a3,a4,a5,a6,a7)
#define log_exception8(f,a1,a2,a3,a4,a5,a6,a7,a8)
#define log_exception9(f,a1,a2,a3,a4,a5,a6,a7,a8,a9)
#endif		


/* log event errors  */

#if TRACE_LEVEL >= TL_EVENT

#define log_event0(f)							\
	logerr0(TL_EVENT, ERRNONE, f)
	
#define log_event1(f,a1)						\
	logerr1(TL_EVENT, ERRNONE, f, a1)

#define log_event2(f,a1,a2)						\
	logerr2(TL_EVENT, ERRNONE, f, a1, a2)

#define log_event3(f,a1,a2,a3)					\
	logerr3(TL_EVENT, ERRNONE, f, a1, a2, a3)

#define log_event4(f,a1,a2,a3,a4)				\
	logerr4(TL_EVENT, ERRNONE, f, a1, a2, a3, a4)

#define log_event5(f,a1,a2,a3,a4,a5)			\
	logerr5(TL_EVENT, ERRNONE, f, a1, a2, a3, a4, a5)

#define log_event6(f,a1,a2,a3,a4,a5,a6)			\
	logerr6(TL_EVENT, ERRNONE, f, a1, a2, a3, a4, a5, a6)

#define log_event7(f,a1,a2,a3,a4,a5,a6,a7)			\
	logerr7(TL_EVENT, ERRNONE, f, a1, a2, a3, a4, a5, a6, a7)

#define log_event8(f,a1,a2,a3,a4,a5,a6,a7,a8)			\
	logerr8(TL_EVENT, ERRNONE, f, a1, a2, a3, a4, a5, a6, a7, a8)

#define log_event9(f,a1,a2,a3,a4,a5,a6,a7,a8,a9)			\
	logerr9(TL_EVENT, ERRNONE, f, a1, a2, a3, a4, a5, a6, a7, a8, a9)

#else

#define log_event0(f)
#define log_event1(f,a1)
#define log_event2(f,a1,a2)
#define log_event3(f,a1,a2,a3)
#define log_event4(f,a1,a2,a3,a4)
#define log_event5(f,a1,a2,a3,a4,a5)
#define log_event6(f,a1,a2,a3,a4,a5,a6)
#define log_event7(f,a1,a2,a3,a4,a5,a6,a7)
#define log_event8(f,a1,a2,a3,a4,a5,a6,a7,a8)
#define log_event9(f,a1,a2,a3,a4,a5,a6,a7,a8,a9)
#endif		


/* log transaction errors  */

#if TRACE_LEVEL >= TL_TRANSACTION

#define log_transaction0(f)							\
	logerr0(TL_TRANSACTION, ERRNONE, f)
	
#define log_transaction1(f,a1)						\
	logerr1(TL_TRANSACTION, ERRNONE, f, a1)

#define log_transaction2(f,a1,a2)						\
	logerr2(TL_TRANSACTION, ERRNONE, f, a1, a2)

#define log_transaction3(f,a1,a2,a3)					\
	logerr3(TL_TRANSACTION, ERRNONE, f, a1, a2, a3)

#define log_transaction4(f,a1,a2,a3,a4)				\
	logerr4(TL_TRANSACTION, ERRNONE, f, a1, a2, a3, a4)

#define log_transaction5(f,a1,a2,a3,a4,a5)			\
	logerr5(TL_TRANSACTION, ERRNONE, f, a1, a2, a3, a4, a5)

#define log_transaction6(f,a1,a2,a3,a4,a5,a6)			\
	logerr6(TL_TRANSACTION, ERRNONE, f, a1, a2, a3, a4, a5, a6)

#define log_transaction7(f,a1,a2,a3,a4,a5,a6,a7)			\
	logerr7(TL_TRANSACTION, ERRNONE, f, a1, a2, a3, a4, a5, a6, a7)

#define log_transaction8(f,a1,a2,a3,a4,a5,a6,a7,a8)			\
	logerr8(TL_TRANSACTION, ERRNONE, f, a1, a2, a3, a4, a5, a6, a7, a8)

#define log_transaction9(f,a1,a2,a3,a4,a5,a6,a7,a8,a9)			\
	logerr9(TL_TRANSACTION, ERRNONE, f, a1, a2, a3, a4, a5, a6, a7, a8, a9)

#else

#define log_transaction0(f)
#define log_transaction1(f,a1)
#define log_transaction2(f,a1,a2)
#define log_transaction3(f,a1,a2,a3)
#define log_transaction4(f,a1,a2,a3,a4)
#define log_transaction5(f,a1,a2,a3,a4,a5)
#define log_transaction6(f,a1,a2,a3,a4,a5,a6)
#define log_transaction7(f,a1,a2,a3,a4,a5,a6,a7)
#define log_transaction8(f,a1,a2,a3,a4,a5,a6,a7,a8)
#define log_transaction9(f,a1,a2,a3,a4,a5,a6,a7,a8,a9)
#endif		



/* log state_chng errors  */

#if TRACE_LEVEL >= TL_STATE_CHNG

#define log_state_chng0(f)							\
	logerr0(TL_STATE_CHNG, ERRNONE, f)
	
#define log_state_chng1(f,a1)						\
	logerr1(TL_STATE_CHNG, ERRNONE, f, a1)

#define log_state_chng2(f,a1,a2)						\
	logerr2(TL_STATE_CHNG, ERRNONE, f, a1, a2)

#define log_state_chng3(f,a1,a2,a3)					\
	logerr3(TL_STATE_CHNG, ERRNONE, f, a1, a2, a3)

#define log_state_chng4(f,a1,a2,a3,a4)				\
	logerr4(TL_STATE_CHNG, ERRNONE, f, a1, a2, a3, a4)

#define log_state_chng5(f,a1,a2,a3,a4,a5)			\
	logerr5(TL_STATE_CHNG, ERRNONE, f, a1, a2, a3, a4, a5)

#define log_state_chng6(f,a1,a2,a3,a4,a5,a6)			\
	logerr6(TL_STATE_CHNG, ERRNONE, f, a1, a2, a3, a4, a5, a6)

#define log_state_chng7(f,a1,a2,a3,a4,a5,a6,a7)			\
	logerr7(TL_STATE_CHNG, ERRNONE, f, a1, a2, a3, a4, a5, a6, a7)

#define log_state_chng8(f,a1,a2,a3,a4,a5,a6,a7,a8)			\
	logerr8(TL_STATE_CHNG, ERRNONE, f, a1, a2, a3, a4, a5, a6, a7, a8)

#define log_state_chng9(f,a1,a2,a3,a4,a5,a6,a7,a8,a9)			\
	logerr9(TL_STATE_CHNG, ERRNONE, f, a1, a2, a3, a4, a5, a6, a7, a8, a9)

#else

#define log_state_chng0(f)
#define log_state_chng1(f,a1)
#define log_state_chng2(f,a1,a2)
#define log_state_chng3(f,a1,a2,a3)
#define log_state_chng4(f,a1,a2,a3,a4)
#define log_state_chng5(f,a1,a2,a3,a4,a5)
#define log_state_chng6(f,a1,a2,a3,a4,a5,a6)
#define log_state_chng7(f,a1,a2,a3,a4,a5,a6,a7)
#define log_state_chng8(f,a1,a2,a3,a4,a5,a6,a7,a8)
#define log_state_chng9(f,a1,a2,a3,a4,a5,a6,a7,a8,a9)
#endif		



/* log debug info */

#if TRACE_LEVEL >= TL_DEBUG

#define log_debug0(f)							\
	logerr0(TL_DEBUG, ERRNONE, f)
	
#define log_debug1(f,a1)						\
	logerr1(TL_DEBUG, ERRNONE, f, a1)

#define log_debug2(f,a1,a2)						\
	logerr2(TL_DEBUG, ERRNONE, f, a1, a2)

#define log_debug3(f,a1,a2,a3)					\
	logerr3(TL_DEBUG, ERRNONE, f, a1, a2, a3)

#define log_debug4(f,a1,a2,a3,a4)				\
	logerr4(TL_DEBUG, ERRNONE, f, a1, a2, a3, a4)

#define log_debug5(f,a1,a2,a3,a4,a5)			\
	logerr5(TL_DEBUG, ERRNONE, f, a1, a2, a3, a4, a5)

#define log_debug6(f,a1,a2,a3,a4,a5, a6)			\
	logerr6(TL_DEBUG, ERRNONE, f, a1, a2, a3, a4, a5, a6)

#define log_debug7(f,a1,a2,a3,a4,a5,a6,a7)			\
	logerr7(TL_DEBUG, ERRNONE, f, a1, a2, a3, a4, a5, a6, a7)

#define log_debug8(f,a1,a2,a3,a4,a5,a6,a7,a8)			\
	logerr8(TL_DEBUG, ERRNONE, f, a1, a2, a3, a4, a5, a6, a7, a8)

#define log_debug9(f,a1,a2,a3,a4,a5,a6,a7,a8,a9)			\
	logerr9(TL_DEBUG, ERRNONE, f, a1, a2, a3, a4, a5, a6, a7, a8, a9)

#else

#define log_debug0(f)
#define log_debug1(f,a1)
#define log_debug2(f,a1,a2)
#define log_debug3(f,a1,a2,a3)
#define log_debug4(f,a1,a2,a3,a4)
#define log_debug5(f,a1,a2,a3,a4,a5)
#define log_debug6(f,a1,a2,a3,a4,a5,a6)
#define log_debug7(f,a1,a2,a3,a4,a5,a6,a7)
#define log_debug8(f,a1,a2,a3,a4,a5,a6,a7,a8)
#define log_debug9(f,a1,a2,a3,a4,a5,a6,a7,a8,a9)
#endif		



/* log info errors  */

#if TRACE_LEVEL >= TL_INFO

#define log_info0(f)							\
	logerr0(TL_INFO, ERRNONE, f)
	
#define log_info1(f,a1)						\
	logerr1(TL_INFO, ERRNONE, f, a1)

#define log_info2(f,a1,a2)						\
	logerr2(TL_INFO, ERRNONE, f, a1, a2)

#define log_info3(f,a1,a2,a3)					\
	logerr3(TL_INFO, ERRNONE, f, a1, a2, a3)

#define log_info4(f,a1,a2,a3,a4)				\
	logerr4(TL_INFO, ERRNONE, f, a1, a2, a3, a4)

#define log_info5(f,a1,a2,a3,a4,a5)			\
	logerr5(TL_INFO, ERRNONE, f, a1, a2, a3, a4, a5)

#define log_info6(f,a1,a2,a3,a4,a5, a6)			\
	logerr6(TL_INFO, ERRNONE, f, a1, a2, a3, a4, a5, a6)

#define log_info7(f,a1,a2,a3,a4,a5, a6, a7)			\
	logerr7(TL_INFO, ERRNONE, f, a1, a2, a3, a4, a5, a6, a7)

#define log_info8(f,a1,a2,a3,a4,a5, a6,a7,a8)			\
	logerr8(TL_INFO, ERRNONE, f, a1, a2, a3, a4, a5, a6,a7,a8)

#define log_info9(f,a1,a2,a3,a4,a5, a6,a7,a8,a9)			\
	logerr9(TL_INFO, ERRNONE, f, a1, a2, a3, a4, a5, a6,a7,a8,a9)

#else

#define log_info0(f)
#define log_info1(f,a1)
#define log_info2(f,a1,a2)
#define log_info3(f,a1,a2,a3)
#define log_info4(f,a1,a2,a3,a4)
#define log_info5(f,a1,a2,a3,a4,a5)
#define log_info6(f,a1,a2,a3,a4,a5, a6)
#define log_info7(f,a1,a2,a3,a4,a5, a6,a7)
#define log_info8(f,a1,a2,a3,a4,a5, a6,a7,a8)
#define log_info9(f,a1,a2,a3,a4,a5, a6,a7,a8,a9)
#endif		



/* log fnc_entry errors  */

#if TRACE_LEVEL >= TL_FNC_ENTRY

#define log_fnc_entry0(f)							\
	logerr0(TL_FNC_ENTRY, ERRNONE, f)
	
#define log_fnc_entry1(f,a1)						\
	logerr1(TL_FNC_ENTRY, ERRNONE, f, a1)

#define log_fnc_entry2(f,a1,a2)						\
	logerr2(TL_FNC_ENTRY, ERRNONE, f, a1, a2)

#define log_fnc_entry3(f,a1,a2,a3)					\
	logerr3(TL_FNC_ENTRY, ERRNONE, f, a1, a2, a3)

#define log_fnc_entry4(f,a1,a2,a3,a4)				\
	logerr4(TL_FNC_ENTRY, ERRNONE, f, a1, a2, a3, a4)

#define log_fnc_entry5(f,a1,a2,a3,a4,a5)			\
	logerr5(TL_FNC_ENTRY, ERRNONE, f, a1, a2, a3, a4, a5)

#define log_fnc_entry6(f,a1,a2,a3,a4,a5,a6)			\
	logerr6(TL_FNC_ENTRY, ERRNONE, f, a1, a2, a3, a4, a5,a6)

#define log_fnc_entry7(f,a1,a2,a3,a4,a5,a6,a7)			\
	logerr7(TL_FNC_ENTRY, ERRNONE, f, a1, a2, a3, a4, a5,a6,a7)

#define log_fnc_entry8(f,a1,a2,a3,a4,a5,a6,a7,a8)			\
	logerr8(TL_FNC_ENTRY, ERRNONE, f, a1, a2, a3, a4, a5,a6,a7,a8)

#define log_fnc_entry9(f,a1,a2,a3,a4,a5,a6,a7,a8,a9)			\
	logerr9(TL_FNC_ENTRY, ERRNONE, f, a1, a2, a3, a4, a5,a6,a7,a8,a9)

#else

#define log_fnc_entry0(f)
#define log_fnc_entry1(f,a1)
#define log_fnc_entry2(f,a1,a2)
#define log_fnc_entry3(f,a1,a2,a3)
#define log_fnc_entry4(f,a1,a2,a3,a4)
#define log_fnc_entry5(f,a1,a2,a3,a4,a5)
#define log_fnc_entry6(f,a1,a2,a3,a4,a5,a6)
#define log_fnc_entry7(f,a1,a2,a3,a4,a5,a6,a7)
#define log_fnc_entry8(f,a1,a2,a3,a4,a5,a6,a7,a8)
#define log_fnc_entry9(f,a1,a2,a3,a4,a5,a6,a7,a8,a9)
#endif


/*
 *****************************************************************
 *		Assetion definition used by DAMA/DIF
 *****************************************************************
*/
#undef assert
#define assert(condition,f,action)            \
    if (!(condition)) {                       \
      log_abnormal1("ASSERT FAILED-- %s", f); \
      action;                                 \
    }


#else

/*
 **************************************************************
 *	printf() version of log() definitions for when NO_LOGGING
 *	is defined
 **************************************************************
*/

#ifndef logout
#define	logout stderr
#endif

#include <stdio.h>
#define log_fnc_entry1(f,a1)
#define log_fnc_entry2(f,a1,a2)

#define		FNC_ENTRY(S)	register char *fn = "S";							\
							log_fnc_entry1("%s: ENTRY",fn);						\
							MPaxCurrRou = (void *) S;

#define		FNC_EXIT()		log_fnc_entry1("%s: EXIT",fn)

#define		FNC_RETURN(R)	return(R)

/*	for log_dump.c in mpax lib.	*/
#define	logerr3(l,e,f,a1,a2,a3)					\
	( fprintf(logout, f, a1, a2, a3),			\
	  fprintf(logout, "\n") )

/*
 *	Within the context of NO_LOGGING enabled, log levels TL_FATAL
 *	TL_INTERNAL, and TL_ABNORMAL are always converted and printed
*/

#define log_fatal0(f)						\
	( fprintf(logout, f),								\
	  fprintf(logout, "\n") )
	
#define log_fatal1(f,a1)					\
	( fprintf(logout, f, a1),							\
	  fprintf(logout, "\n") )

#define log_fatal2(f,a1,a2)					\
	( fprintf(logout, f, a1, a2),						\
	  fprintf(logout, "\n") )

#define log_fatal3(f,a1,a2,a3)				\
	( fprintf(logout, f, a1, a2, a3),					\
	  fprintf(logout, "\n") )

#define log_fatal4(f,a1,a2,a3,a4)			\
	( fprintf(logout, f, a1, a2, a3, a4),				\
	  fprintf(logout, "\n") )

#define log_fatal5(f,a1,a2,a3,a4,a5)		\
	( fprintf(logout, f, a1, a2, a3, a4, a5),			\
	  fprintf(logout, "\n") )

#define log_fatal6(f,a1,a2,a3,a4,a5,a6)		\
	( fprintf(logout, f, a1, a2, a3, a4, a5, a6),		\
	  fprintf(logout, "\n") )

#define log_internal0(f)					\
	( fprintf(logout, f),								\
	  fprintf(logout, "\n") )
	
#define log_internal1(f,a1)					\
	( fprintf(logout, f, a1),							\
	  fprintf(logout, "\n") )

#define log_internal2(f,a1,a2)				\
	( fprintf(logout, f, a1, a2),						\
	  fprintf(logout, "\n") )

#define log_internal3(f,a1,a2,a3)			\
	( fprintf(logout, f, a1, a2, a3),					\
	  fprintf(logout, "\n") )

#define log_internal4(f,a1,a2,a3,a4)		\
	( fprintf(logout, f, a1, a2, a3, a4),				\
	  fprintf(logout, "\n") )

#define log_internal5(f,a1,a2,a3,a4,a5)		\
	( fprintf(logout, f, a1, a2, a3, a4, a5),			\
	  fprintf(logout, "\n") )

#define log_internal6(f,a1,a2,a3,a4,a5,a6)	\
	( fprintf(logout, f, a1, a2, a3, a4, a5, a6),		\
	  fprintf(logout, "\n") )

#define log_internal7(f,a1,a2,a3,a4,a5,a6,a7)\
	( fprintf(logout, f, a1, a2, a3, a4, a5, a6, a7),	\
	  fprintf(logout, "\n") )

#define log_internal8(f,a1,a2,a3,a4,a5,a6,a7,a8)\
	( fprintf(logout, f, a1, a2, a3, a4, a5, a6, a7, a8),	\
	  fprintf(logout, "\n") )

#define log_abnormal0(f)					\
	( fprintf(logout, f),								\
	  fprintf(logout, "\n") )
	
#define log_abnormal1(f,a1)					\
	( fprintf(logout, f, a1),							\
	  fprintf(logout, "\n") )

#define log_abnormal2(f,a1,a2)				\
	( fprintf(logout, f, a1, a2),						\
	  fprintf(logout, "\n") )

#define log_abnormal3(f,a1,a2,a3)			\
	( fprintf(logout, f, a1, a2, a3),					\
	  fprintf(logout, "\n") )

#define log_abnormal4(f,a1,a2,a3,a4)		\
	( fprintf(logout, f, a1, a2, a3, a4),				\
	  fprintf(logout, "\n") )

#define log_abnormal5(f,a1,a2,a3,a4,a5)		\
	( fprintf(logout, f, a1, a2, a3, a4, a5),			\
	  fprintf(logout, "\n") )

#define log_abnormal6(f,a1,a2,a3,a4,a5,a6)	\
	( fprintf(logout, f, a1, a2, a3, a4, a5, a6),		\
	  fprintf(logout, "\n") )

#define log_abnormal7(f,a1,a2,a3,a4,a5,a6,a7)\
	( fprintf(logout, f, a1, a2, a3, a4, a5, a6, a7),	\
	  fprintf(logout, "\n") )

#define log_abnormal8(f,a1,a2,a3,a4,a5,a6,a7,a8)\
	( fprintf(logout, f, a1, a2, a3, a4, a5, a6, a7, a8),	\
	  fprintf(logout, "\n") )


#if TRACE_LEVEL >= TL_EXCEPTION

#define log_exception0(f)					\
	( fprintf(logout, f),								\
	  fprintf(logout, "\n") )
	
#define log_exception1(f,a1)				\
	( fprintf(logout, f, a1),							\
	  fprintf(logout, "\n") )

#define log_exception2(f,a1,a2)				\
	( fprintf(logout, f, a1, a2),						\
	  fprintf(logout, "\n") )

#define log_exception3(f,a1,a2,a3)			\
	( fprintf(logout, f, a1, a2, a3),					\
	  fprintf(logout, "\n") )

#define log_exception4(f,a1,a2,a3,a4)		\
	( fprintf(logout, f, a1, a2, a3, a4),				\
	  fprintf(logout, "\n") )

#define log_exception5(f,a1,a2,a3,a4,a5)	\
	( fprintf(logout, f, a1, a2, a3, a4, a5),			\
	  fprintf(logout, "\n") )

#define log_exception6(f,a1,a2,a3,a4,a5,a6)	\
	( fprintf(logout, f, a1, a2, a3, a4, a5, a6),		\
	  fprintf(logout, "\n") )

#define log_exception7(f,a1,a2,a3,a4,a5,a6,a7)\
	( fprintf(logout, f, a1, a2, a3, a4, a5, a6, a7),	\
	  fprintf(logout, "\n") )

#define log_exception8(f,a1,a2,a3,a4,a5,a6,a7,a8)\
	( fprintf(logout, f, a1, a2, a3, a4, a5, a6, a7, a8),	\
	  fprintf(logout, "\n") )

#else

#define log_exception0(f)
#define log_exception1(f,a1)
#define log_exception2(f,a1,a2)
#define log_exception3(f,a1,a2,a3)
#define log_exception4(f,a1,a2,a3,a4)
#define log_exception5(f,a1,a2,a3,a4,a5)
#define log_exception6(f,a1,a2,a3,a4,a5,a6)
#define log_exception7(f,a1,a2,a3,a4,a5,a6,a7)
#define log_exception8(f,a1,a2,a3,a4,a5,a6,a7,a8)

#endif


#if TRACE_LEVEL >= TL_EVENT

#define log_event0(f)						\
	( fprintf(logout, f),								\
	  fprintf(logout, "\n") )
	
#define log_event1(f,a1)					\
	( fprintf(logout, f, a1),							\
	  fprintf(logout, "\n") )

#define log_event2(f,a1,a2)					\
	( fprintf(logout, f, a1, a2),						\
	  fprintf(logout, "\n") )

#define log_event3(f,a1,a2,a3)				\
	( fprintf(logout, f, a1, a2, a3),					\
	  fprintf(logout, "\n") )

#define log_event4(f,a1,a2,a3,a4)			\
	( fprintf(logout, f, a1, a2, a3, a4),				\
	  fprintf(logout, "\n") )

#define log_event5(f,a1,a2,a3,a4,a5)		\
	( fprintf(logout, f, a1, a2, a3, a4, a5),			\
	  fprintf(logout, "\n") )

#define log_event6(f,a1,a2,a3,a4,a5,a6)		\
	( fprintf(logout, f, a1, a2, a3, a4, a5, a6),		\
	  fprintf(logout, "\n") )

#define log_event7(f,a1,a2,a3,a4,a5,a6,a7)	\
	( fprintf(logout, f, a1, a2, a3, a4, a5, a6, a7),	\
	  fprintf(logout, "\n") )

#define log_event8(f,a1,a2,a3,a4,a5,a6,a7,a8)\
	( fprintf(logout, f, a1, a2, a3, a4, a5, a6, a7, a8),\
	  fprintf(logout, "\n") )

#else

#define log_event0(f)
#define log_event1(f,a1)
#define log_event2(f,a1,a2)
#define log_event3(f,a1,a2,a3)
#define log_event4(f,a1,a2,a3,a4)
#define log_event5(f,a1,a2,a3,a4,a5)
#define log_event6(f,a1,a2,a3,a4,a5,a6)
#define log_event7(f,a1,a2,a3,a4,a5,a6,a7)
#define log_event8(f,a1,a2,a3,a4,a5,a6,a7,a8)

#endif



#if	TRACE_LEVEL >= TL_TRANSACTION

#define log_transaction0(f)					\
	( fprintf(logout, f),								\
	  fprintf(logout, "\n") )
	
#define log_transaction1(f,a1)				\
	( fprintf(logout, f, a1),							\
	  fprintf(logout, "\n") )

#define log_transaction2(f,a1,a2)			\
	( fprintf(logout, f, a1, a2),						\
	  fprintf(logout, "\n") )

#define log_transaction3(f,a1,a2,a3)		\
	( fprintf(logout, f, a1, a2, a3),					\
	  fprintf(logout, "\n") )

#define log_transaction4(f,a1,a2,a3,a4)		\
	( fprintf(logout, f, a1, a2, a3, a4),				\
	  fprintf(logout, "\n") )

#define log_transaction5(f,a1,a2,a3,a4,a5)	\
	( fprintf(logout, f, a1, a2, a3, a4, a5),			\
	  fprintf(logout, "\n") )

#define log_transaction6(f,a1,a2,a3,a4,a5,a6)\
	( fprintf(logout, f, a1, a2, a3, a4, a5, a6),		\
	  fprintf(logout, "\n") )

#define log_transaction7(f,a1,a2,a3,a4,a5,a6,a7)\
	( fprintf(logout, f, a1, a2, a3, a4, a5, a6, a7),		\
	  fprintf(logout, "\n") )

#define log_transaction8(f,a1,a2,a3,a4,a5,a6,a7,a8)\
	( fprintf(logout, f, a1, a2, a3, a4, a5, a6, a7, a8),	\
	  fprintf(logout, "\n") )

#define log_transaction9(f,a1,a2,a3,a4,a5,a6,a7,a8, a9)\
	( fprintf(logout, f, a1, a2, a3, a4, a5, a6, a7, a8, a9),	\
	  fprintf(logout, "\n") )

#else

#define log_transaction0(f)
#define log_transaction1(f,a1)
#define log_transaction2(f,a1,a2)
#define log_transaction3(f,a1,a2,a3)
#define log_transaction4(f,a1,a2,a3,a4)
#define log_transaction5(f,a1,a2,a3,a4,a5)
#define log_transaction6(f,a1,a2,a3,a4,a5,a6)
#define log_transaction7(f,a1,a2,a3,a4,a5,a6,a7)
#define log_transaction8(f,a1,a2,a3,a4,a5,a6,a7,a8)
#define log_transaction9(f,a1,a2,a3,a4,a5,a6,a7,a8, a9)

#endif


#if TRACE_LEVEL >= TL_STATE_CHNG

#define log_state_chng0(f)					\
	( fprintf(logout, f),								\
	  fprintf(logout, "\n") )
	
#define log_state_chng1(f,a1)				\
	( fprintf(logout, f, a1),							\
	  fprintf(logout, "\n") )

#define log_state_chng2(f,a1,a2)			\
	( fprintf(logout, f, a1, a2),						\
	  fprintf(logout, "\n") )

#define log_state_chng3(f,a1,a2,a3)			\
	( fprintf(logout, f, a1, a2, a3),					\
	  fprintf(logout, "\n") )

#define log_state_chng4(f,a1,a2,a3,a4)		\
	( fprintf(logout, f, a1, a2, a3, a4),				\
	  fprintf(logout, "\n") )

#define log_state_chng5(f,a1,a2,a3,a4,a5)	\
	( fprintf(logout, f, a1, a2, a3, a4, a5),			\
	  fprintf(logout, "\n") )

#define log_state_chng6(f,a1,a2,a3,a4,a5,a6)\
	( fprintf(logout, f, a1, a2, a3, a4, a5, a6),		\
	  fprintf(logout, "\n") )

#define log_state_chng7(f,a1,a2,a3,a4,a5,a6,a7)\
	( fprintf(logout, f, a1, a2, a3, a4, a5, a6, a7),	\
	  fprintf(logout, "\n") )

#define log_state_chng8(f,a1,a2,a3,a4,a5,a6,a7,a8)\
	( fprintf(logout, f, a1, a2, a3, a4, a5, a6, a7, a8),	\
	  fprintf(logout, "\n") )

#else

#define log_state_chng0(f)
#define log_state_chng1(f,a1)
#define log_state_chng2(f,a1,a2)
#define log_state_chng3(f,a1,a2,a3)
#define log_state_chng4(f,a1,a2,a3,a4)
#define log_state_chng5(f,a1,a2,a3,a4,a5)
#define log_state_chng6(f,a1,a2,a3,a4,a5,a6)
#define log_state_chng7(f,a1,a2,a3,a4,a5,a6,a7)
#define log_state_chng8(f,a1,a2,a3,a4,a5,a6,a7,a8)

#endif


#if TRACE_LEVEL >= TL_DEBUG

#define log_debug0(f)						\
	( fprintf(logout, f),								\
	  fprintf(logout, "\n") )
	
#define log_debug1(f,a1)					\
	( fprintf(logout, f, a1),							\
	  fprintf(logout, "\n") )

#define log_debug2(f,a1,a2)					\
	( fprintf(logout, f, a1, a2),						\
	  fprintf(logout, "\n") )

#define log_debug3(f,a1,a2,a3)				\
	( fprintf(logout, f, a1, a2, a3),					\
	  fprintf(logout, "\n") )

#define log_debug4(f,a1,a2,a3,a4)			\
	( fprintf(logout, f, a1, a2, a3, a4),				\
	  fprintf(logout, "\n") )

#define log_debug5(f,a1,a2,a3,a4,a5)		\
	( fprintf(logout, f, a1, a2, a3, a4, a5),			\
	  fprintf(logout, "\n") )

#define log_debug6(f,a1,a2,a3,a4,a5, a6)	\
	( fprintf(logout, f, a1, a2, a3, a4, a5, a6),		\
	  fprintf(logout, "\n") )

#define log_debug7(f,a1,a2,a3,a4,a5,a6,a7)	\
	( fprintf(logout, f, a1, a2, a3, a4, a5, a6, a7),	\
	  fprintf(logout, "\n") )

#define log_debug8(f,a1,a2,a3,a4,a5,a6,a7,a8)\
	( fprintf(logout, f, a1, a2, a3, a4, a5, a6, a7, a8),\
	  fprintf(logout, "\n") )

#else

#define log_debug0(f)
#define log_debug1(f,a1)
#define log_debug2(f,a1,a2)
#define log_debug3(f,a1,a2,a3)
#define log_debug4(f,a1,a2,a3,a4)
#define log_debug5(f,a1,a2,a3,a4,a5)
#define log_debug6(f,a1,a2,a3,a4,a5, a6)
#define log_debug7(f,a1,a2,a3,a4,a5, a6, a7)
#define log_debug8(f,a1,a2,a3,a4,a5,a6,a7,a8)

#endif


#if TRACE_LEVEL >= TL_INFO

#define log_info0(f)						\
	( fprintf(logout, f),								\
	  fprintf(logout, "\n") )
	
#define log_info1(f,a1)					\
	( fprintf(logout, f, a1),							\
	  fprintf(logout, "\n") )

#define log_info2(f,a1,a2)					\
	( fprintf(logout, f, a1, a2),						\
	  fprintf(logout, "\n") )

#define log_info3(f,a1,a2,a3)				\
	( fprintf(logout, f, a1, a2, a3),					\
	  fprintf(logout, "\n") )

#define log_info4(f,a1,a2,a3,a4)			\
	( fprintf(logout, f, a1, a2, a3, a4),				\
	  fprintf(logout, "\n") )

#define log_info5(f,a1,a2,a3,a4,a5)		\
	( fprintf(logout, f, a1, a2, a3, a4, a5),			\
	  fprintf(logout, "\n") )

#define log_info6(f,a1,a2,a3,a4,a5, a6)	\
	( fprintf(logout, f, a1, a2, a3, a4, a5, a6),		\
	  fprintf(logout, "\n") )

#define log_info7(f,a1,a2,a3,a4,a5,a6,a7)	\
	( fprintf(logout, f, a1, a2, a3, a4, a5, a6, a7),	\
	  fprintf(logout, "\n") )

#define log_info8(f,a1,a2,a3,a4,a5,a6,a7,a8)\
	( fprintf(logout, f, a1, a2, a3, a4, a5, a6, a7, a8),\
	  fprintf(logout, "\n") )

#define log_info9(f,a1,a2,a3,a4,a5,a6,a7,a8,a9)\
	( fprintf(logout, f, a1, a2, a3, a4, a5, a6, a7, a8, a9),\
	  fprintf(logout, "\n") )

#else

#define log_info0(f)
#define log_info1(f,a1)
#define log_info2(f,a1,a2)
#define log_info3(f,a1,a2,a3)
#define log_info4(f,a1,a2,a3,a4)
#define log_info5(f,a1,a2,a3,a4,a5)
#define log_info6(f,a1,a2,a3,a4,a5,a6)
#define log_info7(f,a1,a2,a3,a4,a5,a6,a7)
#define log_info8(f,a1,a2,a3,a4,a5,a6,a7,a8)
#define log_info9(f,a1,a2,a3,a4,a5,a6,a7,a8,a9)

#endif


/*
 *	Within the context of NO_LOGGING, log level TL_FNC_ENTRY is NEVER printed
*/


#define log_fnc_entry0(f)
#define log_fnc_entry1(f,a1)
#define log_fnc_entry2(f,a1,a2)
#define log_fnc_entry3(f,a1,a2,a3)
#define log_fnc_entry4(f,a1,a2,a3,a4)
#define log_fnc_entry5(f,a1,a2,a3,a4,a5)
#define log_fnc_entry6(f,a1,a2,a3,a4,a5,a6)
#define log_fnc_entry7(f,a1,a2,a3,a4,a5,a6,a7)
#define log_fnc_entry8(f,a1,a2,a3,a4,a5,a6,a7,a8)
#define log_fnc_entry9(f,a1,a2,a3,a4,a5,a6,a7,a8,a9)


/*	for log_dump.c in mpax lib.	*/
#define	logerr3(l,e,f,a1,a2,a3)					\
	( fprintf(logout, f, a1, a2, a3),			\
	  fprintf(logout, "\n") )

/*
 *	Within the context of NO_LOGGING enabled, log levels TL_FATAL
 *	TL_INTERNAL, and TL_ABNORMAL are always converted and printed
*/

#define log_fatal0(f)						\
	( fprintf(logout, "File \"%s\"; Line %d; # ", __FILE__, __LINE__), \
	  fprintf(logout, f),								\
	  fprintf(logout, "\n") )
	
#define log_fatal1(f,a1)					\
	( fprintf(logout, "File \"%s\"; Line %d; # ", __FILE__, __LINE__), \
	  fprintf(logout, f, a1),							\
	  fprintf(logout, "\n") )

#define log_fatal2(f,a1,a2)					\
	( fprintf(logout, "File \"%s\"; Line %d; # ", __FILE__, __LINE__), \
	  fprintf(logout, f, a1, a2),						\
	  fprintf(logout, "\n") )

#define log_fatal3(f,a1,a2,a3)				\
	( fprintf(logout, "File \"%s\"; Line %d; # ", __FILE__, __LINE__), \
	  fprintf(logout, f, a1, a2, a3),					\
	  fprintf(logout, "\n") )

#define log_fatal4(f,a1,a2,a3,a4)			\
	( fprintf(logout, "File \"%s\"; Line %d; # ", __FILE__, __LINE__), \
	  fprintf(logout, f, a1, a2, a3, a4),				\
	  fprintf(logout, "\n") )

#define log_fatal5(f,a1,a2,a3,a4,a5)		\
	( fprintf(logout, "File \"%s\"; Line %d; # ", __FILE__, __LINE__), \
	  fprintf(logout, f, a1, a2, a3, a4, a5),			\
	  fprintf(logout, "\n") )

#define log_fatal6(f,a1,a2,a3,a4,a5,a6)		\
	( fprintf(logout, "File \"%s\"; Line %d; # ", __FILE__, __LINE__), \
	  fprintf(logout, f, a1, a2, a3, a4, a5, a6),		\
	  fprintf(logout, "\n") )

#define log_internal0(f)					\
	( fprintf(logout, "File \"%s\"; Line %d; # ", __FILE__, __LINE__), \
	  fprintf(logout, f),								\
	  fprintf(logout, "\n") )
	
#define log_internal1(f,a1)					\
	( fprintf(logout, "File \"%s\"; Line %d; # ", __FILE__, __LINE__), \
	  fprintf(logout, f, a1),							\
	  fprintf(logout, "\n") )

#define log_internal2(f,a1,a2)				\
	( fprintf(logout, "File \"%s\"; Line %d; # ", __FILE__, __LINE__), \
	  fprintf(logout, f, a1, a2),						\
	  fprintf(logout, "\n") )

#define log_internal3(f,a1,a2,a3)			\
	( fprintf(logout, "File \"%s\"; Line %d; # ", __FILE__, __LINE__), \
	  fprintf(logout, f, a1, a2, a3),					\
	  fprintf(logout, "\n") )

#define log_internal4(f,a1,a2,a3,a4)		\
	( fprintf(logout, "File \"%s\"; Line %d; # ", __FILE__, __LINE__), \
	  fprintf(logout, f, a1, a2, a3, a4),				\
	  fprintf(logout, "\n") )

#define log_internal5(f,a1,a2,a3,a4,a5)		\
	( fprintf(logout, "File \"%s\"; Line %d; # ", __FILE__, __LINE__), \
	  fprintf(logout, f, a1, a2, a3, a4, a5),			\
	  fprintf(logout, "\n") )

#define log_internal6(f,a1,a2,a3,a4,a5,a6)	\
	( fprintf(logout, "File \"%s\"; Line %d; # ", __FILE__, __LINE__), \
	  fprintf(logout, f, a1, a2, a3, a4, a5, a6),		\
	  fprintf(logout, "\n") )

#define log_internal7(f,a1,a2,a3,a4,a5,a6,a7)\
	( fprintf(logout, "File \"%s\"; Line %d; # ", __FILE__, __LINE__), \
	  fprintf(logout, f, a1, a2, a3, a4, a5, a6, a7),	\
	  fprintf(logout, "\n") )

#define log_internal8(f,a1,a2,a3,a4,a5,a6,a7,a8)\
	( fprintf(logout, "File \"%s\"; Line %d; # ", __FILE__, __LINE__), \
	  fprintf(logout, f, a1, a2, a3, a4, a5, a6, a7, a8),	\
	  fprintf(logout, "\n") )

#define log_abnormal0(f)					\
	( fprintf(logout, "File \"%s\"; Line %d; # ", __FILE__, __LINE__), \
	  fprintf(logout, f),								\
	  fprintf(logout, "\n") )
	
#define log_abnormal1(f,a1)					\
	( fprintf(logout, "File \"%s\"; Line %d; # ", __FILE__, __LINE__), \
	  fprintf(logout, f, a1),							\
	  fprintf(logout, "\n") )

#define log_abnormal2(f,a1,a2)				\
	( fprintf(logout, "File \"%s\"; Line %d; # ", __FILE__, __LINE__), \
	  fprintf(logout, f, a1, a2),						\
	  fprintf(logout, "\n") )

#define log_abnormal3(f,a1,a2,a3)			\
	( fprintf(logout, "File \"%s\"; Line %d; # ", __FILE__, __LINE__), \
	  fprintf(logout, f, a1, a2, a3),					\
	  fprintf(logout, "\n") )

#define log_abnormal4(f,a1,a2,a3,a4)		\
	( fprintf(logout, "File \"%s\"; Line %d; # ", __FILE__, __LINE__), \
	  fprintf(logout, f, a1, a2, a3, a4),				\
	  fprintf(logout, "\n") )

#define log_abnormal5(f,a1,a2,a3,a4,a5)		\
	( fprintf(logout, "File \"%s\"; Line %d; # ", __FILE__, __LINE__), \
	  fprintf(logout, f, a1, a2, a3, a4, a5),			\
	  fprintf(logout, "\n") )

#define log_abnormal6(f,a1,a2,a3,a4,a5,a6)	\
	( fprintf(logout, "File \"%s\"; Line %d; # ", __FILE__, __LINE__), \
	  fprintf(logout, f, a1, a2, a3, a4, a5, a6),		\
	  fprintf(logout, "\n") )

#define log_abnormal7(f,a1,a2,a3,a4,a5,a6,a7)\
	( fprintf(logout, "File \"%s\"; Line %d; # ", __FILE__, __LINE__), \
	  fprintf(logout, f, a1, a2, a3, a4, a5, a6, a7),	\
	  fprintf(logout, "\n") )

#define log_abnormal8(f,a1,a2,a3,a4,a5,a6,a7,a8)\
	( fprintf(logout, "File \"%s\"; Line %d; # ", __FILE__, __LINE__), \
	  fprintf(logout, f, a1, a2, a3, a4, a5, a6, a7, a8),	\
	  fprintf(logout, "\n") )


#if TRACE_LEVEL >= TL_EXCEPTION

#define log_exception0(f)					\
	( fprintf(logout, "File \"%s\"; Line %d; # ", __FILE__, __LINE__), \
	  fprintf(logout, f),								\
	  fprintf(logout, "\n") )
	
#define log_exception1(f,a1)				\
	( fprintf(logout, "File \"%s\"; Line %d; # ", __FILE__, __LINE__), \
	  fprintf(logout, f, a1),							\
	  fprintf(logout, "\n") )

#define log_exception2(f,a1,a2)				\
	( fprintf(logout, "File \"%s\"; Line %d; # ", __FILE__, __LINE__), \
	  fprintf(logout, f, a1, a2),						\
	  fprintf(logout, "\n") )

#define log_exception3(f,a1,a2,a3)			\
	( fprintf(logout, "File \"%s\"; Line %d; # ", __FILE__, __LINE__), \
	  fprintf(logout, f, a1, a2, a3),					\
	  fprintf(logout, "\n") )

#define log_exception4(f,a1,a2,a3,a4)		\
	( fprintf(logout, "File \"%s\"; Line %d; # ", __FILE__, __LINE__), \
	  fprintf(logout, f, a1, a2, a3, a4),				\
	  fprintf(logout, "\n") )

#define log_exception5(f,a1,a2,a3,a4,a5)	\
	( fprintf(logout, "File \"%s\"; Line %d; # ", __FILE__, __LINE__), \
	  fprintf(logout, f, a1, a2, a3, a4, a5),			\
	  fprintf(logout, "\n") )

#define log_exception6(f,a1,a2,a3,a4,a5,a6)	\
	( fprintf(logout, "File \"%s\"; Line %d; # ", __FILE__, __LINE__), \
	  fprintf(logout, f, a1, a2, a3, a4, a5, a6),		\
	  fprintf(logout, "\n") )

#define log_exception7(f,a1,a2,a3,a4,a5,a6,a7)\
	( fprintf(logout, "File \"%s\"; Line %d; # ", __FILE__, __LINE__), \
	  fprintf(logout, f, a1, a2, a3, a4, a5, a6, a7),	\
	  fprintf(logout, "\n") )

#define log_exception8(f,a1,a2,a3,a4,a5,a6,a7,a8)\
	( fprintf(logout, "File \"%s\"; Line %d; # ", __FILE__, __LINE__), \
	  fprintf(logout, f, a1, a2, a3, a4, a5, a6, a7, a8),	\
	  fprintf(logout, "\n") )

#else

#define log_exception0(f)
#define log_exception1(f,a1)
#define log_exception2(f,a1,a2)
#define log_exception3(f,a1,a2,a3)
#define log_exception4(f,a1,a2,a3,a4)
#define log_exception5(f,a1,a2,a3,a4,a5)
#define log_exception6(f,a1,a2,a3,a4,a5,a6)
#define log_exception7(f,a1,a2,a3,a4,a5,a6,a7)
#define log_exception8(f,a1,a2,a3,a4,a5,a6,a7,a8)

#endif


#if TRACE_LEVEL >= TL_EVENT

#define log_event0(f)						\
	( fprintf(logout, "File \"%s\"; Line %d; # ", __FILE__, __LINE__), \
	  fprintf(logout, f),								\
	  fprintf(logout, "\n") )
	
#define log_event1(f,a1)					\
	( fprintf(logout, "File \"%s\"; Line %d; # ", __FILE__, __LINE__), \
	  fprintf(logout, f, a1),							\
	  fprintf(logout, "\n") )

#define log_event2(f,a1,a2)					\
	( fprintf(logout, "File \"%s\"; Line %d; # ", __FILE__, __LINE__), \
	  fprintf(logout, f, a1, a2),						\
	  fprintf(logout, "\n") )

#define log_event3(f,a1,a2,a3)				\
	( fprintf(logout, "File \"%s\"; Line %d; # ", __FILE__, __LINE__), \
	  fprintf(logout, f, a1, a2, a3),					\
	  fprintf(logout, "\n") )

#define log_event4(f,a1,a2,a3,a4)			\
	( fprintf(logout, "File \"%s\"; Line %d; # ", __FILE__, __LINE__), \
	  fprintf(logout, f, a1, a2, a3, a4),				\
	  fprintf(logout, "\n") )

#define log_event5(f,a1,a2,a3,a4,a5)		\
	( fprintf(logout, "File \"%s\"; Line %d; # ", __FILE__, __LINE__), \
	  fprintf(logout, f, a1, a2, a3, a4, a5),			\
	  fprintf(logout, "\n") )

#define log_event6(f,a1,a2,a3,a4,a5,a6)		\
	( fprintf(logout, "File \"%s\"; Line %d; # ", __FILE__, __LINE__), \
	  fprintf(logout, f, a1, a2, a3, a4, a5, a6),		\
	  fprintf(logout, "\n") )

#define log_event7(f,a1,a2,a3,a4,a5,a6,a7)	\
	( fprintf(logout, "File \"%s\"; Line %d; # ", __FILE__, __LINE__), \
	  fprintf(logout, f, a1, a2, a3, a4, a5, a6, a7),	\
	  fprintf(logout, "\n") )

#define log_event8(f,a1,a2,a3,a4,a5,a6,a7,a8)\
	( fprintf(logout, "File \"%s\"; Line %d; # ", __FILE__, __LINE__), \
	  fprintf(logout, f, a1, a2, a3, a4, a5, a6, a7, a8),\
	  fprintf(logout, "\n") )

#else

#define log_event0(f)
#define log_event1(f,a1)
#define log_event2(f,a1,a2)
#define log_event3(f,a1,a2,a3)
#define log_event4(f,a1,a2,a3,a4)
#define log_event5(f,a1,a2,a3,a4,a5)
#define log_event6(f,a1,a2,a3,a4,a5,a6)
#define log_event7(f,a1,a2,a3,a4,a5,a6,a7)
#define log_event8(f,a1,a2,a3,a4,a5,a6,a7,a8)

#endif



#if	TRACE_LEVEL >= TL_TRANSACTION

#define log_transaction0(f)					\
	( fprintf(logout, "File \"%s\"; Line %d; # ", __FILE__, __LINE__), \
	  fprintf(logout, f),								\
	  fprintf(logout, "\n") )
	
#define log_transaction1(f,a1)				\
	( fprintf(logout, "File \"%s\"; Line %d; # ", __FILE__, __LINE__), \
	  fprintf(logout, f, a1),							\
	  fprintf(logout, "\n") )

#define log_transaction2(f,a1,a2)			\
	( fprintf(logout, "File \"%s\"; Line %d; # ", __FILE__, __LINE__), \
	  fprintf(logout, f, a1, a2),						\
	  fprintf(logout, "\n") )

#define log_transaction3(f,a1,a2,a3)		\
	( fprintf(logout, "File \"%s\"; Line %d; # ", __FILE__, __LINE__), \
	  fprintf(logout, f, a1, a2, a3),					\
	  fprintf(logout, "\n") )

#define log_transaction4(f,a1,a2,a3,a4)		\
	( fprintf(logout, "File \"%s\"; Line %d; # ", __FILE__, __LINE__), \
	  fprintf(logout, f, a1, a2, a3, a4),				\
	  fprintf(logout, "\n") )

#define log_transaction5(f,a1,a2,a3,a4,a5)	\
	( fprintf(logout, "File \"%s\"; Line %d; # ", __FILE__, __LINE__), \
	  fprintf(logout, f, a1, a2, a3, a4, a5),			\
	  fprintf(logout, "\n") )

#define log_transaction6(f,a1,a2,a3,a4,a5,a6)\
	( fprintf(logout, "File \"%s\"; Line %d; # ", __FILE__, __LINE__), \
	  fprintf(logout, f, a1, a2, a3, a4, a5, a6),		\
	  fprintf(logout, "\n") )

#define log_transaction7(f,a1,a2,a3,a4,a5,a6,a7)\
	( fprintf(logout, "File \"%s\"; Line %d; # ", __FILE__, __LINE__), \
	  fprintf(logout, f, a1, a2, a3, a4, a5, a6, a7),		\
	  fprintf(logout, "\n") )

#define log_transaction8(f,a1,a2,a3,a4,a5,a6,a7,a8)\
	( fprintf(logout, "File \"%s\"; Line %d; # ", __FILE__, __LINE__), \
	  fprintf(logout, f, a1, a2, a3, a4, a5, a6, a7, a8),	\
	  fprintf(logout, "\n") )

#define log_transaction9(f,a1,a2,a3,a4,a5,a6,a7,a8,a9)\
	( fprintf(logout, "File \"%s\"; Line %d; # ", __FILE__, __LINE__), \
	  fprintf(logout, f, a1, a2, a3, a4, a5, a6, a7, a8,a9),	\
	  fprintf(logout, "\n") )

#else

#define log_transaction0(f)
#define log_transaction1(f,a1)
#define log_transaction2(f,a1,a2)
#define log_transaction3(f,a1,a2,a3)
#define log_transaction4(f,a1,a2,a3,a4)
#define log_transaction5(f,a1,a2,a3,a4,a5)
#define log_transaction6(f,a1,a2,a3,a4,a5,a6)
#define log_transaction7(f,a1,a2,a3,a4,a5,a6,a7)
#define log_transaction8(f,a1,a2,a3,a4,a5,a6,a7,a8)
#define log_transaction8(f,a1,a2,a3,a4,a5,a6,a7,a8,a9)

#endif


#if TRACE_LEVEL >= TL_STATE_CHNG

#define log_state_chng0(f)					\
	( fprintf(logout, "File \"%s\"; Line %d; # ", __FILE__, __LINE__), \
	  fprintf(logout, f),								\
	  fprintf(logout, "\n") )
	
#define log_state_chng1(f,a1)				\
	( fprintf(logout, "File \"%s\"; Line %d; # ", __FILE__, __LINE__), \
	  fprintf(logout, f, a1),							\
	  fprintf(logout, "\n") )

#define log_state_chng2(f,a1,a2)			\
	( fprintf(logout, "File \"%s\"; Line %d; # ", __FILE__, __LINE__), \
	  fprintf(logout, f, a1, a2),						\
	  fprintf(logout, "\n") )

#define log_state_chng3(f,a1,a2,a3)			\
	( fprintf(logout, "File \"%s\"; Line %d; # ", __FILE__, __LINE__), \
	  fprintf(logout, f, a1, a2, a3),					\
	  fprintf(logout, "\n") )

#define log_state_chng4(f,a1,a2,a3,a4)		\
	( fprintf(logout, "File \"%s\"; Line %d; # ", __FILE__, __LINE__), \
	  fprintf(logout, f, a1, a2, a3, a4),				\
	  fprintf(logout, "\n") )

#define log_state_chng5(f,a1,a2,a3,a4,a5)	\
	( fprintf(logout, "File \"%s\"; Line %d; # ", __FILE__, __LINE__), \
	  fprintf(logout, f, a1, a2, a3, a4, a5),			\
	  fprintf(logout, "\n") )

#define log_state_chng6(f,a1,a2,a3,a4,a5,a6)\
	( fprintf(logout, "File \"%s\"; Line %d; # ", __FILE__, __LINE__), \
	  fprintf(logout, f, a1, a2, a3, a4, a5, a6),		\
	  fprintf(logout, "\n") )

#define log_state_chng7(f,a1,a2,a3,a4,a5,a6,a7)\
	( fprintf(logout, "File \"%s\"; Line %d; # ", __FILE__, __LINE__), \
	  fprintf(logout, f, a1, a2, a3, a4, a5, a6, a7),	\
	  fprintf(logout, "\n") )

#define log_state_chng8(f,a1,a2,a3,a4,a5,a6,a7,a8)\
	( fprintf(logout, "File \"%s\"; Line %d; # ", __FILE__, __LINE__), \
	  fprintf(logout, f, a1, a2, a3, a4, a5, a6, a7, a8),	\
	  fprintf(logout, "\n") )

#else

#define log_state_chng0(f)
#define log_state_chng1(f,a1)
#define log_state_chng2(f,a1,a2)
#define log_state_chng3(f,a1,a2,a3)
#define log_state_chng4(f,a1,a2,a3,a4)
#define log_state_chng5(f,a1,a2,a3,a4,a5)
#define log_state_chng6(f,a1,a2,a3,a4,a5,a6)
#define log_state_chng7(f,a1,a2,a3,a4,a5,a6,a7)
#define log_state_chng8(f,a1,a2,a3,a4,a5,a6,a7,a8)

#endif


#if TRACE_LEVEL >= TL_DEBUG

#define log_debug0(f)						\
	( fprintf(logout, "File \"%s\"; Line %d; # ", __FILE__, __LINE__), \
	  fprintf(logout, f),								\
	  fprintf(logout, "\n") )
	
#define log_debug1(f,a1)					\
	( fprintf(logout, "File \"%s\"; Line %d; # ", __FILE__, __LINE__), \
	  fprintf(logout, f, a1),							\
	  fprintf(logout, "\n") )

#define log_debug2(f,a1,a2)					\
	( fprintf(logout, "File \"%s\"; Line %d; # ", __FILE__, __LINE__), \
	  fprintf(logout, f, a1, a2),						\
	  fprintf(logout, "\n") )

#define log_debug3(f,a1,a2,a3)				\
	( fprintf(logout, "File \"%s\"; Line %d; # ", __FILE__, __LINE__), \
	  fprintf(logout, f, a1, a2, a3),					\
	  fprintf(logout, "\n") )

#define log_debug4(f,a1,a2,a3,a4)			\
	( fprintf(logout, "File \"%s\"; Line %d; # ", __FILE__, __LINE__), \
	  fprintf(logout, f, a1, a2, a3, a4),				\
	  fprintf(logout, "\n") )

#define log_debug5(f,a1,a2,a3,a4,a5)		\
	( fprintf(logout, "File \"%s\"; Line %d; # ", __FILE__, __LINE__), \
	  fprintf(logout, f, a1, a2, a3, a4, a5),			\
	  fprintf(logout, "\n") )

#define log_debug6(f,a1,a2,a3,a4,a5, a6)	\
	( fprintf(logout, "File \"%s\"; Line %d; # ", __FILE__, __LINE__), \
	  fprintf(logout, f, a1, a2, a3, a4, a5, a6),		\
	  fprintf(logout, "\n") )

#define log_debug7(f,a1,a2,a3,a4,a5,a6,a7)	\
	( fprintf(logout, "File \"%s\"; Line %d; # ", __FILE__, __LINE__), \
	  fprintf(logout, f, a1, a2, a3, a4, a5, a6, a7),	\
	  fprintf(logout, "\n") )

#define log_debug8(f,a1,a2,a3,a4,a5,a6,a7,a8)\
	( fprintf(logout, "File \"%s\"; Line %d; # ", __FILE__, __LINE__), \
	  fprintf(logout, f, a1, a2, a3, a4, a5, a6, a7, a8),\
	  fprintf(logout, "\n") )

#else

#define log_debug0(f)
#define log_debug1(f,a1)
#define log_debug2(f,a1,a2)
#define log_debug3(f,a1,a2,a3)
#define log_debug4(f,a1,a2,a3,a4)
#define log_debug5(f,a1,a2,a3,a4,a5)
#define log_debug6(f,a1,a2,a3,a4,a5, a6)
#define log_debug7(f,a1,a2,a3,a4,a5, a6, a7)
#define log_debug8(f,a1,a2,a3,a4,a5,a6,a7,a8)

#endif


#if TRACE_LEVEL >= TL_INFO

#define log_info0(f)						\
	( fprintf(logout, "File \"%s\"; Line %d; # ", __FILE__, __LINE__), \
	  fprintf(logout, f),								\
	  fprintf(logout, "\n") )
	
#define log_info1(f,a1)					\
	( fprintf(logout, "File \"%s\"; Line %d; # ", __FILE__, __LINE__), \
	  fprintf(logout, f, a1),							\
	  fprintf(logout, "\n") )

#define log_info2(f,a1,a2)					\
	( fprintf(logout, "File \"%s\"; Line %d; # ", __FILE__, __LINE__), \
	  fprintf(logout, f, a1, a2),						\
	  fprintf(logout, "\n") )

#define log_info3(f,a1,a2,a3)				\
	( fprintf(logout, "File \"%s\"; Line %d; # ", __FILE__, __LINE__), \
	  fprintf(logout, f, a1, a2, a3),					\
	  fprintf(logout, "\n") )

#define log_info4(f,a1,a2,a3,a4)			\
	( fprintf(logout, "File \"%s\"; Line %d; # ", __FILE__, __LINE__), \
	  fprintf(logout, f, a1, a2, a3, a4),				\
	  fprintf(logout, "\n") )

#define log_info5(f,a1,a2,a3,a4,a5)		\
	( fprintf(logout, "File \"%s\"; Line %d; # ", __FILE__, __LINE__), \
	  fprintf(logout, f, a1, a2, a3, a4, a5),			\
	  fprintf(logout, "\n") )

#define log_info6(f,a1,a2,a3,a4,a5, a6)	\
	( fprintf(logout, "File \"%s\"; Line %d; # ", __FILE__, __LINE__), \
	  fprintf(logout, f, a1, a2, a3, a4, a5, a6),		\
	  fprintf(logout, "\n") )

#define log_info7(f,a1,a2,a3,a4,a5,a6,a7)	\
	( fprintf(logout, "File \"%s\"; Line %d; # ", __FILE__, __LINE__), \
	  fprintf(logout, f, a1, a2, a3, a4, a5, a6, a7),	\
	  fprintf(logout, "\n") )

#define log_info8(f,a1,a2,a3,a4,a5,a6,a7,a8)\
	( fprintf(logout, "File \"%s\"; Line %d; # ", __FILE__, __LINE__), \
	  fprintf(logout, f, a1, a2, a3, a4, a5, a6, a7, a8),\
	  fprintf(logout, "\n") )

#define log_info9(f,a1,a2,a3,a4,a5,a6,a7,a8,a9)\
	( fprintf(logout, "File \"%s\"; Line %d; # ", __FILE__, __LINE__), \
	  fprintf(logout, f, a1, a2, a3, a4, a5, a6, a7, a8, a9),\
	  fprintf(logout, "\n") )

#else

#define log_info0(f)
#define log_info1(f,a1)
#define log_info2(f,a1,a2)
#define log_info3(f,a1,a2,a3)
#define log_info4(f,a1,a2,a3,a4)
#define log_info5(f,a1,a2,a3,a4,a5)
#define log_info6(f,a1,a2,a3,a4,a5,a6)
#define log_info7(f,a1,a2,a3,a4,a5,a6,a7)
#define log_info8(f,a1,a2,a3,a4,a5,a6,a7,a8)
#define log_info9(f,a1,a2,a3,a4,a5,a6,a7,a8,a9)

#endif


/*
 *	Within the context of NO_LOGGING, log level TL_FNC_ENTRY is NEVER printed
*/


#define log_fnc_entry0(f)
#define log_fnc_entry1(f,a1)
#define log_fnc_entry2(f,a1,a2)
#define log_fnc_entry3(f,a1,a2,a3)
#define log_fnc_entry4(f,a1,a2,a3,a4)
#define log_fnc_entry5(f,a1,a2,a3,a4,a5)
#define log_fnc_entry6(f,a1,a2,a3,a4,a5,a6)
#define log_fnc_entry7(f,a1,a2,a3,a4,a5,a6,a7)
#define log_fnc_entry8(f,a1,a2,a3,a4,a5,a6,a7,a8)
#define log_fnc_entry9(f,a1,a2,a3,a4,a5,a6,a7,a8,a9)



#endif					/* ifndef NO_LOGGING */


#endif

