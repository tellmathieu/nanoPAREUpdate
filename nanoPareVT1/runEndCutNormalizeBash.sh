#!/bin/bash

normalize=$1
refTable=$2
dataDir=$3
transcript_bedgraph_capmaskedDir=$4
suff=$5

sampleNames=($(cat $refTable | awk '{ print $4 }' | sort | uniq))

for name in ${sampleNames[@]}
	do
		bash $normalize ${name} $dataDir $transcript_bedgraph_capmaskedDir $suff
	done

