#ifndef LINT

#endif
extern	char	libRelease[];
static	char	*LibRelease = libRelease;
/*.
 ****************************************************************************
 *	pm.c	Module to handle Process Managment issues.
 *
 *	DATA ABTRACTION
 *
 *		The functions provided in this module are:
 *
 *		Process Managment Library Functions
 *		---------------------------
 *		pm_active	-	Put process in active state.
 *		pm_inactive	-	Put process in inactive state.
 *		pm_down		-	Put process in draining state and exit when inactive.
 *		pm_abort	-	Put process in abort state and exit.
 *		pm_debug	-	Generate process debug info.
 *
 *		pm_add_goactive	-	Add routine to the go active execute list.
 *		pm_add_active	-	Add routine to the active execute list.
 *		pm_add_inactive	-	Add routine to the inactive execute list.
 *		pm_add_abort	-	Add routine to the abort execute list.
 *		pm_add_exit		-	Add routine to the exit execute list.
 *		pm_add_debug	-	Add routine to the debug execute list.
 *
 *		pm_rmv_goactive	-	Remove routine from the go active execute list.
 *		pm_rmv_active	-	Remove routine from the active execute list.
 *		pm_rmv_inactive	-	Remove routine from the inactive execute list.
 *		pm_rmv_abort	-	Remove routine from the abort execute list.
 *		pm_rmv_exit		-	Remove routine from the exit execute list.
 *		pm_rmv_debug	-	Remove routine from the debug execute list.
 *
 *		pm_set_exit_routine	-	Set the exit routine to be called to exit.
 *		pm_nm_msg	-	Handle network management messages.
 *
 *		Local Functions
 *		---------------------------
 *		pm_exit		-	Exit process.
 *		pm_add_ent	-	Add a routine entry to a queue.
 *		pm_rmv_ent	-	Remove a routine entry from a queue.
 *		pm_exec_que	-	Execute a routine queue.
 *
 *
 *	Notes:
 *		This module uses the idea of a execute queue - a queue of buffers
 *			that contain pointers to routines to be called on the occurance
 *			of some event (this could be converted to use events??).
 *
 *		Process debug:
 *			This module supports process debuging with the calls pm_add_debug
 *			and pm_debug.  The call pm_add_debug will add routines to the
 *			debug queue, such that calls to pm_debug will call all routines
 *			on the debug queue.
 *
 *		Process states:
 *			Processes will start in the PROC_INACTIVE state and initilize.
 *			Once initilize a call will be made to pm_active which will
 *			all routines that were added to the goactive queue (with a call
 *			to pm_add_goactive) will be called.  If all routines on the
 *			goactive queue return 0, the process will go active, otherwise
 *			the process state will be set to PROC_GOING_ACTIVE and
 *			it is the responsibility of the routine that returned non zero
 *			to call pm_active again when that subsystem is ready to go active.
 *			When the process goes active, all routines on the active queue
 *			will be called.
 *
 *			If it is required to put the process in an inactive state, a
 *			call wil be made to pm_inactive() which will place the process
 *			in the PROC_INACTIVE state and cause all routines that were added
 *			to the inactive queue (with a call to pm_add_inactive) to be called.
 *			If any routines on the inactive queue return not zero (indicating
 *			they are not ready to go inactive) it is there responsibility
 *			to have pm_inactive called at a later time when they are ready
 *			to go inactive, at that time, all routines on the inactive queue
 *			are recalled.
 *			If the current process state is PROC_DRAINING, it is left as
 *			PROC_DRAINING and if all routines on the inactive queue return 0,
 *			then pm_inactive will do the exit processing.
 *
 *			On the occurence of a major error (pointer error...) a call
 *			will be made to pm_abort().  This call will not return.
 *			This routine sets the process state to PROC_ABORT, call
 *			pm_debug, call all routine that were added to the abort queue
 *			(with a	call to pm_add_abort) will be called, and then
 *			all routines added to the exit queue (with a call to pm_add_exit)
 *			will be called, then the process will exit.
 *
 *			On the occurence of a minor error a call will be made to pm_down().
 *			This call sets the currect process state to PROC_DRAINING and
 *			calls pm_inactive() which will evendualty take the process down.
 *
 *			If a process is in the PROC_INACTIVE state and needs to go active,
 *			a call to pm_active() will call all routines that were added to
 *			active queue (with a call to pm_add_active) and the process
 *			state will be set to PROC_ACTIVE.
 *
 ****************************************************************************
 */


#include <stdio.h>
#include <malloc.h>
#ifdef SYSV
#include	<fcntl.h>
#endif
#include "global.h"
#include "mpax.h"
#include "presaddr.h"
#include "netaddr.h"
#include "queue.h"
#include "dispatcher.h"
#include "vmsg.h"
#include "msg_rsc.h"
#include "msg_nm.h"
#include "damadif.h"
#include "messages.h"
#include "id.h"
#include "ipc.h"
#include "errors.h"
#include "log.h"
#include "msg_chan.h"
#include "startup.h"
#include "pm.h"


/**********************/
/* External Variables */
/**********************/
extern	int			errno;		/* System error code						*/

/**********************/
/* Static Variables */
/**********************/
static	PM_EXEC_QUE	PmGoActQue	= PM_EXEC_QUE_INIT(PmGoActQue);
static	PM_EXEC_QUE	PmActQue	= PM_EXEC_QUE_INIT(PmActQue);
static	PM_EXEC_QUE	PmInactQue	= PM_EXEC_QUE_INIT(PmInactQue);
static	PM_EXEC_QUE	PmDebugQue	= PM_EXEC_QUE_INIT(PmDebugQue);
static	PM_EXEC_QUE	PmAbortQue	= PM_EXEC_QUE_INIT(PmAbortQue);
static	PM_EXEC_QUE	PmExitQue	= PM_EXEC_QUE_INIT(PmExitQue);

static	int	PmErrno = 0;
static	int	PmMPaxError = 0;
static	int PmExitError = 0;

static	void	*EntArg = NULL;
static	void	(*PmExitRoutine)() = NULL;

/*.
***************************************************************

pm_exec_que -- This routine calls all routines on the specified queue.

SYNOPSIS:

int pm_exec_que(qhd)
QHD	*qhd;

DESCRIPTION:

	Call the routine specified for every entry on the passed queue,
	stoping if any return a negative value.

PARAMETERS:

	qhd		-	ptr to queue of PM_ROU_ENT buffers.

RETURNS:

	If any routine in the exec list returns a neg value, it is returned.
	Else if any routine in the exec list returns a positive value,
	it is returned.  Else 0 is returned.

***************************************************************
*/

int pm_exec_que(eq)
register	PM_EXEC_QUE	*eq;
{
	register	PM_ROU_ENT	*e;
	register	int		rc,r;

	if (eq->flags & PM_EXEC_QUE_FLAG_EXEC)
	{
		log_abnormal1(
			"pm_exec_que Attempt to exec q: 0x%lx while allready exec q",eq);
		return(0);
	}
	eq->flags |= PM_EXEC_QUE_FLAG_EXEC;
	rc = 0;
	e = (PM_ROU_ENT *) queue_look_head(&eq->que);
	while ( e )
	{
		if ( e->rou )
		{
			if ((r = (*(e->rou))(e->arg)) < 0)
				return(r);
			else if (r > 0  &&  rc == 0)
				rc = r;
		}
		e = (PM_ROU_ENT *) queue_look_next(&eq->que, &e->qbf);
	}
	eq->flags &= ~PM_EXEC_QUE_FLAG_EXEC;
	return(rc);
}

/*.
***************************************************************

pm_set_exit_routine -- this routine sets the final exit routine.

SYNOPSIS:

int pm_set_exit_routine(rou);
void		(*rou)();

DESCRIPTION:

This routine sets the final exit routine.

PARAMETERS:

	rou	-	The routine to call on exit.

***************************************************************
*/

int pm_set_exit_routine(rou)
void		(*rou)();
{
	PmExitRoutine = rou;
	return(0);
}


/*.
***************************************************************

pm_exit -- this routine exits the Process.

SYNOPSIS:

int pm_exit(status)
int	status;

DESCRIPTION:

This routine calls all exit routine and then calls the system exit.

PARAMETERS:

	status	-	The status to exit with.

***************************************************************
*/

int pm_exit(status)
int	status;
{
	log_fatal1("pm_exit: Process exit: ProcSts: %d", ProcSts);
	log_fatal3("\t: errno: %d, MPaxError: %d, exit error: %d",
		errno, MPaxError, status);

	if (!PmErrno)
		PmErrno = errno;
	if (!PmMPaxError)
		PmMPaxError = MPaxError;
	if (!PmExitError)
		PmExitError = status;

	ProcSts = PROC_ABORT;
	pm_debug();
	pm_exec_que(&PmExitQue);

	log_fatal3(
		"pm_exit: Process Exiting, errno: %d, MPaxError: %d, exit error: %d",
		PmErrno, PmMPaxError, PmExitError);
	log_fatal0("\tShut'er down Scotty, she's suckin' mud again.\t");
	close_log();
	if (PmExitRoutine)
		(*PmExitRoutine)(status);
	else
		exit(status);
	return(0);
}

/*.
***************************************************************

pm_active -- Put process in an inactive state.

SYNOPSIS:

pm_active()

DESCRIPTION:

This routine will set the process state to PROC_INACTIVE and call all
inactive routines. If the process state is PROC_DRAININ and all inactive
routines are idle, this routine will call pm_exit to exit the process.

PARAMETERS:

	None.

***************************************************************
*/

int pm_active()
{
	register	int		err;

	log_state_chng1("pm_active: Process going active: ProcSts: %d", ProcSts);

	switch (ProcSts)
	{
	case PROC_INACTIVE:
	case PROC_GOING_INACTIVE:
	case PROC_GOING_ACTIVE:
		err = pm_exec_que(&PmGoActQue);
		if (err < 0)
		{
			log_fatal0("pm_active: error:%d on going active");
			pm_down(err);
			return(-1);
		}
		else if (err == 0)
		{
			ProcSts = PROC_ACTIVE;
			if ((err = pm_exec_que(&PmActQue)) < 0)
			{
				log_fatal0("pm_active: error:%d on active notice");
				pm_down(err);
				return(-1);
			}
		}
		else
		{
			log_state_chng0("pm_active: Not ready to go active yet");
		}
		break;

	case PROC_ACTIVE:
		log_state_chng0("pm_active: Process allready active");
		break;

	case PROC_DRAINING:
		log_state_chng0("pm_active: Process Draining, can't go active");
		return(-1);
		break;

	case PROC_ABORT:
		log_state_chng0("pm_active: Process Aborting, can't go active");
		return(-1);

	default:
		log_fatal0("pm_active: invalid ProcSts");
		pm_abort(-1);
		return(-1);
		break;
	}

	return(0);
}

/*.
***************************************************************

pm_inactive -- Put process in an inactive state.

SYNOPSIS:

pm_inactive()

DESCRIPTION:

This routine will set the process state to PROC_INACTIVE and call all
inactive routines. If the process state is PROC_DRAININ and all inactive
routines are idle, this routine will call pm_exit to exit the process.

PARAMETERS:

	None.

***************************************************************
*/

int pm_inactive()
{
	register	int	rc;

	log_fatal1("pm_inactive: Process down: ProcSts: %d", ProcSts);

	switch (ProcSts)
	{
	case PROC_INACTIVE:
		log_state_chng0("pm_inactive: Process allready inactive");
		return(0);
		break;

	case PROC_GOING_INACTIVE:
		log_debug0("pm_inactive: Process allready going inactive");
		break;

	case PROC_ACTIVE:
	case PROC_GOING_ACTIVE:
		ProcSts = PROC_GOING_INACTIVE;
		pm_debug();
		break;

	case PROC_DRAINING:
		log_state_chng0("pm_inactive: Process allready draining");
		break;

	case PROC_ABORT:
		log_state_chng0("pm_inactive: Process allready abort");
		return(-1);

	default:
		log_fatal0("pm_inactive: invalid ProcSts");
		pm_abort(-1);
		return(-1);
		break;
	}

	if ((rc = pm_exec_que(&PmInactQue)) < 0)
		return(pm_abort(rc));
	else if (rc == 0 && ProcSts == PROC_DRAINING)
		pm_exit(PmExitError);

	return(0);
}

/*.
***************************************************************

pm_down -- perform a clean shutdown of process.

SYNOPSIS:

int pm_down(status)
int	status;

DESCRIPTION:

This routine will set the process state to PROC_DRAINING and call pm_inactive.
When the process is inactive, it will exit.

PARAMETERS:

	status	-	The status to exit with.

***************************************************************
*/

int pm_down(status)
int	status;
{
	log_fatal1("pm_down: Process down: ProcSts: %d", ProcSts);
	log_fatal3("\t: errno: %d, MPaxError: %d, exit error: %d",
		errno, MPaxError, status);

	switch (ProcSts)
	{
	case PROC_INACTIVE:
	case PROC_GOING_INACTIVE:
		ProcSts = PROC_DRAINING;
		PmErrno = errno;
		PmMPaxError = MPaxError;
		PmExitError = status;
		errno = MPaxError = 0;
		break;

	case PROC_GOING_ACTIVE:
	case PROC_ACTIVE:
		ProcSts = PROC_DRAINING;
		PmErrno = errno;
		PmMPaxError = MPaxError;
		PmExitError = status;
		errno = MPaxError = 0;
		pm_debug();
		break;

	case PROC_DRAINING:
		break;

	case PROC_ABORT:
		return(-1);

	default:
		log_fatal0("pm_inactive: invalid ProcSts");
		pm_abort(-1);
		return(-1);
		break;
	}

	pm_inactive();

	return(0);
}

/*.
***************************************************************

pm_abort -- This routine will abort the process.

SYNOPSIS:

int pm_abort(status)
int	status;

DESCRIPTION:

This routine will set the process state to PROC_ABORT and call all abort
routines then call pm_exit to exit the process.

PARAMETERS:

	status	-	The status to exit with.

***************************************************************
*/

int pm_abort(status)
int	status;
{
	log_fatal1("pm_abort: Process Abort: ProcSts: %d", ProcSts);
	log_fatal3("\t: errno: %d, MPaxError: %d, exit error: %d",
		errno, MPaxError, status);

	switch (ProcSts)
	{
	case PROC_ABORT:
		return(-1);

	case PROC_DRAINING:
		if (!PmErrno)
			PmErrno = errno;
		if (!PmMPaxError)
			PmMPaxError = MPaxError;
		if (!PmExitError)
			PmExitError = status;
		break;

	default:
		PmErrno = errno;
		PmMPaxError = MPaxError;
		PmExitError = status;
	}

	errno = MPaxError = 0;

	ProcSts = PROC_ABORT;

	pm_debug();

	pm_exec_que(&PmAbortQue);

	pm_exit(status);

	return 0;			
		/* This return is being added to accomodate the changes in the
		    the 'C' complier from SunOs 4.0.3 to to SunOs 4.1.1

		    For a complete discussion of the see bug: VDIlu00863.
		*/
}

/*.
***************************************************************

pm_debug -- Generate all process debug info.

SYNOPSIS:

pm_debug()

DESCRIPTION:

Call all debug routines on the debug queue.

PARAMETERS:

		none.

***************************************************************
*/

int pm_debug()
{
	static	in_debug = 0;

	log_abnormal3("pm_debug: ProcSts: %d, errno: %d, MPaxError: %d",
		ProcSts, errno, MPaxError);

	if (in_debug)
		return(0);

	errno = 0;
	MPaxError = ERRNONE;

	in_debug = 1;
	pm_exec_que(&PmDebugQue);
	in_debug = 0;
	return(0);
}

/*.
***************************************************************

pm_add_ent -- Add a PM_ROU_ENT entry to the specified queue.

SYNOPSIS:

int pm_add_ent(rou,arg,que)
int		(*rou)();
void	*arg;
QHD		*que;

DESCRIPTION:

Allocates a PM_ROU_ENT buffer, filles it in, and added it to the specified queue.

PARAMETERS:

	rou		-	Routine to be called for this PM_ROU_ENT entry.
	arg		-	Argument to pass to routine to be called for this entry.
	que		-	Queue to put PM_ROU_ENT on.

SIDE EFFECTS:

***************************************************************
*/

int pm_add_ent(rou,arg,que)
register	int		(*rou)();
register	void	*arg;
register	QHD		*que;
{
	register	PM_ROU_ENT	*e;

	log_fnc_entry2("pm_add_ent:	rou: 0x%lx, arg: 0x%lx",rou,arg);

	e = (PM_ROU_ENT * )calloc(1,sizeof(PM_ROU_ENT));
	if ( e == NULL )
	{
		MPaxError = errno;
		log_internal0("pm_add_ent: calloc failed");
		return(-1);
	}

	e->rou = rou;
	e->arg = arg;
	queue_buf_init(que, 1, sizeof(PM_ROU_ENT), (char *) e);

	return(0);
}

/*.
***************************************************************

pm_add_goactive
pm_add_active
pm_add_inactive
pm_add_abort
pm_add_exit
pm_add_debug

		-	Add the specified routine to the correct execute queue.

SYNOPSIS:

int pm_add_????(rou,arg)
int		(*rou)();
void	*arg;

DESCRIPTION:

Call pm_add_ent to add the specified routine to the correct execute queue.

PARAMETERS:

	rou	-	Routine to be executed when the queue is executed.
				Routine should be defined as:
					int	rou(arg);
					(some ptr type) arg;
				The routine should return an int, the value is used in some
				cases for process state decisions - see intro note, pm_inactive.

	arg	-	Argument to pass to routine when the routine is executed.

SIDE EFFECTS:

***************************************************************
*/

int pm_add_goactive(rou,arg)
int		(*rou)();
void	*arg;
{
	return(pm_add_ent(rou,arg,&PmGoActQue));
}

int pm_add_active(rou,arg)
int		(*rou)();
void	*arg;
{
	return(pm_add_ent(rou,arg,&PmActQue));
}

int pm_add_inactive(rou,arg)
int		(*rou)();
void	*arg;
{
	return(pm_add_ent(rou,arg,(QHD *)&PmInactQue));
}

int pm_add_abort(rou,arg)
int		(*rou)();
void	*arg;
{
	return(pm_add_ent(rou,arg,(QHD *)&PmAbortQue));
}

int pm_add_exit(rou,arg)
int		(*rou)();
void	*arg;
{
	return(pm_add_ent(rou,arg,(QHD *)&PmExitQue));
}

int pm_add_debug(rou,arg)
int		(*rou)();
void	*arg;
{
	return(pm_add_ent(rou,arg,(QHD *)&PmDebugQue));
}

/*.
***************************************************************

pm_rmv_ent -- Remove a PM_ROU_ENT entry from the specified queue.

SYNOPSIS:

int pm_rmv_ent(rou,arg,que)
int		(*rou)();
void	*arg;
QHD		*que;

DESCRIPTION:

Find the PM_ROU_ENT buffer on the specified queue and release it.

PARAMETERS:

	rou		-	Routine to be called for this PM_ROU_ENT entry.
	arg		-	Argument to pass to routine to be called for this entry.
	que		-	Queue to put PM_ROU_ENT on.

***************************************************************
*/

PM_ROU_ENT *pm_rmv_find(que,e,rou)
register	QHD		*que;
register	PM_ROU_ENT	*e;
register	int		(*rou)();
{

	return((e->rou == rou  &&  e->arg == EntArg) ? e : NULL);
}

int pm_rmv_ent(rou,arg,que)
register	int		(*rou)();
register	void	*arg;
register	QHD		*que;
{
	register	PM_ROU_ENT	*e;

	log_fnc_entry2("pm_rmv_ent:	rou: 0x%lx, arg: 0x%lx",rou,arg);

	EntArg = arg;
	if (!(e = (PM_ROU_ENT * ) queue_mapi(que,(void *)pm_rmv_find,rou)))
	{
		MPaxError = errno;
		log_debug0("pm_rmv_ent: entry not found");
		return(-1);
	}

	if (!queue_remq(que,&e->qbf))
	{
		log_fatal2("pm_rmv_ent: queue error rmv ent: 0x%lx from que: 0x%lx",
			e,que);
		return(pm_abort(MPaxError));
	}

#if defined(SYSV) || defined(SGI) 
	free(e);
#else
#if defined(SPARC)
	/* Sun Release 4.1 returns 1 on success and 0 on error */
	if (!free(e))
#else
	/* So what system returns non-zero on error?  Only the shadow knows */
	if (free(e))
#endif
	{
		log_fatal1("pm_rmv_ent: error on freeing of ent: 0x%lx", e);
		return(pm_abort(MPaxError));
	}
#endif

	return(0);
}

/*.
***************************************************************

pm_rmv_goactive
pm_rmv_active
pm_rmv_inactive
pm_rmv_abort
pm_rmv_exit
pm_rmv_debug

		-	Remove the specified routine from the correct execute queue.

SYNOPSIS:

int pm_rmv_????(rou,arg)
int		(*rou)();
void	*arg;

DESCRIPTION:

Call pm_rmv_ent to remove the specified routine from the correct execute queue.

PARAMETERS:

	rou	-	Routine to be executed when the queue is executed.
	arg	-	Argument to pass to routine when the routine is executed.

***************************************************************
*/

int pm_rmv_goactive(rou,arg)
int		(*rou)();
void	*arg;
{
	return(pm_rmv_ent(rou,arg,&PmGoActQue));
}

int pm_rmv_active(rou,arg)
int		(*rou)();
void	*arg;
{
	return(pm_rmv_ent(rou,arg,&PmActQue));
}

int pm_rmv_inactive(rou,arg)
int		(*rou)();
void	*arg;
{
	return(pm_rmv_ent(rou,arg,&PmInactQue));
}

int pm_rmv_abort(rou,arg)
int		(*rou)();
void	*arg;
{
	return(pm_rmv_ent(rou,arg,&PmAbortQue));
}

int pm_rmv_exit(rou,arg)
int		(*rou)();
void	*arg;
{
	return(pm_rmv_ent(rou,arg,(QHD *)&PmExitQue));
}

int pm_rmv_debug(rou,arg)
int		(*rou)();
void	*arg;
{
	return(pm_rmv_ent(rou,arg,(QHD *)&PmDebugQue));
}

/*.
 ****************************************************************************
 *	pm_nm_msg - Handle a Network management message
 *					 
 *	SYNOPSIS:
 *
 *	int pm_nm_msg(m,msgq)
 *	MSG_NM	*m;
 *	VMSGQ *msgq;
 *
 *	DESCRIPTION:
 *
 *		This routine is called to handle a Network management message.
 *
 *	PARAMETERS:
 *		m - Pointer to MSG_NM Network management message
 *
 *	RETURNS:
 *
 *		-1 on error (msg releaseed).
 *		0 if msg handled (msg releaseed).
 *		1 if msg should be passed to user (msg NOT released).
 *
 ****************************************************************************
 */
int pm_nm_msg(m, msgq)
register	MSG_NM	*m;
register VMSGQ *msgq;
{
	register	int		rc = 0;

	log_debug2("pm_nm_msg: Entered, NM msg: %d, class: 0x%x",
		m->hdr.msgtype, m->hdr.class);

	/*
	 *	Check for network management message.
	 */
	if (m->hdr.msgtype < MSGBASE_NM || m->hdr.msgtype > MSGCEL_NM)
		return (1);

	/*
	 *	Check for OCP connnection and correct destination
	 */
	if (!(msgq->flags & VMSGQ_FLAG_OCP_CONN) || na_cmp(&m->hdr.dest_na, NetAddr))
		return (1);

	/*
	 *	Check for returned messages
	 */
	if (m->hdr.class & MSG_CLASS_RET)
	{
		if (MSG_IS_RESP(m))
		{
			/*
			 *	Returned message
			 */
			log_abnormal5(
	"pm_nm_msg: Net addr: %d,%d,%d,%d sent req: %d but did not wait for resp",
				m->hdr.src_na.na_super, m->hdr.src_na.na_net,
				m->hdr.src_na.na_sub, m->hdr.src_na.na_point,
				MSG_RESP_TO(m->hdr.msgtype));
		}
		else
		{
			log_info1("pm_nm_msg: returned msg type: %d, passed to user func",
				m->hdr.msgtype);
			rc = 1;
		}
	}
	else
	{
		switch (m->hdr.msgtype)
		{
		case MSG_NM_TRACE:
			log_info2("pm_nm_msg: Trace level %d; new trace level %d", 
						TraceLevel, m->tlevel);
			TraceLevel = m->tlevel;
			if (m->size)
				set_logsize(m->size);
			break;

		case MSG_NM_GETSTS:
			/*	convert recv msg to resp	*/
			vmsg_sethdr(m, &m->hdr.src_na,
				MSG_TYPE_RESP(MSG_NM_GETSTS),MSG_NM_LEN);
			m->tlevel = TraceLevel;
			m->state = ProcSts;
			if (vmsg_sendbuf(msgq, m))
				return(-1);
			m = NULL;
			break;

		case MSG_NM_ACTIVE:
			pm_active();
			break;

		case MSG_NM_INACT:
			pm_inactive();
			break;

		case MSG_NM_SYS_DOWN:
		case MSG_NM_PROC_DOWN:
			log_abnormal4("pm_nm_msg: recv'd MSG_NM_SYS_DOWN from: %d,%d,%d,%d",
				m->hdr.src_na.na_super, m->hdr.src_na.na_net,
				m->hdr.src_na.na_sub, m->hdr.src_na.na_point);
			pm_down();
			break;

		case MSG_NM_SAVELOG:
			save_log();
			if (m->size)
				set_logsize(m->size);
			break;

		case MSG_NM_DEBUG:
			pm_debug();
			break;

		case MSG_NM_RESETLOG:
			reset_log();
			if (m->size)
				set_logsize(m->size);
			break;

		default:
			log_info1("pm_nm_msg: msg type: %d, passed to user func",
				m->hdr.msgtype);
			rc = 1;
		}
	}

	if (m && rc != 1)
	{
		if (vmsg_relbuf(m))
		{
			log_fatal0("pm_nm_msg: vmsg_relbuf failed on a msg buffer");
			rc = -1;
		}
	}
	return(rc);
}

/****************************************************************************/
/*.
 *  pm_send_nm_msg -- send a network managment message.
 *
 *  SYNOPSIS:
 *      pm_send_nm_msg(type, dest, na, tlevel, state)
 *		MSGTYPE type;
 *		NET_ADDR *dest, *na;
 *		short tlevel, state;
 *
 *  DESCRIPTION:
 *
 *
 *  PARAMETERS:
 *		type		- Msg type.
 *		dest		- Msg dest.
 *		na			- Network address value ?? to place in msg.
 *						(Does anyone use this value ??).
 *		tlevel		- trace level to place in msg.
 *		state		- State value to place in msg.
 *		size		- Size value to place in msg.
 *
 *  RETURNS:
 *		-1 on error.
 *		0 if msg sent ok.
 *		1 if not msg buffer avaible.
 *
 */
/****************************************************************************/
int pm_send_nm_msg( type, dest, na, tlevel, state, size)
MSGTYPE type; 
NET_ADDR *dest, *na; 
short tlevel, state; 
ulong	size;
{
	register	MSG_NM *msg;

	if (!(msg = (MSG_NM *)msg_getbuf()))
	{
		log_abnormal0("pm_send_nm_msg: Cannot get a msg buf");
		return(1);
	}
	msg_sethdr( msg, dest, type, MSG_NM_LEN);
	msg->na = *na;
	msg->tlevel = tlevel;
	msg->state = state;
	msg->size = size;
	msg->hdr.class |= MSG_CLASS_URGENT;
	return(msg_sendbuf(msg));
}

/*.
 ****************************************************************************
 *	pm_bc_nm_msg - send broadcast network managment message.
 *					 
 *	SYNOPSIS:
 *
 *	int pm_bc_nm_msg(type, dest, tlevel, state, size)
 *	MSGTYPE type; 
 *	NET_ADDR *dest; 
 *	short tlevel, state; 
 *	ulong	size;
 *
 *	DESCRIPTION:
 *		This routine is called to send broadcast network managment messages.
 *
 *	PARAMETERS:
 *		type		- Msg type.
 *		dest		- Msg dest.
 *		tlevel		- trace level to place in msg.
 *		state		- State value to place in msg.
 *		size		- Size value to place in msg.
 *
 *	RETURNS:
 *		-1 on error.
 *		0 if msg sent ok.
 *		1 if not msg buffer avaible.
 *
 ****************************************************************************
 */
int pm_bc_nm_msg(type, dest, tlevel, state, size)
MSGTYPE type; 
NET_ADDR *dest; 
short tlevel, state; 
ulong	size;
{
	NET_ADDR	na;

	if (dest)
		log_debug4("pm_bc_nm_msg: Entered, NA: %d,%d,%d,%d",
			dest->na_super, dest->na_net, dest->na_sub, dest->na_point);
	else
		log_debug0("pm_bc_nm_msg: Entered, No NA specified");

	if (!dest)
	{
		if (net_name_to_na(NET_NAME_OCP, &na))
		{
			log_abnormal1(
				"pm_bc_nm_msg: NetAddr of '%s' not in network routing tables",
				NET_NAME_OCP);
			return(-1);
		}
		na.na_point = NA_BROADCAST_POINT;
		dest = &na;
	}

	return(pm_send_nm_msg(type, dest, dest, tlevel, state, size));
}

/*.
 ****************************************************************************
 *	pm_savelogs,pm_resetlogs, pm_trace_all - Send Network management msgs
 *					 
 *	SYNOPSIS:
 *
 *	int pm_savelogs(na)
 *	int pm_resetlogs(na)
 *	int pm_trace_all(na,tlevel)
 *
 *	NET_ADDR    *na;
 *	int			 tlevel;
 *
 *	DESCRIPTION:
 *		These routines send broadcast Network management messages to cause
 *		all process on given sites to save there logs, teset there logs,
 *		or change there trace level.
 *
 *	PARAMETERS:
 *		na	-	pointer to network address structure of site with na_point
 *				set to -1 for broadcast.  If na is NULL, current site
 *				receives msgs.
 *		tlevel-	Trace level to set all proceses to.
 *
 *	RETURNS:
 *		-1 on error.
 *		0 if msg sent ok.
 *		1 if not msg buffer avaible.
 *
 ****************************************************************************
 */
int pm_savelogs(na)
NET_ADDR	*na;
{
	return(pm_bc_nm_msg(MSG_NM_SAVELOG, na, 0, 0, 0));
}
int pm_resetlogs(na)
NET_ADDR	*na;
{
	return(pm_bc_nm_msg(MSG_NM_RESETLOG, na, 0, 0, 0));
}
int pm_trace_all(na,tlevel)
NET_ADDR	*na;
int			 tlevel;
{
	return(pm_bc_nm_msg(MSG_NM_RESETLOG, na, tlevel, 0, 0));
}

