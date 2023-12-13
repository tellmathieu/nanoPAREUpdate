#!/bin/bash


# command to run this in snakemake bash runEndCutGstarBash.sh {params.sRna} {params.numShuffledSets} {params.gstar} {params.dataShuffleDir} {params.gstar_prog} {params.transcriptomeFASTA} {params.dataDir}

st=`date +%s`
		
sRna="/share/quonlab/workspaces/tmathieu/meyers/nanoPAREUpdate/nanoPARE/EndCut.pipeline/resources/sRNAs/anno.mir.tas.fa"
numShuffledSets=1000
gstarsh="/share/quonlab/workspaces/tmathieu/meyers/nanoPAREUpdate/nanoPARE/EndCut.pipeline/scripts/nanoPARE_GSTAr_v02_orig_slow.sh"
dataShuffleDir="/share/quonlab/workspaces/tmathieu/meyersData/shuffleDir"
gstar_prog="/share/quonlab/workspaces/tmathieu/meyers/nanoPAREUpdate/nanoPARE/EndCut.pipeline/scripts/GSTAr.pl"
transcriptome="/share/quonlab/workspaces/tmathieu/meyers/nanoPAREUpdate/nanoPARE/resources/transcriptome.fasta"
dataDir="/share/quonlab/workspaces/tmathieu/meyersData"

bash $gstarsh $dataShuffleDir $sRna $gstar_prog $transcriptome $dataDir

et=`date +%s`
rt=$((et-st))
echo "//////////ENDCUT_GSTAR_2_DONE ${rt} s" >> runtime.log