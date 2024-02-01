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
resultsEndMask="/home/ec2-user/nanoPAREUpdate/nanoPARE/results/EndMask"


'''st=`date +%s`		
bash /home/ec2-user/nanoPAREUpdate/nanoPareVT1/runEndCutNormalizeBash.sh $normalize $ref $dataDir "transcript_bedgraph_capmasked_orig_jan22" "transcript.capmasked" $resultsEndMask
et=`date +%s`
rt=$((et-st))
echo "//////////ENDCUT_NORMALIZE_DONE ($rt s)" >> $runtime_log

st=`date +%s`
bash /home/ec2-user/nanoPAREUpdate/nanoPareVT1/runEndCutStep1Bash.sh /home/ec2-user/nanoPAREUpdate/nanoPARE/EndCut.pipeline/scripts/nanoPARE_EndCut.step1_v02.sh $ref $dataDir 20 "transcript_bedgraph_capmasked_orig_jan22" "transcript.capmasked" $gstarDir $dataShuffleDir $resultsEndMask
et=`date +%s`
rt=$((et-st))
echo "//////////ENDCUT_STEP1_WIN1_DONE ($rt s)" >> $runtime_log

st=`date +%s`
bash /home/ec2-user/nanoPAREUpdate/nanoPareVT1/runEndCutStep1Bash.sh /home/ec2-user/nanoPAREUpdate/nanoPARE/EndCut.pipeline/scripts/nanoPARE_EndCut.step1_v02.sh $ref $dataDir 50 "transcript_bedgraph_capmasked_orig_jan22" "transcript.capmasked" $gstarDir $dataShuffleDir $resultsEndMask
et=`date +%s`
rt=$((et-st))
echo "//////////ENDCUT_STEP1_WIN2_DONE ($rt s)" >> $runtime_log

'''
st=`date +%s`
bash /home/ec2-user/nanoPAREUpdate/nanoPareVT1/runEndCutStep2Bash.sh /home/ec2-user/nanoPAREUpdate/nanoPARE/EndCut.pipeline/scripts/EndCut_step2.v03gstar.git.R $ref $dataDir "transcript_bedgraph_capmasked_orig_jan22" "transcript.capmasked" $numShuffledSets $endCutResourceDir
et=`date +%s`
rt=$((et-st))
echo "//////////ENDCUT_STEP2_DONE ($rt s)" >> $runtime_log

echo "nanoPARE run success pipestance exiting" >> $runtime_log
