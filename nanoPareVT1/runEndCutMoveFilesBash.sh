#!/bin/bash

resultsEndMask=$1
bedgraphDir=$2

allbg=($(find $resultsEndMask -print | grep -i .transcript.capmasked.bedgraph))
		
if [ ${#allbg[@]} -ne 0 ] 
	then
		echo "Moving files."
		for file in "${allbg[@]}"
		do
			mv $resultsEndMask${file} $bedgraphDir
		done
	else
		echo "Bedgraphs already moved."
fi
echo "Past the moving step."
