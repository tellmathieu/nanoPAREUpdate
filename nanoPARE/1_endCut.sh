#!/bin/bash
st=`date +%s`
srun -t 0-2 -p gc512 --mem 500000 -n 48 --partition production --pty python3 /share/quonlab/workspaces/tmathieu/meyers/nanoPAREUpdate/nanoPARE/EndCut.pipeline/scripts/sRNA_shuffler.py /share/quonlab/workspaces/tmathieu/meyers/nanoPAREUpdate/nanoPARE/EndCut.pipeline/resources/sRNAs/anno.mir.tas.fa 1000 /share/quonlab/workspaces/tmathieu/meyersData/shuffleDir_orig_mond
et=`date +%s`
rt=$((et-st))
echo "//////////ENDCUT_SHUFFLER_1_DONE (${rt} s)" >> runtime.log
