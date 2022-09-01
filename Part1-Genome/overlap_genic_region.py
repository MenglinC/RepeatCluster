'''
select the overlap regions between two files
2022-06-25
try to add the file vector
'''
import argparse
parser = argparse.ArgumentParser()
parser.add_argument("-a", "--inputA", help="this is parameter a",dest="file1",type=str,default="protein_transcript_2k.bed")
parser.add_argument("-b", "--inputB", help="this is parameter b",dest="file2",type=str,default="repeat_interest.bed")
input = parser.parse_args()

f1 = open(input.file1)
lines = f1.readlines()
f2 = open(input.file2)
parags = f2.readlines()
for line in lines:
	args = line.split()
	chr_insert = args[0]
	start_insert = int(args[1]) 
	end_insert = int(args[2])
	ID_insert = args[3]
	name_insert = args[4]
	tag_insert=args[5]
	for parag in parags:
		parameter = parag.split()
		chr_gtf = parameter[0]
		start_gtf = int(parameter[1])
		end_gtf = int(parameter[2])
		#len_gtf=end_gtf-start_gtf
		#n = len_gtf/2
		sclass=parameter[3]
		subfamily=parameter[4]
		family=parameter[5]
		if chr_insert == chr_gtf:
			if(start_insert<start_gtf and end_insert>end_gtf):
				print(chr_insert,start_insert,end_insert,ID_insert,name_insert,tag_insert,start_gtf,end_gtf,sclass,subfamily,family)