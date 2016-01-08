/*
 *********************************************************************
 *			pm.h	-	Defines for the Process Managment module.
 *
 *	This include file requires the following include files:
 *		global.h, mpax.h, netaddr.h, queue.h
 *********************************************************************
 *

 */

#ifndef _PM_
#define _PM_

typedef struct
{
    QBF     qbf;
    int     (*rou)();
    void    *arg;
}   PM_ROU_ENT;
 
typedef struct
{
    QHD     que;
    ulong   flags;
}   PM_EXEC_QUE;
 
#define PM_EXEC_QUE_FLAG_EXEC   0x0001
 
#define PM_EXEC_QUE_INIT(q) { QUE_INIT((q),NULL,NULL,NULL,NULL), 0}


int pm_exec_que(PM_EXEC_QUE *eq);
int	pm_set_exit_routine(void (*rou)());
int pm_exit(int status);
int pm_active(void);
int pm_inactive(void);
int pm_down(int status);
int pm_abort(int status);
int pm_debug(void);
int pm_add_ent(int (*rou)(), void *arg, QHD *que);
int pm_add_goactive(int (*rou)(), void *arg);
int pm_add_active(int (*rou)(), void *arg);
int pm_add_inactive(int (*rou)(), void *arg);
int pm_add_abort(int (*rou)(), void *arg);
int pm_add_exit(int (*rou)(), void *arg);
int pm_add_debug(int (*rou)(), void *arg);
int pm_rmv_ent(int (*rou)(), void *arg, QHD *que);
int pm_rmv_goactive(int (*rou)(), void *arg);
int pm_rmv_active(int (*rou)(), void *arg);
int pm_rmv_inactive(int (*rou)(), void *arg);
int pm_rmv_abort(int (*rou)(), void *arg);
int pm_rmv_exit(int (*rou)(), void *arg);
int pm_rmv_debug(int (*rou)(), void *arg);
int pm_nm_msg(MSG_NM *m, VMSGQ *msgq);
int pm_send_nm_msg( MSGTYPE type, NET_ADDR *dest, NET_ADDR *na, short tlevel, short state, ulong size);
int pm_bc_nm_msg( MSGTYPE type, NET_ADDR *dest, short tlevel, short state, ulong size);
int pm_savelogs(NET_ADDR *na);
int pm_resetlogs(NET_ADDR *na);
int pm_trace_all(NET_ADDR *na, int tlevel);


#endif

