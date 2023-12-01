#!/bin/bash

sRna=$1
numShuffledSets=$2
gstarsh=$3
dataShuffleDir=$4
gstar_prog=$5
transcriptome=$6
dataDir=$7

bash $gstarsh $dataShuffleDir $sRna $gstar_prog $transcriptome $dataDir

#fileNames=($(cat $1 | awk '{ print $2 }' | sort | uniq))

#for name in ${fileNames[@]}
#	do
		
#	done

