#ifndef LINT

#endif
extern	char	libRelease[];
static	char	*LibRelease = libRelease;
/*.
 ****************************************************************************
 *
 *	log_dump		dump bytes in hex and ascii.
 *
 *	SYNOPSIS:
 *
 *	int log_dump ( level, addr, len )
 *		int		level;		indicated trace level at which to log error
 *		BYTE	*addr;		ptr to buffer to dump.
 *		int		len;		len to dump.
 *
 *	RETURNS:
 *
 *		none.
 *
 ****************************************************************************
.*/
#include <stdio.h>
#include <ctype.h>
#include <string.h>
#include "global.h"
#include "log.h"

extern short TraceLevel;
extern BYTE	TraceLevels[TC_MAX];

void log_dump_with_class (class, level, adr, len) 
register	void *adr;
register	int		class, len, level;
{
	register int i, offset;
	char buf[128], dbuf[17];
	unsigned char *addr;
	int	classTraceLevel;

	addr = (unsigned char *) adr ;

	if (level < 0)
		level = 0;

	classTraceLevel = TraceLevel;
	if ( class > TC_DEFAULT  &&  class < TC_MAX && TraceLevels[class] != 0)
		  classTraceLevel = TraceLevels[class];
	if (level && classTraceLevel < level)
		return;

	if (len <= 0 || addr == NULL)
		return;

	buf[0] = dbuf[16] = 0;
	for (offset = 0; len > 0; addr += 16, len -= 16, offset += 16)
	{
		for (i = 0; i < 16; ++i)
		{
			if (i < len)
			{
				sprintf (&buf[i * 3], " %02X", addr[i]);
				dbuf[i] = isprint(addr[i]) ? addr[i] : ' ';
			}
			else
			{
				strcpy(&buf[i * 3], "   ");
				dbuf[i] = 0;
			}
		}
		logerr (class, level, 0, "\t (%03x) %s\t: %s", offset, buf, dbuf);
	}
}

void log_dump (level, adr, len) 
register	void *adr;
register	int		len, level;
{
	log_dump_with_class (TRACE_CLASS, level, adr, len);
}

