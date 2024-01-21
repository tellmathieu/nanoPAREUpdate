# nanoPAREUpdate

This is an update to the nanaPARE pipeline from: 
https://www.ncbi.nlm.nih.gov/pmc/articles/PMC6280765/

The goal is to make it significantly faster and easier to run by using snakemake as a scaffolding and replacing the GSTAr program with SPARTa (https://www.ncbi.nlm.nih.gov/pmc/articles/PMC4191380/#B21).

I ran my tests with a low cost slurm setup that I setup on AWS (Amazon Web Services), and the process I used to do that is at https://github.com/tellmathieu/individual-slurm. I imagine most people would use a pre-established cluster. Also, the updated version is easy enough to run on a computer with at least 1GB of RAM.

To get started, you need a reference genome and fastqs.

## Installing and Running nanoPAREUpdate

To get started, I downloaded this github repository, and the sPARTA repository into my newly create folder.


```
# copies the latest code from this git repo
git clone https://github.com/tellmathieu/nanoPAREUpdate.git

# changes into that directory
cd nanoPAREUpdate

# copies the sPARTA code into the folder. You don't have to put it in this folder. I just did it, because my config file has it in this location. You could customize this though if you know how to alter the snakemake file and the `config.json` file.
git clone https://github.com/atulkakrana/sPARTA.git
```

Next, I installed mamba () on the computer to make an environment that has all the programs this pipeline needs. I did this instead of assuming that the user was running this on a HPC (high performance computing) cluster with modules pre-loaded. Mamba is basically a package installer that makes the process so much easier, because it figures out dependencies for you. If you have trouble with this step, you can refer to the mamba github page: https://github.com/conda-forge/miniforge.

```
# this downloads the bash software script
wget "https://github.com/conda-forge/miniforge/releases/latest/download/Miniforge3-$(uname)-$(uname -m).sh"

# this is the command that runs what you just downloaded to install the program. You will have to interact with this to get it installed (like agreeing to terms of service)
bash Miniforge3-$(uname)-$(uname -m).sh

# this initializes the mamba program that you just installed so you can call it on the command line
source ~/.bashrc
```

Next is to create the environment using mamba.

```
# running this takes about 15 minutes. If you have issues with this, I'd recommend troubleshooting with mamba documentation or just typing into google what error message you're getting.
mamba env create -f nanoPAREUpdate/yaml/nanopare6.yaml

# loads the environment you just created
mamba activate nanopare6
```

When you have the environment setup, you're going to want to alter the config_sparta_aws.json file. To point to the appropriate places in your file structure. Some of the locations I put in are full path lengths that you will need to change, but if the file path doesn't start with `/home/` then you don't need to set it. This repo comes with reference and annotation gff files from *Arabidopsis thaliana*, so these start off being pointed internally, but you can use your own files depending on the fastqs you're using.

The following are the categories you absolutely have to change. Everything else is settings or internal filepaths (only exception is if you didn't put sPARTA in your `nanoPareUpdate` folder).

```
# fasta file of the organism of your choice
"fastaRef" : "/home/ec2-user/nanoPAREUpdate/nanoPARE/resources/genome.fasta",

# annotation file for the organism of your choice. The default is a gff file type, but if you change it to a .gtf file format, you will also need to change the field "annotationType".
"annotation" : "/home/ec2-user/nanoPAREUpdate/nanoPARE/resources/annotation.gff",

# this refTable is created automatically using this program, but your fastqs need to be in the right format. Refer to the original nanoPARE pipeline if you want to manually create your file.
# You can also alter the python program that I have do this in the pipeline: nanoPAREUpdate/nanoPareVT1/python/createRefTable.py
# the format this program reads is <sample-type>.<sample-number>.<lib-type>.fq.gz
# so my files were name testsparta1.3.BODY.fq.gz and testsparta1.3.5P.fq.gz
# you need to set the the <lib-type> to either 'BODY' or '5P'
# this python script assumes that the samples are made with single ends (SE) and nextera sequencing.
"refTable" : "/home/ec2-user/meyersData/reference_sparta1.table",

# folder where your fastqs are
"fastqDir" : "/home/ec2-user/meyersData/FASTQsparta1",

# location and name of the runtime log
"runtime_log" : "/home/ec2-user/meyersData/runtimesparta_1.log",

# list of miRNAs that you are looking at. This was supplied to me.
"sRna" : "/home/ec2-user/nanoPAREUpdate/nanoPARE/EndCut.pipeline/resources/sRNAs/anno.mir.tas.fa",

# where you downloaded the git repo
"programDir" : "/home/ec2-user/nanoPAREUpdate",

# where you want data output to be put, though some of it is put into the file structure, just the stuff you are likely to look at
"dataDir" : "/home/ec2-user/meyersData",
```








