#!/bin/bash

SIZE=512K
COUNT=1
FILE_COUNT=1000

for f in $(seq 1 $FILE_COUNT); do
	dd if=/dev/urandom of=./files/$f bs=$SIZE count=$COUNT
done
