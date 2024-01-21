#!/usr/bin/env bash

runtime_log="runtimejan20orig.log"
ref="/share/quonlab/workspaces/tmathieu/meyersData/reference.table"
normalize="http://esb.genomecenter.ucdavis.edu/share/quonlab/workspaces/tmathieu/meyers/nanoPAREUpdate/nanoPARE/EndCut.pipeline/scripts/nanoPARE_EndCut.step1_v02_normalize.sh"

st=`date +%s`
echo "//////////START-orig-manual-pipeline (${st} )" > $runtime_log
bash nanoPARE_setup.sh -R /share/quonlab/workspaces/tmathieu/meyersData/reference.table -G /share/quonlab/workspaces/tmathieu/meyers/nanoPAREUpdate/nanoPARE/resources/genome.fasta -A /share/quonlab/workspaces/tmathieu/meyers/nanoPAREUpdate/nanoPARE/resources/annotation.gff --cpus 48 > setup.stdout.log 2> setup.stderr.log
et=`date +%s`
rt=$((et-st))
echo "//////////SETUP_DONE (${rt} s)" >> $runtime_log

st=`date +%s`
# Modify the range of numbers to account for the number of rows in resources/reference.table
for l in {1..6} ;do bash endMap.sh -L "${l}" -R /share/quonlab/workspaces/tmathieu/meyersData/reference.table -G /share/quonlab/workspaces/tmathieu/meyers/nanoPAREUpdate/nanoPARE/resources/genome.fasta -A /share/quonlab/workspaces/tmathieu/meyers/nanoPAREUpdate/nanoPARE/resources/annotation.gff --cpus 48 >> endmap.stdout.log 2>> endmap.stderr.log;done
et=`date +%s`
rt=$((et-st))
echo "//////////ENDMAP_FINISHED (${rt} s)" >> $runtime_log

st=`date +%s`
# Modify the range of numbers to accommodate the number of samples you will be processing
for n in {1..3} ;do bash endGraph.sh -N "test${n}" -R /share/quonlab/workspaces/tmathieu/meyersData/reference.table -G /share/quonlab/workspaces/tmathieu/meyers/nanoPAREUpdate/nanoPARE/resources/genome.fasta -A /share/quonlab/workspaces/tmathieu/meyers/nanoPAREUpdate/nanoPARE/resources/annotation.gff --cpus 48 >> endgraph.stdout.log 2>> endgraph.stderr.log;done

et=`date +%s`
rt=$((et-st))
echo "//////////ENDGRAPH_FINISHED! (${rt} s)" >> $runtime_log

st=`date +%s`
bash endClass.sh --type test -R /share/quonlab/workspaces/tmathieu/meyersData/reference.table -G /share/quonlab/workspaces/tmathieu/meyers/nanoPAREUpdate/nanoPARE/resources/genome.fasta -A /share/quonlab/workspaces/tmathieu/meyers/nanoPAREUpdate/nanoPARE/resources/annotation.gff --cpus 48 >> endclass.stdout.log 2>> endclass.stderr.log
et=`date +%s`
rt=$((et-st))
echo "//////////ENDCLASS_FINISHED! (${rt} s)" >> $runtime_log

st=`date +%s`
bash endMask.sh --type test -R /share/quonlab/workspaces/tmathieu/meyersData/reference.table -G /share/quonlab/workspaces/tmathieu/meyers/nanoPAREUpdate/nanoPARE/resources/genome.fasta -A /share/quonlab/workspaces/tmathieu/meyers/nanoPAREUpdate/nanoPARE/resources/annotation.gff --cpus 48 >> endmask.stdout.log 2>> endmask.stderr.log
et=`date +%s`
rt=$((et-st))
echo "//////////ENDMASK_FINISHED! (${rt} s)" >> $runtime_log

st=`date +%s`
python3 /share/quonlab/workspaces/tmathieu/meyers/nanoPAREUpdate/nanoPARE/EndCut.pipeline/scripts/sRNA_shuffler.py /share/quonlab/workspaces/tmathieu/meyers/nanoPAREUpdate/nanoPARE/EndCut.pipeline/resources/sRNAs/anno.mir.tas.fa 1000 /share/quonlab/workspaces/tmathieu/meyersData/shuffleDir_orig_mond
et=`date +%s`
rt=$((et-st))
echo "//////////ENDCUT_SHUFFLER_1_DONE (${rt} s)" >> $runtime_log

st=`date +%s`
		
sRna="/share/quonlab/workspaces/tmathieu/meyers/nanoPAREUpdate/nanoPARE/EndCut.pipeline/resources/sRNAs/anno.mir.tas.fa"
numShuffledSets=1000
gstarsh="/share/quonlab/workspaces/tmathieu/meyers/nanoPAREUpdate/nanoPARE/EndCut.pipeline/scripts/nanoPARE_GSTAr_v02_orig_slow.sh"
dataShuffleDir="/share/quonlab/workspaces/tmathieu/meyersData/shuffleDirJan2"
gstar_prog="/share/quonlab/workspaces/tmathieu/meyers/nanoPAREUpdate/nanoPARE/EndCut.pipeline/scripts/GSTAr.pl"
transcriptome="/share/quonlab/workspaces/tmathieu/meyers/nanoPAREUpdate/nanoPARE/resources/transcriptome.fasta"
dataDir="/share/quonlab/workspaces/tmathieu/meyersData"
gstarDir="GSTAr" #don't change this, the gstar step has this hardcoded.
endCutResourceDir="/share/quonlab/workspaces/tmathieu/meyers/nanoPAREUpdate/nanoPARE/EndCut.pipeline/resources"

bash $gstarsh $dataShuffleDir $sRna $gstar_prog $transcriptome $dataDir

et=`date +%s`
rt=$((et-st))
echo "//////////ENDCUT_GSTAR_2_DONE ${rt} s" >> $runtime_log

st=`date +%s`
		
bash /share/quonlab/workspaces/tmathieu/meyers/nanoPAREUpdate/nanoPareVT1/runEndCutNormalizeBash.sh $normalize $ref $dataDir "transcript_bedgraph_capmasked_orig_jan2"
 "transcript.capmasked"
et=`date +%s`
rt=$((et-st))
echo "//////////ENDCUT_NORMALIZE_DONE ($rt s)" >> $runtime_log

st=`date +%s`
bash /share/quonlab/workspaces/tmathieu/meyers/nanoPAREUpdate/nanoPareVT1/runEndCutStep1Bash.sh /share/quonlab/workspaces/tmathieu/meyers/nanoPAREUpdate/nanoPARE/EndCut.pipeline/scripts/nanoPARE_EndCut.step1_v02.sh $ref $dataDir 20 "transcript_bedgraph_capmasked_orig_jan2" "transcript.capmasked" $gstarDir $dataShuffleDir
et=`date +%s`
rt=$((et-st))
echo "//////////ENDCUT_STEP1_WIN1_DONE ($rt s)" >> $runtime_log

st=`date +%s`
bash /share/quonlab/workspaces/tmathieu/meyers/nanoPAREUpdate/nanoPareVT1/runEndCutStep1Bash.sh /share/quonlab/workspaces/tmathieu/meyers/nanoPAREUpdate/nanoPARE/EndCut.pipeline/scripts/nanoPARE_EndCut.step1_v02.sh $ref $dataDir 50 "transcript_bedgraph_capmasked_orig_jan2" "transcript.capmasked" $gstarDir $dataShuffleDir
et=`date +%s`
rt=$((et-st))
echo "//////////ENDCUT_STEP1_WIN2_DONE ($rt s)" >> $runtime_log

st=`date +%s`
bash /share/quonlab/workspaces/tmathieu/meyers/nanoPAREUpdate/nanoPareVT1/runEndCutStep2Bash.sh /share/quonlab/workspaces/tmathieu/meyers/nanoPAREUpdate/nanoPARE/EndCut.pipeline/scripts/EndCut_step2.v03.git.R $ref $dataDir "transcript_bedgraph_capmasked_orig_jan2" "transcript.capmasked" $numShuffledSets $endCutResourceDir
et=`date +%s`
rt=$((et-st))
echo "//////////ENDCUT_STEP2_DONE ($rt s)" >> $runtime_log

echo "nanoPARE run success pipestance exiting" >> $runtime_log
