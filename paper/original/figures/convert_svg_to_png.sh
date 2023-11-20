#!/bin/bash
set -e
DPI=450
PARALLELL_DEGREE=4


function convert {
	i=0
	for filename in $(find *.svg 2> /dev/null); do
		new_file=$(basename $filename .svg)
		
		# Parallelized
		inkscape $filename -d $DPI-D -o ${new_file}.png --export-type=png &> /dev/null &
		pids[${i}]=$!
		i=$(($i+1))
		if (( $i % $PARALLELL_DEGREE == 0 ))
		then
			for pid in ${pids[*]}; do
				wait $pid
			done
		fi
	done
	for pid in ${pids[*]}; do
		wait $pid
	done
}


echo "Converting Transcode figures to $DPI dpi"
cd transcode
convert
cd ..
