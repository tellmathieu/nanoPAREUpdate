dataShuffleDir=$1
mainDir=$2

cd $dataShuffleDir

rename 's/0/zero_/' *.shuffled.fa
rename 's/1/one_/' *.shuffled.fa
rename 's/2/two_/' *.shuffled.fa
rename 's/3/three_/' *.shuffled.fa
rename 's/4/four_/' *.shuffled.fa
rename 's/5/five_/' *.shuffled.fa
rename 's/6/six_/' *.shuffled.fa
rename 's/7/seven_/' *.shuffled.fa
rename 's/8/eight_/' *.shuffled.fa
rename 's/9/nine_/' *.shuffled.fa

cd $mainDir
