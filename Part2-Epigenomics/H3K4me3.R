setwd("/home/xxzhang/data/Epigenome/cistrome/human_histone_mark/Hs_repeat/H3K4me3_result/")
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
filelist_v1 <- as.matrix(gsub("H3K4me3_","", filelist))
filelist_v2 <- as.matrix(gsub(".bed.gz.result","", filelist_v1))
colnames(dataset_filiter)<-filelist_v2
filelist_v3 <- as.matrix(gsub("sort/Hs_","",test1$X.file ))
filelist_v4 <- as.matrix(gsub(".bed.gz","",filelist_v3))
rownames(dataset_filiter)<-filelist_v4
write.table(dataset_filiter,"../H3K4me3.txt",quote=F,row.names=T)