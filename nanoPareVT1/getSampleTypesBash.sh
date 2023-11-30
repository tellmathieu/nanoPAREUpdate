#!/bin/bash

sampleTypes=($(cat $1 | awk '{ print $5 }' | sort | uniq))

for type in ${sampleTypes[@]}
	do
		bash $2 -T ${type} -R $1 -G $3 -A $4 --cpus $5 --uug $6 --upstream $7
	done
