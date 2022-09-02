#install.packages("getopt")
library(getopt)
spec <- matrix(
  c("data_dir","f", 2, "character", "/H3K4me3/",
    "label","l", 1, "character",  "H3K4me3",
    "outfile","o", 2, "character",  "H3K4me3.txt",
    "help","h", 0, "logical",  "This is Help!"),
  byrow=TRUE, ncol=5)

# 使用getopt方法
opt <- getopt(spec=spec)

# opt实际上就是一个列表，直接使用$来索引到对应的参数的值
data_dir<-opt$data_dir
input_dir<-paste("/home/xxzhang/data/Epigenome/cistrome/human_histone_mark/Hs_repeat",data_dir,sep="")
label<-opt$label
output_file<-opt$outfile
output_dir<-paste("../",output_file,sep="")
print(input_dir)
print(label)
print(output_dir)
setwd(input_dir)
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
filelist_v1 <- as.matrix(gsub(label,"", filelist))
filelist_v2 <- as.matrix(gsub(".bed.gz.result","", filelist_v1))
colnames(dataset_filiter)<-filelist_v2
filelist_v3 <- as.matrix(gsub("sort/Hs_","",test1$X.file ))
filelist_v4 <- as.matrix(gsub(".bed.gz","",filelist_v3))
rownames(dataset_filiter)<-filelist_v4
write.table(dataset_filiter,output_dir,quote=F,row.names=T)