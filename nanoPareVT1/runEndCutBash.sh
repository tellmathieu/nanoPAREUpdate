#!/bin/bash

shuffle=$1
sRna=$2
numShuffledSets=$3

python3 $shuffle $sRna $numShuffledSets
#python3 shuffle sRna numShuffledSets

#fileNames=($(cat $1 | awk '{ print $2 }' | sort | uniq))

#for name in ${fileNames[@]}
#	do
		
#	done

