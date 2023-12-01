#!/bin/bash

normalize=$1
refTable=$2
dataDir=$3
transcriptome=$4
dataDir=$5
transcript_bedgraph_capmaskedDir=$6
suff=$7

sampleNames=($(cat $refTable | awk '{ print $4 }' | sort | uniq))

for name in ${sampleNames[@]}
	do
		bash $normalize ${name} $dataDir $transcript_bedgraph_capmaskedDir $suff
	done

