#!/bin/bash

# Script to plot Energy vs Volume for fcc structure

for num in {30..50..1}
do
	i=`echo "scale=2 ; ${num}/10" | bc`  # convert into floating point values
		
	ee=`grep -A1 "Energy initial, next-to-last, final =" out.run$i`
	
	vol=`echo "($i)^3" | bc`

	echo $vol $ee  >>summary.dat 
done

# concatenate the file into plottable format

awk '!($2=$3=$4=$5=$6=$8=$9="")' summary.dat > E-v.dat

# Use gnuplot to plot the data

gnuplot -persist pp   # pp has the parameters for the plot
 
