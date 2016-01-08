#$Source: /home/bbennett/pass/archive/Posda/c_source/makefile,v $
#$Date: 2013/07/12 12:02:38 $
#$Revision: 1.12 $
#
#Copyright 2008, Bill Bennett, Erik Strom
# Part of the Posda package
# Posda may be copied only under the terms of either the Artistic License or     the
# GNU General Public License, which may be found in the Posda Distribution,
# or at http://posda.com/License.html
#
#
# Normal use: # make clean;make all; make install
#

MODULES = ReadContours  \
          NewReadContours \
          LogPixOp \
          DvhBinner \
          DoseResampler \
          IsoDose \
          ContourToBitmap \
          ContourToBitMap3d \
          UncompressBitMap \
          ToPbm \
          ComputeMargin \
          SumDose \
          RtogTextToNum \
          ContourExtractor \
          BadFtpChk \
          CompressedPixBitMapToContour
SOURCES := $(MODULES).c 
OBJS := $(MODULES)

CC= gcc
CFLAGS= -O2 -lm

# % : %.c
#   $(CC) $(CFLAGS) –c $(.SOURCE)

# $(OBJS) : %.c
#	$(CC) $(CFLAGS) -c  -o $(.TARGET) $(.TARGET).c

# do not optimize the following above -O1 or they will fail:
#  ContourToBitMap3d 
#  ReadContours
#
# Following modules are listed in order of CPU usage
all: 
	gcc -O3 -o DoseResampler DoseResampler.c
	gcc -O3 -o DvhBinner DvhBinner.c
	gcc -O3 -o LogPixOp LogPixOp.c
	gcc -O3 -o IsoDose IsoDose.c
	gcc -O1 -o ReadContours ReadContours.c
	gcc -O1 -o NewReadContours NewReadContours.c
	gcc -O3 -o ContourToBitmap ContourToBitmap.c
	gcc -O1 -o ContourToBitMap3d ContourToBitMap3d.c
	gcc -O3 -o UncompressBitMap UncompressBitMap.c
	gcc -O3 -o ToPbm ToPbm.c
	gcc -O3 -lm -o ComputeMargin ComputeMargin.c 
	gcc -O3 -o SumDose SumDose.c 
	gcc -O3 -o RtogTextToNum RtogTextToNum.c 
	gcc -O3 -o ContourExtractor ContourExtractor.c 
	gcc -O3 -o BadFtpChk BadFtpChk.c 
	gcc -O3 -o CompressedPixBitMapToContour CompressedPixBitMapToContour.c 

clean:
	rm -f $(OBJS)  

install: clean all
	mv $(OBJS) ../../bin/

.PHONY: install

