/*
 ************************************************************************
 *			queue.h -- Standard queue routine data definitions			*
 *
 *	This include file requires the following include files: 
 *
 *		global.h
 *
 ************************************************************************
 *

 */

#ifndef _QUE_
#define _QUE_



/* Standard queue link  */

typedef struct qlk 
{
	char		*qlk_prev;
	char		*qlk_next;
} QLK;

/* Standard queue header */

typedef struct qhd
{
	QLK		qhd_chain;			/* chain of buffers 						*/
	long	qhd_onq;			/* number of buffers on queue 				*/
	long	qhd_owned;			/* number of buffers owned 					*/
	void	(*qhd_start)();		/* routine to be called when transition to 
									non empty made 							*/
	void	*qhd_start_arg;		/* ptr to arg of unknown type for start func*/
	void	(*qhd_end)();		/* routine to be called when transition to 
									empty made 								*/
	void	*qhd_end_arg;		/* ptr to arg of unknown type for end func	*/
	unsigned short	qhd_chk_value;	/* check value, set on que init			*/
	long	qhd_buf_siz;		/* size of each buffer						*/
    char    *qhd_addr;          /* ptr to calloc() memory holding que bufs	*/
    short   qhd_nice;           /* indicates que buf mem is contiguous		*/
} QHD;

/* Standard buffer header */

typedef struct qbf
{
	QLK	     buf_link;			/* link to prior and next        */
	QHD	     *buf_owner;		/* ptr to owning queue           */
	long	 buf_size;			/* number of bytes in buffer     */
	void	 *buf_curr_owner;	/* current owner of buffer       */
								/*   qhd ptr or routine ptr      */
	unsigned short	 buf_offset;/* offset qbf is into actual struct	*/
} QBF;


#define queue_empty(q) (((q)->qhd_chain.qlk_next) == ( char *)(q))
#define queue_size(q) ((q)->qhd_onq)
#define queue_owned(q) ((q)->qhd_owned)
#define	queue_valid(q) ((q) && (q) != QUE_BUF_STATICALLY_OWNED && (q)->qhd_chk_value == QUE_CHK_VALUE)
#define queue_on_free_que(b) ((b)->buf_curr_owner == (void *) (b)->buf_owner)

#define queue_buf_curr_owner(b,r) ({if (!queue_on_que(b)) (b)->buf_curr_owner =(r)})

#define queue_on_que(b) ((b)->buf_link.qlk_prev || (b)->buf_link.qlk_next)
#define	queue_buf_valid(b)			( (b)  &&							\
			(((b)->buf_link.qlk_prev && (b)->buf_link.qlk_next &&		\
				((b)->buf_curr_owner == QUE_BUF_STATICALLY_OWNED || queue_valid((b)->buf_curr_owner)) ||						\
			 (!(b)->buf_link.qlk_prev && !(b)->buf_link.qlk_next)))

	/*	if buf is on a queue, returns queue head, NULL otherwise	*/
#define	queue_buf_que(b)	(queue_on_que(b) ? ((b)->buf_curr_owner == QUE_BUF_STATICALLY_OWNED ? NULL : (b)->buf_curr_owner) : NULL)


#define QUE_BUF_STATICALLY_OWNED	(QHD *)-2L
	/* for statically or locally allocated buffers */
#define QUE_CHK_VALUE	0x0dead
#define	QUE_INIT(q, s,s_a, e,e_a)							\
	{	{(char *) &(q), (char *) &(q)}, 0, 0, s, s_a, e, e_a,	\
		QUE_CHK_VALUE, 0, NULL, FALSE	}

#define	QUE_BUF_INIT(b)									\
		{ {NULL, NULL}, NULL, (sizeof(b)-sizeof(struct qbf)), NULL }

#define queue_not_empty_func(q,f,a) 						\
	{	((QHD *)(q))->qhd_start		= f;				\
		((QHD *)(q))->qhd_start_arg	= (void *)(a);	}
		
#define queue_empty_func(q,f,a) 							\
	{	((QHD *)(q))->qhd_end		= f;				\
		((QHD *)(q))->qhd_end_arg	= (void *)(a);	}
		
#define queue_buf_on_que(b) 								\
	( ((QBF *)b)->buf_link.qlk_prev && 				\
	  ((QBF *)b)->buf_link.qlk_next)

#define	queue_rem_buf(b)									\
	(	queue_buf_on_que(b) ?								\
		(QBF *)queue_remq((QHD *)((QBF *)b)->buf_curr_owner,(b)):((QBF *)b))

#define	queue_str_addr(b) ((void *) (((char *)(b)) - (b)->buf_offset))

#ifdef ANSI_PROTO

typedef	void (*QUE_MAP_FUNC)(QHD *q, void *b, void *a);
typedef	void (*QUE_MAPR_FUNC)(void *p);
typedef	void *(*QUE_MAPI_FUNC)(QHD *q, void *b, void *a);

void queue_init(QHD *q, void (*s)(), void *s_a, void (*e)(), void *e_a);
void queue_buf_init(QHD *q, unsigned long n, unsigned long s, void *p);
void queue_mbuf_init(QHD *q, unsigned long n, unsigned long s, void *p, QBF *b);
void queue_buf_alloc(QBF **b, unsigned long s);
void queue_buf_static_alloc(QBF *b, unsigned long s);
long  queue_buf_rel(QHD *q);
long  queue_buf_free(QHD *q);
long  queue_purge(QHD *q);
void  *queue_get(QHD *q);
void  *queue_get_tail(QHD *q);
void  *queue_look_head(QHD *q);
void  *queue_look_tail(QHD *q);
void  *queue_look_next(QHD *q, QBF *b);
void  *queue_look_prev(QHD *q, QBF *b);
long  queue_put(QHD *q, QBF *b);
long  queue_put_head(QHD *q, QBF *b);
long  queue_rel(QBF *q);
long  queue_put_prio(QHD *q, QBF *b, int (*o)());
void  *queue_remq(QHD *q, QBF *b);
void queue_mapr(QHD *q, QUE_MAPR_FUNC);
void queue_map(QHD *q, QUE_MAP_FUNC, void *a);
void *queue_mapi_from(QHD *q, QUE_MAPI_FUNC, void *a, QBF *s);
void *queue_mapi(QHD *q, QUE_MAPI_FUNC, void *a);
void *queue_bmapi(QHD *q, QUE_MAPI_FUNC, void *a);
void queue_p(QHD *q, QBF *b, QLK *l);
long  queue_set_owner(QBF *b, void *p);
long  queue_copy(QHD *fq, QHD *src, QHD *dest);
long  queue_move(QHD *src, QHD *dest);
void queue_dump(QHD *q, void (*f)());

#else

typedef	void (*QUE_MAP_FUNC)();
typedef	void (*QUE_MAPR_FUNC)();
typedef	void *(*QUE_MAPI_FUNC)();

void queue_init();
void queue_buf_init();
void queue_mbuf_init();
void queue_buf_alloc();
void queue_buf_static_alloc();
int  queue_buf_rel();
int  queue_buf_free();
int  queue_purge();
void  *queue_get();
void  *queue_get_tail();
void  *queue_look_head();
void  *queue_look_tail();
void  *queue_look_next();
void  *queue_look_prev();
int  queue_put();
int  queue_put_head();
int  queue_rel();
int  queue_put_prio();
void  *queue_remq();
void queue_mapr();
void queue_map();
void *queue_mapi_from();
void *queue_mapi();
void *queue_bmapi();
void queue_p();
int  queue_set_owner();
int  queue_copy();
void queue_dump();
#endif

#endif

