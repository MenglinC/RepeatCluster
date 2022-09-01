> Epigenomics Annotation 
> 
> nearly last for two mouthes
> 
> 2022-07-01 —— 2022-08-29


###  Preinstallation
>giggle enrichment analysis
>
> Reference:
> https://github.com/ryanlayer/giggle
> https://www.nature.com/articles/nmeth.4556

```shell
#安装giggle
git clone https://github.com/ryanlayer/giggle.gitcd giggle/
make

#安装dependency
wget  https://github.com/brentp/gargs/releases/download/v0.3.9/gargs_linux
chmod +x gargs_linux #给该文件可执行权限
mv gargs_linux gargs
vim ~/.bashrc 
source ~/.bashrc
```
### test example

```shell
#进行富集分析的时候的步骤主要分为三部分
#Part0:下载示例的数据集

mkdir repeat
url="http://hgdownload.soe.ucsc.edu/goldenPath/hg19/database/rmsk.txt.gz"
curl -s $url | gunzip -c | cut -f 6,7,8,11,12,13 > repeat/rmsk.bed

url="http://hgdownload.soe.ucsc.edu/goldenPath/hg19/database/simpleRepeat.txt.gz"
curl -s $url | gunzip -c | cut -f 2,3,4,17 > repeat/simpleRepeat.bed

url="http://hgdownload.soe.ucsc.edu/goldenPath/hg19/database/microsat.txt.gz"
curl -s $url | gunzip -c | cut -f 2,3,4 > repeat/microsat.bed

url="http://hgdownload.soe.ucsc.edu/goldenPath/hg19/database/genomicSuperDups.txt.gz"
curl -s $url | gunzip -c | cut -f 2,3,4,5 > repeat/genomicSuperDups.bed

url="http://hgdownload.soe.ucsc.edu/goldenPath/hg19/database/chainSelf.txt.gz"
curl -s $url | gunzip -c  | cut -f 3,5,6,7,10,11 > repeat/chainSelf.bed

#Part1:sort_bed，这一步做了两件事，其一是讲原始的bed文件进行压缩成gz的格式，其二就是对数据进行排序。

mkdir repeat_sort
giggle/scripts/sort_bed "repeat/*.bed" repeat_sort 4

#Part2:建立索引

giggle index -i "repeat_sort/*gz" -o repeat_sort_b -f -s

#Part3:对输入文件与索引比对
#下面显示的是特定的区间范围，即一号染色体的200457776至200457776这个范围内的比对结果。
#结果显示，该部分的序列比对到了一号染色体的L2a的重复序列家族的片段上。

giggle search -i repeat_sort_b -r 1:200457776-200457776 -f rmsk,simple -v

```
> chr1    200457488   200457811   L2a LINE    L2  repeat_sort/rmsk.bed.gz


在上述这一步骤中，归纳主要的报错，及对错误的解决的方式。

(1) 输入文件要压缩

> Not a BGZF file 'human_specifc_repeat.bed.gz'

错误原因：输入文件非bgzf格式的压缩文件。
解决方式：

```shell
bgzip human_specifc_repeat.bed
```

(2) 输出结果文件为空

错误原因：输入文件非严格的“\t”分隔的文件，因此虽然运行的过程没有报错，但结果为空。
检查方法：
```
vim test.bed
set list #查看，如果是^I，则说明是tab分隔。
```
解决方法：
```
sed 's/\s\+/\t/g' test.bed >test2.bed  #运用sed替换空格
```

（3）构建索引时，报错显示无法打开文件。

报错内容：
```
Could not open file './named_sort/H3K4me1_None_T_Lymphocyte_Blood.2.bed.gz'
giggle: Could not open ./named_sort/H3K4me1_None_T_Lymphocyte_Blood.2.bed.gz.
```
错误原因：这里曾经困惑了我很久，后来发现是用于构建索引的输入的文件严重的超过了服务器的内存的limit，于是显示报错。
解决方法：
```
#更好的解决方法应该是用unlimit修改限制,但是由于我们的服务器管理员不好说话，所以迂回的解决思路是拆分输入文件，分批构建索引，然后再合并结果文件
#这个吐槽一下，这个解决方法真的超级麻烦
giggle index -i "./named_H3K4me3_s1/*" -o ./named_H3K4me3_s1_index -s -f
# Indexed 15307478 intervals.
giggle index -i "./named_H3K4me3_s2/*" -o ./named_H3K4me3_s2_index -s -f
# Indexed 14881229 intervals.
giggle index -i "./named_H3K4me3_s3/*" -o ./named_H3K4me3_s3_index -s -f
# Indexed 14168564 intervals.
giggle index -i "./named_H3K4me3_s4/*" -o ./named_H3K4me3_s4_index -s -f
# Indexed 27907381 intervals.
cp ../Hs_repeat.bed.gz ./
giggle search -i ./named_H3K4me3_s1_index/ -q Hs_repeat.bed.gz -s >Hs_repeat.bed.gz.giggle.H3K4me3_s1.result
giggle search -i ./named_H3K4me3_s2_index/ -q Hs_repeat.bed.gz -s >Hs_repeat.bed.gz.giggle.H3K4me3_s2.result
giggle search -i ./named_H3K4me3_s3_index/ -q Hs_repeat.bed.gz -s >Hs_repeat.bed.gz.giggle.H3K4me3_s3.result
giggle search -i ./named_H3K4me3_s4_index/ -q Hs_repeat.bed.gz -s >Hs_repeat.bed.gz.giggle.H3K4me3_s4.result
cat Hs_repeat.bed.gz.giggle.H3K4me3_s* >Hs_repeat.bed.gz.giggle.H3K4me3_all.result
awk '$8>0' Hs_repeat.bed.gz.giggle.H3K4me3_all.result >repeat_positive.H3K4me3.result

```

### Experiment

#### 这里的实验的主要内容是：建立索引。
>
> 索引的话，目前在前期的实验中尝试了很多种。

(1)Roadmap建立索引。

(2)六种histrone mark建立索引。

(3)染色质开放状态的数据（acc）建立索引。

(4)使用转录因子的数据建立索引。

(5)使用人特异性的重复序列家族建立索引。

#### 其次就是构建比对的reference序列。
>
> reference的序列现在主要尝试的有。

(1)全部的重复序列。

(2)将重复序列亚家族从原先的全部的序列中拆分出来的结果。

** 这部分到现在有问题，需要重新做。
** 主要的问题是原先提取的特别的不准确。

#### 注

这个过程中就涉及到了一些非常基础但是不能忽略的问题。
进行二次处理的目的是为了使我们的结果可视化更好。

(1)文件重命名。

将原始的根据ID命名的文件，转化为转录因子/Histone mark/Dnase+细胞系+组织的文件名。

(2)将待构建索引的文件进行排序。

(3)根据比对结果用R画图——heatmap不太友好。

#现在再把这个过程再理一理，然后师弟加入了这个筛选的过程。我理一下，如何把这部分的内容拆出来，让师弟也参与其中。
#现在就这样吧。
















