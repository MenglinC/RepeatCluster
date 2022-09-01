```shell
cp ./subfamily/Hs_L1PA2.bed.gz ../cistrome/human_histone_mark/
cd ../cistrome/human_histone_mark/
mkdir L1PA2_sort
./sort_bed Hs_L1PA2.bed.gz  L1PA2_sort 4
time giggle index -i "./L1PA2_sort/*.gz"  -o L1PA2_sort_b -f -s
cp -R L1PA2_sort_b/ ./Hs_repeat

### 好像一不小心把Hs_repeat文件夹给删除了。##一定要小心。
time ./sort_bed "./named/*.bed"  named_sort  32
cp ../named_sort/H3K4me3_* ./H3K4me3/  #不要用这种模糊匹配,错配的程度很大
ls ./H3K4me3 |xargs -i -t sh -c "giggle search -i  L1PA2_sort_b/ -q ./H3K4me3/{} -s >./H3K4me3_result/{}.result"

```

>(base) [xxzhang@mu02 Hs_repeat]$ Rscript H3K4me3.R
>
>[1] 1 8
>
>Error in read.table(file = file, header = header, sep = sep, quote = quote,  :
>  no lines available in input
>Calls: read.delim -> read.table
>Execution halted

解决方法：
```shell
find ./H3K4me3_result/ -name "*" -type f -size 0c | xargs -n 1 rm -f
Rscript H3K4me3.R
```

