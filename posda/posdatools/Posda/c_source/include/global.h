/*
 ******************************************************************************
 *
 *			global.h
 *
 *	Common Boolean and other constant definitions global to all modules.
 *
 *	As a general rule, this file should be included in all source modules.
 *
 ******************************************************************************

*/

#ifndef _GLOBAL_
#define	_GLOBAL_


/*
*
*	The following ENVironments are supported:
*
*		UNIX_ENV:	unix environment, all unix call are valid.
*		IBMPC_ENV:	ibm pc environment, some unix calls are valid.
*
*		The absence of a ENV should assume UNIX_ENV.
*		The UNIX_ENV and IBMPC_ENV are set by the makefiles on the appropriate
*		machine.  
*
*	The following code VERersions are supported:
*
*		STUB_VER:	stub version code will be generated for the module.
*
*		The absence of a VER should assume normal code.
*		The STUB_VER will be set by the makefiles for all objects to be
*		placed in the libtest dir on the sun.  For any module that uses
*		routine calls that are not supported on a given environment, the
*		module should define STUB_VER at the start of that module if the
*		environment is defined.  
*
*
*/


#if !defined(UNIX_ENV)  &&  !defined(XENIX)
#ifndef IBMPC_ENV

#ifndef ANSI_PROTO
#define ANSI_PROTO
#endif
#ifndef	_NFILE
#include	<stdio.h>
#endif

#endif
#else
#include	<sys/types.h>
#endif

/*
 *  The Sun and Motorola System 5 stuff differs in a few areas.
 *  The following ifdefs/defines will allow seperate code bracketed
 *  by SOLARIS or MOTO, and common code identified by SYSV
 */
#ifndef SYSV
#ifdef SOLARIS
#define SYSV
#endif

#ifdef MOTO
#define SYSV
#endif
#endif  /* SYSV */

#define PATHNAME_DELIMITER_CHAR	'/'
#define PATHNAME_DELIMITER_STR	"/"


#ifndef	TRUE
#define	TRUE	(1)
#endif

#ifndef	FALSE
#define	FALSE	(0)
#endif

#ifndef BOOLEAN
#define BOOLEAN char
#endif

#ifndef	SUCCESS
#define	SUCESS	TRUE
#endif

#ifndef FAIL
#define	FAIL	FALSE
#endif

#ifndef	NULL
#define	NULL	(0L)
#endif

#ifndef	EOF
#define	EOF	(-1)
#endif

#ifndef BYTE
#define BYTE unsigned char
#endif

#ifndef ushort
#define	ushort unsigned short
#endif
#ifndef ulong
#define	ulong unsigned long
#endif

#ifndef L_SET
#define L_SET       0
#endif

#ifndef L_INCR
#define L_INCR      1
#endif

#ifndef L_XTND
#define L_XTND      2
#endif

#ifdef SYSV
#define F_OK        0   /* does file exist */
#define X_OK        1   /* is it executable by caller */
#define W_OK        2   /* writable by caller */
#define R_OK        4   /* readable by caller */
/* lseek definitions */
#define	L_SET		0	/* absolute offset */
#define	L_INCR		1	/* relative to current offset */
#define	L_XTND		2	/* relative to end of file */

#define	u_short ushort
#define	u_long ulong

#define	bcopy(a, b, c)	memcpy(b, a, c)
#define	bzero(a, c)		memset(a, 0, c)

#endif

#ifdef ANSI_PROTO
extern	char	*getname(char *str);
#else
extern	char	*getname();
#endif

/*	Define calloc,malloc,free to use the vcalloc.. calls for free mem check. */
#ifndef __VMEM__
void *vcalloc(size_t nmemb, size_t size);
void *vmalloc(size_t size);
void vfree(void *ptr);
void *vrealloc(void *origPtr, size_t newSize);
#endif
#define	calloc(num,len)		vcalloc(num,len)
#ifdef malloc
#undef malloc
#endif
#define	malloc(len)			vmalloc(len)
#define	free(ptr)			vfree(ptr)
//#define realloc(ptr, size)		vrealloc((ptr),(size))
#define realloc(ptr, size)		vrealloc(ptr,size)
/* copied from vmsg.h	*/



#endif

