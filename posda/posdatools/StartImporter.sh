#!/bin/sh
cd /home/posda/NewPosdaTools/DatabaseProcessor
rm nohup.out
nohup PosdaFileProcessDaemon.pl &
cd ../BacklogProcessor
rm nohup.out
nohup ProcessBacklog.pl &
