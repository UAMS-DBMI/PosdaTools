#!/usr/bin/env bash
echo "Executing posda_shell inside docker container..."

docker exec -itw /home/posda/posdatools/ posda2_posda_1 /home/posda/posdatools/posda_shell
