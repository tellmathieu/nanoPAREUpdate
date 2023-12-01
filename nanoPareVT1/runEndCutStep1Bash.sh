#!/bin/bash

step1=$1
refTable=$2
dataDir=$3
WIN=$4
transcript_bedgraph_capmaskedDir=$5
suff=$6

sampleNames=($(cat $refTable | awk '{ print $4 }' | sort | uniq))

for name in ${sampleNames[@]}
	do
		bash $step1 ${name} $dataDir $WIN $transcript_bedgraph_capmaskedDir $suff
	done

