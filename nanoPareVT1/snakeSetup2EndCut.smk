import os, sys, glob

##---GLOBAL---##

configfile: "config.json"
localrules: all

os.system('rm endCutStep2Done.txt') #Tell Mathieu for debuggingg or rerunning a step when fixing a mistake
threads = int(config["threads"])


##---PIPELINE---#

rule all:
	input:
		os.path.join(config["programDir"], config["mainDir"], "endCutStep2Done.txt"),

rule setup_sh:
	input:
		fastqDir = config["fastqDir"]

	threads: threads

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

	threads: threads

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

	threads: threads

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

	threads: threads

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

	threads: threads

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

rule endCutShuffle_sh:
	input:
		os.path.join(config["programDir"], config["mainDir"], "endMaskDone.txt")

	threads: threads

	params:
		shuffle = os.path.join(config["programDir"], config["nanoDir"], config["5endCutPipelineDir"], config["5.1-shuffle"]),
		sRna = config["sRna"],
		numShuffledSets = config["numShuffledSets"],
		dataShuffleDir = os.path.join(config["dataDir"], config["shuffleDir"])

	output:
		os.path.join(config["programDir"], config["mainDir"], "endCutShuffleDone.txt")


	shell:
		'''
		mkdir -p {params.dataShuffleDir}
		python3 {params.shuffle} {params.sRna} {params.numShuffledSets} {params.dataShuffleDir}
		echo DONE > {output}
		'''

rule endCutGstar_sh:
	input:
		os.path.join(config["programDir"], config["mainDir"], "endCutShuffleDone.txt")

	threads: threads

	params:
		gstar = os.path.join(config["programDir"], config["nanoDir"], config["5endCutPipelineDir"], config["5.2-gstar"]),
		gstar_prog = os.path.join(config["programDir"], config["nanoDir"], config["5endCutPipelineDir"], config["5.2.1-gstarprog"]),
		sRna = config["sRna"],
		numShuffledSets = config["numShuffledSets"],
		dataShuffleDir = os.path.join(config["dataDir"], config["shuffleDir"]),
		transcriptomeFASTA = os.path.join(config["programDir"], config["nanoDir"], config["transcriptomeFASTA"]),
		dataDir = config["dataDir"],

	output:
		os.path.join(config["programDir"], config["mainDir"], "endCutGstarDone.txt")


	shell:
		'''
		bash runEndCutGstarBash.sh {params.sRna} {params.numShuffledSets} {params.gstar} {params.dataShuffleDir} {params.gstar_prog} {params.transcriptomeFASTA} {params.dataDir}
		echo DONE > {output}
		'''

rule endCutNormalize_sh:
	input:
		os.path.join(config["programDir"], config["mainDir"], "endCutGstarDone.txt")

	threads: threads

	params:
		normalize =os.path.join(config["programDir"], config["nanoDir"], config["5endCutPipelineDir"], config["5.3-normalize"]),
		dataDir = config["dataDir"],
		refTable = config["refTable"],
		bedgraphDir =  os.path.join(config["dataDir"], "transcript_bedgraph_capmasked/"),
		resultsEndMask = os.path.join(config["programDir"], config["nanoDir"], config["resultsEndMask"]),
		transcript_bedgraph_capmaskedDir = config["transcript_bedgraph_capmaskedDir"],
		suff = config["suff"]

	output:
		os.path.join(config["programDir"], config["mainDir"], "endCutNormalizeDone.txt")


	shell:
		'''
		mkdir -p {params.bedgraphDir}
		
		bash runEndCutMoveFilesBash.sh {params.resultsEndMask} {params.bedgraphDir}

		bash runEndCutNormalizeBash.sh {params.normalize} {params.refTable} {params.dataDir} {params.transcript_bedgraph_capmaskedDir} {params.suff}
		echo DONE > {output}
		'''

rule endCutStep1WIN1_sh:
	input:
		os.path.join(config["programDir"], config["mainDir"], "endCutNormalizeDone.txt")

	threads: threads

	params:
		step1 = os.path.join(config["programDir"], config["nanoDir"], config["5endCutPipelineDir"], config["5.4-step1"]),
		step2 = os.path.join(config["programDir"], config["nanoDir"], config["5endCutPipelineDir"], config["5.5-step2"]),
		refTable = config["refTable"],
		WIN = config["nucleotideWIN1"],
		dataDir = config["dataDir"],
		transcript_bedgraph_capmaskedDir = config["transcript_bedgraph_capmaskedDir"],
		suff = config["suff"]

	output:
		os.path.join(config["programDir"], config["mainDir"], "endCutStep1WIN1Done.txt")


	shell:
		'''
		bash runEndCutStep1Bash.sh {params.step1} {params.refTable} {params.dataDir} {params.WIN} {params.transcript_bedgraph_capmaskedDir} {params.suff}
		echo DONE > {output}
		'''

rule endCutStep1WIN2_sh:
	input:
		os.path.join(config["programDir"], config["mainDir"], "endCutStep1WIN1Done.txt")

	threads: threads

	params:
		step1 = os.path.join(config["programDir"], config["nanoDir"], config["5endCutPipelineDir"], config["5.4-step1"]),
		step2 = os.path.join(config["programDir"], config["nanoDir"], config["5endCutPipelineDir"], config["5.5-step2"]),
		refTable = config["refTable"],
		WIN = config["nucleotideWIN2"],
		dataDir = config["dataDir"],
		transcript_bedgraph_capmaskedDir = config["transcript_bedgraph_capmaskedDir"],
		suff = config["suff"]

	output:
		os.path.join(config["programDir"], config["mainDir"], "endCutStep1WIN2Done.txt")


	shell:
		'''
		bash runEndCutStep1Bash.sh {params.step1} {params.refTable} {params.dataDir} {params.WIN} {params.transcript_bedgraph_capmaskedDir} {params.suff}
		echo DONE > {output}
		'''

rule endCutStep2_sh:
	input:
		os.path.join(config["programDir"], config["mainDir"], "endCutStep1WIN2Done.txt")

	threads: threads

	params:
		step2 = os.path.join(config["programDir"], config["nanoDir"], config["5endCutPipelineDir"], config["5.5-step2"]),
		refTable = config["refTable"],
		dataDir = config["dataDir"],
		transcript_bedgraph_capmaskedDir = config["transcript_bedgraph_capmaskedDir"],
		suff = config["suff"],
		numShuffledSets = config["numShuffledSets"],
		endCutResourceDir = os.path.join(config["programDir"], config["nanoDir"], config["5endCutResourceDir"])

	output:
		os.path.join(config["programDir"], config["mainDir"], "endCutStep2Done.txt")


	shell:
		'''
		bash runEndCutStep2Bash.sh {params.step2} {params.refTable} {params.dataDir} {params.transcript_bedgraph_capmaskedDir} {params.suff} {params.numShuffledSets} {params.endCutResourceDir}
		echo DONE > {output}
		'''
