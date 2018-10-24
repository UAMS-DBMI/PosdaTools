#ifndef LINT

#endif
extern	char	libRelease[];
static	char	*LibRelease = libRelease;
static unsigned long gLastLogTick;
/*.
 **********************************************************************
 * 
 *	logerr.c		 error logging functions
 * 
 *	DATA ABSTRACTION:
 * 
 *	This module contains functions related to error logging
 *
 *	FUNCTIONS IN THIS MODULE:
 * 
 *	get_progname	return ASCII program name for process
 *	logerr			log error to $LOG file based on current and indicated
 *					trace levels
 *	logerrln		log error to $LOG file, including all fields of logerr()
 *					AND the file name and line number indicating from where 
 *					this function was called
 *  reset_log       resets the log file
 *  save_log        saves the log file to a time-stamped filename
 *	set_logsize		set the maximum size of the $LOG file before error messages
 *					are wrapped to the start of the file
 *	t_open			(static) initialize and open trace log file
 *	t_print			(static) function to print standard-format message to
 *					trace log file
 *	t_eopen			(static) open error process
 *	t_eprint		(static) write error message to err log process
 * 	
 *	GLOBAL DATA DEFINED IN THIS MODULE:
 *
 *	FILE	*stdtrace;	file pointer of trace error log file
 *	int		TraceOpen;	non-zero if trace log file has been opened
 *
 *	EXTERNALS REFERENCED:
 *
 *	int	Trace_to_Term;	if non-zero, log error msgs go to stderr and the trace
 *						file is not opened
 *
 *	SEE ALSO:
 *
 *	startup()
 *************************************************************************
*/

/*LINTLIBRARY*/

#include	<stdio.h>

#ifdef THINK_C
#define va_dcl		short va_alist;
#include 	<StdArg.h>
#else
#include	<varargs.h>
#endif

#include	"global.h"
#include	"log.h"
#include	<values.h>
#include	<string.h>
#include	<ctype.h>
#ifdef MOTO
#include <bsd_port.h>
#endif
#if defined (SYSV)
#include	<time.h>
#endif
#include	<sys/time.h>

#include	"mpax.h"
#include	"errors.h"
#include	"shd_mem.h"
#include	"startup.h"
#include	"presaddr.h"
#include	"netaddr.h"

#define MAXLOGMSG	1024		/* Maximum size of a log message	*/
/*
 *	Global data definitions
*/
FILE	*stdtrace = NULL;	/* trace file descriptor						*/
		short	gFlushToDisk = 1;

BYTE	TraceLevels[TC_MAX] = {0};
int		TraceOpen = 0;		/* non-zero if trace log file opened			*/
int		LogFileLineNumbers = 1;	/* file and line number logging on by default */

static long	MaxLogSize = MAXLOGSIZE;	/* can be reset via set_logsize()	*/

static int	LogLine=1;			/* line number counter for log lines	*/

/*
 *	External references
*/

extern	int	errno;			/* extrernals for referencing	*/ 
extern	int	 sys_nerr;		/* extrernals for referencing	*/ 
extern	char *sys_errlist[];		/*	system error messages		*/

extern	char	*getname();
#ifdef	ANSI_PROTO
static int t_open(void);
static int t_print(int err, char *msg, int tlevel);
#endif

/*.
 *****************************************************************************
 *
 *	get_program		return pointer to program name of indicated program 
 *					id index
 *
 *	SYNOPSIS:
 *
 *	char *get_progname(procid)
 *		int	procid;					program index id into shared debug array
 *
 *	RETURNS:
 *
 *	char * -	pointer to ASCII program name (of form AAAAAAnn)
 *
 *	EXTERNALS REFERENCED:
 *
 *****************************************************************************
*/

char *get_progname()
{
	if ( NetName == NULL  ||  NetName->point_name[0] == 0 )
		return("NONE");
	else
		return(NetName->point_name);
}

/*.
 *****************************************************************************
 *
 *	get_program		return pointer to program name of indicated program 
 *					id index
 *
 *	SYNOPSIS:
 *
 *	char *get_progname(procid)
 *		int	procid;					program index id into shared debug array
 *
 *	RETURNS:
 *
 *	char * -	pointer to ASCII program name (of form AAAAAAnn)
 *
 *	EXTERNALS REFERENCED:
 *
 *****************************************************************************
*/

char *get_logname()
{
	static	char	logname[128];

	strcpy(logname, "${LOG}");
	strcat(logname, PATHNAME_DELIMITER_STR);
	strcat(logname,get_progname());
	strcpy(logname,getname(logname));
	return(logname);
}

/*
 *****************************************************************************
 *
 *  close_log      close the error log file
 *
 *  SYNOPSIS:
 *
 *  void close_log()
 *
 *  RETURNS:
 *
 *  none.
 *
 *  EXTERNALS REFERENCED:
 *
 *  int TraceOpen;          set to zero when trace file successfully closed.
 *	int	stdtrace;			trace log file FILE pointer
 *
 *****************************************************************************
*/
void close_log()
{
	register	char 	*logname;
				char	newname[128];

    /*
     * don't need to do anything if log file not opened or disabled
     */
    if ( TraceOpen == 0 )
        return;
    if ( TraceDisabled != 0 )
        return;

    /*
     * close the log and set the global variable, TraceOpen=0, so that
     * on the next call of t_print, t_open will be called.
     */
    fclose(stdtrace);
    TraceOpen = 0;

    return;
}

/*
 *****************************************************************************
 *
 *  reset_log      reset the error log file
 *
 *  SYNOPSIS:
 *
 *  void reset_log()
 *
 *  RETURNS:
 *
 *  none.
 *
 *  EXTERNALS REFERENCED:
 *
 *  int TraceOpen;          set to zero when trace file successfully closed.
 *	int	stdtrace;			trace log file FILE pointer
 *
 *****************************************************************************
*/
void reset_log()
{
	register	char 	*logname;
				char	newname[128];

	close_log();

	logname = get_logname();
	strcpy(newname, "${LOG}/.old/");
	strcat(newname,get_progname());
	strcpy(newname,getname(newname));

	link(logname, newname);
	unlink(logname);
	log_abnormal1("Reset log, old log: '%s'",newname);

    return;
}



/*
 *****************************************************************************
 *
 *  save_log      save the error log file
 *
 *  SYNOPSIS:
 *
 *  void save_log()
 *
 *  RETURNS:
 *
 *  none.
 *
 *  EXTERNALS REFERENCED:
 *
 *****************************************************************************
*/
void save_log()
{
	register	long		rc;
				struct tm	*tmstr;
				char		oldname[256], newname[256];
	extern		int     	errno;

#ifdef	SYSV
	long			tod;
#else
	struct	timeval	tp;
#endif

    /*
     * don't need to do anything if log file not opened or disabled
     */
    if ( TraceOpen == 0 )
        return;
    if ( TraceDisabled != 0 )
        return;


#ifdef	SYSV
	tod = (long)time(0);	/* get current time */
	tmstr = (struct tm*)localtime(&tod);
#else
	gettimeofday(&tp,NULL);	/* get current time */
	tmstr = (struct tm*)localtime(&tp.tv_sec);
	tp.tv_usec /= 10000;
#endif

	strncpy(oldname,get_logname(), sizeof(oldname));

    sprintf(newname, "%s.%02d%02d.%02d%02d%02d",
            oldname, tmstr->tm_mon+1, tmstr->tm_mday,
            tmstr->tm_hour, tmstr->tm_min, tmstr->tm_sec);

    /*
     * close the log and set the global variable, TraceOpen=0, so that
     * on the next call of t_print, t_open will be called.
     */
    fclose(stdtrace);
    TraceOpen = 0;

	link(oldname, newname);
	unlink(oldname);
    errno = 0;

	log_abnormal1("Save log, old log: '%s'", newname);

    return;
}

/*
 *****************************************************************************
 *
 *  set_logsize		set maximum log size
 *
 *  SYNOPSIS:
 *
 *  void set_logsize(siz)
 *		long siz;
 *
 *  RETURNS:
 *
 *  none.
 *
 *	NOTES
 *
 *	This function should be called immediately after startup().  It does not
 *	alter the physical length of the log file.  It just resets the variable 
 *	used by logerr() functions when looking to see if the log file has grow
 *	to or past its maximum allowable size.  If the log file has grown to 200K 
 *	bytes and set_logsize(25000L) is called the log will not shrink.  Log 
 *	calls will just begin rapping at 25000 bytes and the rest of the old data
 *	past 25000 will remain in the file.
 *****************************************************************************
*/
void set_logsize(siz)
	long	siz;
{
	MaxLogSize = siz;
	return;
}

/******************************************************************************
 *
 *  set_file_line_logging
 *		Turns the logging of filenames and line
 *		numbers, in the file where the log statement
 *		was called from, on or off. Where 0 is off and
 *		non 0 is on.
 *
 *  SYNOPSIS:
 *
 *  void set_file_line_logging( flag )
 *		int flag;
 *
 *  RETURNS:
 *  none.
 *
 *  EXTERNALS REFERENCED:
 *  int  LogFileLineNumbers
 *
 ******************************************************************************/
void set_file_line_logging( flag )
	int	flag;
{
	LogFileLineNumbers = flag;
	return;
}

/*
 *****************************************************************************
 *
 *  set_loglevel		set log level for class range.
 *
 *  SYNOPSIS:
 *
 *  void set_loglevel(siz)
 *		long siz;
 *
 *  RETURNS:
 *
 *  none.
 *
 *	NOTES
 *
 *	This function is used to set specific values for log classes.
 *****************************************************************************
*/
int set_loglevel(level, startClass, endClass)
	long	level, startClass, endClass;
{
	if (startClass > endClass)
	{
		startClass = TC_DEFAULT;
		endClass = TC_MAX-1;
	}
	else
	{
		if (startClass < TC_DEFAULT)
			startClass = TC_DEFAULT;
		if (endClass > TC_MAX-1)
			endClass = TC_MAX-1;
	}
	memset(&TraceLevels[startClass],level,endClass-startClass+1);
	if (startClass == TC_DEFAULT)
		TraceLevel = level;
		
	return(0);
}



/*.
 ****************************************************************************
 *
 *	logerr		log error message to trace/debug log file
 *
 *	SYNOPSIS:
 *
 *	int logerr ( tlevel, errcode, format, [args ... ])
 *		int		tlevel;		indicated trace level at which to log error
 *		int		errcode;	error message number
 *		char    *format;	format string for printf
 *		int		args;		args to printf (number and type dependent
 *							  on format argument)
 *
 *	Tlevel, errcode, and format are REQUIRED arguments.  There only
 *	needs to be 'args' arguments if required by format string.
 *
 *	RETURNS:
 *
 *	 0		error message logged
 *	-1		unable to log error message (MPaxError set to error code)
 *
 *	DESCRIPTION
 *
 *	This function logs errors messages to the trace/debug log file for the
 *	program indicated by its program id MyID.
 *	The trace file for any function will be a
 *	file named in the form "${LOG}/AAAAnn", where ${LOG} is the environment
 *	variable defining the directory in which to create the log file, "AAAA"
 *	is the basic ASCII program id as defined in id.h, and "nn" is the index
 *	id defined at process creation (via the -i nn command line option).  If
 *	"nn" is zero then the file name will be of the form "${LOG}/AAAA".
 *
 *	Messages are place sequentially in the log file in a standard format.  If
 *	the total size of the file exceeds MAXLOGSIZE bytes (defined in shd_mem.h)
 *	then the file is re-wound and messages start over at the 1st of the file.
 *	The messages are numbered sequentially to make it evident when rewinding
 *	has occurred.
 *
 *	If the indicated trace/debug level of the error is zero (0) the message
 *	is considered critical and is also logged to the system log file via
 *	the logerr() function and err process.
 *
 *	The format of messages in this file is:
 *
 *	PROGnn (msg #) Error: nnn <description of error number, if any>
 *	PROGnn (msg #)   <user supplied error message ...>
 *
 *	ALGORITHM:	
 *
 *	Use vprintf format and varargs to allow printing of variable formats.
 *	If indicatead trace level <= current program trace level print msg 
 *		to stderr (get program trace level from shared memory).
 *	If indicated trace level == 0 pass error code and formated error
 *		message on to logerr().
 *
 *	EXTERNALS REFERENCED:
 *
 *	stdtrace		trace log file descriptor
 *	MyID			program index id
 ****************************************************************************
.*/

/*VARARGS4*/
int logerr(va_alist)
	va_dcl
{
	va_list		args;
	int			classTraceLevel;

	/*
	 * the function arguments will be extracted from varargs list and
	 * placed here
	*/
register	int		tclass;				/* indicated trace level				*/
register	int		tlevel;				/* indicated trace level				*/
register	int		errcode;			/* error code 							*/
register	char	*format;			/* format strint (printf(3) style)		*/
	
	char	buf[MAXLOGMSG+1];		/* buffer for formatted message string	*/

	/*
	 * Extract the required arguments from the va_alist
	*/
	va_start(args);
	
/*
 *	See if trace level is such that we are supposed to print this
 *	error message
 */
	tclass = va_arg(args, int);
	tlevel = va_arg(args, int);
	if ( tlevel < 0 )
		  tlevel = 0;
	classTraceLevel = TraceLevel;
	if ( tclass > TC_DEFAULT  &&  tclass < TC_MAX && TraceLevels[tclass] != 0)
		  classTraceLevel = TraceLevels[tclass];
	if ( tlevel > 0  &&  classTraceLevel < tlevel ) 
	{
		va_end(args);
		return(0);
	}

	errcode = va_arg(args, int);
	format = va_arg(args, char *);

	/*
	 * Go ahead and format the message so we can get out of 'va_arg' mode
	*/
	vsprintf(buf, format, args);

	va_end(args);
	
	return(_logerr( tlevel, errcode, buf));
}

/*.
 ****************************************************************************
 *
 *	logerrln		log error messages with file and line numbers
 *
 *	SYNOPSIS:
 *
 *	int logerrln( tlevel, errcode, file, line, format, [args ... ])
 *		int		tlevel;		indicated trace level at which to log error
 *		int		errcode;	error message number
 *		char 	*file;		file name
 *		int		line;		line number
 *		char    *format;	format string for printf
 *		int		args;		args to printf (number and type dependent
 *							  on format argument)
 *
 *	There only needs to be 'args' arguments if required by format string.
 *
 *	RETURNS:
 *
 *	 0		error message logged
 *	-1		unable to log error message (MPaxError set to error code)
 *
 *	DESCRIPTION
 *
 *	This function is equivalent to logerr() except that the souce file name and
 *	line number are included as arguments.
 *
 ****************************************************************************
.*/

/*VARARGS4*/
int logerrln(va_alist)
	va_dcl
{
	va_list		args;
	register	int	index;
	int			classTraceLevel;
/*
 * the function arguments will be extracted from varargs list and
 * placed here
 */
register	int		tclass;				/* indicated trace level			*/
register	int		tlevel;				/* indicated trace level			*/
register	int		errcode;			/* error code 						*/
register	char 	*file;
register	int		line;
register	char	*format;			/* format strint (printf(3) style)	*/
			char	buf[MAXLOGMSG+1];	/* buf for formatted message string	*/

/*
 * Extract the required arguments from the va_alist
 */
	va_start(args);
	
/*
 *	See if trace level is such that we are supposed to print this
 *	error message
 */
	tclass = va_arg(args, int);
	tlevel = va_arg(args, int);
	if ( tlevel < 0 )
		  tlevel = 0;
	classTraceLevel = TraceLevel;
	if ( tclass > TC_DEFAULT  &&  tclass < TC_MAX && TraceLevels[tclass] != 0)
		  classTraceLevel = TraceLevels[tclass];
	if ( tlevel > 0  &&  classTraceLevel < tlevel ) 
	{
		va_end(args);
		return(0);
	}

	errcode = va_arg(args, int);
	file = va_arg(args, char *);
	line = va_arg(args, int);
	format = va_arg(args, char *);

/*
 * Go ahead and format the message so we can get out of 'va_arg' mode
 */
	strcpy(buf, "");
	if( LogFileLineNumbers )
	{ 
 		strcpy( buf, "[");
		index = strlen(file)-1;
		for ( index = strlen(file)-1; index > 0; index--)
			if ( file[index] == '/' )
			{
				index++;
				break;
			}
 		strcat( buf, &(file[index]));
 		buf[strlen(buf)-2] = 0;
		sprintf(&buf[strlen(buf)], ", %d] ",line);
	} /* end if */

	vsprintf(&buf[strlen(buf)], format, args);

	va_end(args);
	
	return(_logerr(tlevel, errcode, buf));
}

/*.
 ****************************************************************************
 *
 *	_logerr		low-level error message logging
 *
 *	SYNOPSIS:
 *
 *	int _logerr ( tlevel, errcode, str)
 *		int		tlevel;		indicated trace level at which to log error
 *		int		errcode;	error message number
 *		char    *str;		string for printf
 *
 *	RETURNS:
 *
 *	 0		error message logged
 *	-1		unable to log error message (MPaxError set to error code)
 *
 *	DESCRIPTION
 *
 *
 ****************************************************************************
.*/

/*VARARGS4*/
int _logerr(tlevel, errcode, str)
int		tlevel;
int		errcode;
char    *str;
{
	register	long	rc;
				long	position;
				char	prt_buf[256];

/*
 *	Set up and open log file if it is not already
 *	open
 */
	if ( TraceOpen == 0 )
	{
		  if ( t_open() != 0 )
			return(-1);
	}

/*
 *	Have we reached the log file size limit???
 */
	if ( TraceDisabled == 0 && ftell(stdtrace) > MaxLogSize ) 
	{
		  fflush(stdtrace);
		  rewind(stdtrace);
	}

/*
 *	 Print Out the Error Message to the Log File
 */
	t_print(errcode, str, tlevel);

	return(0);
}

/*
 *****************************************************************************
 *
 *	t_open		open error log file
 *
 *	SYNOPSIS:
 *
 *	static
 *	int t_open(procid)
 *		int		procid;		program id index
 *
 *	RETURNS:
 *
 *	int		 0				log file successfully opened
 *			-1				open failed (MPaxError contains error code)
 *
 *	EXTERNALS REFERENCED:
 *
 *	int	stdtrace;			trace log file FILE pointer
 *	int	TraceOpen;			set to non-zero when trace file successfully
 *							opened
 *	int	Trace_to_Term		if non-zero then output logerr() msgs to stderr
 *							instead of logfile
 *
 *****************************************************************************
*/
static int t_open()
{
	register	char	*nameptr;
	register	long	rc;
	char		logname[256], newname[256], oldname[256];

	static		int	 logged_err = 0;	/* non-zero if open error logged */

#ifdef	SYSV
	long		tod;
#else
	struct		timeval	tp;
#endif

	struct		tm	*tmstr;

	/*
	 * don't need to do anything if log file already opened or disabled
	*/
	if ( TraceOpen != 0 )
		return(0);
	if ( TraceDisabled != 0 )
	{
		TraceOpen = 1;
		return(0);
	}

	nameptr = get_progname();

#ifdef	SYSV
	tod = (long)time(0);	/* get current time */
	tmstr = (struct tm*)localtime(&tod);
#else
	gettimeofday(&tp,NULL);	/* get current time */
	tmstr = (struct tm*)localtime(&tp.tv_sec);
	tp.tv_usec /= 10000;
#endif

	strncpy(logname,get_logname(), sizeof(logname));


	/*
	 * open log file
	 */
	if ( (stdtrace = fopen(logname, "w")) == NULL )
	{
		/*
		 *	unable to open log file
		*/
		MPaxError = errno;
		if ( logged_err == 0 )
		{
			fprintf(stderr, "%s: Unable to open trace log file %s\n", 
				nameptr, 
				logname);
			if ( errno < sys_nerr )
				fprintf(stderr, "%s: errno=%d, %s\n", nameptr, errno, 
					sys_errlist[errno]);
			else
				fprintf(stderr, "%s: errno=d\n", nameptr, errno);
			logged_err++;
		}
		return(-1);
	}

	TraceOpen++;
	logged_err = 0;
	t_print(0, "***** LOG FILE OPENED *****", 0);
	return(0);
}

/*
 *****************************************************************************
 *
 *	t_print		print error message to trace log file in standard format
 *
 *	SYNOPSIS:
 *
 *	static
 *	int t_print(line, err, msg);
 *		int		line;		current line number in error log
 *		int		err;		error code
 *		char	*msg;		error message to log
 *		int		tlevel;		indicated trace level at which to log error
 *
 *	RETURNS:
 *
 *	int - 0 if OK, -1 on error.
 *
 *	EXTERNALS REFERENCED:
 *
 *	int	stdtrace;				trace log file FILE pointer
 *
 *****************************************************************************
*/
static int t_print(err, msg, tlevel)
	int		err;			/* error code							*/
	char	*msg;			/* error message to log					*/
	int		tlevel;
{
	register	char    *ptr1, *ptr2, *sys_err;
	
	static	char	dbuf[] = "";		/* dummy, null text buffer		*/

#ifdef	SYSV
	long			tod;
#else
	struct	timeval	tp;
#endif

	struct	tm		*tmstr;

	char    msg_buf[MAXLOGMSG+1],
			*program;

	sys_err = dbuf;

#ifdef	SYSV
	tod = (long)time(0);	/* get current time */
	tmstr = (struct tm*)localtime(&tod);
#else
	gettimeofday(&tp,NULL);	/* get current time */
	tmstr = (struct tm*)localtime(&tp.tv_sec);
#if !defined (SHORTER_LOGGING)
	tp.tv_usec /= 10000;
#endif
#endif

#if defined (SHORTER_LOGGING)
	program = "";
#else
	program = get_progname();
#endif

	strncpy( msg_buf, msg, MAXLOGMSG );	/* so we're don't corrupt caller's string */

	ptr1 = msg_buf;
	while ( ptr1 != 0 ) 
	{
		if ( (ptr2 = strchr(ptr1, '\n')) != 0 )
			*ptr2++ = '\0';
		if ( err > 0 && err < sys_nerr )
			sys_err = sys_errlist[err];
		if ( Trace_to_Term != 0 )
		{
			if ( err != 0 )
			{
				fprintf(stderr, "(%d) ", LogLine); 
				fprintf(stderr, "Err: %d\n", err);
			}
			if ( *ptr1 != '\0' )
			{
				fprintf(stderr, "(%d) ", LogLine);
				fprintf(stderr, "%s\n",ptr1 );
			}
		}
		
		if ( TraceDisabled != 0 )
			return(0);
			
		if ( err != 0 )
		{
#if defined (SYSV)
			fprintf(stdtrace, "%2d/%2.2d %2d:%2.2d:%2.2d %-5s (%d) %d ",
				tmstr->tm_mon+1, tmstr->tm_mday, tmstr->tm_hour, 
				tmstr->tm_min, tmstr->tm_sec,
				program, LogLine, tlevel); 
#else
#if defined (SHORTER_LOGGING)
			fprintf(stdtrace, "%02d/%02d %02d:%02d:%02d %d %d ",
				tmstr->tm_mon+1, tmstr->tm_mday, tmstr->tm_hour, 
				tmstr->tm_min, tmstr->tm_sec, LogLine, tlevel);
#else
			fprintf(stdtrace, "%2d/%2.2d %2d:%2.2d:%2.2d.%2.2d %-5s (%d) %d ",
				tmstr->tm_mon+1, tmstr->tm_mday, tmstr->tm_hour, 
				tmstr->tm_min, tmstr->tm_sec, tp.tv_usec,
				program, LogLine, tlevel);
#endif 
#endif
			fprintf(stdtrace, "Err: %3d; %s\n", err, sys_err);
		}
		if ( *ptr1 != '\0'  )
		{
#if defined (SYSV)
			fprintf(stdtrace, "%2d/%2.2d %2d:%2.2d:%2.2d %-5s (%d) %d ",
				tmstr->tm_mon+1, tmstr->tm_mday, tmstr->tm_hour, 
				tmstr->tm_min, tmstr->tm_sec,
				program, LogLine, tlevel);
#else
#if defined (SHORTER_LOGGING)
			fprintf(stdtrace, "%02d/%02d %02d:%02d:%02d %d %d ",
				tmstr->tm_mon+1, tmstr->tm_mday, tmstr->tm_hour, 
				tmstr->tm_min, tmstr->tm_sec, LogLine, tlevel);
#else
			fprintf(stdtrace, "%2d/%2.2d %2d:%2.2d:%2.2d.%2.2d %-5s (%d) %d ",
				tmstr->tm_mon+1, tmstr->tm_mday, tmstr->tm_hour, 
				tmstr->tm_min, tmstr->tm_sec, tp.tv_usec,
				program, LogLine, tlevel);
#endif 
#endif
			fprintf(stdtrace, "%s\n",ptr1 );
		}
		ptr1 = ptr2;
		LogLine++;
	}
	if (gFlushToDisk)
	{
		fflush(stdtrace);
	}

	return(0);
}

