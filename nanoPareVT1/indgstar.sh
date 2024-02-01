#!/bin/bash

#set variables
export dataShuffledDir="/home/ec2-user/meyersData/shuffleDir_orig_jan22"
export originFASTA="/home/ec2-user/nanoPAREUpdate/nanoPARE/EndCut.pipeline/resources/sRNAs/anno.mir.tas.fa"
export GSTAr_prog="/home/ec2-user/nanoPAREUpdate/nanoPARE/EndCut.pipeline/scripts/GSTAr.pl"
#export NAME1=fb1_1to1 -- Mathieu removing these to see if it runs w/o
#export SAMPLE=fb.W

#export WIN=20
#########################################
#export WSEQ_s=mRNA/180228 # Mathieu not sure what this is supposed to represent, might removed or change later
export WSEQ="/home/ec2-user/meyersData" # Mathieu removed slash because config files have end slashes
export TRANSC="/home/ec2-user/nanoPAREUpdate/nanoPARE/resources/transcriptome.fasta"

item="anno.mir.tas.7.shuffled.fa"

mkdir -p $WSEQ/GSTAr/$item
cd $WSEQ/GSTAr/$item

#run GSTAr.pl
perl $GSTAr_prog -t -a $dataShuffledDir/$item $TRANSC > $WSEQ/GSTAr/$item.GSTAr

rm -r $WSEQ/GSTAr/$item

#extract predictions from GSTAr files (select entries with Allen Scores equal to or between 0 and 6, and generate bedfile of transcript isoform name, slice.site, slice.site + 1, sRNA name, Allen Score
awk 'NR > 8' $WSEQ/GSTAr/$item.GSTAr | awk -v OFS='\t' '{if ($9 <= 6.0) print $2,$5-1,$5,$1,$9}' | sort -k1,1 -k2,2n | awk -v OFS='\t' '{split($4,a,"_shuffled"); print $1,$2,$3,a[1],$5}' > $WSEQ/GSTAr/$item.pred.sites.bed
