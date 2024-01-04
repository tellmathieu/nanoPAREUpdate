#!/usr/bin/env bash


st=`date +%s`
echo "//////////START (${st} )" > runtime.log
bash nanoPARE_setup.sh -R /share/quonlab/workspaces/tmathieu/meyersData/reference.table -G /share/quonlab/workspaces/tmathieu/meyers/nanoPAREUpdate/nanoPARE/resources/genome.fasta -A /share/quonlab/workspaces/tmathieu/meyers/nanoPAREUpdate/nanoPARE/resources/annotation.gff --cpus 48 > setup.stdout.log 2> setup.stderr.log
et=`date +%s`
rt=$((et-st))
echo "//////////SETUP_DONE (${rt} s)" >> runtime.log

st=`date +%s`
# Modify the range of numbers to account for the number of rows in resources/reference.table
for l in {1..6} ;do bash endMap.sh -L "${l}" -R /share/quonlab/workspaces/tmathieu/meyersData/reference.table -G /share/quonlab/workspaces/tmathieu/meyers/nanoPAREUpdate/nanoPARE/resources/genome.fasta -A /share/quonlab/workspaces/tmathieu/meyers/nanoPAREUpdate/nanoPARE/resources/annotation.gff --cpus 48 >> endmap.stdout.log 2>> endmap.stderr.log;done
et=`date +%s`
rt=$((et-st))
echo "//////////ENDMAP_FINISHED (${rt} s)" >> runtime.log

st=`date +%s`
# Modify the range of numbers to accommodate the number of samples you will be processing
for n in {1..3} ;do bash endGraph.sh -N "test${n}" -R /share/quonlab/workspaces/tmathieu/meyersData/reference.table -G /share/quonlab/workspaces/tmathieu/meyers/nanoPAREUpdate/nanoPARE/resources/genome.fasta -A /share/quonlab/workspaces/tmathieu/meyers/nanoPAREUpdate/nanoPARE/resources/annotation.gff --cpus 48 >> endgraph.stdout.log 2>> endgraph.stderr.log;done

et=`date +%s`
rt=$((et-st))
echo "//////////ENDGRAPH_FINISHED! (${rt} s)" >> runtime.log

st=`date +%s`
bash endClass.sh --type test -R /share/quonlab/workspaces/tmathieu/meyersData/reference.table -G /share/quonlab/workspaces/tmathieu/meyers/nanoPAREUpdate/nanoPARE/resources/genome.fasta -A /share/quonlab/workspaces/tmathieu/meyers/nanoPAREUpdate/nanoPARE/resources/annotation.gff --cpus 48 >> endclass.stdout.log 2>> endclass.stderr.log
et=`date +%s`
rt=$((et-st))
echo "//////////ENDCLASS_FINISHED! (${rt} s)" >> runtime.log

st=`date +%s`
bash endMask.sh --type test -R /share/quonlab/workspaces/tmathieu/meyersData/reference.table -G /share/quonlab/workspaces/tmathieu/meyers/nanoPAREUpdate/nanoPARE/resources/genome.fasta -A /share/quonlab/workspaces/tmathieu/meyers/nanoPAREUpdate/nanoPARE/resources/annotation.gff --cpus 48 >> endmask.stdout.log 2>> endmask.stderr.log
et=`date +%s`
rt=$((et-st))
echo "//////////ENDMASK_FINISHED! (${rt} s)" >> runtime.log

st=`date +%s`
python3 /share/quonlab/workspaces/tmathieu/meyers/nanoPAREUpdate/nanoPARE/EndCut.pipeline/scripts/sRNA_shuffler.py /share/quonlab/workspaces/tmathieu/meyers/nanoPAREUpdate/nanoPARE/EndCut.pipeline/resources/sRNAs/anno.mir.tas.fa 1000 /share/quonlab/workspaces/tmathieu/meyersData/shuffleDir_orig_mond
et=`date +%s`
rt=$((et-st))
echo "//////////ENDCUT_SHUFFLER_1_DONE (${rt} s)" >> runtime.log


echo "nanoPARE run success pipestance exiting" >> runtime.log
