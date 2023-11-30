import os, re, sys
import pandas as pd

dir_lst = []

def main():
    fastqDir, tablename, seq_run, adapter_seq = getArgs()
    scanFolder(fastqDir, tablename, seq_run, adapter_seq)

def getArgs():
    fastqDir = sys.argv[1]
    tablename = sys.argv[2]
    seq_run = sys.argv[3]
    adapter_seq = sys.argv[4]
    return (fastqDir, tablename, seq_run, adapter_seq)

def scanFolder(fastqDir, tablename, seq_run, adapter_seq):
	fastqPath = os.path.join(fastqDir)
	for root in os.walk(fastqPath):
		for sample in root[2]:
			if re.search(r'\.fq.gz',sample):
				REF = {
					'path' : root[0],
					'filename' : sample,
					'sample_name': (sample.split('.')[0] + sample.split('.')[1]), 
					'sample_type': sample.split('.')[0], 
					'lib_type': sample.split('.')[2], 
					'seq_run': seq_run,
					'adapter_seq' : adapter_seq
					}
				dir_lst.append(REF)
	refTable = pd.DataFrame(dir_lst)
	refTable.index += 1
	refTable.to_csv(tablename, sep="\t", header=False)
	return


main()
