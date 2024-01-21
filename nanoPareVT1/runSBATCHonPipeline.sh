#!/bin/bash

source ~/.bashrc
mamba activate nanopare6

snakemake --snakefile snakeSetup2EndCutUpdate_sparta1.smk --cores 2
