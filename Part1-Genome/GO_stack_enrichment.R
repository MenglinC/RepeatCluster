library(plyr) #zhongyao
library(AnnotationHub)	
library(org.Hs.eg.db) 
library(clusterProfiler)
library(dplyr)
library(ggplot2)
library(gridExtra)
#BiocManager::install("plyr",force = TRUE)

#setwd("E://2022暑假（2022-06-2022-08）//gene//")
setwd("E://2022暑假（2022-06-2022-08）//Roadmap//")

#data<-read.table("Alu_gene-sybmbol.txt")
#data<-read.table("SVA_gene-sybmbol.txt")
#data<-read.table("L1_gene-sybmbol.txt")
#data<-read.table("LTR_gene-sybmbol.txt")
data<-read.table("brain_active_gene-symbol.txt")
data<-read.table("tissue_common_gene.txt")
interest_gene<-data$V1
f1=interest_gene
EG2Ensembl=toTable(org.Hs.egSYMBOL)	 #将ENTREZID和ENSEMBL对应的数据存入该变量
#EG2Ensembl=toTable(org.Hs.eg.)
#f=f1$V2
f=f1
geneLists=data.frame(symbol=f)
results=merge(geneLists,EG2Ensembl,by='symbol',all.x=T)
#results=merge(geneLists,EG2Ensembl,by='trans_id',all.x=T)
id=na.omit(results$gene_id)  #提取出非NA的ENTREZID #对于transid有很多匹配不上


# ego3<-enrichGO(OrgDb="org.Hs.eg.db", gene = id, ont = "BP") 
# p1<-dotplot(ego3,showCategory=10,title="Enrichment GO Top10(BP)")
# p2<-barplot(ego3, showCategory=20,title="EnrichmentGO(BP)")
# p1
# p2
# ego3<-enrichGO(OrgDb="org.Hs.eg.db", gene = id, ont = "CC") 
# p1<-dotplot(ego3,showCategory=10,title="Enrichment GO Top10(BP)")
# p2<-barplot(ego3, showCategory=20,title="EnrichmentGO(BP)")
# ego3<-enrichGO(OrgDb="org.Hs.eg.db", gene = id, ont = "MF") 
# p1<-dotplot(ego3,showCategory=10,title="Enrichment GO Top10(BP)")
# p2<-barplot(ego3, showCategory=20,title="EnrichmentGO(BP)")



ego_CC <- enrichGO(gene = id,
                   OrgDb=org.Hs.eg.db,
                   keyType = "ENTREZID",
                   ont = "CC",
                   pAdjustMethod = "BH",
                   minGSSize = 1,
                   pvalueCutoff = 0.01,
                   qvalueCutoff = 0.05,
                   readable = TRUE)

ego_BP <- enrichGO(gene = id,
                   OrgDb=org.Hs.eg.db,
                   keyType = "ENTREZID",
                   ont = "BP",
                   pAdjustMethod = "BH",
                   minGSSize = 1,
                   pvalueCutoff = 0.01,
                   qvalueCutoff = 0.05,
                   readable = TRUE)


ego_MF <- enrichGO(gene = id,
                   OrgDb=org.Hs.eg.db,
                   keyType = "ENTREZID",
                   ont = "MF",
                   pAdjustMethod = "BH",
                   minGSSize = 1,
                   pvalueCutoff = 0.01,
                   qvalueCutoff = 0.05,
                   readable = TRUE)

# #LTR 放宽阈值
# ego_CC <- enrichGO(gene = id,
#                    OrgDb=org.Hs.eg.db,
#                    keyType = "ENTREZID",
#                    ont = "CC",
#                    pAdjustMethod = "BH",
#                    minGSSize = 1,
#                    pvalueCutoff = 0.1,
#                    qvalueCutoff = 0.1,
#                    readable = TRUE)
# 
# ego_BP <- enrichGO(gene = id,
#                    OrgDb=org.Hs.eg.db,
#                    keyType = "ENTREZID",
#                    ont = "BP",
#                    pAdjustMethod = "BH",
#                    minGSSize = 1,
#                    pvalueCutoff = 0.1,
#                    qvalueCutoff = 0.1,
#                    readable = TRUE)
# 
# ego_MF <- enrichGO(gene = id,
#                    OrgDb=org.Hs.eg.db,
#                    keyType = "ENTREZID",
#                    ont = "MF",
#                    pAdjustMethod = "BH",
#                    minGSSize = 1,
#                    pvalueCutoff = 0.1,
#                    qvalueCutoff = 0.1,
#                    readable = TRUE)



display_number = c(10, 10, 10)#这三个数字分别代表选取的BP、CC、MF的通路条数，这个自己设置就行了
ego_result_BP <- as.data.frame(ego_BP)[1:display_number[1], ]
ego_result_CC <- as.data.frame(ego_CC)[1:display_number[2], ]
ego_result_MF <- as.data.frame(ego_MF)[1:display_number[3], ]

##将以上我们摘取的部分通路重新组合成数据框
go_enrich_df <- data.frame(
  ID=c(ego_result_BP$ID, ego_result_CC$ID, ego_result_MF$ID),                         Description=c(ego_result_BP$Description,ego_result_CC$Description,ego_result_MF$Description),
  GeneNumber=c(ego_result_BP$Count, ego_result_CC$Count, ego_result_MF$Count),
  type=factor(c(rep("biological process", display_number[1]), 
                rep("cellular component", display_number[2]),
                rep("molecular function", display_number[3])), 
              levels=c("biological process", "cellular component","molecular function" )))

##通路的名字太长了，我选取了通路的前五个单词作为通路的名字
# for(i in 1:nrow(go_enrich_df)){
#   description_splite=strsplit(go_enrich_df$Description[i],split = " ")
#   description_collapse=paste(description_splite[[1]][1:8],collapse = " ") #这里的5就是指5个单词的意思，可以自己更改
#   go_enrich_df$Description[i]=description_collapse
#   go_enrich_df$Description=gsub(pattern = "NA","",go_enrich_df$Description)
# }

##开始绘制GO柱状图
###横着的柱状图
# go_enrich_df$type_order=factor(rev(as.integer(rownames(go_enrich_df))),labels=rev(go_enrich_df$Description))#这一步是必须的，为了让柱子按顺序显示，不至于很乱
# COLS <- c("#66C3A5", "#8DA1CB", "#FD8D62")#设定颜色
# 
# ggplot(data=go_enrich_df, aes(x=type_order,y=GeneNumber, fill=type)) + #横纵轴取值
#   geom_bar(stat="identity", width=0.8) + #柱状图的宽度，可以自己设置
#   scale_fill_manual(values = COLS) + ###颜色
#   coord_flip() + ##这一步是让柱状图横过来，不加的话柱状图是竖着的
#   xlab("GO term") + 
#   ylab("Gene_Number") + 
#   labs(title = "The Most Enriched GO Terms")+
#   theme_bw()

###竖着的柱状图 
go_enrich_df$type_order=factor(rev(as.integer(rownames(go_enrich_df))),labels=rev(go_enrich_df$Description))
library(RColorBrewer)
COLS<-brewer.pal(name="Dark2",3)
#COLS <- c("#FF82AB", "#B3EE3A", "#D8BFD8")
go_enrich_df_2<-na.omit(go_enrich_df)

ggplot(data=go_enrich_df_2, aes(x=type_order,y=GeneNumber, fill=type)) + 
  geom_bar(stat="identity", width=0.8) + 
  scale_fill_manual(values = COLS) + 
  theme_bw() + 
  ylab("")+
  xlab("")+
  theme(axis.text.x=element_text(face = "bold", color="gray50",angle = 70,vjust = 1, hjust = 1 ))+
  coord_flip()+
  labs(title="Tissue Common Geneset Functional Enrichment")+
  theme(plot.title=element_text(hjust=0.5))


p1<-ggplot(data=go_enrich_df_2, aes(x=type_order,y=GeneNumber, fill=type)) + 
    geom_bar(stat="identity", width=0.8) + 
    scale_fill_manual(values = COLS) + 
    theme_bw() + 
    ylab("")+
    xlab("")+
    theme(axis.text.x=element_text(face = "bold", color="gray50",angle = 70,vjust = 1, hjust = 1 ))+
    coord_flip()+
    theme(legend.position = 'none')

p2<-ggplot(data=go_enrich_df_2, aes(x=type_order,y=GeneNumber, fill=type)) + 
  geom_bar(stat="identity", width=0.8) + 
  scale_fill_manual(values = COLS) + 
  theme_bw() + 
  ylab("")+
  xlab("")+
  theme(axis.text.x=element_text(face = "bold", color="gray50",angle = 70,vjust = 1, hjust = 1 ))+
  coord_flip()+
  theme(legend.position = 'none')

library(RColorBrewer)
colors<-brewer.pal(name="Dark2",3)
colors

p3<-ggplot(data=go_enrich_df_2, aes(x=type_order,y=GeneNumber, fill=type)) + 
  geom_bar(stat="identity", width=0.8) + 
  scale_fill_manual(values = colors) + 
  theme_bw() + 
  xlab("Go terms")+
  ylab("gene number")+
  theme(axis.text.x=element_text(face = "bold", color="gray50",angle = 70,vjust = 1, hjust = 1 ))+
  coord_flip()


p4<-ggplot(data=go_enrich_df_2, aes(x=type_order,y=GeneNumber, fill=type)) + 
  geom_bar(stat="identity", width=0.8) + 
  scale_fill_manual(values = COLS) + 
  theme_bw() + 
  ylab("")+
  xlab("")+
  theme(axis.text.x=element_text(face = "bold", color="gray50",angle = 70,vjust = 1, hjust = 1 ))+
  coord_flip()+
  theme(legend.position = 'none')


p5 <- cowplot::plot_grid(p1, p2,p4,p3,ncol = 2,nrow=2,labels = c("Alu","SVA","LTR","L1"))#将p1-p4四幅图组合成一幅图，按照两行两列排列，标签分别为A、B、C、D。（LETTERS[1:4] 意为提取26个大写英文字母的前四个:A、B、C、D）
p5

