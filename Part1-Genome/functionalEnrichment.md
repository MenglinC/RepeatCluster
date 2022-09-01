> 这一块主要是看不同的家族有什么样的功能。
>
> 今天师兄讲了一篇文章，其中一些点觉得还是蛮有意思的。就是一些人特异性的细胞类型会富集到一些特定的通路中，而这些通路，我之前模模糊糊有遇到过。
>
> 所以现在想，如果可以更精细的注释，再看看细胞类型，能不能得到一些有意思的结果。

### 1、提取重复序列位于蛋白编码基因的body范围内（±2kb）的基因。

```python
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
```

### 2、功能通路的富集

根据前面的方法的话，就可以得到Alu、SVA或其他的一些family所在gene body区域的基因。
然后我们就按照家族，对这些gene list进行富集。
目前主要采用了两种方法。

#### （1）方法一:clusterProfiler-富集分析

==> GO_stack_enrichment.R

#### （2）方法二：Cytoscape BiNGO-网络图的富集分析

==> 图形化界面完成即可。

### 3、配受体相互作用分析


















