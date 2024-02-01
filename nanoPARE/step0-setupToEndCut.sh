#!/bin/bash

runtime_log="runtimejan22orig.log"
ref="/home/ec2-user/meyersData/reference.table"
normalize="/home/ec2-user/nanoPAREUpdate/nanoPARE/EndCut.pipeline/scripts/nanoPARE_EndCut.step1_v02_normalize.sh"
sRna="/home/ec2-user/nanoPAREUpdate/nanoPARE/EndCut.pipeline/resources/sRNAs/anno.mir.tas.fa"
numShuffledSets=1000
gstarsh="/home/ec2-user/nanoPAREUpdate/nanoPARE/EndCut.pipeline/scripts/nanoPARE_GSTAr_v02_orig_slow.sh"
dataShuffleDir="/home/ec2-user/meyersData/shuffleDir_orig_jan22"
gstar_prog="/home/ec2-user/nanoPAREUpdate/nanoPARE/EndCut.pipeline/scripts/GSTAr.pl"
transcriptome="/home/ec2-user/nanoPAREUpdate/nanoPARE/resources/transcriptome.fasta"
dataDir="/home/ec2-user/meyersData"
gstarDir="GSTAr" #don't change this, the gstar step has this hardcoded.
endCutResourceDir="/home/ec2-user/nanoPAREUpdate/nanoPARE/EndCut.pipeline/resources"


st=`date +%s`
bash endMask.sh --type test -R $ref -G /home/ec2-user/nanoPAREUpdate/nanoPARE/resources/genome.fasta -A /home/ec2-user/nanoPAREUpdate/nanoPARE/resources/annotation.gff --cpus 2 >> endmask.stdout.log 2>> endmask.stderr.log
et=`date +%s`
rt=$((et-st))
echo "//////////ENDMASK_FINISHED! (${rt} s)" >> $runtime_log
