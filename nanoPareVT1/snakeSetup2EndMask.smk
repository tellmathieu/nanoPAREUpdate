import os, sys, glob

##---GLOBAL---##

configfile: "config.json"
localrules: all

os.system('rm endCutDone.txt') #Tell Mathieu for debuggingg or rerunning a step when fixing a mistake
cpu = int(config["cpu"])


##---PIPELINE---#

rule all:
	input:
		os.path.join(config["programDir"], config["mainDir"], "endCutDone.txt"),

rule setup_sh:
	input:
		fastqDir = config["fastqDir"]

	threads: cpu

	params:
		setup = os.path.join(config["programDir"], config["nanoDir"], config["setupBashScript"]),
		genomeFasta = config["fastaRef"],
		genomeAnnotation = config["annotation"],
		refTable = config["refTable"],
		seq_run = config["seq_run_SE_or_PE"],
		adapter_seq = config["adapter_seq"],
		createRefTable = os.path.join(config["programDir"], config["mainDir"], config["createRefTable"]),
		ram = config["ram"],
		cpu = config["cpu"],
		gtf_gene_tag = config["gtf_gene_tag"],
		gtf_transcript_tag = config["gtf_transcript_tag"]

	output:
		os.path.join(config["programDir"], config["mainDir"], "setupDone.txt")

	shell:
		'''
			python3 {params.createRefTable} {input.fastqDir} {params.refTable} {params.seq_run} {params.adapter_seq}
			bash {params.setup} -R {params.refTable} -G {params.genomeFasta} -A {params.genomeAnnotation} --ram {params.ram} --cpus {params.cpu} --gtf_gene_tag {params.gtf_gene_tag} --gtf_transcript_tag {params.gtf_transcript_tag}
			echo DONE > {output}
		'''


rule endMap_sh:
	input:
		os.path.join(config["programDir"], config["mainDir"], "setupDone.txt")

	threads: cpu

	params:
		endMap = os.path.join(config["programDir"], config["nanoDir"], config["1endMapBashScript"]),
		genomeFasta = config["fastaRef"],
		genomeAnnotation = config["annotation"],
		refTable = config["refTable"],
		ram = config["ram"],
		cpu = config["cpu"],
		icomp = config["icomp"]

	output:
		os.path.join(config["programDir"], config["mainDir"], "endMapDone.txt")

	shell:
		'''
			total_lines=$(cat {params.refTable} | wc -l)
			line=1
			while [ $line -le $total_lines ]
			do 
				bash {params.endMap} -L $line -R {params.refTable} -G {params.genomeFasta} -A {params.genomeAnnotation} --ram {params.ram} --cpus {params.cpu} --icomp {params.icomp}
				let line++
			done
			echo DONE > {output}
		'''


rule endGraph_sh:
	input:
		os.path.join(config["programDir"], config["mainDir"], "endMapDone.txt")

	threads: cpu

	params:
		endGraph = os.path.join(config["programDir"], config["nanoDir"], config["2endGraphBashScript"]),
		genomeFasta = config["fastaRef"],
		genomeAnnotation = config["annotation"],
		refTable = config["refTable"],
		ram = config["ram"],
		cpu = config["cpu"],
		kernel = config["kernel"],
		bandwidth = config["bandwidth"],
		fraglen = config["fraglen"]

	output:
		os.path.join(config["programDir"], config["mainDir"], "endGraphDone.txt")


	shell:
		'''
		bash endGraphBash.sh {params.refTable} {params.endGraph} {params.genomeFasta} {params.genomeAnnotation} {params.ram} {params.cpu} {params.kernel} {params.bandwidth} {params.fraglen}
		echo DONE > {output}
		'''

rule endClass_sh:
	input:
		os.path.join(config["programDir"], config["mainDir"], "endGraphDone.txt")

	threads: cpu

	params:
		endClass = os.path.join(config["programDir"], config["nanoDir"], config["3endClassBashScript"]),
		genomeFasta = config["fastaRef"],
		genomeAnnotation = config["annotation"],
		refTable = config["refTable"],
		cpu = config["cpu"],
		uug = config["uug"],
		upstream = config["upstream"]

	output:
		os.path.join(config["programDir"], config["mainDir"], "endClassDone.txt")


	shell:
		'''
		bash getSampleTypesBash.sh {params.refTable} {params.endClass} {params.genomeFasta} {params.genomeAnnotation} {params.cpu} {params.uug} {params.upstream}
		echo DONE > {output}
		'''

rule endMask_sh:
	input:
		os.path.join(config["programDir"], config["mainDir"], "endClassDone.txt")

	threads: cpu

	params:
		endMask = os.path.join(config["programDir"], config["nanoDir"], config["4endMaskBashScript"]),
		genomeFasta = config["fastaRef"],
		genomeAnnotation = config["annotation"],
		refTable = config["refTable"],
		cpu = config["cpu"]

	output:
		os.path.join(config["programDir"], config["mainDir"], "endMaskDone.txt")


	shell:
		'''
		bash endMaskBash.sh {params.refTable} {params.endMask} {params.genomeFasta} {params.genomeAnnotation} {params.cpu}
		echo DONE > {output}
		'''

rule endCut_sh:
	input:
		os.path.join(config["programDir"], config["mainDir"], "endMaskDone.txt")

	threads: cpu

	params:
		shuffle = os.path.join(config["programDir"], config["nanoDir"], config["5endCutPipelineDir"], config["5.1-shuffle"]),
		gstar = os.path.join(config["programDir"], config["nanoDir"], config["5endCutPipelineDir"], config["5.2-gstar"]),
		normalize =os.path.join(config["programDir"], config["nanoDir"], config["5endCutPipelineDir"], config["5.3-normalize"]),
		step1 = os.path.join(config["programDir"], config["nanoDir"], config["5endCutPipelineDir"], config["5.4-step1"]),
		step2 = os.path.join(config["programDir"], config["nanoDir"], config["5endCutPipelineDir"], config["5.5-step2"]),
		genomeFasta = config["fastaRef"],
		genomeAnnotation = config["annotation"],
		refTable = config["refTable"],
		cpu = config["cpu"],
		sRna = config["sRna"],
		numShuffledSets = config["numShuffledSets"]
		dataDir = config["dataDir"]

	output:
		os.path.join(config["programDir"], config["mainDir"], "endCutDone.txt")


	shell:
		'''
		bash runEndCutBash.sh {params.shuffle} {params.sRna} {params.numShuffledSets} {params.gtar} {params.dataDir}
		echo DONE > {output}
		'''


