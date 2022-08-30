> 这里就介绍一下，下载到cistrome数据之后，如何完整的把数据运行下来得到我们想要的结果的整个的流程。

### （一）cistrome数据库原始数据下载链接

获取方式：通过邮件向cistrome申请数据下载。

> 数据下载链接：
>
>Human CHROMATIN accessibility, 3.0G: http://cistrome.org/db/batchdata/R56Q7GGRZEY7L4PH4RA9.tar.gz
>
>Human HISTONE MARK AND VARIANT, 7.2G: http://cistrome.org/db/batchdata/GTYPP2KEMBOVQL3DDGS2.tar.gz
>
>Human FACTOR, 4.6G: http://cistrome.org/db/batchdata/24KRO157XZ5Y204IEVFN.tar.gz

### （二）数据预处理

#### （1）解压缩
```shell
mkdir backup
cd backup/
# wget http://cistrome.org/db/batchdata/GTYPP2KEMBOVQL3DDGS2.tar.gz
mv ../human_histone_mark/GTYPP2KEMBOVQL3DDGS2.tar ./
tar -xf GTYPP2KEMBOVQL3DDGS2.tar
#得到两个文件，一个文件为human_hm_full_QC.txt，另一个文件为human_hm.tar.gz。
#human_hm.tar.gz文件主要是存放若干hm的数据的。
#human_hm_full_QC.txt文件则是记录这些chip-seq文件的质量。
```
>DCid    Species GSMID   Factor  Cell_line       Cell_type       Tissue_type     FastQC  UniquelyMappedRatio     PBC     PeaksFoldChangeAbove10  FRiP    PeaksUnionDHSRatio
>268     Homo sapiens    GSM648494       H3K4me1 aTconv  T Lymphocyte    Blood   29.0    0.1307  0.971   1907.0  0.22995929190699999     0.6944
>269     Homo sapiens    GSM648495       H3K4me3 aTconv  T Lymphocyte    Blood   28.0    0.134   0.932   7935.0  0.669119075747  0.9740000000000001
>272     Homo sapiens    GSM575295       H3K27me3        BG01    Embryonic Stem Cell     Embryo  37.0    0.1048  0.629   1173.0  0.17529650710900002     0.3536
>273     Homo sapiens    GSM575280       H3K4me3 BG01    Embryonic Stem Cell     Embryo  37.0    0.3263  0.925   8562.0  0.42073125      0.975
>274     Homo sapiens    GSM575296       H3K27me3        BG03    Embryonic Stem Cell     Embryo  30.0    0.32799999999999996     0.594   15.0    0.0088483688839 0.9
>275     Homo sapiens    GSM575281       H3K4me3 BG03    Embryonic Stem Cell     Embryo  30.0    0.6394  0.802   10668.0 0.72779575      0.9768
>367     Homo sapiens    GSM575223       H3K4me2 Caco-2  Epithelium      Colon   29.0    0.9159          15203.0 0.39174425      0.9374
>368     Homo sapiens    GSM575222       H3K4me2 Caco-2  Epithelium      Colon   30.0    0.9148  0.953   16241.0 0.49084399999999995     0.9634
>382     Homo sapiens    GSM610328       H3K4me1 CMK     Megakaryocyte   Blood   30.0    0.7686  0.988   117.0   0.14427 0.8012

#接下来再解压缩.gz的那个文件。

```
tar -xzf human_hm.tar.gz
rm *.tar
rm *.tar.gz

#解压成了一个新的文件夹
```
![图片](https://user-images.githubusercontent.com/55335232/187350636-c1f4fc82-e33f-4a8c-ab75-1f4ebea36172.png)


#### （2）过滤低质量文件

>参考链接：https://genome.ucsc.edu/ENCODE/qualityMetrics.html
>
>参考链接：http://cistrome.org/db/#/
>
>参考文献：
>
>Sprang, Maximilian & Krüger, Matteo & Andrade, Miguel & Fontaine, Jean-Fred. (2021). 
>Statistical guidelines for quality control of next-generation sequencing techniques.
>Life Science Alliance. 4. e202101113. 10.26508/lsa.202101113. 

过滤指标：
* reads的数量
* 重复率

那个文件中有多种指标，我们来一点点的看看。这些指标就是常用的参数。

* FastQC（Raw sequence median quality score） 

按照我的经验的话，这个值应该指的是这个样本的reads整体的测序质量。
感觉这个测序质量差不多在30附近，这说明什么呢？

* UniquelyMappedRatio（% Reads uniquely mapped ）  

样本中大概有多少的reads是被单一的比对的，这个数值是一个比例的问题。

* PBC（PCR bottleneck coefficient）

这个也是衡量文库质量的一个指标。感觉也是类似的计算一个比例。
PBC = N1/Nd 
N1= number of genomic locations to which EXACTLY one unique mapping read maps, #唯一匹配的reads的基因组的区域
Nd = the number of genomic locations to which AT LEAST one unique mapping read maps. #至少匹配一条reads的基因组的区域
Provisionally, 0-0.5 is severe bottlenecking, 0.5-0.8 is moderate bottlenecking, 0.8-0.9 is mild bottlenecking, while 0.9-1.0 is no bottlenecking. 

* PeaksFoldChangeAbove10 （Number of merged Fold 10 peaks）  

我觉得这里应该是这套数据中，与背景相比比较明显的peak的数量。

* FRiP（Fraction of reads in peaks）

分子是位于peak区域的reads总数，分母是比对到参考基因组上的reads总数。
也就是说，也存在少量的reads是没有匹配到所谓的peak上的。所以，在这里我们需要区分一些概念，即reads和peak。

* PeaksUnionDHSRatio（% Top 5k peaks overlapping with union DHS）

proportion of the 500 most signiﬁcant peaks overlapping with a union of DNase-seq peaks derived from ENCODE ﬁles

> 注：
> 理想情况下，是可以根据特定的阈值，对这些样本进行过滤的。但是现在不知道应该选择什么样的阈值更加的合适？


#### （3）文件重命名

这个分为两步，由于原先的文件名（如上图）都是以ID为标识，且命名的特别的不规范。

* 首先以ID，重新规范命名文件。==>这里的话，基本上就是rename.sh这个文件。

```shell
for var in `ls ./human_hm/*.bed` #这里的话，ls标识是可以被修改的
do
        mv  $var  ${var%%_*.bed}.bed
done
```
* 其次根据已有的对应的关系，将ID转换为样本标识的文件名。==>这里，基本上是rename.py这个文件。

如果比较复杂的代码，就把代码放置在一个独立的文件中。

```shell
python rename.py --help

Usage: rename.py [options]
Options:
  -h, --help            show this help message and exit
  -m METADATA_FILE_NAME, --metadata_file_name=METADATA_FILE_NAME
                        path to TF_human_data_information.txt file
  -i CURR_DIR           Input data directory
  -o NAMED_DIR          Output data directory
  -n NAME_MAP_FILE_NAME
                        ID to name mapping file
```
就包括一个输入文件的路径，一个输出文件的路径，一个metadata的文件（转换的参照），以及文件名转换前后的跟踪输出【通过对这些大佬们的代码的梳理，在一些规范上帮助我很多】。


#### （4）构建索引

```
time giggle index -i "./named_sort/H3K27ac*" -o ./named_sort_H3K27ac_b -s -f
```

#### （5）与索引进行比对

这里涉及到一个细节的问题，我们之前是对重复序列的家族进行了比对。
拆分的时候就不太对。
```
grep 'SVA_D' /home/xxzhang/workplace/project/geneRegion/repeat_interest.bed |sed 's/\s\+/\t/g' |bgzip -c >Hs_SVA_D.bed.gz
```
之前使用的是这个代码，来从repeat_interest.bed文件中提取相关的序列。
但是这种方式有一个bug就是，Alu和AluY会都被放到Alu的文件中去。

使用grep不够精确,使用awk似乎更能精确的满足需求。
```
awk '$4=="LTR5_Hs"' /home/xxzhang/workplace/project/geneRegion/repeat_interest.bed

```
接下来，这里的话，其实有一个批量的操作：批量的提取压缩特定的家族的文件，然后对其构建索引比对，并对比对的结果绘制热图。
这里我使用的是perl完成这个内容。

```perl
#!perl
open (MARK, "< Hs_repeat_subfamily.txt") or die "can not open it!";
while ($line = <MARK>){
		print($line);
		chomp($line);
		print($line);
		system_call("grep \"".$line."\" /home/xxzhang/workplace/project/geneRegion/repeat_interest.bed |sed 's\/\\s\\+\/\\t\/g' |bgzip -c >Hs_".$line.".bed.gz");
		system_call("time giggle search -i split_sort_b -q Hs_".$line.".bed.gz -s >Hs_".$line.".bed.gz.giggle.result");
		system_call("python /home/xxzhang/workplace/software/giggle/scripts/giggle_heat_map.py -s /home/xxzhang/workplace/software/giggle/examples/rme/states.txt -c /home/xxzhang/workplace/software/giggle/examples/rme/EDACC_NAME.txt -i Hs_".$line.".bed.gz.giggle.result -o ./result/Hs_".$line.".bed.gz.3x11.pdf -n /home/xxzhang/workplace/software/giggle/examples/rme/new_groups.txt --x_size 3 --y_size 11 --stat combo --ablines 15,26,31,43,52,60,72,82,87,89,93,101,103,116,120,122,127 --state_names /home/xxzhang/workplace/software/giggle/examples/rme/short_states.txt --group_names /home/xxzhang/workplace/software/giggle/examples/rme/new_groups_names.txt");
} 
close(MARK);

sub system_call
{
  my $command=$_[0];
  print "\n\n".$command."\n\n";
  system($command);
}

```
该文件夹下必须同时包括一个存放Hs_repeat_subfamily.txt的文件。

#### （6）对富集的结果绘制热图。

这里的主要思路就是，提取每一个文件中的combo_score，然后每个文件都有一个score,对score进行提取绘图。
也是批量的操作，运用到了一些小技巧。

```R
filelist <- list.files("./")
n <-length(filelist)
files <- paste("./",filelist,sep="")
test<- read.delim(file=files[1],header=T,sep="")
dim(test)
test1<-test[,c(1,8)]
dataset_filiter<-as.character(test1$combo_score)
for (i in 2:n)
{
  txt_data<-read.delim(file=files[i],header=T,sep="")
  txt_data<-txt_data[,c(1,8)]
  dataset_filiter <- cbind(dataset_filiter,txt_data[,2])
}
filelist_v1 <- as.matrix(gsub("H3K27me3_","", filelist))
filelist_v2 <- as.matrix(gsub(".bed.gz.result","", filelist_v1))
colnames(dataset_filiter)<-filelist_v2
filelist_v3 <- as.matrix(gsub("sort/Hs_","",test1$X.file ))
filelist_v4 <- as.matrix(gsub(".bed.gz","",filelist_v3))
rownames(dataset_filiter)<-filelist_v4
write.table(dataset_filiter,"../H3K27me3.txt",quote=F,row.names=T)

```

到这里基本上算是结束了。













