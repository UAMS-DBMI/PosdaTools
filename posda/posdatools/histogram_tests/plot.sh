#!/usr/bin/env bash

#feh $1 &
./generate_scatter_data.py $1 > scatter.dat
gnuplot -c scatter.gplot
rm scatter.dat
