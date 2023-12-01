#!/bin/bash

step2=$1
refTable=$2
dataDir=$3
transcript_bedgraph_capmaskedDir=$4
suff=$5
numShuffledSets=$6
endCutResourceDir=$7

sampleNames=($(cat $refTable | awk '{ print $4 }' | sort | uniq))

for name in ${sampleNames[@]}
	do
		Rscript $step2 ${name} $dataDir$transcript_bedgraph_capmaskedDir/${name} $suff $endCutResourceDir $numShuffledSets $dataDir $transcript_bedgraph_capmaskedDir
	done
