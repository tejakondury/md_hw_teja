#!/bin/bash

for num in {1..30..1}
do
	i=`echo "scale=2 ; ${num}/10" | bc`

	ee=`grep -A1 "Energy initial, next-to-last, final =" out.run$i`
	echo $i $ee  >>summary.dat 
done

# concatenate the file into plottable format

awk '!($2=$3=$4=$5=$6=$8=$9="")' summary.dat > potential.dat

# Use gnuplot to plot the data

gnuplot -persist pp   # pp has the parameters for the plot
 
