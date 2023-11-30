#!/bin/bash

sampleNames=($(cat $1 | awk '{ print $4 }' | sort | uniq))

for name in ${sampleNames[@]}
	do
		bash $2 -N ${name} -R $1 -G $3 -A $4 --cpus $5 --rpm $6 --kernel $7 --bandwidth $8 --fraglen $9
	done
