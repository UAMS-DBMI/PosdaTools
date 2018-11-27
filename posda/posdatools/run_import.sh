#!/bin/bash

for i in $(seq 0 8); do
	NewProcessFilesInDb.pl &	
done

# this waits only on the final spawned process
wait $!
