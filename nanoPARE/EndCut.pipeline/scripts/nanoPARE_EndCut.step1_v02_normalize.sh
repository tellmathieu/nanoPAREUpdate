#!/bin/bash


############set variables##############
export outDir_s=$3
export outDir_a=$4

export sample_name=$1
export WSEQ=$2


########################################

export BG=$WSEQ$outDir_s/${sample_name}.$outDir_a.bedgraph
export BG_norm=$BG.norm

echo 'Number of lines in original bedgraph:'
wc $BG

##get total number of transcriptome-mapping reads from BG file and use it to normalize BG hit-normalized reads
TMR=$(awk -v OFS='\t' '{sum+=$4}END{print sum}' $BG)
MTMR=$(awk '{print +$1 }' <<< $TMR)
MTMR=$(bc -l <<< $MTMR/1000000)

echo 'Total number of hit-normalized transcriptome-mapping reads (in millions: ' $MTMR

awk -v OFS='\t' -v MTMR="$MTMR" '{print $1,$2,$3,$4,$4/MTMR}' $BG > $BG_norm

echo 'Number of lines in normalized bedgraph:'
wc $BG_norm

echo 'nanoPARE_EndCut.step1_v02_normalize.sh complete!'
