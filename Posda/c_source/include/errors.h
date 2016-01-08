/*
 *********************************************************************
 *			errors.h
 *
 *	Application Error Code Definitions
 *
 *********************************************************************
 */


/*

 */

#ifndef	_ERRORS_
#define	_ERRORS_

#include <sys/errno.h>

#define	PosdaERR			100

/*
 *	 Device Driver Error Codes
*/

#define	EOPEN		PosdaERR+0	/* device is already open			*/
#define	EPDMA		PosdaERR+1	/* psuedo-dma error					*/
#define	ENOCONFIG	PosdaERR+2	/* device not configured (ioctl)    */
#define	ERESIDUE	PosdaERR+3	/* residue left after read or write */
#define ENODAT		PosdaERR+4	/* no data available				*/
#define ESESSION	PosdaERR+5	/* read/write session violation		*/
#define EMSG		PosdaERR+6	/* device comm failure				*/
#define EDEVICE		PosdaERR+7	/* general device error				
									use GETERR_XX for more info		*/
#define EBADSIZ		PosdaERR+8	/* bad read or write size			*/
#define EIDLE		PosdaERR+9	/* device idle (ACR-NEMA driver)	*/
/*
 *	General Error Codes Common to All Processes
 */
#define	ERRNONE		0			/* not an error code					*/
#define	ERRSYSBUSY	PosdaERR+10	/* system or channel congested (full)	*/
#define	ERRCHANDOWN	PosdaERR+11	/* output channel is DOWN				*/
#define	ERRINVCHAN	PosdaERR+12	/* invalid channel name or id specified	*/
#define	ERRINVFTYP	PosdaERR+13	/* invalid file type specified			*/
#define	ERRINVPRI	PosdaERR+14	/* invalid xmit priority specified		*/
#define	ERRNOTFND	PosdaERR+15	/* unable to open file					*/
#define	ERRINVIO	PosdaERR+16	/* invalid i/o operation specified		*/
#define	ERRNOTRDY	PosdaERR+17	/* device/file not ready for i/o		*/
#define	ERRTIMOUT	PosdaERR+18	/* device or i/o operation timeout out	*/
#define	ERRSHARED	PosdaERR+19	/* shared memory not opened/initialized	*/
#define	ERRBADID	PosdaERR+20	/* invalid program id or all id's used	*/
#define	ERRDUPID	PosdaERR+21	/* duplicate program id specified		*/
#define	ERRQUEFUL	PosdaERR+22	/* internal queue full					*/
#define	ERRQUEEMP	PosdaERR+23	/* internal queue empty					*/
#define	ERRQUEPUT	PosdaERR+24	/* error on queue put					*/
#define	ERRQUEGET	PosdaERR+25	/* error on queue get					*/
#define	ERRQUEPFQ	PosdaERR+26	/* que err - attempt to purge free que	*/
#define	ERRQUEPNB	PosdaERR+27	/* que err - attempt to put null buff	*/
#define	ERRQUEBOQ	PosdaERR+28	/* que err - attempt to put buff on queue
								   that was allready on queue			*/
#define	ERRFCNTL	PosdaERR+29	/* file control operation failed		*/
#define	ERRPARM		PosdaERR+30	/* parameter error						*/
#define	ERRINTERNAL	PosdaERR+31	/* internal error (bad addr, table, ect)*/
#define	ERRINVFID	PosdaERR+32	/* invalid file id						*/
#define	ERRINVSD	PosdaERR+33	/* invalid sd specified					*/
#define	ERRIPCINIT	PosdaERR+34	/* sd not open and/or ipc tbl not init'd */
#define	ERRINVMSG	PosdaERR+35	/* invalid msg type in IPC message		*/
#define	ERRSYSDOWN	PosdaERR+36	/* system/process is down/inactive		*/
#define	ERRNOTOWNER	PosdaERR+37	/* not owner of file					*/
#define	ERRNOFILE	PosdaERR+38	/* no file available for operation		*/
#define	ERRINVOP	PosdaERR+39	/* invalid/illegal operation			*/
#define	ERRCHANNAK	PosdaERR+40	/* received nak for chan up msg			*/
#define	ERRINVFSTS	PosdaERR+41	/* invalid file status specified		*/
#define	ERRNCFINV	PosdaERR+42	/* network config file invalid			*/
#define	ERRQUEINV	PosdaERR+43	/* que head not initilized				*/
#define ERRQUEALLOC PosdaERR+44   /* malloc() failed                      */
#define ERRSHORTBUF PosdaERR+45   /* internal buffer to short				*/
#define	ERRINVNA	PosdaERR+46	/* invalid network address				*/
#define	ERRDBDOWN	PosdaERR+47	/* generic 'database is down' error		*/



#endif

