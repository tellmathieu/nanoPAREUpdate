#!/bin/bash

normalize=$1
refTable=$2
dataDir=$3
transcript_bedgraph_capmaskedDir=$4
suff=$5
resultsEndMask=$6

sampleNames=($(cat $refTable | awk '{ print $4 }' | sort | uniq))

for name in ${sampleNames[@]}
	do
		sampleType=($(cat $refTable | grep "${name}" | awk '{ print $5 }'))
		bash $normalize ${name} $dataDir $transcript_bedgraph_capmaskedDir $suff $resultsEndMask $sampleType
	done

