'''
select the overlap regions between two files
2022-06-16
'''
f1 = open("insertion_filter.bed")
lines = f1.readlines()
f2 = open("hg38_stat_SINE_LINE_LTR_SVA.txt")
parags = f2.readlines()
for line in lines:
	args = line.split()
	chr_insert = args[0]
	start_insert = int(args[1]) 
	end_insert = int(args[2])
	flag=1
	for parag in parags:
		parameter = parag.split()
		chr_gtf = parameter[0]
		start_gtf = int(parameter[1])
		end_gtf = int(parameter[2])
		len_gtf=end_gtf-start_gtf
		n = len_gtf/2
		sclass=parameter[4]
		subfamily=parameter[6]
		family=parameter[7]
		if chr_insert == chr_gtf:
			if ((start_insert<start_gtf and end_insert>(start_gtf+n))or(start_insert>=start_gtf and start_insert<(end_gtf-n))):
				print(chr_insert,start_insert,end_insert,start_gtf,end_gtf,sclass,subfamily,family)