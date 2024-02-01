#!/bin/bash

#set variables
#export NAME1=fb1_1to1
#export outDir_s=transcript_bedgraph_capmasked
#export outDir_a=W.transcript.capmasked

#NOTE: don't run 20 and 50 WIN simultaneously
export sample_name=$1
export WSEQ=$2
export WIN=$3
export shuffledNamesDir=$7
export progDir=$6
export outDir_s=$4
export outDir_a=$5
export resultsEndMask=$8
export refTable=$9
export sampleType=($(cat $refTable | grep "${sample_name}" | awk '{ print $5 }'))
#########################################
#export WSEQ_s=mRNA/180228/
#export WSEQ=/lustre/scratch/users/michael.nodine/seq/$WSEQ_s
#export dataRoot=WSEQ
#export TEST=anno.mir.tas.fa.GSTAr
#export SHUFF=anno.mir.tas
export BG=$resultsEndMask/$sampleType/${sample_name}.$outDir_a.bedgraph
export BG_norm=$WSEQ/$outDir_s/${sample_name}.$outDir_a.bedgraph.norm
export BG_norm_overlap=$BG_norm.overlap
export BG_norm_overlap_up=$BG_norm.overlap.up
export BG_norm_overlap_down=$BG_norm.overlap.down
export outDir=$WSEQ/$outDir_s/${sample_name}/
########################################

mkdir -p $outDir

cd $shuffledNamesDir

shuffleArray=(*)
# Iterates through the shuffled files to run GSTAr
for item in "${shuffleArray[@]}"
do
        ##get intersection with *pred.sites.bed and BG_norm, select those with at least one read at predicted site and record 
        ##sRNA, Transcript, Slice.site, AllenScore, flankMax.rpm slice.site.rpm slice.site.hit.norm
        item1=${item%.fa}
        cat $BG_norm | sed 's/\.[0-9]//g' > ${BG_norm}.trim

        bedtools intersect -wb -wa -a $WSEQ/$outDir_s/${item1}.pred.sites.bed -b ${BG_norm}.trim | awk -v OFS='\t' '{print $1,$2,$3,$4,$5,$9,$10}' | sort -k1,1 -k2,2n > $BG_norm_overlap.${item1} 
        echo 'step 1 complete...'
        ##for all sites with detectable reads, generate bed files of upstream and downstream regions
        awk -v OFS='\t' -v WIN="$WIN" '{if ($2 - WIN > 0) print $1,$2 - WIN,$3 - 2; else print $1, 0, $3 - 1}' $BG_norm_overlap.${item1} > $BG_norm_overlap_up.${item1}  
        awk -v OFS='\t' -v WIN="$WIN" '{print $1, $2 + 2, $3 + WIN}' $BG_norm_overlap.${item1} > $BG_norm_overlap_down.${item1}
        echo 'step 2 complete...'
        ##now look for maximum in up and down files
        bedtools map -a $BG_norm_overlap_up.${item1} -b $BG_norm -c 5 -o max -null 0 > $BG_norm_overlap_up.plus.${item1}
        bedtools map -a $BG_norm_overlap_down.${item1} -b $BG_norm -c 5 -o max -null 0 > $BG_norm_overlap_down.plus.${item1}
        echo 'step 3 complete...'
        ##print max of flank up/down for each to the end of reformatted norm_overlap file
        awk 'BEGIN {print "sRNA\tTranscript\tSlice.site\tAllenScore\tflankMax.rpm\tslice.site.rpm\tslice.site.hit.norm"}' > $outDir/${item1}_${sample_name}.${outDir_a}_win_${WIN}_detectedSites.txt
        paste $BG_norm_overlap.${item1} $BG_norm_overlap_up.plus.${item1} $BG_norm_overlap_down.plus.${item1} | awk -v OFS='\t' '{if ($11 > $15) print $4,$1,$2,$5,$11,$7,$6; else print $4,$1,$2,$5,$15,$7,$6}' | sort -k1,1 -n -f -k2,2 >> $outDir/${item1}_${sample_name}.${outDir_a}_win_${WIN}_detectedSites.txt
        echo 'step 4 complete...'
        #remove intermediate files
        rm $BG_norm_overlap.${item1} $BG_norm_overlap_up.${item1} $BG_norm_overlap_down.${item1} $BG_norm_overlap_up.plus.${item1} $BG_norm_overlap_down.plus.${item1}
done

echo 'nanoPARE_EndCut.step1_v02.sh complete!'
