#!/bin/bash


#command to run this in snakemake bash runEndCutGstarBash.sh {params.sRna} {params.numShuffledSets} {params.gstar} {params.dataShuffleDir} {params.gstar_prog} {params.transcriptomeFASTA} {params.dataDir}
		

sRna=$1
numShuffledSets=$2
gstarsh=$3
dataShuffleDir=$4
gstar_prog=$5
transcriptome=$6
dataDir=$7


bash $gstarsh $dataShuffleDir $sRna $gstar_prog $transcriptome $dataDir


