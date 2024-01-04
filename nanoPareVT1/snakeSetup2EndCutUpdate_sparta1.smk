import os, sys, glob

##---GLOBAL---##

configfile: "config_sparta.json"
localrules: all

#os.system('rm endCutStep2Done.txt') #Tell Mathieu for debuggingg or rerunning a step when fixing a mistake
threads = int(config["threads"])


##---PIPELINE---#

rule all:
	input:
		os.path.join(config["programDir"], config["mainDir"], "endCutStep2SpartaDone.txt"),


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
		gtf_transcript_tag = config["gtf_transcript_tag"],
		runtime_log = config["runtime_log"]

	output:
		os.path.join(config["programDir"], config["mainDir"], "setupSpartaDone.txt")

	shell:
		'''
			st=`date +%s`
			python3 {params.createRefTable} {input.fastqDir} {params.refTable} {params.seq_run} {params.adapter_seq}
			bash {params.setup} -R {params.refTable} -G {params.genomeFasta} -A {params.genomeAnnotation} --ram {params.ram} --cpus {params.cpu} --gtf_gene_tag {params.gtf_gene_tag} --gtf_transcript_tag {params.gtf_transcript_tag}
			echo DONE > {output}
			et=`date +%s`
			rt=$((et-st))
			echo "//////////SETUP_DONE ($rt s)" > {params.runtime_log}
		'''


rule endMap_sh:
	input:
		os.path.join(config["programDir"], config["mainDir"], "setupSpartaDone.txt")


	threads: threads

	params:
		endMap = os.path.join(config["programDir"], config["nanoDir"], config["1endMapBashScript"]),
		genomeFasta = config["fastaRef"],
		genomeAnnotation = config["annotation"],
		refTable = config["refTable"],
		ram = config["ram"],
		cpu = config["cpu"],
		icomp = config["icomp"],
		runtime_log = config["runtime_log"]

	output:
		os.path.join(config["programDir"], config["mainDir"], "endMapSpartaDone.txt")

	shell:
		'''
			st=`date +%s`
			total_lines=$(cat {params.refTable} | wc -l)
			line=1
			while [ $line -le $total_lines ]
			do 
				bash {params.endMap} -L $line -R {params.refTable} -G {params.genomeFasta} -A {params.genomeAnnotation} --ram {params.ram} --cpus {params.cpu} --icomp {params.icomp}
				let line++
			done
			et=`date +%s`
			rt=$((et-st))
			echo "//////////ENDMAP_DONE ($rt s)" >> {params.runtime_log}
			echo DONE > {output}
		'''


rule endGraph_sh:
	input:
		os.path.join(config["programDir"], config["mainDir"], "endMapSpartaDone.txt")

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
		fraglen = config["fraglen"],
		runtime_log = config["runtime_log"]

	output:
		os.path.join(config["programDir"], config["mainDir"], "endGraphSpartaDone.txt")


	shell:
		'''
		st=`date +%s`
		bash endGraphBash.sh {params.refTable} {params.endGraph} {params.genomeFasta} {params.genomeAnnotation} {params.ram} {params.cpu} {params.kernel} {params.bandwidth} {params.fraglen}
		et=`date +%s`
		rt=$((et-st))
		echo "//////////ENDGRAPH_DONE ($rt s)" >> {params.runtime_log}
		echo DONE > {output}
		'''

rule endClass_sh:
	input:
		os.path.join(config["programDir"], config["mainDir"], "endGraphSpartaDone.txt")

	threads: threads

	params:
		endClass = os.path.join(config["programDir"], config["nanoDir"], config["3endClassBashScript"]),
		genomeFasta = config["fastaRef"],
		genomeAnnotation = config["annotation"],
		refTable = config["refTable"],
		cpu = config["cpu"],
		uug = config["uug"],
		upstream = config["upstream"],
		runtime_log = config["runtime_log"]

	output:
		os.path.join(config["programDir"], config["mainDir"], "endClassSpartaDone.txt")


	shell:
		'''
		st=`date +%s`
		bash getSampleTypesBash.sh {params.refTable} {params.endClass} {params.genomeFasta} {params.genomeAnnotation} {params.cpu} {params.uug} {params.upstream}
		et=`date +%s`
		rt=$((et-st))
		echo "//////////ENDCLASS_DONE ($rt s)" >> {params.runtime_log}
		echo DONE > {output}
		'''

rule endMask_sh:
	input:
		os.path.join(config["programDir"], config["mainDir"], "endClassSpartaDone.txt")

	threads: threads

	params:
		endMask = os.path.join(config["programDir"], config["nanoDir"], config["4endMaskBashScript"]),
		genomeFasta = config["fastaRef"],
		genomeAnnotation = config["annotation"],
		refTable = config["refTable"],
		cpu = config["cpu"],
		runtime_log = config["runtime_log"]

	output:
		os.path.join(config["programDir"], config["mainDir"], "endMaskSpartaDone.txt")


	shell:
		'''
		st=`date +%s`
		bash endMaskBash.sh {params.refTable} {params.endMask} {params.genomeFasta} {params.genomeAnnotation} {params.cpu}
		et=`date +%s`
		rt=$((et-st))
		echo "//////////ENDMASK_DONE ($rt s)" >> {params.runtime_log}
		echo DONE > {output}
		'''

checkpoint endCutShuffle_sh:
	input:
		os.path.join(config["programDir"], config["mainDir"], "setupSpartaDone.txt")

	threads: threads

	params:
		shuffle = os.path.join(config["programDir"], config["nanoDir"], config["5endCutPipelineDir"], config["5.1-shuffle"]),
		sRna = config["sRna"],
		numShuffledSets = config["numShuffledSets"],
		dataShuffleDir = os.path.join(config["dataDir"], config["shuffleDir"]),
		mainDir = os.path.join(config["programDir"], config["mainDir"]),
		runtime_log = config["runtime_log"],
		doneFile = os.path.join(config["programDir"], config["mainDir"], "endCutShuffleSpartaDone.txt")

	output:
		directory(os.path.join(config["dataDir"], config["shuffleDir"])),
		doneFile = os.path.join(config["programDir"], config["mainDir"], "endCutShuffleSpartaDone.txt")


	shell:
		'''
		export st=`date +%s`
		mkdir -p {params.dataShuffleDir}
		python3 {params.shuffle} {params.sRna} {params.numShuffledSets} {output}
		
		#removing integers from file names
		bash removeIntegers.sh {params.dataShuffleDir} {params.mainDir}

		export et=`date +%s`
		export rt=$et-$st
		echo "//////////ENDCUT_SHUFFLE_DONE ($rt s)" >> {params.runtime_log}
		echo DONE > {params.doneFile}
		'''

rule Sparta_starttime:
	input:
		previousDone = os.path.join(config["programDir"], config["mainDir"], "endCutShuffleSpartaDone.txt"),
		endMaskDone = os.path.join(config["programDir"], config["mainDir"], "endMaskSpartaDone.txt")

	params:
		runtime_log = config["runtime_log"]

	output:
		os.path.join(config["programDir"], config["mainDir"], "endCutSpartaStartTimeDone.txt")

	shell:
		'''
		export st=`date +%s`
		echo "//////////ENDCUT_SPARTA_START_TIME_DONE ($st s)" >> {params.runtime_log}
		echo DONE > {output}
		'''

rule endCutSparta_sh:
	input:
		previousDone = os.path.join(config["programDir"], config["mainDir"], "endCutShuffleSpartaDone.txt"),
		startTime = os.path.join(config["programDir"], config["mainDir"], "endCutSpartaStartTimeDone.txt"),
		endMaskDone = os.path.join(config["programDir"], config["mainDir"], "endMaskSpartaDone.txt"),
		miRfa = os.path.join(config["dataDir"], config["shuffleDir"], '{miRShuffled}.fa')

	threads: threads

	params:
		genomeFasta = config["fastaRef"],
		genomeAnnotation = config["annotation"],
		annoType = config["annotationType"],
		genomeFeature = config["genomeFeature"],
		sparta_prog = os.path.join(config["programDir"], config["sPARTADir"], config["5.2-spartaprog"]),
		sRna = config["sRna"],
		numShuffledSets = config["numShuffledSets"],
		dataShuffleDir = os.path.join(config["dataDir"], config["shuffleDir"]),
		transcriptomeFASTA = os.path.join(config["programDir"], config["nanoDir"], config["transcriptomeFASTA"]),
		bedgraphDir =  os.path.join(config["dataDir"], config["transcript_bedgraph_capmaskedDir"]),
		dataDir = config["dataDir"],
		runtime_log = config["runtime_log"],
		spartaDir = os.path.join(config["dataDir"], config["sPARTADir"])

	output:
		os.path.join(config["dataDir"], config["transcript_bedgraph_capmaskedDir"], '{miRShuffled}.pred.sites.bed')

	shell:
		'''
		#execution of miRferno from the sPARTA program
		python3 {params.sparta_prog} -genomeFile {params.genomeFasta} -annoType {params.annoType} -annoFile {params.genomeAnnotation} -genomeFeature {params.genomeFeature} -miRNAFile {input.miRfa} -tarPred H -tarScore S --map2DD

		awk 'NR > 1' predicted/All.targs.parsed.csv | awk -F "," '{{print $2,$3,$1,$6}}' | awk -F " " '{{split($2,a,"-"); print $1,a[1],a[2],$3,$4}}' | sort -k1,1 -k2,2n | awk -F ' ' -v OFS="\t" '{{split($4,a,"_shuffled"); print $1,$2,$3,a[1],$5}}' > {params.bedgraphDir}/{wildcards.miRShuffled}.pred.sites.bed

		'''

def aggregate_input(wildcards):
    '''
    aggregate the file names of the random number of files
    generated at the scatter step
    '''
    checkpoint_output = checkpoints.endCutShuffle_sh.get(**wildcards).output[0]
    mirShuffled, = glob_wildcards(os.path.join(checkpoint_output, '{miRS}.fa'))
    return expand(os.path.join(config["dataDir"], config["transcript_bedgraph_capmaskedDir"], '{miRShuffled}.pred.sites.bed'), miRShuffled = mirShuffled)


rule Sparta_collapse:
	input:
		aggregate_input,
		os.path.join(config["programDir"], config["mainDir"], "endCutSpartaStartTimeDone.txt")
		
	output:
		os.path.join(config["programDir"], config["mainDir"], "endCutSpartaCollapseDone.txt"),

	shell:
		'''
		echo DONE > {output}
		'''

rule Sparta_endtime:
	input:
		os.path.join(config["programDir"], config["mainDir"], "endCutSpartaCollapseDone.txt")

	params:
		runtime_log = config["runtime_log"]
		
	output:
		os.path.join(config["programDir"], config["mainDir"], "endCutSpartaDone.txt")

	shell:
		'''
		export et=`date +%s`
		echo "//////////ENDCUT_SPARTA_END_TIME_DONE ($et s)" >> {params.runtime_log}
		echo 'nanoPARE_sPARTA complete!'
		echo DONE > {output}
		'''

rule endCutNormalize_sh:
	input:
		os.path.join(config["programDir"], config["mainDir"], "endCutSpartaDone.txt"),
		os.path.join(config["programDir"], config["mainDir"], "endMaskSpartaDone.txt")

	threads: threads

	params:
		normalize =os.path.join(config["programDir"], config["nanoDir"], config["5endCutPipelineDir"], config["5.3-normalize"]),
		dataDir = config["dataDir"],
		refTable = config["refTable"],
		bedgraphDir =  os.path.join(config["dataDir"], config["transcript_bedgraph_capmaskedDir"]),
		resultsEndMask = os.path.join(config["programDir"], config["nanoDir"], config["resultsEndMask"]),
		transcript_bedgraph_capmaskedDir = config["transcript_bedgraph_capmaskedDir"],
		suff = config["suff"],
		runtime_log = config["runtime_log"]

	output:
		os.path.join(config["programDir"], config["mainDir"], "endCutNormSpartaDone.txt")

	shell:
		'''
		st=`date +%s`
		
		bash runEndCutNormalizeBash.sh {params.normalize} {params.refTable} {params.dataDir} {params.transcript_bedgraph_capmaskedDir} {params.suff}
		et=`date +%s`
		rt=$((et-st))
		echo "//////////ENDCUT_NORMALIZE_DONE ($rt s)" >> {params.runtime_log}
		echo DONE > {output}
		'''

rule endCutStep1WIN1_sh:
	input:
		os.path.join(config["programDir"], config["mainDir"], "endCutNormSpartaDone.txt")

	threads: threads

	params:
		step1 = os.path.join(config["programDir"], config["nanoDir"], config["5endCutPipelineDir"], config["5.4-step1"]),
		step2 = os.path.join(config["programDir"], config["nanoDir"], config["5endCutPipelineDir"], config["5.5-step2"]),
		refTable = config["refTable"],
		WIN = config["nucleotideWIN1"],
		dataDir = config["dataDir"],
		transcript_bedgraph_capmaskedDir = config["transcript_bedgraph_capmaskedDir"],
		suff = config["suff"],
		runtime_log = config["runtime_log"],
		dataShuffleDir = os.path.join(config["dataDir"], config["shuffleDir"]),
		spartaDir = os.path.join(config["dataDir"], config["sPARTADir"])

	output:
		os.path.join(config["programDir"], config["mainDir"], "endCutStep1WIN1SpartaDone.txt")


	shell:
		'''
		st=`date +%s`
		bash runEndCutStep1Bash.sh {params.step1} {params.refTable} {params.dataDir} {params.WIN} {params.transcript_bedgraph_capmaskedDir} {params.suff} {params.spartaDir} {params.dataShuffleDir}
		et=`date +%s`
		rt=$((et-st))
		echo "//////////ENDCUT_STEP1_WIN1_DONE ($rt s)" >> {params.runtime_log}
		echo DONE > {output}
		'''

rule endCutStep1WIN2_sh:
	input:
		os.path.join(config["programDir"], config["mainDir"], "endCutStep1WIN1SpartaDone.txt")

	threads: threads

	params:
		step1 = os.path.join(config["programDir"], config["nanoDir"], config["5endCutPipelineDir"], config["5.4-step1"]),
		step2 = os.path.join(config["programDir"], config["nanoDir"], config["5endCutPipelineDir"], config["5.5-step2"]),
		refTable = config["refTable"],
		WIN = config["nucleotideWIN2"],
		dataDir = config["dataDir"],
		transcript_bedgraph_capmaskedDir = config["transcript_bedgraph_capmaskedDir"],
		suff = config["suff"],
		runtime_log = config["runtime_log"],
		dataShuffleDir = os.path.join(config["dataDir"], config["shuffleDir"]),
		spartaDir = os.path.join(config["dataDir"], config["sPARTADir"])

	output:
		os.path.join(config["programDir"], config["mainDir"], "endCutStep1WIN2SpartaDone.txt")


	shell:
		'''
		st=`date +%s`
		bash runEndCutStep1Bash.sh {params.step1} {params.refTable} {params.dataDir} {params.WIN} {params.transcript_bedgraph_capmaskedDir} {params.suff} {params.spartaDir} {params.dataShuffleDir}
		et=`date +%s`
		rt=$((et-st))
		echo "//////////ENDCUT_STEP1_WIN2_DONE ($rt s)" >> {params.runtime_log}
		echo DONE > {output}
		'''

rule endCutStep2_sh:
	input:
		os.path.join(config["programDir"], config["mainDir"], "endCutStep1WIN2SpartaDone.txt")

	threads: threads

	params:
		step2 = os.path.join(config["programDir"], config["nanoDir"], config["5endCutPipelineDir"], config["5.5-step2"]),
		refTable = config["refTable"],
		dataDir = config["dataDir"],
		transcript_bedgraph_capmaskedDir = config["transcript_bedgraph_capmaskedDir"],
		suff = config["suff"],
		numShuffledSets = config["numShuffledSets"],
		endCutResourceDir = os.path.join(config["programDir"], config["nanoDir"], config["5endCutResourceDir"]),
		runtime_log = config["runtime_log"]

	output:
		os.path.join(config["programDir"], config["mainDir"], "endCutStep2SpartaDone.txt")

	shell:
		'''
		st=`date +%s`
		bash runEndCutStep2Bash.sh {params.step2} {params.refTable} {params.dataDir} {params.transcript_bedgraph_capmaskedDir} {params.suff} {params.numShuffledSets} {params.endCutResourceDir}
		et=`date +%s`
		rt=$((et-st))
		echo "//////////ENDCUT_STEP2_DONE ($rt s)" >> {params.runtime_log}
		echo DONE > {output}
		'''
